libname original "E:\sas\sas����\����Ԥ����";
libname Q1 "E:\sas\sas����\��һ��";

/* ========= ƽ��������������� =========*/

proc arima data = original.data_0; /* ��ԭ���н���ƽ���Լ��飬���־���ƽ��*/
    identify var = _801040_SWI stationarity = (ADF);
    identify var = _801180_SWI stationarity = (ADF);
	identify var = _801710_SWI stationarity = (ADF);
run;
proc arima data = original.data_0; /* �������ʽ���ƽ���Լ��飬���ֽ��ͨ��*/
    identify var = _801040_SWI_r stationarity = (ADF);
    identify var = _801180_SWI_r stationarity = (ADF);
	identify var = _801710_SWI_r stationarity = (ADF);
run;

/* ========= ���������Իع�ģ�� =========*/

%let sg = sg1;
%let stage = 1; /* ����ͨ�����ĺ����ʵ�ֲ�ͬ�׶εļ��������������ֻչʾ��һ�׶ε�������*/
/* ��ʹ�ú��������Ϊʮ���׶εĽ��һ�����ʵ����̫�����ˣ�������С���Ƿֹ���ɸ�������ģ����������ڷ���*/

data Q1.&sg;
    set original.data_0 (keep = A period obs _801040_SWI _801180_SWI _801710_SWI _801040_SWI_r _801180_SWI_r _801710_SWI_r);
	if period = &stage;
run;

proc gplot data = Q1.&sg; /* ��ͼ�۲�������ҵ�������ϵ��ͺ��ϵ*/
    title "���ز������ĺ͸�����ҵ������ָ����&stage.�׶�����ͼ";
	plot _801040_SWI*A _801180_SWI*A _801710_SWI*A / overlay legend vaxis = axis1 haxis = axis2;
	axis1 label = (a=-90 r=90 "��ҵָ��");
	axis2 label = ("����");
	symbol1 i = join ci = red;
	symbol2 i = join ci = yellow;
	symbol3 i = join ci = blue;
run;

/* ========= ���������Իع�ģ�� =========*/

%let sg = sg1;
%let stage = 1; /* ����ͨ�����ĺ����ʵ�ֲ�ͬ�׶εļ��������������ֻչʾ��һ�׶ε�������*/
/* ��ʹ�ú��������Ϊʮ���׶εĽ��һ�����ʵ����̫�����ˣ�������С���Ƿֹ���ɸ�������ģ����������ڷ���*/

data Q1.&sg;
    set original.data_0 (keep = A period obs _801040_SWI _801180_SWI _801710_SWI _801040_SWI_r _801180_SWI_r _801710_SWI_r);
	if period = &stage;
run;

proc varmax data = Q1.&sg plot = impulse; /* ��������ҵ���������Իع�ģ�͵Ĺ���*/
    id obs interval = day;
	model _801040_SWI_r _801180_SWI_r _801710_SWI_r / minic=(p=10 q=0 type=AIC) print=(impulsx=(all)); /* ����ͺ����Ϊ10�ף�ѡȡAIC��Ϊ���б�׼���Ա�����������֮���������Ӧ���*/
	causal group1=(_801040_SWI_r) group2=(_801180_SWI_r _801710_SWI_r); /* �Ա�������֮����и������������*/
	causal group1=(_801180_SWI_r) group2=(_801040_SWI_r _801710_SWI_r);
	causal group1=(_801710_SWI_r) group2=(_801040_SWI_r _801180_SWI_r);
run;
