# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 13:51:54 2019

@author: yuba316
"""

import pandas as pd
import datetime
import calendar
import time
import matplotlib.pyplot as plt
import talib as ta
import numpy as np
from scipy.stats import norm

import tushare as ts
pro = ts.pro_api("f6233ac191e0221b30736b8cbca6dc232b2824b217ef4a2bfd97d798")

#%% ===========================================================================
#
#    获取期权信息模块：依据每月期权到期日标的收盘价判断并获取次月平值/虚二档期权
#
# =============================================================================

def GetOpInfo(): # 获取50etf历史上所有档位的期权信息
    etf_o_info = pro.opt_basic(exchange='SSE', fields='ts_code,name,call_put,exercise_price,maturity_date')
    etf_o_info = etf_o_info.sort_values(by=["maturity_date","call_put","exercise_price"]) # 按到期月份/认购认沽/执行价从小到大排序
    etf_o_info = etf_o_info.drop(etf_o_info[(etf_o_info["exercise_price"]*1000%10)!=0.0].index) # 删除执行价不合规的记录
    etf_o_info = etf_o_info.reset_index(drop=True)
    
    return etf_o_info

def Get50(today): # 获取50etf历史数据
    mid = datetime.datetime.strftime(today-datetime.timedelta(days=1250), "%Y%m%d") # 因为接口限制每次只能返回1000条数据，所以要分两次访问
    etf_1 = pro.fund_daily(ts_code='510050.SH', fields='trade_date,close,pre_close', start_date='20150325', end_date=mid)
    etf_2 = pro.fund_daily(ts_code='510050.SH', fields='trade_date,close,pre_close', start_date=mid, end_date=datetime.datetime.strftime(today, "%Y%m%d"))
    etf = pd.concat([etf_1,etf_2], ignore_index=True) # 拼接两次返回结果
    etf = etf.sort_values(by='trade_date') # 按交易日排序
    etf = etf.reset_index(drop=True)
    
    return etf

def Get4thWed(year,month): # 获取当月50etf期权到期日，每个月的第四个星期三
    c = calendar.Calendar(firstweekday=calendar.SUNDAY)
    monthcal = c.monthdatescalendar(year,month)
    forthWed = [day for week in monthcal for day in week if day.weekday() == 2 and day.month == month][3]
    
    return forthWed

def GetDate(today): # 获取当月期权到期日
    forthWed = Get4thWed(today.year,today.month)
    year = forthWed.year
    month = forthWed.month
    day = forthWed.day
    if today.day > day and month == 12: # 若今天已经过了本月期权的到期日，则自动切换为下个月的期权合约
        month = 1
        year = year+1
    elif today.day > day:
        month = month+1
    maturity_date = datetime.date.strftime(Get4thWed(year,month), "%Y%m%d")
    
    return maturity_date

def GetOpInfo_AnO(etf_o_info,etf,today): # 获取50etf平值和虚二档期权信息
    this_date = GetDate(today)
    maturity_date = etf_o_info["maturity_date"].unique() # 获取每月期权到期日
    isontime = etf["trade_date"].apply(lambda x: x in maturity_date)
    etf_0 = etf[isontime][["trade_date","close"]] # 只提取每月期权到期日当天的50etf价格作为判断次月期权平虚值的标准
    etf_0 = etf_0.reset_index(drop=True)
    this_month_close = etf_0.iloc[-1]["close"]
    etf_0["close"] = etf_0["close"].shift(1) # 向下移动一行，作为下个月到期期权平虚值的判断标准
    etf_0.loc[len(etf_0)] = [this_date,this_month_close]
    etf_0 = etf_0.rename(columns = {'trade_date':'maturity_date'})

    etf_o_info = pd.merge(etf_o_info,etf_0,how='left',on='maturity_date') # 按到期月份对齐拼接
    etf_o_info = etf_o_info.dropna(axis=0, how='any') # 删掉第一个已经到期的月份
    etf_o_info["re"] = abs(etf_o_info["close"] - etf_o_info["exercise_price"]) # 比较执行价与到期日时50etf收盘价的价差
    ATM = etf_o_info.groupby("maturity_date")["re"].min() # 选取价差最小的作为平值期权
    ATM_min = pd.DataFrame(columns=["maturity_date","min"])
    ATM_min["maturity_date"] = ATM.index
    ATM_min["min"] = list(ATM)
    etf_o_info = pd.merge(etf_o_info,ATM_min,how='left',on='maturity_date')

    index_ATM_C = etf_o_info[(etf_o_info["call_put"] == 'C') & (etf_o_info["re"] == etf_o_info["min"])].index
    index_OoM_C = index_ATM_C+2 # 挑选出虚二档期权
    index_ATM_P = etf_o_info[(etf_o_info["call_put"] == 'P') & (etf_o_info["re"] == etf_o_info["min"])].index
    index_OoM_P = index_ATM_P-2
    index = {'ATM_C':index_ATM_C,'OoM_C':index_OoM_C,'ATM_P':index_ATM_P,'OoM_P':index_OoM_P}
    info = ["ts_code","name","call_put","exercise_price","maturity_date"]
    option_info = {}
    name = ['ATM_C','OoM_C','ATM_P','OoM_P']
    for i in name:
        option_info[i] = etf_o_info.loc[index[i]][info]
        option_info[i]["start_date"] = option_info[i]["maturity_date"].shift(1)
        option_info[i].iloc[0,-1] = '20150325'
        option_info[i]["start_date"] = option_info[i]["start_date"].apply(lambda x: datetime.datetime.strftime((datetime.datetime.strptime(x, '%Y%m%d')+datetime.timedelta(days=1)), '%Y%m%d'))
    
    return option_info

#%% ===========================================================================
#
#         获取期权历史数据模块：获取历史上每月平值/虚二档期权的行情信息数据
#
# =============================================================================

def GetOpData_AnO(option_info): # 获取50etf平值和虚二档期权历史数据
    option_data = {}
    count = 1
    for i in option_info.keys():
        op = option_info[i]
        n = len(op)
        df_0 = pd.DataFrame(columns=["ts_code","trade_date","pre_settle","settle"])
        for j in range(n):
            if count%150 == 0: # 每分钟限制访问接口150次，而每次只能返回一个期权，故需要手动休眠
                time.sleep(60)
            df = pro.opt_daily(ts_code=op.iloc[j]["ts_code"], start_date=op.iloc[j]["start_date"], end_date=op.iloc[j]["maturity_date"], fields='ts_code,trade_date,settle,pre_settle')
            df_0 = pd.concat([df_0,df], ignore_index=True)
            count = count+1
        df_0 = df_0.sort_values(by=["ts_code","trade_date"]) # 每张期权行情按交易日排序
        df_0 = df_0.reset_index(drop=True)
        option_data[i] = df_0
    
    return option_data

#%% ===========================================================================
#
#                    指数计算模块：计算各期权策略指数的历史数据
#
# =============================================================================
    
def MergeData(etf,option_info,option_data):
    option_data = pd.merge(option_data,option_info[["ts_code","exercise_price","maturity_date"]],how='left',on='ts_code')
    option_data = pd.merge(etf,option_data,how='left',on='trade_date')
    option_data = option_data.drop([0],axis=0)
    option_data = option_data.reset_index(drop=True)
    option_data["settle"] = option_data["settle"].fillna(0)
    option_data["pre_settle"] = option_data["pre_settle"].fillna(0)
    option_data = option_data.fillna(method='ffill')
    
    return option_data

def GetIndex(option_data):
    BXM = option_data["ATM_C"]
    BXM["50_pc"] = BXM["close"]/BXM["pre_close"]
    BXM.loc[0,"50_pc"] = 1000
    BXM["benchmark"] = BXM["50_pc"].cumprod()
    BXM["pc"] = (BXM["close"]-BXM["settle"])/(BXM["pre_close"]-BXM["pre_settle"])
    BXM.loc[0,"pc"] = 1000
    BXM["index"] = BXM["pc"].cumprod()
    BXM["last_index"] = BXM["index"].shift(1)
    BXM.loc[0,"last_index"] = BXM["index"].loc[0]
    BXM["return"] = 100*(BXM["index"]-BXM["last_index"])/BXM["last_index"]
    
    BXY = option_data["OoM_C"]
    BXY["50_pc"] = BXY["close"]/BXY["pre_close"]
    BXY.loc[0,"50_pc"] = 1000
    BXY["benchmark"] = BXY["50_pc"].cumprod()
    BXY["pc"] = (BXY["close"]-BXY["settle"])/(BXY["pre_close"]-BXY["pre_settle"])
    BXY.loc[0,"pc"] = 1000
    BXY["index"] = BXY["pc"].cumprod()
    BXY["last_index"] = BXY["index"].shift(1)
    BXY.loc[0,"last_index"] = BXY["index"].loc[0]
    BXY["return"] = 100*(BXY["index"]-BXY["last_index"])/BXY["last_index"]
    
    Put = option_data["ATM_P"]
    Put["50_pc"] = Put["close"]/Put["pre_close"]
    Put.loc[0,"50_pc"] = 1000
    Put["benchmark"] = Put["50_pc"].cumprod()
    Put["pc"] = (Put["close"]+Put["settle"])/(Put["pre_close"]+Put["pre_settle"])
    Put.loc[0,"pc"] = 1000
    Put["index"] = Put["pc"].cumprod()
    Put["last_index"] = Put["index"].shift(1)
    Put.loc[0,"last_index"] = Put["index"].loc[0]
    Put["return"] = 100*(Put["index"]-Put["last_index"])/Put["last_index"]
    
    Collar = pd.merge(option_data["OoM_C"],option_data["OoM_P"][["trade_date","ts_code","pre_settle","settle","exercise_price"]],how='left',on='trade_date')
    Collar["50_pc"] = Collar["close"]/Collar["pre_close"]
    Collar.loc[0,"50_pc"] = 1000
    Collar["benchmark"] = Collar["50_pc"].cumprod()
    Collar["pc"] = (Collar["close"]-Collar["settle_x"]+Collar["settle_y"])/(Collar["pre_close"]-Collar["pre_settle_x"]+Collar["pre_settle_y"])
    Collar.loc[0,"pc"] = 1000
    Collar["index"] = Collar["pc"].cumprod()
    Collar["last_index"] = Collar["index"].shift(1)
    Collar.loc[0,"last_index"] = Collar["index"].loc[0]
    Collar["return"] = 100*(Collar["index"]-Collar["last_index"])/Collar["last_index"]
    
    BXM["sigma"] = ta.STDDEV(BXM["close"], timeperiod=252) # 取一个交易年为历史波动率的周期参数
    BXM["T-t"] = BXM["maturity_date"].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d')) - BXM["trade_date"].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))
    BXM["T-t"] = BXM["T-t"].apply(lambda x: (x.days+1)/365)
    BXM["exp"] = np.exp(-0.035*BXM["T-t"]) # 取3.5%作为无风险收益率
    BXM.loc[BXM[BXM["T-t"]<=0].index,"T-t"]=0
    BXM["d1"] = (np.log(BXM["close"]/BXM["exercise_price"])+0.5*BXM["T-t"]*BXM["sigma"]**2)/(BXM["sigma"]*np.sqrt(BXM["T-t"]))
    BXM["d2"] = BXM["d1"] - BXM["sigma"]*np.sqrt(BXM["T-t"])
    BXM["C"] = BXM["exp"]*(BXM["close"]*norm.cdf(BXM["d1"])-BXM["exercise_price"]*norm.cdf(BXM["d2"]))
    BXM["delta"] = BXM["exp"]*norm.cdf(BXM["d1"])
    BXM["gamma"] = (BXM["exp"]*norm.pdf(BXM["d1"]))/(BXM["close"]*BXM["sigma"]*np.sqrt(BXM["T-t"]))
    BXM["vega"]  = BXM["exp"]*BXM["close"]*norm.pdf(BXM["d1"])*np.sqrt(BXM["T-t"])
    BXM["theta"] = 0.035*BXM["C"] - (BXM["exp"]*BXM["close"]*BXM["sigma"]*norm.pdf(BXM["d1"]))/(2*np.sqrt(BXM["T-t"]))
    
    index = {"BXM":BXM,"BXY":BXY,"Put":Put,"Collar":Collar}
    return index

#%% ===========================================================================
#
#                 可视化模块：绘制各期权策略指数与基线的对比走势图
#
# =============================================================================

def Visualize(index):
    xticks = index["BXM"]["trade_date"].loc[[0,int((len(index["BXM"])-1)*1/3),int((len(index["BXM"])-1)*2/3),int((len(index["BXM"])-1))]]
    plt.figure(figsize=(16,16))
    name = {"BXM":"平值备兑策略","BXY":"虚二档备兑策略","Put":"平值对冲策略","Collar":"虚二档衣领策略"}
    n = 0
    for i in index.keys():
        n = n+1
        plt.subplot(4,1,n)
        plt.plot(index[i]["trade_date"],index[i]["benchmark"],label = "benchmark")
        plt.plot(index[i]["trade_date"],index[i]["index"],label = name[i])
        plt.title(name[i])
        plt.legend(bbox_to_anchor=(0,0),loc=3)
        plt.xticks(xticks.tolist())

#%% ===========================================================================
#
#                          输出模块：输出指数为excel文件
#
# =============================================================================

def Output(path): # path为想要保存的excel地址
    today = datetime.datetime.today()
    etf_o_info = GetOpInfo()
    etf = Get50(today)
    option_info = GetOpInfo_AnO(etf_o_info,etf,today)
    option_data = GetOpData_AnO(option_info)
    for i in option_data.keys():
        option_data[i] = MergeData(etf,option_info[i],option_data[i])
    index = GetIndex(option_data)
    Visualize(index)
    writein = pd.concat([index["BXM"][["trade_date","index","return"]],index["BXY"][["index","return"]],index["Put"][["index","return"]],index["Collar"][["index","return"]]],axis=1)
    writein.columns = ['日期','BXM','BXM收益率','BXY','BXY收益率','PUT','PUT收益率','Collar','Collar收益率']
    BXM = index["BXM"][["trade_date","index","return","delta","gamma","theta","vega"]]
    BXM.columns = ['日期','BXM','BXM收益率','BXM-delta','BXM-gamma','BXM-theta','BXM-vega']
    writer = pd.ExcelWriter(path) # path为输出路径
    writein.to_excel(writer, sheet_name='benchmark', index=False)
    BXM.to_excel(writer, sheet_name='BXM', index=False)
    writer.save()

#%% test
Output(r"D:\work\GitHubProgram\OptionStrategyIndex(Python)\strategy_index.xlsx")