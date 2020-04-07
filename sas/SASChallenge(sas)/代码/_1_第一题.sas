libname original "E:\sas\sas大赛\数据预处理";
libname Q1 "E:\sas\sas大赛\第一题";

/* ========= 平稳性与白噪声检验 =========*/

proc arima data = original.data_0; /* 对原序列进行平稳性检验，发现均不平稳*/
    identify var = _801040_SWI stationarity = (ADF);
    identify var = _801180_SWI stationarity = (ADF);
	identify var = _801710_SWI stationarity = (ADF);
run;
proc arima data = original.data_0; /* 对收益率进行平稳性检验，发现结果通过*/
    identify var = _801040_SWI_r stationarity = (ADF);
    identify var = _801180_SWI_r stationarity = (ADF);
	identify var = _801710_SWI_r stationarity = (ADF);
run;

/* ========= 建立向量自回归模型 =========*/

%let sg = sg1;
%let stage = 1; /* 可以通过更改宏变量实现不同阶段的检验结果输出，这里只展示第一阶段的输出结果*/
/* 不使用宏语句是因为十个阶段的结果一起输出实在是太冗杂了，且我们小组是分工完成该项任务的，逐个输出便于分析*/

data Q1.&sg;
    set original.data_0 (keep = A period obs _801040_SWI _801180_SWI _801710_SWI _801040_SWI_r _801180_SWI_r _801710_SWI_r);
	if period = &stage;
run;

proc gplot data = Q1.&sg; /* 作图观察三个行业在走势上的滞后关系*/
    title "房地产、建材和钢铁行业的申万指数第&stage.阶段走势图";
	plot _801040_SWI*A _801180_SWI*A _801710_SWI*A / overlay legend vaxis = axis1 haxis = axis2;
	axis1 label = (a=-90 r=90 "行业指数");
	axis2 label = ("日期");
	symbol1 i = join ci = red;
	symbol2 i = join ci = yellow;
	symbol3 i = join ci = blue;
run;

/* ========= 建立向量自回归模型 =========*/

%let sg = sg1;
%let stage = 1; /* 可以通过更改宏变量实现不同阶段的检验结果输出，这里只展示第一阶段的输出结果*/
/* 不使用宏语句是因为十个阶段的结果一起输出实在是太冗杂了，且我们小组是分工完成该项任务的，逐个输出便于分析*/

data Q1.&sg;
    set original.data_0 (keep = A period obs _801040_SWI _801180_SWI _801710_SWI _801040_SWI_r _801180_SWI_r _801710_SWI_r);
	if period = &stage;
run;

proc varmax data = Q1.&sg plot = impulse; /* 对三个行业进行向量自回归模型的构建*/
    id obs interval = day;
	model _801040_SWI_r _801180_SWI_r _801710_SWI_r / minic=(p=10 q=0 type=AIC) print=(impulsx=(all)); /* 最大滞后阶数为10阶，选取AIC作为评判标准，对变量进行两两之间的脉冲响应检测*/
	causal group1=(_801040_SWI_r) group2=(_801180_SWI_r _801710_SWI_r); /* 对变量两两之间进行格兰杰因果检验*/
	causal group1=(_801180_SWI_r) group2=(_801040_SWI_r _801710_SWI_r);
	causal group1=(_801710_SWI_r) group2=(_801040_SWI_r _801180_SWI_r);
run;
