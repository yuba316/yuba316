libname original "E:\sas\sas����\����Ԥ����";

/* ========= ���ݵ��� =========*/

proc import out = original.data_0
    datafile = "E:\sas\sas����\����Ԥ����\�����ʮ�˸���ҵ���̼�.xlsx"
	dbms = xlsx replace;
	getnames = yes;
	datarow = 2;
	range = "��ʷ����2$A2:AC4793"n; /* �����͵ײ������޹���Ϣ����ָ�������ȡ*/
run;

data original.data_0; /* ��������ԭʼ�����ݼ�����28����ҵ�����̼�*/
    set original.data_0;
	if A = . then delete;
run;

/* ========= ���ƴ���ָ������ͼ�������˻��ֽ׶� =========*/

proc import out = original.ss
    datafile = "E:\sas\sas����\����Ԥ����\����ָ��.xlsx" /* ������Դ�����ײƾ���http://quotes.money.163.com/trade/lsjysj_zhishu_000001.html?year=2019&season=4*/
	dbms = xlsx replace;
	getnames = yes;
run;

proc gplot data = original.ss; /* ��ͼ��ʾ�����ǿ��Դ��µؽ��������ƻ���Ϊ10���׶Σ�����1-4��5-8��Ϊ�������ƵĴ����ڣ���9-10������һ�����ڵĿ�ʼ*/
    title "��ָ֤��2000/01/04-2019/10/11����ͼ";
	plot ss000001*date;
	symbol i = join;
run;

data original.data_0; /* ���������ƽ�ԭʼ���ݼ�����Ϊ10���׶Σ���һ���µı���period��Ϊ���*/
    set original.data_0;
    if (year(A) < 2001) | (year(A) = 2001 & month(A) <7) then period = 1;
	else if (year(A) < 2005) | (year(A) = 2005 & month(A) < 7) then period = 2;
	else if (year(A) < 2007) | (year(A) = 2007 & month(A) < 10) then period = 3;
	else if (year(A) < 2008) | (year(A) = 2008 & month(A) < 10) then period = 4;
	else if (year(A) < 2009) | (year(A) = 2009 & month(A) < 7) then period = 5;
	else if (year(A) < 2014) | (year(A) = 2014 & month(A) < 7) then period = 6;
	else if (year(A) < 2015) | (year(A) = 2015 & month(A) < 7) then period = 7;
	else if year(A) < 2016 then period = 8;
	else if year(A) < 2018 then period = 9;
	else period = 10;
run;

data original.data_0;
    set original.data_0;
	by period;
	retain obs; /* ��¼ÿһ��ʱ��������еĹ۲�ֵ��������������Իع�����ģ�͵Ľ���*/
	if first.period then obs = 1;
	else obs = obs+1;
run;

/* ========= �������ݸ�ʽ����������������� =========*/

data original.data_0;
    set original.data_0;
	_801010_SWI_1 = input(_801010_SWI, 14.);
    _801020_SWI_1 = input(_801020_SWI, 14.);
    _801030_SWI_1 = input(_801030_SWI, 14.);
    _801040_SWI_1 = input(_801040_SWI, 14.);
    _801050_SWI_1 = input(_801050_SWI, 14.);
    _801080_SWI_1 = input(_801080_SWI, 14.);
    _801110_SWI_1 = input(_801110_SWI, 14.);
    _801120_SWI_1 = input(_801120_SWI, 14.);
    _801130_SWI_1 = input(_801130_SWI, 14.);
    _801140_SWI_1 = input(_801140_SWI, 14.);
    _801150_SWI_1 = input(_801150_SWI, 14.);
    _801160_SWI_1 = input(_801160_SWI, 14.);
    _801170_SWI_1 = input(_801170_SWI, 14.);
    _801180_SWI_1 = input(_801180_SWI, 14.);
    _801200_SWI_1 = input(_801200_SWI, 14.);
    _801210_SWI_1 = input(_801210_SWI, 14.);
    _801230_SWI_1 = input(_801230_SWI, 14.);
    _801710_SWI_1 = input(_801710_SWI, 14.);
    _801720_SWI_1 = input(_801720_SWI, 14.);
    _801730_SWI_1 = input(_801730_SWI, 14.);
    _801740_SWI_1 = input(_801740_SWI, 14.);
    _801750_SWI_1 = input(_801750_SWI, 14.);
    _801760_SWI_1 = input(_801760_SWI, 14.);
    _801770_SWI_1 = input(_801770_SWI, 14.);
    _801780_SWI_1 = input(_801780_SWI, 14.);
    _801790_SWI_1 = input(_801790_SWI, 14.);
    _801880_SWI_1 = input(_801880_SWI, 14.);
    _801890_SWI_1 = input(_801890_SWI, 14.);
	drop _801010_SWI _801020_SWI _801030_SWI _801040_SWI _801050_SWI
_801080_SWI _801110_SWI _801120_SWI _801130_SWI _801140_SWI _801150_SWI
_801160_SWI _801170_SWI _801180_SWI _801200_SWI _801210_SWI _801230_SWI
_801710_SWI _801720_SWI _801730_SWI _801740_SWI _801750_SWI _801760_SWI
_801770_SWI _801780_SWI _801790_SWI _801880_SWI _801890_SWI;
    rename
	_801010_SWI_1 = _801010_SWI
    _801020_SWI_1 = _801020_SWI
    _801030_SWI_1 = _801030_SWI
    _801040_SWI_1 = _801040_SWI
    _801050_SWI_1 = _801050_SWI
    _801080_SWI_1 = _801080_SWI
    _801110_SWI_1 = _801110_SWI
    _801120_SWI_1 = _801120_SWI
    _801130_SWI_1 = _801130_SWI
    _801140_SWI_1 = _801140_SWI
    _801150_SWI_1 = _801150_SWI
    _801160_SWI_1 = _801160_SWI
    _801170_SWI_1 = _801170_SWI
    _801180_SWI_1 = _801180_SWI
    _801200_SWI_1 = _801200_SWI
    _801210_SWI_1 = _801210_SWI
    _801230_SWI_1 = _801230_SWI
    _801710_SWI_1 = _801710_SWI
    _801720_SWI_1 = _801720_SWI
    _801730_SWI_1 = _801730_SWI
    _801740_SWI_1 = _801740_SWI
    _801750_SWI_1 = _801750_SWI
    _801760_SWI_1 = _801760_SWI
    _801770_SWI_1 = _801770_SWI
    _801780_SWI_1 = _801780_SWI
    _801790_SWI_1 = _801790_SWI
    _801880_SWI_1 = _801880_SWI
    _801890_SWI_1 = _801890_SWI;
	label _801010_SWI_1 = "ũ������";
    label _801020_SWI_1 = "�ɾ�";
    label _801030_SWI_1 = "����";
    label _801040_SWI_1 = "����";
    label _801050_SWI_1 = "��ɫ����";
    label _801080_SWI_1 = "����";
    label _801110_SWI_1 = "���õ���";
    label _801120_SWI_1 = "ʳƷ����";
    label _801130_SWI_1 = "��֯��װ";
    label _801140_SWI_1 = "�Ṥ����";
    label _801150_SWI_1 = "ҽҩ����";
    label _801160_SWI_1 = "������ҵ";
    label _801170_SWI_1 = "��ͨ����";
    label _801180_SWI_1 = "���ز�";
    label _801200_SWI_1 = "��ҵó��";
    label _801210_SWI_1 = "���з���";
    label _801230_SWI_1 = "�ۺ�";
    label _801710_SWI_1 = "��������";
    label _801720_SWI_1 = "����װ��";
    label _801730_SWI_1 = "�����豸";
    label _801740_SWI_1 = "��������";
    label _801750_SWI_1 = "�����";
    label _801760_SWI_1 = "��ý";
    label _801770_SWI_1 = "ͨ��";
    label _801780_SWI_1 = "����";
    label _801790_SWI_1 = "��������";
    label _801880_SWI_1 = "����";
    label _801890_SWI_1 = "��е�豸";
run;

data original.data_0;
    set original.data_0;
	_801010_SWI_r = log(_801010_SWI)-log(lag(_801010_SWI));
	_801020_SWI_r = log(_801020_SWI)-log(lag(_801020_SWI));
	_801030_SWI_r = log(_801030_SWI)-log(lag(_801030_SWI));
	_801040_SWI_r = log(_801040_SWI)-log(lag(_801040_SWI));
	_801050_SWI_r = log(_801050_SWI)-log(lag(_801050_SWI));
	_801080_SWI_r = log(_801080_SWI)-log(lag(_801080_SWI));
	_801110_SWI_r = log(_801110_SWI)-log(lag(_801110_SWI));
	_801120_SWI_r = log(_801120_SWI)-log(lag(_801120_SWI));
	_801130_SWI_r = log(_801130_SWI)-log(lag(_801130_SWI));
	_801140_SWI_r = log(_801140_SWI)-log(lag(_801140_SWI));
	_801150_SWI_r = log(_801150_SWI)-log(lag(_801150_SWI));
	_801160_SWI_r = log(_801160_SWI)-log(lag(_801160_SWI));
	_801170_SWI_r = log(_801170_SWI)-log(lag(_801170_SWI));
	_801180_SWI_r = log(_801180_SWI)-log(lag(_801180_SWI));
	_801200_SWI_r = log(_801200_SWI)-log(lag(_801200_SWI));
	_801210_SWI_r = log(_801210_SWI)-log(lag(_801210_SWI));
	_801230_SWI_r = log(_801230_SWI)-log(lag(_801230_SWI));
	_801710_SWI_r = log(_801710_SWI)-log(lag(_801710_SWI));
	_801720_SWI_r = log(_801720_SWI)-log(lag(_801720_SWI));
	_801730_SWI_r = log(_801730_SWI)-log(lag(_801730_SWI));
	_801740_SWI_r = log(_801740_SWI)-log(lag(_801740_SWI));
	_801750_SWI_r = log(_801750_SWI)-log(lag(_801750_SWI));
	_801760_SWI_r = log(_801760_SWI)-log(lag(_801760_SWI));
	_801770_SWI_r = log(_801770_SWI)-log(lag(_801770_SWI));
	_801780_SWI_r = log(_801780_SWI)-log(lag(_801780_SWI));
	_801790_SWI_r = log(_801790_SWI)-log(lag(_801790_SWI));
	_801880_SWI_r = log(_801880_SWI)-log(lag(_801880_SWI));
	_801890_SWI_r = log(_801890_SWI)-log(lag(_801890_SWI));
	label _801010_SWI_r = "ũ������";
    label _801020_SWI_r = "�ɾ�";
    label _801030_SWI_r = "����";
    label _801040_SWI_r = "����";
    label _801050_SWI_r = "��ɫ����";
    label _801080_SWI_r = "����";
    label _801110_SWI_r = "���õ���";
    label _801120_SWI_r = "ʳƷ����";
    label _801130_SWI_r = "��֯��װ";
    label _801140_SWI_r = "�Ṥ����";
    label _801150_SWI_r = "ҽҩ����";
    label _801160_SWI_r = "������ҵ";
    label _801170_SWI_r = "��ͨ����";
    label _801180_SWI_r = "���ز�";
    label _801200_SWI_r = "��ҵó��";
    label _801210_SWI_r = "���з���";
    label _801230_SWI_r = "�ۺ�";
    label _801710_SWI_r = "��������";
    label _801720_SWI_r = "����װ��";
    label _801730_SWI_r = "�����豸";
    label _801740_SWI_r = "��������";
    label _801750_SWI_r = "�����";
    label _801760_SWI_r = "��ý";
    label _801770_SWI_r = "ͨ��";
    label _801780_SWI_r = "����";
    label _801790_SWI_r = "��������";
    label _801880_SWI_r = "����";
    label _801890_SWI_r = "��е�豸";
run;
