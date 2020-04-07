libname original "E:\sas\sas����\����Ԥ����";
libname Q2 "E:\sas\sas����\�ڶ���";

/* ========= �ֽ׶ν���������ͳ�� =========*/

%let sg = sg1;
%let stage = 1; /* ����ͨ�����ĺ����ʵ�ֲ�ͬ�׶εļ��������������ֻչʾ��һ�׶ε�������*/
/* ��ʹ�ú��������Ϊʮ���׶εĽ��һ�����ʵ����̫�����ˣ�������С���Ƿֹ���ɸ�������ģ����������ڷ���*/
/* ����ʮ���׶������ݾ�������õ��ķ�����Ҳ������ͬ���ɴ�ʹ�ú�������������Ϊ���ѣ��������ĳ���Ҳ�޷��̶����ʲ��÷ֹ��ķ�ʽ��ʡʱ��*/

data Q2.&sg._t;
    set original.data_0(drop = obs);
	if period = &stage;
	drop period;
run;

proc means data = Q2.&sg._t maxdec=4 mean median max min std skewness kurtosis;
    title "��&sg.�׶���ҵ������������ͳ��";
	var _801010_SWI_r _801020_SWI_r _801030_SWI_r _801040_SWI_r _801050_SWI_r
_801080_SWI_r _801110_SWI_r _801120_SWI_r _801130_SWI_r _801140_SWI_r _801150_SWI_r
_801160_SWI_r _801170_SWI_r _801180_SWI_r _801200_SWI_r _801210_SWI_r _801230_SWI_r
_801710_SWI_r _801720_SWI_r _801730_SWI_r _801740_SWI_r _801750_SWI_r _801760_SWI_r
_801770_SWI_r _801780_SWI_r _801790_SWI_r _801880_SWI_r _801890_SWI_r;
run;

proc gplot data = Q2.&sg._t; /* ��ͼ�۲�28����ҵ�������ϵ��ͺ��ϵ*/
    title "��&stage.�׶θ���ҵ����ָ������ͼ";
	plot _801010_SWI*A _801020_SWI*A _801030_SWI*A _801040_SWI*A _801050_SWI*A
_801080_SWI*A _801110_SWI*A _801120_SWI*A _801130_SWI*A _801140_SWI*A _801150_SWI*A
_801160_SWI*A _801170_SWI*A _801180_SWI*A _801200_SWI*A _801210_SWI*A _801230_SWI*A
_801710_SWI*A _801720_SWI*A _801730_SWI*A _801740_SWI*A _801750_SWI*A _801760_SWI*A
_801770_SWI*A _801780_SWI*A _801790_SWI*A _801880_SWI*A _801890_SWI*A / overlay legend vaxis = axis1 haxis = axis2;
	axis1 label = (a=-90 r=90 "��ҵָ��");
	axis2 label = ("����");
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

proc corr data = Q2.&sg._t pearson outp = Q2.&sg._pearson; /* ��ͼ�۲�28����ҵ����س̶�*/
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

/* ========= ������� =========*/

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

/* ========= ��ÿ�����ڵ���ҵ���и������������ =========*/

data Q2.&sg;
    set original.data_0;
	if period = &stage;
run;

proc varmax data = Q2.&sg;
    id obs interval = day;
	model _801790_SWI_r _801760_SWI_r _801740_SWI_r _801890_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801790_SWI_r) group2=(_801760_SWI_r _801740_SWI_r _801890_SWI_r); /* �Ա�������֮����и������������*/
	causal group1=(_801760_SWI_r) group2=(_801790_SWI_r _801740_SWI_r _801890_SWI_r); 
	causal group1=(_801740_SWI_r) group2=(_801790_SWI_r _801760_SWI_r _801890_SWI_r); 
	causal group1=(_801890_SWI_r) group2=(_801790_SWI_r _801760_SWI_r _801740_SWI_r); 
run;

/* ========= ��ÿ����ҵ���ڵ���ҵ���и������������ =========*/

data Q2.&sg._Ind;
    set original.data_0;
	if period = &stage;
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801890_SWI_r _801740_SWI_r _801140_SWI_r _801130_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801890_SWI_r) group2=(_801740_SWI_r _801140_SWI_r _801130_SWI_r); /* ��е�豸�������������Ṥ�������֯����*/
	causal group1=(_801740_SWI_r) group2=(_801890_SWI_r _801140_SWI_r _801130_SWI_r); 
	causal group1=(_801140_SWI_r) group2=(_801890_SWI_r _801740_SWI_r _801130_SWI_r); 
	causal group1=(_801130_SWI_r) group2=(_801890_SWI_r _801740_SWI_r _801140_SWI_r);
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801020_SWI_r _801050_SWI_r _801030_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801020_SWI_r) group2=(_801050_SWI_r _801030_SWI_r); /* �ɾ����ɫ����������*/
	causal group1=(_801050_SWI_r) group2=(_801020_SWI_r _801030_SWI_r); 
	causal group1=(_801030_SWI_r) group2=(_801020_SWI_r _801050_SWI_r); 
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801040_SWI_r _801710_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r/ minic=(p=10 q=0 type=AIC);
	causal group1=(_801040_SWI_r) group2=(_801710_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r); /* �������������ϡ����ز�������װ�Ρ����õ���*/
	causal group1=(_801710_SWI_r) group2=(_801040_SWI_r _801180_SWI_r _801720_SWI_r _801110_SWI_r); 
	causal group1=(_801180_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801720_SWI_r _801110_SWI_r); 
	causal group1=(_801720_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801180_SWI_r _801110_SWI_r);
	causal group1=(_801110_SWI_r) group2=(_801040_SWI_r _801710_SWI_r _801180_SWI_r _801720_SWI_r);
run;

proc varmax data = Q2.&sg._Ind;
    id obs interval = day;
	model _801160_SWI_r _801170_SWI_r _801880_SWI_r _801080_SWI_r _801730_SWI_r _801770_SWI_r _801750_SWI_r _801150_SWI_r _801010_SWI_r/ minic=(p=10 q=0 type=AIC);
	/* ������ҵ����ͨ��������������ӡ������豸��ͨ�š��������ҽҩ�����ũ������*/
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
	causal group1=(_801210_SWI_r) group2=(_801200_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); /* ���з������ҵó�ס�ʳƷ���ϡ���ý�����С���������*/
	causal group1=(_801200_SWI_r) group2=(_801210_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); 
	causal group1=(_801120_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801760_SWI_r _801780_SWI_r _801790_SWI_r); 
	causal group1=(_801760_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801780_SWI_r _801790_SWI_r);
	causal group1=(_801780_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801760_SWI_r _801790_SWI_r);
	causal group1=(_801790_SWI_r) group2=(_801210_SWI_r _801200_SWI_r _801120_SWI_r _801760_SWI_r _801780_SWI_r);
run;

/* ========= ��ÿ�׶��ڴ�����ҵ�ֶ�ЧӦ����Ͳ�ҵ������������Ӧ =========*/

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
