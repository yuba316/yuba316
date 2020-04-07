libname original "E:\sas\sas大赛\数据预处理";
libname Q2 "E:\sas\sas大赛\第二题";

/* ========= 分阶段进行描述性统计 =========*/

%let sg = sg1;
%let stage = 1; /* 可以通过更改宏变量实现不同阶段的检验结果输出，这里只展示第一阶段的输出结果*/
/* 不使用宏语句是因为十个阶段的结果一起输出实在是太冗杂了，且我们小组是分工完成该项任务的，逐个输出便于分析*/
/* 而且十个阶段内依据聚类分析得到的分类结果也不尽相同，由此使用宏语句操作起来较为困难，设计数组的长度也无法固定，故采用分工的方式节省时间*/

data Q2.&sg._t;
    set original.data_0(drop = obs);
	if period = &stage;
	drop period;
run;

proc means data = Q2.&sg._t maxdec=4 mean median max min std skewness kurtosis;
    title "第&sg.阶段行业收益率描述性统计";
	var _801010_SWI_r _801020_SWI_r _801030_SWI_r _801040_SWI_r _801050_SWI_r
_801080_SWI_r _801110_SWI_r _801120_SWI_r _801130_SWI_r _801140_SWI_r _801150_SWI_r
_801160_SWI_r _801170_SWI_r _801180_SWI_r _801200_SWI_r _801210_SWI_r _801230_SWI_r
_801710_SWI_r _801720_SWI_r _801730_SWI_r _801740_SWI_r _801750_SWI_r _801760_SWI_r
_801770_SWI_r _801780_SWI_r _801790_SWI_r _801880_SWI_r _801890_SWI_r;
run;

proc gplot data = Q2.&sg._t; /* 作图观察28个行业在走势上的滞后关系*/
    title "第&stage.阶段各行业申万指数走势图";
	plot _801010_SWI*A _801020_SWI*A _801030_SWI*A _801040_SWI*A _801050_SWI*A
_801080_SWI*A _801110_SWI*A _801120_SWI*A _801130_SWI*A _801140_SWI*A _801150_SWI*A
_801160_SWI*A _801170_SWI*A _801180_SWI*A _801200_SWI*A _801210_SWI*A _801230_SWI*A
_801710_SWI*A _801720_SWI*A _801730_SWI*A _801740_SWI*A _801750_SWI*A _801760_SWI*A
_801770_SWI*A _801780_SWI*A _801790_SWI*A _801880_SWI*A _801890_SWI*A / overlay legend vaxis = axis1 haxis = axis2;
	axis1 label = (a=-90 r=90 "行业指数");
	axis2 label = ("日期");
	symbol1 i = join;
	symbol2 i = join;
	symbol3 i = join;
	symbol4 i = join;
	symbol5 i = join;
	symbol6 i = join;
	symbol7 i = join;
	symbol8 i = join;
	symbol9 i = join;
	symbol10 i = join;
	symbol11 i = join;
	symbol12 i = join;
	symbol13 i = join;
	symbol14 i = join;
	symbol15 i = join;
	symbol16 i = join;
	symbol17 i = join;
	symbol18 i = join;
	symbol19 i = join;
	symbol20 i = join;
	symbol21 i = join;
	symbol22 i = join;
	symbol23 i = join;
	symbol24 i = join;
	symbol25 i = join;
	symbol26 i = join;
	symbol27 i = join;
	symbol28 i = join;
run;

proc corr data = Q2.&sg._t pearson outp = Q2.&sg._pearson; /* 作图观察28个行业的相关程度*/
    var _801010_SWI _801020_SWI _801030_SWI _801040_SWI _801050_SWI
_801080_SWI _801110_SWI _801120_SWI _801130_SWI _801140_SWI _801150_SWI
_801160_SWI _801170_SWI _801180_SWI _801200_SWI _801210_SWI _801230_SWI
_801710_SWI _801720_SWI _801730_SWI _801740_SWI _801750_SWI _801760_SWI
_801770_SWI _801780_SWI _801790_SWI _801880_SWI _801890_SWI;
run;

data Q2.&sg._pearson;
    set Q2.&sg._pearson;
	if _NAME_ = '' then delete;
	drop _TYPE_ _NAME_;
run;

/* ========= 聚类分析 =========*/

proc transpose data = Q2.&sg._t out = Q2.&sg._t;
    var A _801010_SWI _801020_SWI _801030_SWI _801040_SWI _801050_SWI
_801080_SWI _801110_SWI _801120_SWI _801130_SWI _801140_SWI _801150_SWI
_801160_SWI _801170_SWI _801180_SWI _801200_SWI _801210_SWI _801230_SWI
_801710_SWI _801720_SWI _801730_SWI _801740_SWI _801750_SWI _801760_SWI
_801770_SWI _801780_SWI _801790_SWI _801880_SWI _801890_SWI;
run;

data Q2.&sg._t;
    set Q2.&sg._t;
    if _name_ = 'A' then delete;
	drop _name_;
	rename _label_ = stock;
run;

proc cluster data = Q2.&sg._t outtree = Q2.&sg._tree method = ave ccc pseudo;
    id stock;
run;

/* ========= 对每个类内的行业进行格兰杰因果检验 =========*/

data Q2.&sg;
    set original.data_0;
	if period = &stage;
run;

proc varmax data = Q2.&sg;
    id obs interval = day;
	model _801790_SWI_r _801760_SWI_r _801740_SWI_r _801890_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801790_SWI_r) group2=(_801760_SWI_r _801740_SWI_r _801890_SWI_r); /* 对变量两两之间进行格兰杰因果检验*/
	causal group1=(_801760_SWI_r) group2=(_801790_SWI_r _801740_SWI_r _801890_SWI_r); 
	causal group1=(_801740_SWI_r) group2=(_801790_SWI_r _801760_SWI_r _801890_SWI_r); 
	causal group1=(_801890_SWI_r) group2=(_801790_SWI_r _801760_SWI_r _801740_SWI_r); 
run;

/* ========= 对每个产业链内的行业进行格兰杰因果检验 =========*/

data Q2.&sg._Ind;
    set original.data_0;
	if period = &stage;
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801890_SWI_r _801740_SWI_r _801140_SWI_r _801130_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801890_SWI_r) group2=(_801740_SWI_r _801140_SWI_r _801130_SWI_r); /* 机械设备→国防军工→轻工制造→纺织服务*/
	causal group1=(_801740_SWI_r) group2=(_801890_SWI_r _801140_SWI_r _801130_SWI_r); 
	causal group1=(_801140_SWI_r) group2=(_801890_SWI_r _801740_SWI_r _801130_SWI_r); 
	causal group1=(_801130_SWI_r) group2=(_801890_SWI_r _801740_SWI_r _801140_SWI_r);
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801020_SWI_r _801050_SWI_r _801030_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801020_SWI_r) group2=(_801050_SWI_r _801030_SWI_r); /* 采掘→有色金属→化工*/
	causal group1=(_801050_SWI_r) group2=(_801020_SWI_r _801030_SWI_r); 
	causal group1=(_801030_SWI_r) group2=(_801020_SWI_r _801050_SWI_r); 
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801040_SWI_r _801710_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801040_SWI_r) group2=(_801710_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r); /* 钢铁→建筑材料→房地产→建筑装饰→家用电器*/
	causal group1=(_801710_SWI_r) group2=(_801040_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r); 
	causal group1=(_801180_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801720_SWI_r _801110_SWI_r); 
	causal group1=(_801720_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801180_SWI_r _801110_SWI_r);
	causal group1=(_801110_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801180_SWI_r _801720_SWI_r);
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r/ minic=(p=10 q=0 type=AIC);
	/* 公共事业→交通运输→汽车→电子→电气设备→通信→计算机→医药生物→农林牧渔*/
	causal group1=(_801160_SWI_r) group2=(_801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r); 
	causal group1=(_801170_SWI_r) group2=(_801160_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r); 
	causal group1=(_801880_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r); 
	causal group1=(_801080_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r);
	causal group1=(_801730_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r);
	causal group1=(_801770_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r);
	causal group1=(_801750_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801150_SWI_r _801010_SWI_r);
	causal group1=(_801150_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801010_SWI_r);
	causal group1=(_801010_SWI_r) group2=(_801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r);
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801210_SWI_r _801200_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801210_SWI_r) group2=(_801200_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); /* 休闲服务→商业贸易→食品饮料→传媒→银行→非银金融*/
	causal group1=(_801200_SWI_r) group2=(_801210_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); 
	causal group1=(_801120_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); 
	causal group1=(_801760_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801780_SWI_r _801790_SWI_r);
	causal group1=(_801780_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801760_SWI_r _801790_SWI_r);
	causal group1=(_801790_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r);
run;

/* ========= 对每阶段内存在行业轮动效应的类和产业链进行脉冲响应 =========*/

%let sg = sg1;
%let stage = 1;

data Q2.&sg._imp;
    set original.data_0;
	if period = &stage;
run;

proc varmax data = Q2.&sg._imp plot = impulse;
    id obs interval = day;
	model _801790_SWI_r _801760_SWI_r _801740_SWI_r _801890_SWI_r/ minic=(p=10 q=0 type=AIC) print=(impulsx=(simple));
run;
