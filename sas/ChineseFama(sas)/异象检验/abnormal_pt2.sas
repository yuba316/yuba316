libname abnormal "E:\sas\sas\个人项目\异象"; /* 这是第一part产生的数据库位置*/
libname abn_pt2 "E:\sas\sas\个人项目\异象\pt2"; /* 这是第二part要保存的地址*/

/* ========= 异象研究 =========*/

data abn_pt2.abn_0;
    set abnormal.noshell_0; /* 本程序所需的第一个表，共2个*/
	drop SMB VMG PMO;
run;

proc sort data = abn_pt2.abn_0 out = abn_pt2.abn_0;
    by stkcd year;
run;

data abn_pt2.abn;
    set abn_pt2.abn_0;
	by stkcd year;
	if first.year;
run;

proc sort data = abn_pt2.abn out = abn_pt2.abn;
    by year stkcd;
run;

proc rank data = abn_pt2.abn out = abn_pt2.abn groups = 10;
    by year;
	ranks group;
	var Msmvttl;
run;

proc sort data = abn_pt2.abn out = abn_pt2.abn;
    by year group;
run;

/* ========= 异象研究：计算四因子 =========*/

proc rank data = abn_pt2.abn out = abn_pt2.abn groups = 2;
    by year group;
	ranks Msmvttl_rank; /* 划分SMB*/
	var Msmvttl;
run;

data abn_pt2.abn;
    set abn_pt2.abn;
	if Msmvttl_rank = 0 then SMB = 'S';
	else SMB = 'B';
	drop Msmvttl_rank;
run;

data abn_pt2.abn_1;
    set abn_pt2.abn;
	if ep < 0 then delete; /* 只取ep为正数进行排序*/
run;

proc rank data = abn_pt2.abn_1 out = abn_pt2.abn_1 groups = 10;
    by year group;
	ranks ep_rank; /* 划分VMG*/
	var ep;
run;

data abn_pt2.abn_1;
    set abn_pt2.abn_1;
	if ep_rank < 3 then VMG = 'V';
	else if ep_rank < 7 then VMG = 'M';
	else VMG = 'G';
	drop ep_rank;
run;

data abn_pt2.abn_2;
    set abn_pt2.abn;
	if turnover = . then delete; /* 只取去年有交易量的记录进行排序*/
run;

proc rank data = abn_pt2.abn_2 out = abn_pt2.abn_2 groups = 10;
    by year;
	ranks turnover_rank; /* 划分PMO*/
	var turnover;
run;

data abn_pt2.abn_2;
    set abn_pt2.abn_2;
	if turnover_rank < 3 then PMO = 'P';
	else if turnover_rank < 7 then PMO = 'M';
	else PMO = 'O';
	drop turnover_rank;
run;

proc sql;
    create table abn_pt2.abn as
	select a.*, VMG
	from abn_pt2.abn as a
	left join abn_pt2.abn_1 as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

proc sql;
    create table abn_pt2.abn as
	select a.*, PMO
	from abn_pt2.abn as a
	left join abn_pt2.abn_2 as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

proc sql;
    create table abn_pt2.abn_0 as
	select a.*, SMB, VMG, PMO, group
	from abn_pt2.abn_0 as a
	left join abn_pt2.abn as b
	on a.stkcd = b.stkcd and a.year = b.year;
run;

data abn_pt2.abn_0;
    set abn_pt2.abn_0;
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

proc sort data = abn_pt2.abn_0; by ymonth group factor; run;

proc summary data = abn_pt2.abn_0;
    weight Msmvttl;
	var profit;
	by ymonth group factor;
	output out = abn_pt2.factor_3 mean = profit;
run;

proc sort data = abn_pt2.abn_0; by ymonth group ffactor; run;

proc summary data = abn_pt2.abn_0;
    weight Msmvttl;
	var profit;
	by ymonth group ffactor;
	output out = abn_pt2.factor_4 mean = profit;
run;

data abn_pt2.factor_3;
    set abn_pt2.factor_3;
	retain SMB;
	if factor = 1 then SMB = profit/3;
	if factor = 2 or factor = 3 then SMB = SMB + profit/3;
	if factor = 4 or factor = 5 or factor = 6 then SMB = SMB - profit/3;
	retain VMG;
	if factor = 1 then VMG = profit/2;
	if factor = 4 then VMG = VMG + profit/2;
	if factor = 3 or factor = 6 then VMG = VMG - profit/2;
run;

data abn_pt2.factor_4;
    set abn_pt2.factor_4;
	retain PMO;
	if ffactor = 1 then PMO = profit/2;
	if ffactor = 4 then PMO = PMO + profit/2;
	if ffactor = 3 or ffactor = 6 then PMO = PMO - profit/2;
run;

proc sql;
    create table abn_pt2.factor as
	select a.ymonth, a.group, SMB, VMG, PMO
	from abn_pt2.factor_3 as a
	left join abn_pt2.factor_4 as b
	on a.ymonth = b.ymonth and a.group = b.group and a.factor = b.ffactor
	where a.factor = . and b.ffactor = . and a.SMB NE . and b.PMO NE .;
run;

data abn_pt2.factor;
    set abn_pt2.factor;
	newymonth = lag(ymonth);
	newgroup = lag(group);
	drop ymonth group;
run;

data abn_pt2.factor;
    retain newymonth newgroup SMB VMG PMO;
    set abn_pt2.factor;
	if newymonth = . then do;
        newymonth = 200001;
		newgroup = 0;
	end;
	rename newymonth = ymonth newgroup = group;
run;

proc sql;
    create table abn_pt2.factor as
	select * from abn_pt2.factor
	union
	(select a.ymonth, a.group, SMB, VMG, PMO
	 from abn_pt2.factor_3 as a
	 left join abn_pt2.factor_4 as b
	 on a.ymonth = b.ymonth and a.group = b.group and a.factor = b.ffactor
	 where a.ymonth = 201612 and a.group = 9 and a.factor = 6);
run;

proc summary data = abn_pt2.abn_0;
    weight Msmvttl;
	var profit;
	by ymonth group;
	output out = abn_pt2.factor_mkt mean = profit;
run;

proc sql;
    create table abn_pt2.factor as
	select a.*, b.profit as MKT
	from abn_pt2.factor as a
	left join abn_pt2.factor_mkt as b
	on a.ymonth = b.ymonth and a.group = b.group;
run;

proc sql;
    create table abn_pt2.abn_reg as
	select a.trade_date, a.ymonth, a.rn_year as year, a.group, a.stkcd, a.profit, b.MKT, b.SMB, b.VMG, b.PMO, a.Msmvttl, a.ep, a.turnover
    from abn_pt2.abn_0 as a
	left join abn_pt2.factor as b
	on a.ymonth = b.ymonth and a.group = b.group;
run;

proc sql;
    create table abn_pt2.abn_reg as
	select a.*, b.interest
	from abn_pt2.abn_reg as a
    left join abnormal.rf as b /* 本程序所需的第二个表，共2个*/
	on a.ymonth = b.ymonth;
run;

/* ========= 异象研究：size =========*/

proc sort data = abn_pt2.abn_reg; by ymonth group; run;

proc rank data = abn_pt2.abn_reg out = abn_pt2.abn_0_size groups = 10;
    by ymonth group;
	ranks size_rank;
	var Msmvttl;
run;

data abn_pt2.abn_0_size;
    set abn_pt2.abn_0_size;
	if size_rank = 0 or size_rank = 9;
run;

proc sort data = abn_pt2.abn_0_size out = abn_pt2.abn_0_size;
    by ymonth group size_rank;
run;

proc summary data = abn_pt2.abn_0_size;
    weight Msmvttl;
	var profit;
	by ymonth group size_rank;
	output out = abn_pt2.abn_0_size_g mean = profit;
run;

data abn_pt2.abn_0_size_g;
    set abn_pt2.abn_0_size_g;
	LS_rn = profit-lag(profit);
run;

data abn_pt2.abn_0_size_g;
    set abn_pt2.abn_0_size_g;
	if size_rank = 9;
	keep ymonth group LS_rn;
run;

proc sql;
    create table abn_pt2.abn_reg_size as
	select a.*, LS_rn
    from abn_pt2.abn_0_size as a
	left join abn_pt2.abn_0_size_g as b
	on a.ymonth = b.ymonth and a.group = b.group;
run;

data abn_pt2.abn_reg_size;
    set abn_pt2.abn_reg_size;
	if LS_rn = . then delete;
run;

data abn_pt2.abn_reg_size;
    set abn_pt2.abn_reg_size;
	MKT = MKT - interest*0.01;
run;

proc reg data = abn_pt2.abn_reg_size;
	title "abnomal-size";
	model LS_rn = MKT SMB VMG PMO;
run;

/* ========= 异象研究：ep =========*/

proc sort data = abn_pt2.abn_reg; by ymonth group; run;

proc rank data = abn_pt2.abn_reg out = abn_pt2.abn_0_ep groups = 10;
    by ymonth group;
	ranks ep_rank;
	var ep;
run;

data abn_pt2.abn_0_ep;
    set abn_pt2.abn_0_ep;
	if ep_rank = 0 or ep_rank = 9;
run;

proc sort data = abn_pt2.abn_0_ep out = abn_pt2.abn_0_ep;
    by ymonth group ep_rank;
run;

proc summary data = abn_pt2.abn_0_ep;
    weight Msmvttl;
	var profit;
	by ymonth group ep_rank;
	output out = abn_pt2.abn_0_ep_g mean = profit;
run;

data abn_pt2.abn_0_ep_g;
    set abn_pt2.abn_0_ep_g;
	LS_rn = profit-lag(profit);
run;

data abn_pt2.abn_0_ep_g;
    set abn_pt2.abn_0_ep_g;
	if ep_rank = 9;
	keep ymonth group LS_rn;
run;

proc sql;
    create table abn_pt2.abn_reg_ep as
	select a.*, LS_rn
    from abn_pt2.abn_0_ep as a
	left join abn_pt2.abn_0_ep_g as b
	on a.ymonth = b.ymonth and a.group = b.group;
run;

data abn_pt2.abn_reg_ep;
    set abn_pt2.abn_reg_ep;
	if LS_rn = . then delete;
run;

data abn_pt2.abn_reg_ep;
    set abn_pt2.abn_reg_ep;
	MKT = MKT - interest*0.01;
run;

proc reg data = abn_pt2.abn_reg_ep;
	title "abnomal-ep";
	model LS_rn = MKT SMB VMG PMO;
run;

/* ========= 异象研究：one-month-return =========*/

proc sort data = abn_pt2.abn_reg; by ymonth group; run;

proc rank data = abn_pt2.abn_reg out = abn_pt2.abn_0_omr groups = 10;
    by ymonth group;
	ranks omr_rank;
	var profit;
run;

data abn_pt2.abn_0_omr;
    set abn_pt2.abn_0_omr;
	if omr_rank = 0 or omr_rank = 9;
run;

proc sort data = abn_pt2.abn_0_omr out = abn_pt2.abn_0_omr;
    by ymonth group omr_rank;
run;

proc summary data = abn_pt2.abn_0_omr;
    weight Msmvttl;
	var profit;
	by ymonth group omr_rank;
	output out = abn_pt2.abn_0_omr_g mean = profit;
run;

data abn_pt2.abn_0_omr_g;
    set abn_pt2.abn_0_omr_g;
	LS_rn = profit-lag(profit);
run;

data abn_pt2.abn_0_omr_g;
    set abn_pt2.abn_0_omr_g;
	if omr_rank = 9;
	keep ymonth group LS_rn;
run;

proc sql;
    create table abn_pt2.abn_reg_omr as
	select a.*, LS_rn
    from abn_pt2.abn_0_omr as a
	left join abn_pt2.abn_0_omr_g as b
	on a.ymonth = b.ymonth and a.group = b.group;
run;

data abn_pt2.abn_reg_omr;
    set abn_pt2.abn_reg_omr;
	if LS_rn = . then delete;
run;

data abn_pt2.abn_reg_omr;
    set abn_pt2.abn_reg_omr;
	MKT = MKT - interest*0.01;
run;

proc reg data = abn_pt2.abn_reg_size;
	title "abnomal-size";
	model LS_rn = MKT SMB VMG PMO;
run;

proc reg data = abn_pt2.abn_reg_ep;
	title "abnomal-ep";
	model LS_rn = MKT SMB VMG PMO;
run;

proc reg data = abn_pt2.abn_reg_omr;
	title "abnomal-one-month-return";
	model LS_rn = MKT SMB VMG PMO;
run;
