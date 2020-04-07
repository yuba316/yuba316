libname original "E:\sas\sas大赛\数据预处理";
libname Q4 "E:\sas\sas大赛\第四题";

%macro mavg(var,lag); /* 用于计算移动平均数的宏*/
/* var: 需要进行移动平均的变量
   lag: 滞后阶数，即求移动平均的时间跨度
*/
%let n = %eval(&lag-1);
(&var 
%do i=1 %to &n;
+ lag&i(&var)
%end;
)/&lag
%mend mavg;

%macro mstd(var,mean,lag); /* 用于计算移动标准差的宏*/
/* var: 需要进行移动平均的变量
   lag: 滞后阶数，即求移动平均的时间跨度
*/
%let n = %eval(&lag-1);
((&var-&mean)**2 
%do i=1 %to &n;
+ (lag&i(&var)-&mean)**2
%end;
)/&n
%mend mstd;

/* ========= 对各阶段各产业链内的行业轮动效应运用布林线突破策略 =========*/

%let sg = sg1;
%let stage = 1;
%let indst = 1;

%let period = 10;  /* 可优化参数：移动平均的步数，初始设置为使用十日均线作为布林线的中轨*/
%let upstd = 1;    /* 可优化参数：布林线轨道的上轨间距*/
%let dwstd = 1;    /* 可优化参数：布林线轨道的下轨间距*/
%let cover = mean; /* 可选参数：平仓点可选在回落至上/中/下轨(up/mean/dw)的任一时刻*/

data Q4.&sg._ind_&indst;
    set original.data_0;
	if period = &stage;
	keep A obs _801180_SWI _801040_SWI _801710_SWI _801720_SWI _801110_SWI; /* 第一条产业链*/
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	mean = %mavg(_801040_SWI,&period);
	label mean = "中轨";
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	std = sqrt(%mstd(_801040_SWI,mean,&period));
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	up = mean+&upstd*std;
	dw = mean-&dwstd*std;
	label up = "上轨";
	label dw = "下轨";
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst end = over;
	if (lag(_801040_SWI) < lag(up) & _801040_SWI >= up) then open = _801040_SWI;
	else open = .;
    if (lag(_801040_SWI) > lag(&cover) & _801040_SWI <= &cover) then close = _801040_SWI;
	else close = .;
	if over then close = _801040_SWI;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	retain flag;
	if open NE . then flag = -1;
	else if close NE . then flag = 1;
	else do;
	    if flag = . then flag = 1;
		else flag = flag;
	end;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	if (open NE . & lag(flag) NE 1) then open = .;
	if (close NE . & lag(flag) NE -1) then close = .;
	label open = "开仓点";
	label close = "平仓点";
run;
proc gplot data = Q4.&sg._ind_&indst;
    title "第&stage.阶段钢铁的布林轨道";
	plot _801040_SWI*A mean*A up*A dw*A open*A close*A / overlay legend vaxis = axis1 haxis = axis2;
	axis1 label = (a=-90 r=90 "行业指数");
	axis2 label = ("日期");
	symbol1 i = join ci = "black";
	symbol2 i = join ci = "green";
	symbol3 i = join ci = "red";
	symbol4 i = join ci = "blue";
	symbol5 i = none v = circle cv = "blue";
	symbol6 i = none v = circle cv = "red";
run;

/* ========= 对各阶段各产业链内的被引导行业运用布林线突破跟投策略 ========= */
data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	retain profit;
	if open NE . then profit = profit - open;
	else if close NE . then profit = profit + close;
	else do;
	    if profit = . then profit = 0;
		else profit = profit;
	end;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst end = over;
	if lag6(open) NE . then open_801180 = _801180_SWI;
	if lag6(close) NE . then close_801180 = _801180_SWI;
	if lag6(open) NE . then open_801710 = _801710_SWI;
	if lag6(close) NE . then close_801710 = _801710_SWI;
	if lag6(open) NE . then open_801720 = _801720_SWI;
	if lag6(close) NE . then close_801720 = _801720_SWI;
	if lag4(open) NE . then open_801110 = _801110_SWI;
	if lag4(close) NE . then close_801110 = _801110_SWI;
	if open NE . then open_801180_0 = _801180_SWI;
	if close NE . then close_801180_0 = _801180_SWI;
	if open NE . then open_801710_0 = _801710_SWI;
	if close NE . then close_801710_0 = _801710_SWI;
	if open NE . then open_801720_0 = _801720_SWI;
	if close NE . then close_801720_0 = _801720_SWI;
	if open NE . then open_801110_0 = _801110_SWI;
	if close NE . then close_801110_0 = _801110_SWI;
	if over then do;
        open_801180 = .;
		open_801710 = .;
		open_801720 = .;
		open_801110 = .;
		open_801180_0 = .;
		open_801710_0 = .;
		open_801720_0 = .;
		open_801110_0 = .;
	    close_801180 = _801180_SWI;
		close_801710 = _801710_SWI;
		close_801720 = _801720_SWI;
		close_801110 = _801110_SWI;
		close_801180_0 = _801180_SWI;
		close_801710_0 = _801710_SWI;
		close_801720_0 = _801720_SWI;
		close_801110_0 = _801110_SWI;
	end;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	if (close_801180 NE . & lag7(flag) NE -1) then close_801180 = .;
	if (close_801710 NE . & lag7(flag) NE -1) then close_801710 = .;
	if (close_801720 NE . & lag7(flag) NE -1) then close_801720 = .;
	if (close_801110 NE . & lag5(flag) NE -1) then close_801110 = .;
	if (close_801180_0 NE . & lag(flag) NE -1) then close_801180_0 = .;
	if (close_801710_0 NE . & lag(flag) NE -1) then close_801710_0 = .;
	if (close_801720_0 NE . & lag(flag) NE -1) then close_801720_0 = .;
	if (close_801110_0 NE . & lag(flag) NE -1) then close_801110_0 = .;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	retain profit_801180;
	if open_801180 NE . then profit_801180 = profit_801180-open_801180;
	else if close_801180 NE . then profit_801180 = profit_801180+close_801180;
	else do;
	    if profit_801180 = . then profit_801180 = 0;
		else profit_801180 = profit_801180;
	end;
	retain profit_801710;
	if open_801710 NE . then profit_801710 = profit_801710-open_801710;
	else if close_801710 NE . then profit_801710 = profit_801710+close_801710;
	else do;
	    if profit_801710 = . then profit_801710 = 0;
		else profit_801710 = profit_801710;
	end;
    retain profit_801720;
	if open_801720 NE . then profit_801720 = profit_801720-open_801720;
	else if close_801720 NE . then profit_801720 = profit_801720+close_801720;
	else do;
	    if profit_801720 = . then profit_801720 = 0;
		else profit_801720 = profit_801720;
	end;
	retain profit_801110;
	if open_801110 NE . then profit_801110 = profit_801110-open_801110;
	else if close_801110 NE . then profit_801110 = profit_801110+close_801110;
	else do;
	    if profit_801110 = . then profit_801110 = 0;
		else profit_801110 = profit_801110;
	end;
	retain profit_801180_0;
	if open_801180_0 NE . then profit_801180_0 = profit_801180_0-open_801180_0;
	else if close_801180_0 NE . then profit_801180_0 = profit_801180_0+close_801180_0;
	else do;
	    if profit_801180_0 = . then profit_801180_0 = 0;
		else profit_801180_0 = profit_801180_0;
	end;
	retain profit_801710_0;
	if open_801710_0 NE . then profit_801710_0 = profit_801710_0-open_801710_0;
	else if close_801710_0 NE . then profit_801710_0 = profit_801710_0+close_801710_0;
	else do;
	    if profit_801710_0 = . then profit_801710_0 = 0;
		else profit_801710_0 = profit_801710_0;
	end;
    retain profit_801720_0;
	if open_801720_0 NE . then profit_801720_0 = profit_801720_0-open_801720_0;
	else if close_801720_0 NE . then profit_801720_0 = profit_801720_0+close_801720_0;
	else do;
	    if profit_801720_0 = . then profit_801720_0 = 0;
		else profit_801720_0 = profit_801720_0;
	end;
	retain profit_801110_0;
	if open_801110_0 NE . then profit_801110_0 = profit_801110_0-open_801110_0;
	else if close_801110_0 NE . then profit_801110_0 = profit_801110_0+close_801110_0;
	else do;
	    if profit_801110_0 = . then profit_801110_0 = 0;
		else profit_801110_0 = profit_801110_0;
	end;
run;

data Q4.&sg._ind_&indst;
    set Q4.&sg._ind_&indst;
	profit_2_801180 = profit + profit_801180;
	profit_2_801710 = profit + profit_801710;
	profit_2_801720 = profit + profit_801720;
	profit_2_801110 = profit + profit_801110;
	profit_2_801180_0 = profit + profit_801180_0;
	profit_2_801710_0 = profit + profit_801710_0;
	profit_2_801720_0 = profit + profit_801720_0;
	profit_2_801110_0 = profit + profit_801110_0;
	profit_sum = profit + profit_801180 + profit_801710 + profit_801720 + profit_801110;
	profit_sum_0 = profit + profit_801180_0 + profit_801710_0 + profit_801720_0 + profit_801110_0;
run;

data Q4.&sg._ind_&indst._profit;
    set Q4.&sg._ind_&indst end = over;
	if over;
	keep profit profit_2_801180 profit_2_801710 profit_2_801720 profit_2_801110 profit_2_801180_0 profit_2_801710_0 profit_2_801720_0 profit_2_801110_0 profit_sum profit_sum_0;
	label profit = "钢铁";
    label profit_2_801180 = "房地产X钢铁";
    label profit_2_801710 = "建筑材料X钢铁";
    label profit_2_801720 = "建筑装饰X钢铁";
	label profit_2_801110 = "家用电器X钢铁";
    label profit_2_801180_0 = "跟投房地产";
    label profit_2_801710_0 = "跟投建筑材料";
    label profit_2_801720_0 = "跟投建筑装饰";
	label profit_2_801110_0 = "跟投家用电器";
    label profit_sum = "总收益";
    label profit_sum_0 = "跟投总收益";
run;

data Q4.&sg._ind_&indst._profit;
    set Q4.&sg._ind_&indst._profit end = over;
	pc_801180 = (profit_2_801180 - profit)/profit_sum*100;
	pc_801710 = (profit_2_801710 - profit)/profit_sum*100;
	pc_801720 = (profit_2_801720 - profit)/profit_sum*100;
	pc_801110 = (profit_2_801110 - profit)/profit_sum*100;
	pc_801180_0 = (profit_2_801180_0 - profit)/profit_sum*100;
	pc_801710_0 = (profit_2_801710_0 - profit)/profit_sum*100;
	pc_801720_0 = (profit_2_801720_0 - profit)/profit_sum*100;
	pc_801110_0 = (profit_2_801110_0 - profit)/profit_sum*100;
	pc_sum = (profit_sum - profit_sum_0)/profit_sum_0*100;
    label pc_801180 = "房地产贡献率";
    label pc_801710 = "建筑材料贡献率";
    label pc_801720 = "建筑装饰贡献率";
	label pc_801110 = "家用电器贡献率";
    label pc_801180_0 = "跟投房地产贡献";
    label pc_801710_0 = "跟投建筑材料贡献";
    label pc_801720_0 = "跟投建筑装饰贡献";
	label pc_801110_0 = "跟投家用电器贡献";
    label pc_sum = "总收益相对跟投增长";
run;

proc export data = Q4.&sg._ind_&indst._profit outfile = "E:\sas\sas大赛\第四题\布林线\&sg._profit_new.xlsx" dbms=xlsx;
run;

/* ========= 寻找新的滞后效应识别指标 ========= */

%let ma=60;

data Q4.ind;
    set original.data_0(keep = A _801040_SWI _801180_SWI _801710_SWI _801720_SWI _801110_SWI);
	range = 100*(_801040_SWI-lag(_801040_SWI))/lag(_801040_SWI); /* 计算涨跌幅*/
	m&ma = %mavg(_801040_SWI,&ma); /* 计算多日均线*/
	close_0_up_lag = lag(_801040_SWI);
	close_0_up_lag2 = lag2(_801040_SWI);
	close_0_up_lag3 = lag3(_801040_SWI);
	close_0_up_lag4 = lag4(_801040_SWI);
	close_1_up_lag = lag(_801180_SWI);
	close_1_up_lag2 = lag2(_801180_SWI);
	close_1_up_lag3 = lag3(_801180_SWI);
	close_1_up_lag4 = lag4(_801180_SWI);
	close_2_up_lag = lag(_801710_SWI);
	close_2_up_lag2 = lag2(_801710_SWI);
	close_2_up_lag3 = lag3(_801710_SWI);
	close_2_up_lag4 = lag4(_801710_SWI);
	close_3_up_lag = lag(_801720_SWI);
	close_3_up_lag2 = lag2(_801720_SWI);
	close_3_up_lag3 = lag3(_801720_SWI);
	close_3_up_lag4 = lag4(_801720_SWI);
	close_4_up_lag = lag(_801110_SWI);
	close_4_up_lag2 = lag2(_801110_SWI);
	close_4_up_lag3 = lag3(_801110_SWI);
	close_4_up_lag4 = lag4(_801110_SWI);
run;

data Q4.ind;
    set Q4.ind;
	if m&ma = . then delete;
run;

data Q4.ind;
    set Q4.ind;
	if lag(range) > 1.5 then up = 1; /* 昨天大涨*/
	else up = 0;
	if lag(range) <= -1.5 then dw = 1; /* 昨天大跌*/
	else dw = 0;
	if (lag(range) > 1.5 & lag(_801040_SWI)>lag(m&ma)) then up_ab&ma = 1; /* 大涨且在均线上方*/
	else up_ab&ma = 0;
	if (lag(range) > 1.5 & lag(_801040_SWI)<lag(m&ma)) then up_bl&ma = 1; /* 大涨且在均线下方*/
	else up_bl&ma = 0;
	if (lag(range) <= -1.5 & lag(_801040_SWI)>lag(m&ma)) then dw_ab&ma = 1; /* 大跌且在均线上方*/
	else dw_ab&ma = 0;
	if (lag(range) <= -1.5 & lag(_801040_SWI)<lag(m&ma)) then dw_bl&ma = 1; /* 大跌且在均线下方*/
	else dw_bl&ma = 0;
run;

data Q4.ind;
    set Q4.ind;
	if (up=1 & (lag(up)=1 | lag2(up)=1 | lag3(up)=1)) then up = 0;
	if (dw=1 & (lag(dw)=1 | lag2(dw)=1 | lag3(dw)=1)) then dw = 0;
	if (up_ab&ma=1 & (lag(up_ab&ma)=1 | lag2(up_ab&ma)=1 | lag3(up_ab&ma)=1)) then up_ab&ma = 0;
	if (dw_ab&ma=1 & (lag(dw_ab&ma)=1 | lag2(dw_ab&ma)=1 | lag3(dw_ab&ma)=1)) then dw_ab&ma = 0;
	if (up_bl&ma=1 & (lag(up_bl&ma)=1 | lag2(up_bl&ma)=1 | lag3(up_bl&ma)=1)) then up_bl&ma = 0;
	if (dw_bl&ma=1 & (lag(dw_bl&ma)=1 | lag2(dw_bl&ma)=1 | lag3(dw_bl&ma)=1)) then dw_bl&ma = 0;
run;

data Q4.ind;
    set Q4.ind;
	up_lag = lag(up);
	up_lag2 = lag2(up);
	up_lag3 = lag3(up);
	dw_lag = lag(dw);
	dw_lag2 = lag2(dw);
	dw_lag3 = lag3(dw);
	up_ab&ma._lag = lag(up_ab&ma);
	up_ab&ma._lag2 = lag2(up_ab&ma);
	up_ab&ma._lag3 = lag3(up_ab&ma);
	dw_ab&ma._lag = lag(dw_ab&ma);
	dw_ab&ma._lag2 = lag2(dw_ab&ma);
	dw_ab&ma._lag3 = lag3(dw_ab&ma);
	up_bl&ma._lag = lag(up_bl&ma);
	up_bl&ma._lag2 = lag2(up_bl&ma);
	up_bl&ma._lag3 = lag3(up_bl&ma);
	dw_bl&ma._lag = lag(dw_bl&ma);
	dw_bl&ma._lag2 = lag2(dw_bl&ma);
	dw_bl&ma._lag3 = lag3(dw_bl&ma);
run;

data Q4.ind;
    set Q4.ind;
	if up = 1 then do;
        close_0_up = close_0_up_lag;
		close_1_up = close_1_up_lag;
		close_2_up = close_2_up_lag;
		close_3_up = close_3_up_lag;
		close_4_up = close_4_up_lag;
	end;
	else if up_lag = 1 then do;
        close_0_up = close_0_up_lag2;
		close_1_up = close_1_up_lag2;
		close_2_up = close_2_up_lag2;
		close_3_up = close_3_up_lag2;
		close_4_up = close_4_up_lag2;
	end;
	else if up_lag2 = 1 then do;
        close_0_up = close_0_up_lag3;
		close_1_up = close_1_up_lag3;
		close_2_up = close_2_up_lag3;
		close_3_up = close_3_up_lag3;
		close_4_up = close_4_up_lag3;
	end;
	else if up_lag3 = 1 then do;
        close_0_up = close_0_up_lag4;
		close_1_up = close_1_up_lag4;
		close_2_up = close_2_up_lag4;
		close_3_up = close_3_up_lag4;
		close_4_up = close_4_up_lag4;
	end;
	if dw = 1 then do;
        close_0_dw = close_0_up_lag;
		close_1_dw = close_1_up_lag;
		close_2_dw = close_2_up_lag;
		close_3_dw = close_3_up_lag;
		close_4_dw = close_4_up_lag;
	end;
	else if dw_lag = 1 then do;
        close_0_dw = close_0_up_lag2;
		close_1_dw = close_1_up_lag2;
		close_2_dw = close_2_up_lag2;
		close_3_dw = close_3_up_lag2;
		close_4_dw = close_4_up_lag2;
	end;
	else if dw_lag2 = 1 then do;
        close_0_dw = close_0_up_lag3;
		close_1_dw = close_1_up_lag3;
		close_2_dw = close_2_up_lag3;
		close_3_dw = close_3_up_lag3;
		close_4_dw = close_4_up_lag3;
	end;
	else if dw_lag3 = 1 then do;
        close_0_dw = close_0_up_lag4;
		close_1_dw = close_1_up_lag4;
		close_2_dw = close_2_up_lag4;
		close_3_dw = close_3_up_lag4;
		close_4_dw = close_4_up_lag4;
	end;
	if up_ab&ma = 1 then do;
        close_0_up_ab&ma = close_0_up_lag;
		close_1_up_ab&ma = close_1_up_lag;
		close_2_up_ab&ma = close_2_up_lag;
		close_3_up_ab&ma = close_3_up_lag;
		close_4_up_ab&ma = close_4_up_lag;
	end;
	else if up_ab&ma._lag = 1 then do;
        close_0_up_ab&ma = close_0_up_lag2;
		close_1_up_ab&ma = close_1_up_lag2;
		close_2_up_ab&ma = close_2_up_lag2;
		close_3_up_ab&ma = close_3_up_lag2;
		close_4_up_ab&ma = close_4_up_lag2;
	end;
	else if up_ab&ma._lag2 = 1 then do;
        close_0_up_ab&ma = close_0_up_lag3;
		close_1_up_ab&ma = close_1_up_lag3;
		close_2_up_ab&ma = close_2_up_lag3;
		close_3_up_ab&ma = close_3_up_lag3;
		close_4_up_ab&ma = close_4_up_lag3;
	end;
	else if up_ab&ma._lag3 = 1 then do;
        close_0_up_ab&ma = close_0_up_lag4;
		close_1_up_ab&ma = close_1_up_lag4;
		close_2_up_ab&ma = close_2_up_lag4;
		close_3_up_ab&ma = close_3_up_lag4;
		close_4_up_ab&ma = close_4_up_lag4;
	end;
	if dw_ab&ma = 1 then do;
        close_0_dw_ab&ma = close_0_up_lag;
		close_1_dw_ab&ma = close_1_up_lag;
		close_2_dw_ab&ma = close_2_up_lag;
		close_3_dw_ab&ma = close_3_up_lag;
		close_4_dw_ab&ma = close_4_up_lag;
	end;
	else if dw_ab&ma._lag = 1 then do;
        close_0_dw_ab&ma = close_0_up_lag2;
		close_1_dw_ab&ma = close_1_up_lag2;
		close_2_dw_ab&ma = close_2_up_lag2;
		close_3_dw_ab&ma = close_3_up_lag2;
		close_4_dw_ab&ma = close_4_up_lag2;
	end;
	else if dw_ab&ma._lag2 = 1 then do;
        close_0_dw_ab&ma = close_0_up_lag3;
		close_1_dw_ab&ma = close_1_up_lag3;
		close_2_dw_ab&ma = close_2_up_lag3;
		close_3_dw_ab&ma = close_3_up_lag3;
		close_4_dw_ab&ma = close_4_up_lag3;
	end;
	else if dw_ab&ma._lag3 = 1 then do;
        close_0_dw_ab&ma = close_0_up_lag4;
		close_1_dw_ab&ma = close_1_up_lag4;
		close_2_dw_ab&ma = close_2_up_lag4;
		close_3_dw_ab&ma = close_3_up_lag4;
		close_4_dw_ab&ma = close_4_up_lag4;
	end;
	if up_bl&ma = 1 then do;
        close_0_up_bl&ma = close_0_up_lag;
		close_1_up_bl&ma = close_1_up_lag;
		close_2_up_bl&ma = close_2_up_lag;
		close_3_up_bl&ma = close_3_up_lag;
		close_4_up_bl&ma = close_4_up_lag;
	end;
	else if up_bl&ma._lag = 1 then do;
        close_0_up_bl&ma = close_0_up_lag2;
		close_1_up_bl&ma = close_1_up_lag2;
		close_2_up_bl&ma = close_2_up_lag2;
		close_3_up_bl&ma = close_3_up_lag2;
		close_4_up_bl&ma = close_4_up_lag2;
	end;
	else if up_bl&ma._lag2 = 1 then do;
        close_0_up_bl&ma = close_0_up_lag3;
		close_1_up_bl&ma = close_1_up_lag3;
		close_2_up_bl&ma = close_2_up_lag3;
		close_3_up_bl&ma = close_3_up_lag3;
		close_4_up_bl&ma = close_4_up_lag3;
	end;
	else if up_bl&ma._lag3 = 1 then do;
        close_0_up_bl&ma = close_0_up_lag4;
		close_1_up_bl&ma = close_1_up_lag4;
		close_2_up_bl&ma = close_2_up_lag4;
		close_3_up_bl&ma = close_3_up_lag4;
		close_4_up_bl&ma = close_4_up_lag4;
	end;
	if dw_bl&ma = 1 then do;
        close_0_dw_bl&ma = close_0_up_lag;
		close_1_dw_bl&ma = close_1_up_lag;
		close_2_dw_bl&ma = close_2_up_lag;
		close_3_dw_bl&ma = close_3_up_lag;
		close_4_dw_bl&ma = close_4_up_lag;
	end;
	else if dw_bl&ma._lag = 1 then do;
        close_0_dw_bl&ma = close_0_up_lag2;
		close_1_dw_bl&ma = close_1_up_lag2;
		close_2_dw_bl&ma = close_2_up_lag2;
		close_3_dw_bl&ma = close_3_up_lag2;
		close_4_dw_bl&ma = close_4_up_lag2;
	end;
	else if dw_bl&ma._lag2 = 1 then do;
        close_0_dw_bl&ma = close_0_up_lag3;
		close_1_dw_bl&ma = close_1_up_lag3;
		close_2_dw_bl&ma = close_2_up_lag3;
		close_3_dw_bl&ma = close_3_up_lag3;
		close_4_dw_bl&ma = close_4_up_lag3;
	end;
	else if dw_bl&ma._lag3 = 1 then do;
        close_0_dw_bl&ma = close_0_up_lag4;
		close_1_dw_bl&ma = close_1_up_lag4;
		close_2_dw_bl&ma = close_2_up_lag4;
		close_3_dw_bl&ma = close_3_up_lag4;
		close_4_dw_bl&ma = close_4_up_lag4;
	end;
run;

data Q4.ind;
    set Q4.ind;
	keep A _801040_SWI _801180_SWI _801710_SWI _801720_SWI _801110_SWI
         close_0_up close_0_dw close_0_up_ab&ma close_0_up_bl&ma close_0_dw_ab&ma close_0_dw_bl&ma
		 close_1_up close_1_dw close_1_up_ab&ma close_1_up_bl&ma close_1_dw_ab&ma close_1_dw_bl&ma
		 close_2_up close_2_dw close_2_up_ab&ma close_2_up_bl&ma close_2_dw_ab&ma close_2_dw_bl&ma
		 close_3_up close_3_dw close_3_up_ab&ma close_3_up_bl&ma close_3_dw_ab&ma close_3_dw_bl&ma
		 close_4_up close_4_dw close_4_up_ab&ma close_4_up_bl&ma close_4_dw_ab&ma close_4_dw_bl&ma;
run;

data Q4.ind_up;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_up)/close_0_up;
    rn_801180_SWI = (_801180_SWI-close_1_up)/close_1_up;
    rn_801710_SWI = (_801710_SWI-close_2_up)/close_2_up;
    rn_801720_SWI = (_801720_SWI-close_3_up)/close_3_up;
    rn_801110_SWI = (_801110_SWI-close_4_up)/close_4_up;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_up;
    set Q4.ind_up;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_up;
    set Q4.ind_up;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_up out=Q4.ind_up;
   by obs;
run;

data Q4.ind_dw;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_dw)/close_0_dw;
    rn_801180_SWI = (_801180_SWI-close_1_dw)/close_1_dw;
    rn_801710_SWI = (_801710_SWI-close_2_dw)/close_2_dw;
    rn_801720_SWI = (_801720_SWI-close_3_dw)/close_3_dw;
    rn_801110_SWI = (_801110_SWI-close_4_dw)/close_4_dw;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_dw;
    set Q4.ind_dw;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_dw;
    set Q4.ind_dw;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_dw out=Q4.ind_dw;
   by obs;
run;

data Q4.ind_up_ab&ma;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_up_ab&ma)/close_0_up_ab&ma;
    rn_801180_SWI = (_801180_SWI-close_1_up_ab&ma)/close_1_up_ab&ma;
    rn_801710_SWI = (_801710_SWI-close_2_up_ab&ma)/close_2_up_ab&ma;
    rn_801720_SWI = (_801720_SWI-close_3_up_ab&ma)/close_3_up_ab&ma;
    rn_801110_SWI = (_801110_SWI-close_4_up_ab&ma)/close_4_up_ab&ma;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_up_ab&ma;
    set Q4.ind_up_ab&ma;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_up_ab&ma;
    set Q4.ind_up_ab&ma;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_up_ab&ma out=Q4.ind_up_ab&ma;
   by obs;
run;

data Q4.ind_up_bl&ma ;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_up_bl&ma)/close_0_up_bl&ma;
    rn_801180_SWI = (_801180_SWI-close_1_up_bl&ma)/close_1_up_bl&ma;
    rn_801710_SWI = (_801710_SWI-close_2_up_bl&ma)/close_2_up_bl&ma;
    rn_801720_SWI = (_801720_SWI-close_3_up_bl&ma)/close_3_up_bl&ma;
    rn_801110_SWI = (_801110_SWI-close_4_up_bl&ma)/close_4_up_bl&ma;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_up_bl&ma;
    set Q4.ind_up_bl&ma;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_up_bl&ma;
    set Q4.ind_up_bl&ma;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_up_bl&ma out=Q4.ind_up_bl&ma;
   by obs;
run;

data Q4.ind_dw_ab&ma;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_dw_ab&ma)/close_0_dw_ab&ma;
    rn_801180_SWI = (_801180_SWI-close_1_dw_ab&ma)/close_1_dw_ab&ma;
    rn_801710_SWI = (_801710_SWI-close_2_dw_ab&ma)/close_2_dw_ab&ma;
    rn_801720_SWI = (_801720_SWI-close_3_dw_ab&ma)/close_3_dw_ab&ma;
    rn_801110_SWI = (_801110_SWI-close_4_dw_ab&ma)/close_4_dw_ab&ma;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_dw_ab&ma;
    set Q4.ind_dw_ab&ma;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_dw_ab&ma;
    set Q4.ind_dw_ab&ma;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_dw_ab&ma out=Q4.ind_dw_ab&ma;
   by obs;
run;

data Q4.ind_dw_bl&ma;
    set Q4.ind;
	rn_801040_SWI = (_801040_SWI-close_0_dw_bl&ma)/close_0_dw_bl&ma;
    rn_801180_SWI = (_801180_SWI-close_1_dw_bl&ma)/close_1_dw_bl&ma;
    rn_801710_SWI = (_801710_SWI-close_2_dw_bl&ma)/close_2_dw_bl&ma;
    rn_801720_SWI = (_801720_SWI-close_3_dw_bl&ma)/close_3_dw_bl&ma;
    rn_801110_SWI = (_801110_SWI-close_4_dw_bl&ma)/close_4_dw_bl&ma;
	keep A rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

data Q4.ind_dw_bl&ma;
    set Q4.ind_dw_bl&ma;
	if rn_801040_SWI = . then delete;
run;

data Q4.ind_dw_bl&ma;
    set Q4.ind_dw_bl&ma;
	obs = mod(_n_,4);
run;

proc sort data=Q4.ind_dw_bl&ma out=Q4.ind_dw_bl&ma;
   by obs;
run;

/* ========= 描述性统计 ========= */

proc means data = Q4.ind_up n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_up;
run;

proc means data = Q4.ind_dw n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_dw;
run;

proc means data = Q4.ind_up_ab&ma n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_up_ab&ma;
run;

proc means data = Q4.ind_up_bl&ma n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_up_bl&ma;
run;

proc means data = Q4.ind_dw_ab&ma n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_dw_ab&ma;
run;

proc means data = Q4.ind_dw_bl&ma n min max median mean std skewness kurtosis maxdec=4;
by obs;
var rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
output out = Q4.stat_ind_dw_bl&ma;
run;

proc export data = Q4.stat_ind_up
outfile = "E:\sas\sas大赛\第四题\stat\大涨.xlsx"
dbms = xlsx;
run;

proc export data = Q4.stat_ind_dw
outfile = "E:\sas\sas大赛\第四题\stat\大跌.xlsx"
dbms = xlsx replace;
run;

proc export data = Q4.ind_up_ab&ma
outfile = "E:\sas\sas大赛\第四题\stat\上大涨.xlsx"
dbms = xlsx replace;
run;

proc export data = Q4.ind_up_bl&ma
outfile = "E:\sas\sas大赛\第四题\stat\下大涨.xlsx"
dbms = xlsx replace;
run;

proc export data = Q4.ind_dw_ab&ma
outfile = "E:\sas\sas大赛\第四题\stat\上大跌.xlsx"
dbms = xlsx replace;
run;

proc export data = Q4.ind_dw_bl&ma
outfile = "E:\sas\sas大赛\第四题\stat\下大跌.xlsx"
dbms = xlsx replace;
run;

/* ========= 绘制核密度估计分布图 ========= */

data Q4.kde_up;
    set Q4.ind_up_ab&ma;
	if obs = 0;
run;

data Q4.kde_dw;
    set Q4.ind_dw_ab&ma;
	if obs = 0;
run;


proc kde data = Q4.kde_up;
   univar rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;

proc kde data = Q4.kde_dw;
   univar rn_801040_SWI rn_801180_SWI rn_801710_SWI rn_801720_SWI rn_801110_SWI;
run;
