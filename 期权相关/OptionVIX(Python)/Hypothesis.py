# -*- coding: utf-8 -*-
"""
Created on Sun Feb  2 21:32:55 2020

@author: yuba316
"""

import datetime
from dateutil.relativedelta import relativedelta
import time

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import talib as ta
import tushare as ts
pro = ts.pro_api("f6233ac191e0221b30736b8cbca6dc232b2824b217ef4a2bfd97d798")

#%% ===========================================================================
#
#                                  VIX编制模块
#
# =============================================================================

def Get50ETF(start_date='20150209',end_date='20200123',field='trade_date,pre_close,pct_chg'): # 获取50ETF历史行情数据
    start_date = datetime.datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.datetime.strptime(end_date, '%Y%m%d')
    days = int((end_date-start_date).days/1000)
    stop_point = [datetime.datetime.strftime(start_date, '%Y%m%d')]
    for i in range(days):
        stop_point.append(datetime.datetime.strftime(start_date+datetime.timedelta(days=(i+1)*1000), '%Y%m%d'))
    stop_point.append(datetime.datetime.strftime(end_date, '%Y%m%d'))
    
    etf = pd.DataFrame(columns=field.split(","))
    for j in range(days+1):
        df = pro.fund_daily(ts_code='510050.SH', start_date=stop_point[j], end_date=stop_point[j+1], fields=field)
        etf = pd.concat([etf,df], ignore_index=True, sort=False)
    etf = etf.sort_values(by='trade_date')
    etf = etf.drop_duplicates(['trade_date'])
    etf = etf.reset_index(drop=True)
    
    return etf

def GetRf(start_date='20150209',end_date='20200123',field='date,1y'):
    start_date = datetime.datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.datetime.strptime(end_date, '%Y%m%d')
    days = int((end_date-start_date).days/2000)
    stop_point = [datetime.datetime.strftime(start_date, '%Y%m%d')]
    for i in range(days):
        stop_point.append(datetime.datetime.strftime(start_date+datetime.timedelta(days=(i+1)*2000), '%Y%m%d'))
    stop_point.append(datetime.datetime.strftime(end_date, '%Y%m%d'))
    
    rf = pd.DataFrame(columns=field.split(","))
    for j in range(days+1):
        df = pro.shibor(start_date=stop_point[j], end_date=stop_point[j+1], fields=field)
        rf = pd.concat([rf,df], ignore_index=True, sort=False)
    rf = rf.rename(columns={'date':'trade_date','1y':'rf'})
    rf = rf.sort_values(by='trade_date')
    rf = rf.drop_duplicates(['trade_date'])
    rf = rf.reset_index(drop=True)
    
    return rf

def GetMtrD(S_D,E_D): # 获取区间内所有近月/次近月期权到期日
    E_D = datetime.datetime.strftime(datetime.datetime.strptime(E_D, '%Y%m%d') + relativedelta(months=2), '%Y%m%d')
    maturity = pro.opt_basic(exchange='SSE', fields='maturity_date').sort_values(by='maturity_date')
    maturity['maturity_month'] = maturity['maturity_date'].apply(lambda x: x[:-2])
    maturity = list(maturity[(maturity['maturity_month']>=S_D[:-2]) & (maturity['maturity_month']<=E_D[:-2])]['maturity_date'].unique())
    
    return maturity

def mergeETF(etf,maturity,rf): # 确认每日50ETF对应的近月/次近月期权合约
    maturity_date = {'trade_date':maturity[:-2],'close_month':maturity[:-2],'far_month':maturity[1:-1]}
    maturity_date = pd.DataFrame(maturity_date)
    etf = pd.merge(etf,maturity_date,how='left',on='trade_date')
    etf.iloc[-1,3] = maturity[-2]
    etf.iloc[-1,4] = maturity[-1]
    etf = etf.fillna(method='bfill')
    etf = pd.merge(etf,rf,how='left',on='trade_date')
    etf['T'] = etf['close_month'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))-etf['trade_date'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))
    etf['T'] = etf['T'].apply(lambda x: x.days+1)
    etf[['close_month','far_month']] = etf[etf['T']>=7][['close_month','far_month']]
    etf = etf.fillna(method='bfill')
    etf = etf.drop('T',axis=1)
    
    return etf
    
def mergeOption(etf,option_basic,close=True):
    option_basic = option_basic.rename(columns={'maturity_date':'close_month'})
    option_basic['far_month'] = option_basic['close_month']
    
    if close:
        etf = pd.merge(etf,option_basic[['ts_code','call_put','exercise_price','close_month']],how='left',on='close_month')
        etf['T'] = etf['close_month'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))-etf['trade_date'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))
        etf['T'] = etf['T'].apply(lambda x: (x.days+1)/365)
    else:
        etf = pd.merge(etf,option_basic[['ts_code','call_put','exercise_price','far_month']],how='left',on='far_month')
        etf['T'] = etf['far_month'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))-etf['trade_date'].apply(lambda x: datetime.datetime.strptime(x, '%Y%m%d'))
        etf['T'] = etf['T'].apply(lambda x: (x.days+1)/365)
    etf['re'] = abs(etf["pre_close"] - etf["exercise_price"]) # 比较执行价与收盘价的价差
    ATM = etf.groupby("trade_date")["re"].min() # 选取价差最小的作为平值期权
    ATM_min = pd.DataFrame(columns=["trade_date","min"])
    ATM_min["trade_date"] = ATM.index
    ATM_min["min"] = list(ATM)
    etf = pd.merge(etf,ATM_min,how='left',on='trade_date')
    etf = etf[etf['re']==etf['min']][['trade_date','pre_close','ts_code','call_put','exercise_price','T','rf']]
    etf_C = etf[etf['call_put']=='C'][['trade_date','pre_close','exercise_price','ts_code']]
    etf_P = etf[etf['call_put']=='P'][['trade_date','ts_code','T','rf']]
    etf = pd.merge(etf_C,etf_P,how='left',on='trade_date')
    etf = etf.rename(columns={'ts_code_x':'C_code','ts_code_y':'P_code'})
    etf = etf.drop_duplicates(['trade_date'])
    etf = etf.reset_index(drop=True)
    
    return etf

def ImpVol(trade_date,pre_close,option_basic,code_C,code_P,T,rf,count):
    index_C = option_basic[option_basic['ts_code']==code_C].index[0]
    index_P = option_basic[option_basic['ts_code']==code_P].index[0]
    code_C,K_C = [option_basic.loc[index_C,'ts_code']],[option_basic.loc[index_C,'exercise_price']]
    code_P,K_P = [option_basic.loc[index_P,'ts_code']],[option_basic.loc[index_P,'exercise_price']]
    i=1
    while(i<5 and option_basic.loc[index_C-i,'exercise_price']>K_C[-1]):
        code_C.append(option_basic.loc[index_C-i,'ts_code'])
        K_C.append(option_basic.loc[index_C-i,'exercise_price'])
        i = i+1
        if index_C-i<0:
            break
    i,n=1,len(option_basic)
    while(i<5 and option_basic.loc[index_P+i,'exercise_price']<K_P[-1]):
        code_P.append(option_basic.loc[index_P+i,'ts_code'])
        K_P.append(option_basic.loc[index_P+i,'exercise_price'])
        i = i+1
        if index_P+i>n:
            break
    settle_C,settle_P = [],[]
    for i in code_C:
        if count%150 == 0:
            time.sleep(60)
        pre_settle = pro.opt_daily(ts_code=i,start_date=trade_date,end_date=trade_date,fields='pre_settle')
        count = count+1
        if len(pre_settle)!=0:
            settle_C.append(pre_settle.iloc[0,0])
        else:
            break
    for i in code_P:
        if count%150 == 0:
            time.sleep(60)
        pre_settle = pro.opt_daily(ts_code=i,start_date=trade_date,end_date=trade_date,fields='pre_settle')
        count = count+1
        if len(pre_settle)!=0:
            settle_P.append(pre_settle.iloc[0,0])
        else:
            break
    n,m = len(settle_C),len(settle_P)
    option = {'code':code_C[:n]+code_P[:m],'K':K_C[:n]+K_P[:m],'pre_settle':settle_C+settle_P}
    option = pd.DataFrame(option)
    option = option.sort_values(by=['K','code'])
    option = option.reset_index(drop=True)
    K_0 = K_C[0]
    Sum = 0
    n = len(option)
    for i in range(n):
        if i==0:
            delta = option['K'].iloc[i+1]-option['K'].iloc[i]
        elif i==n-1:
            delta = option['K'].iloc[i]-option['K'].iloc[i-1]
        else:
            delta = (option['K'].iloc[i+1]-option['K'].iloc[i-1])/2
        Sum = Sum+delta/((option['K'].iloc[i])**2)*(option['pre_settle'].iloc[i])
    sigma = 2/T*Sum*np.exp(T*rf*0.01)-1/T*(float(pre_close)/K_0-1)**2
    
    return sigma,count

etf = Get50ETF()
maturity = GetMtrD(etf.iloc[0,0],etf.iloc[-1,0])
rf = GetRf(etf.iloc[0,0],etf.iloc[-1,0])
etf = mergeETF(etf,maturity,rf)
'''
option_basic = pro.opt_basic(exchange='SSE', fields='ts_code,call_put,exercise_price,maturity_date')
option_basic = option_basic.sort_values(by=['call_put','maturity_date','exercise_price'],ascending=[True,True,False])
option_basic = option_basic.reset_index(drop=True)
close_month = mergeOption(etf,option_basic,True)
far_month = mergeOption(etf,option_basic,False)

close_sigma,far_sigma=[],[]
n,count = len(close_month),1
for i in range(n):
    sigma,count = ImpVol(close_month['trade_date'].loc[i],close_month['pre_close'].loc[i],option_basic,\
                         close_month['C_code'].loc[i],close_month['P_code'].loc[i],close_month['T'].loc[i],close_month['rf'].loc[i],count)
    close_sigma.append(sigma)
for i in range(n):
    sigma,count = ImpVol(far_month['trade_date'].loc[i],far_month['pre_close'].loc[i],option_basic,\
                         far_month['C_code'].loc[i],far_month['P_code'].loc[i],far_month['T'].loc[i],far_month['rf'].loc[i],count)
    far_sigma.append(sigma)

VIX = {'trade_date':list(close_month['trade_date']),'close_month':close_sigma,'far_month':far_sigma}
VIX = pd.DataFrame(VIX)
VIX['VIX'] = np.sqrt((VIX['close_month']+VIX['far_month'])/2)*100
VIX = VIX.fillna(method='ffill')
VIX.to_excel(r"E:\VIX\VIX.xlsx")
'''
#%% ===========================================================================
#
#                             假设一：隐含波动率高估
#
# =============================================================================

VIX = pd.read_excel(r"E:\VIX\VIX.xlsx").iloc[:,1:]
VIX['trade_date'] = VIX['trade_date'].apply(str)
xticks = []
n = len(etf)
for i in range(n):
    if i%36==0:
        xticks.append(etf.loc[i,'trade_date'])
etf['vol_30'] = ta.STDDEV(etf['pre_close'],timeperiod=30)*100
etf['vol_60'] = ta.STDDEV(etf['pre_close'],timeperiod=60)*100
etf['vol_90'] = ta.STDDEV(etf['pre_close'],timeperiod=90)*100
plt.figure(figsize=(12,4))
plt.plot(VIX["trade_date"],VIX["VIX"],label="隐含波动率")
plt.title("50ETF期权VIX指数")
plt.legend(bbox_to_anchor=(0,1),loc=2)
plt.xticks(xticks,rotation=60)
plt.figure(figsize=(12,4))
plt.plot(VIX["trade_date"],VIX["VIX"],label="隐含波动率")
plt.plot(etf["trade_date"],etf["vol_30"],label = "历史波动率（30天）")
plt.plot(etf["trade_date"],etf["vol_60"],label = "历史波动率（60天）")
plt.plot(etf["trade_date"],etf["vol_90"],label = "历史波动率（90天）")
plt.title("假设一：隐含波动率高估")
plt.legend(bbox_to_anchor=(0,1),loc=2)
plt.xticks(xticks,rotation=60)

#%% ===========================================================================
#
#                              假设二：股指涨跌幅小
#
# =============================================================================

etf['pct_chg'] = etf['pct_chg'].apply(lambda x: -1*x if x<0 else x)
etf['pct_chg'] = etf['pct_chg'].apply(lambda x: 5.625 if x>5 else x)
plt.figure(figsize=(12,4))
plt.hist(etf['pct_chg'],bins=25)
plt.xticks(np.linspace(0,5,11))
plt.xlabel('涨跌幅绝对值（%）')
plt.ylabel('频数')
plt.title('假设二：股指涨跌幅小')

#%% ===========================================================================
#
#                       假设三：隐含波动率与股指价格呈正相关
#
# =============================================================================

print("皮尔逊相关系数为："+str(VIX['VIX'].corr(etf['pre_close'])))

plt.figure(figsize=(12,4))
plt.plot(VIX["trade_date"],VIX["VIX"],label="隐含波动率")
plt.title("假设三：隐含波动率与股指价格呈正相关")
plt.legend(bbox_to_anchor=(0,0),loc=3)
plt.xticks(xticks,rotation=60)
ax = plt.twinx()
ax.plot(etf["trade_date"],etf["pre_close"],color='darkorange',label="股指价格")
ax.legend(bbox_to_anchor=(0,1),loc=2)
ax.set_xticks(xticks)