libname abnormal "E:\sas\sas\������Ŀ\����"; /* �������һ��Ҫ�Լ������λ�ã�����ı�ȫ�������������棡����*/

/* ========= ���ݵ��� =========*/

proc import out = abnormal.finance_0
    datafile = "E:\sas\sas\������Ŀ\����\finance_1"
	dbms = xlsx replace;
	getnames = yes;
run;

proc import out = abnormal.income_0
    datafile = "E:\sas\sas\������Ŀ\����\income_1"
	dbms = xlsx replace;
	getnames = yes;
run;

proc import out = abnormal.return_0
    datafile = "E:\sas\sas\������Ŀ\����\return_1"
	dbms = xlsx replace;
	getnames = yes;
run;

/* ========= ��ÿ�����·ݷ�������ֵΪ��׼ =========*/

data abnormal.finance_0;
    set abnormal.finance_0;
	year = floor((VAR3)/10000);
	drop A ts_code VAR5 VAR6 industry;
run;

proc sort data = abnormal.finance_0 out = abnormal.finance_0;
    by VAR10 symbol year VAR3;
run;

data abnormal.finance_0;
    set abnormal.finance_0;
	by VAR10 symbol year VAR3;
	if first.year;
run;

data abnormal.finance_0;
    retain symbol VAR4 VAR7 year VAR10;
    set abnormal.finance_0;
	rename VAR4 = Msmvttl VAR7 = equity symbol = stkcd VAR10 = list_date;
	label symbol = 'stkcd';
	label VAR4 = '��ֵ';
	label VAR10 = 'list_date';
	drop VAR3;
run;

/* ========= ��ÿ�����·ݷ����ľ�����Ϊ��׼ =========*/

data abnormal.income_0;
    set abnormal.income_0;
	year = floor((f_ann_date)/10000);
	drop A ts_code industry;
run;

proc sort data = abnormal.income_0 out = abnormal.income_0;
    by list_date symbol year f_ann_date;
run;

data abnormal.income_0;
    set abnormal.income_0;
	by list_date symbol year f_ann_date;
	if first.year;
run;

data abnormal.income_0;
    retain symbol n_income year;
    set abnormal.income_0;
	rename n_income = income symbol = stkcd;
	label symbol = 'stkcd';
	label n_income = '������';
	drop f_ann_date list_date;
run;

/* ========= ������ӯ�� =========*/

proc sql;
    create table abnormal.finance_1 as
	select a.*, b.income, a.Msmvttl/b.income as ep
	from abnormal.finance_0 as a
    left join abnormal.income_0 as b
	on a.stkcd = b.stkcd and a.year = b.year
	order by a.list_date, a.stkcd, a.year;
run;

/* ========= �ϲ��¶������ʱ� =========*/

data abnormal.return_0;
    retain trade_date symbol profit vol;
    set abnormal.return_0;
	list_y = floor((list_date)/10000);
	drop A close pre_close ts_code industry list_date;
	rename symbol = stkcd;
	label symbol = 'stkcd';
run;

data abnormal.return_0;
    set abnormal.return_0;
	year = floor((trade_date)/10000);
	if floor((trade_date-year*10000)/100) < 7 then year = year-1;
	join_y = list_y+1;
run;

data abnormal.return_0;
    set abnormal.return_0;
	if year < join_y then delete; /* ɾ������ʱ������6���µĸ����¶������ʼ�¼*/
	drop list_y join_y;
run;

proc sql;
    create table abnormal.return_1 as
	select a.*, b.Msmvttl, b.ep, b.list_date
	from abnormal.return_0 as a
	left join abnormal.finance_1 as b
	on a.stkcd = b.stkcd and a.year = b.year
	order by b.list_date, a.stkcd, a.year, a.trade_date;
run;

data abnormal.return_1;
    set abnormal.return_1;
	if Msmvttl = . then delete; /* ɾ�����к�δ����ֵ��¼�ĸ����¶������ʼ�¼*/
run;

/* ========= ����turnover =========*/

proc sql;
    create table abnormal.turnover as
	select stkcd, year, sum(vol) as year_vol
	from abnormal.return_1
	group by stkcd, year;
run;

data abnormal.turnover;
    set abnormal.turnover;
	year = year+1;
run;

proc sql;
    create table abnormal.return_2 as
	select a.*, year_vol
	from abnormal.return_1 as a
    left join abnormal.turnover as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

data abnormal.return_2;
    set abnormal.return_2;
	turnover = vol/year_vol;
	drop list_date vol year_vol;
run;

/* ========= ����00�굽16����ĩ���� =========*/

data abnormal.original_0;
    set abnormal.return_2;
	rn_year = floor((trade_date)/10000);
run;

data abnormal.original_0;
    set abnormal.original_0;
	if rn_year < 2000 then delete; /* ������00�������*/
run;

proc sort data = abnormal.original_0 out = abnormal.original_0;
    by year stkcd trade_date;
run;

/* ========= ȥ���տǹ�˾������SMB\VMG\PMO =========*/

data abnormal.mkt_0;
    set abnormal.original_0;
	by year stkcd trade_date;
	if first.stkcd;
run;

proc rank data = abnormal.mkt_0 out = abnormal.mkt_0 groups = 10;
    by year;
	ranks shell_rank;
	var Msmvttl;
run;

data abnormal.mkt_0;
    set abnormal.mkt_0;
	if shell_rank < 3 then delete; /* ȥ����ֵΪβ��30%�Ŀտǹ�˾*/
	drop shell_rank;
run;

proc rank data = abnormal.mkt_0 out = abnormal.mkt_0 groups = 2;
    by year;
	ranks Msmvttl_rank; /* ����SMB*/
	var Msmvttl;
run;

data abnormal.mkt_0;
    set abnormal.mkt_0;
	if Msmvttl_rank = 0 then SMB = 'S';
	else SMB = 'B';
	drop Msmvttl_rank;
run;

data abnormal.mkt_1;
    set abnormal.mkt_0;
	if ep < 0 then delete; /* ֻȡepΪ������������*/
run;

proc rank data = abnormal.mkt_1 out = abnormal.mkt_1 groups = 10;
    by year;
	ranks ep_rank; /* ����VMG*/
	var ep;
run;

data abnormal.mkt_1;
    set abnormal.mkt_1;
	if ep_rank < 3 then VMG = 'V';
	else if ep_rank < 7 then VMG = 'M';
	else VMG = 'G';
	drop ep_rank;
run;

data abnormal.mkt_2;
    set abnormal.mkt_0;
	if turnover = . then delete; /* ֻȡȥ���н������ļ�¼��������*/
run;

proc rank data = abnormal.mkt_2 out = abnormal.mkt_2 groups = 10;
    by year;
	ranks turnover_rank; /* ����PMO*/
	var turnover;
run;

data abnormal.mkt_2;
    set abnormal.mkt_2;
	if turnover_rank < 3 then PMO = 'P';
	else if turnover_rank < 7 then PMO = 'M';
	else PMO = 'O';
	drop turnover_rank;
run;

proc sql;
    create table abnormal.noshell_0 as
	select a.*, SMB
	from abnormal.original_0 as a
	left join abnormal.mkt_0 as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

proc sql;
    create table abnormal.noshell_0 as
	select a.*, VMG
	from abnormal.noshell_0 as a
	left join abnormal.mkt_1 as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

proc sql;
    create table abnormal.noshell_0 as
	select a.*, PMO
	from abnormal.noshell_0 as a
	left join abnormal.mkt_2 as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

data abnormal.noshell_0;
    set abnormal.noshell_0;
	if SMB = '' then delete; /* ɾ���տǹ�˾�ĸ����¶������ʼ�¼*/
run;

data abnormal.noshell_0;
    set abnormal.noshell_0;
	ymonth = floor(trade_date/100);
run;

/* ========= ���������ӣ�MKT\SMB\VMG\PMO =========*/

data abnormal.factor_0;
    set abnormal.noshell_0;
	if SMB = 'S' and VMG = 'V' then factor = 1;
	if SMB = 'S' and VMG = 'M' then factor = 2;
	if SMB = 'S' and VMG = 'G' then factor = 3;
	if SMB = 'B' and VMG = 'V' then factor = 4;
	if SMB = 'B' and VMG = 'M' then factor = 5;
	if SMB = 'B' and VMG = 'G' then factor = 6;
	if SMB = 'S' and PMO = 'P' then ffactor = 1;
	if SMB = 'S' and PMO = 'O' then ffactor = 3;
	if SMB = 'B' and PMO = 'P' then ffactor = 4;
	if SMB = 'B' and PMO = 'O' then ffactor = 6;
run;

proc sort data = abnormal.factor_0; by ymonth factor; run;

proc summary data = abnormal.factor_0;
    weight Msmvttl;
	var profit;
	by ymonth factor;
	output out = abnormal.factor_3 mean = profit;
run;

proc sort data = abnormal.factor_0; by ymonth ffactor; run;

proc summary data = abnormal.factor_0;
    weight Msmvttl;
	var profit;
	by ymonth ffactor;
	output out = abnormal.factor_4 mean = profit;
run;

data abnormal.factor_3;
    set abnormal.factor_3;
	retain SMB;
	if factor = 1 then SMB = profit/3;
	if factor = 2 or factor = 3 then SMB = SMB + profit/3;
	if factor = 4 or factor = 5 or factor = 6 then SMB = SMB - profit/3;
	retain VMG;
	if factor = 1 then VMG = profit/2;
	if factor = 4 then VMG = VMG + profit/2;
	if factor = 3 or factor = 6 then VMG = VMG - profit/2;
run;

data abnormal.factor_4;
    set abnormal.factor_4;
	retain PMO;
	if ffactor = 1 then PMO = profit/2;
	if ffactor = 4 then PMO = PMO + profit/2;
	if ffactor = 3 or ffactor = 6 then PMO = PMO - profit/2;
run;

proc sql;
    create table abnormal.factor as
	select a.ymonth, SMB, VMG, PMO
	from abnormal.factor_3 as a
	left join abnormal.factor_4 as b
	on a.ymonth = b.ymonth and a.factor = b.ffactor
	where a.factor = . and b.ffactor = . and a.SMB NE . and b.PMO NE .;
run;

data abnormal.factor;
    set abnormal.factor;
	yearmonth = lag(ymonth);
	drop ymonth;
run;

data abnormal.factor;
    retain yearmonth SMB VMG PMO;
    set abnormal.factor;
	if yearmonth = . then yearmonth = 200001;
	rename yearmonth = ymonth;
run;

proc sql;
    create table abnormal.factor as
	select * from abnormal.factor
	union
	(select a.ymonth, SMB, VMG, PMO
	 from abnormal.factor_3 as a
	 left join abnormal.factor_4 as b
	 on a.ymonth = b.ymonth and a.factor = b.ffactor
	 where a.ymonth = 201612 and a.factor = 6);
run;

proc summary data = abnormal.factor_0;
    weight Msmvttl;
	var profit;
	by ymonth;
	output out = abnormal.factor_mkt mean = profit;
run;

proc sql;
    create table abnormal.factor as
	select a.*, b.profit as MKT
	from abnormal.factor as a
	left join abnormal.factor_mkt as b
	on a.ymonth = b.ymonth;
run;

proc sql;
    create table abnormal.reg as
	select a.trade_date, a.stkcd, a.profit, b.MKT, b.SMB, b.VMG, b.PMO, a.ymonth, a.Msmvttl, a.ep, a.turnover
    from abnormal.noshell_0 as a
	left join abnormal.factor as b
	on a.ymonth = b.ymonth;
run;

proc sort data = abnormal.reg out = abnormal.reg;
    by stkcd ymonth;
run;

/* ========= ���㳬�������� =========*/

DATA abnormal.rf (Label="���������ļ�");
Infile 'E:\sas\sas\������Ŀ\����\rf.txt' encoding="utf-16le" delimiter = '09'x Missover Dsd lrecl=32767 firstobs=2;
Format Trdmnt $10.;
Format Interest 12.6;
Informat Trdmnt $10.;
Informat Interest 12.6;
Label Trdmnt="�·�";
Label Interest="������������";
Input Trdmnt $ Interest ;
Run;

data abnormal.rf;
    set abnormal.rf;
	ymonth = substr(Trdmnt,1,4)*100+substr(Trdmnt,6,2);
run;

proc sql;
    create table abnormal.reg as
	select a.*, b.interest
	from abnormal.reg as a
    left join abnormal.rf as b
	on a.ymonth = b.ymonth;
run;

data abnormal.reg;
    set abnormal.reg;
	MKT = MKT - interest*0.01;
	E_rn = profit - interest*0.01;
run;

proc reg data = abnormal.reg;
	title "CH-4";
	model E_rn = MKT SMB VMG PMO;
run;
