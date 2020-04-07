# -*- coding: utf-8 -*-
"""
Created on Sat Feb 29 20:34:18 2020

@author: yuba316
"""

import numpy as np
import pandas as pd
from scipy.stats import norm
import datetime

import talib as ta
import tushare as ts
pro = ts.pro_api("f6233ac191e0221b30736b8cbca6dc232b2824b217ef4a2bfd97d798")

#%%

def GetOP(code='OP510050.SH',date='20200122',CoP='C'):
    option = pro.opt_basic(exchange='SSE', fields='ts_code,exercise_price,list_date,call_put,maturity_date,opt_code')
    option = option[(option['opt_code']==code)&(option['maturity_date']==date)&(option['call_put']==CoP)]
    option.drop(['call_put','maturity_date','opt_code'],axis=1,inplace=True)
    option.sort_values(by="exercise_price",inplace=True)
    option.drop(option[(option["exercise_price"]*1000%10)!=0.0].index,inplace=True) # 删除执行价不合规的记录
    option.reset_index(drop=True,inplace=True)
    return option

def GetOP_quote(code,start_date='20191231',end_date='20200122',field='trade_date,close'):
    quote = pro.opt_daily(ts_code=code,start_date=start_date,end_date=end_date,fields=field).sort_values(by='trade_date').reset_index(drop=True).rename(columns={'close':code})
    return quote

option = GetOP()
option_list = list(option['ts_code'])
option_K = list(option['exercise_price'])
option_quote = GetOP_quote(option_list[0])
for i in option_list[1:]:
    quote = GetOP_quote(i)
    option_quote = pd.merge(option_quote,quote,how='left',on='trade_date')

#%%

etf = pro.fund_daily(ts_code='510050.SH', start_date='20191001', end_date='20200122', fields='trade_date,close').sort_values(by='trade_date').reset_index(drop=True)
etf['sigma'] = ta.STDDEV(etf['close'],30)
etf = etf[etf['trade_date']>='20191231'].reset_index(drop=True).rename(columns={'close':'S0'})
rf = pro.shibor(start_date='20191231', end_date='20200122', fields='date,1y').rename(columns={'date':'trade_date','1y':'rf'})
rf['rf'] = rf['rf'].apply(lambda x: 0.01*x)
etf = pd.merge(etf,rf,how='left',on='trade_date')
etf['T'] = etf['trade_date'].apply(lambda x: (datetime.datetime.strptime('20200122','%Y%m%d')-datetime.datetime.strptime(x,'%Y%m%d')).days/365)
etf = pd.merge(etf,option_quote,how='left',on='trade_date')
n = len(option_K)
for i in range(n):
    etf[option_list[i]+'_K']=option_K[i]

#%%

def BSM_Price(S0,rf,sigma,T,K):
    d1 = (np.log(S0/K)+(rf+0.5*sigma**2)*T)/(sigma*np.sqrt(T))
    d2 = (np.log(S0/K)+(rf-0.5*sigma**2)*T)/(sigma*np.sqrt(T))
    Price = (S0*norm.cdf(d1,0,1)-K*np.exp(-rf*T)*norm.cdf(d2,0,1))
    return Price

def BSM_Vega(S0,rf,sigma,T,K):
    d1 = (np.log(S0/K)+(rf+0.5*sigma**2)*T)/(sigma*np.sqrt(T))
    Vega = S0*norm.cdf(d1,0,1)*np.sqrt(T)
    return Vega

def BSM_VIX(S0,rf,sigma,T,K,C0,n=100):
    for i in range(n):
        sigma = sigma-(BSM_Price(S0,rf,sigma,T,K)-C0)/BSM_Vega(S0,rf,sigma,T,K)
    return sigma

#%%

option_K = option_K[:9]
option_list = option_list[:9]

VIX={'trade_date':list(etf['trade_date'])}
n = len(option_K)
for i in range(n):
    VIX[option_list[i]] = etf.apply(lambda x: BSM_VIX(x['S0'],x['rf'],x['sigma'],x['T'],x[option_list[i]+'_K'],x[option_list[i]]),axis=1)
VIX=pd.DataFrame(VIX)
VIX['T'] = VIX['trade_date'].apply(lambda x: (datetime.datetime.strptime('20200122','%Y%m%d')-datetime.datetime.strptime(x,'%Y%m%d')).days)
VIX = VIX[VIX['T']>=7]
VIX.fillna(method='ffill',inplace=True)

#%%

X = np.array(option_K*11).reshape(11,9)
Y = list(VIX['T'])*9
Y.sort(reverse=True)
Y = np.array(Y).reshape(11,9)
Z = VIX.iloc[:,1:10].values

from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = Axes3D(fig)
ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap='rainbow')
plt.show()