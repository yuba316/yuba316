# -*- coding: utf-8 -*-
"""
Created on Fri Mar 20 09:12:07 2020

@author: yuba
"""

import copy
import datetime
import numpy as np
import pandas as pd
IC = pd.read_excel(r"E:\200221_江海证券\other\指数低开\处理后的ICIH主连数据.xlsx",sheet_name='IC')
IH = pd.read_excel(r"E:\200221_江海证券\other\指数低开\处理后的ICIH主连数据.xlsx",sheet_name='IH')

import talib as ta

import matplotlib.pyplot as plt
from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()

from pyfinance.ols import PandasRollingOLS

#%%

def getIndex(index):
    df = copy.deepcopy(index)
    df['T1_C'] = df['close'].shift(-1)
    df['T2_C'] = df['close'].shift(-2)
    df['T1_O'] = df['open'].shift(-1)
    df['T2_O'] = df['open'].shift(-2)
    
    return df[['trade_date','close','open','T1_C','T2_C','T1_O','T2_O']]

def getSignal(index): # 在此处定义因子
    df = copy.deepcopy(index)
    
    df['pre_close'] = df['close'].shift(1)
    df['HnLOpen'] = (df['open']-df['pre_close'])/df['pre_close']
    
    df['period'] = df['close'].rolling(window=10).mean()
    df['MA'] = (df['close']-df['period'])/df['period']
    
    df['DIF'] = df['close'].ewm(min_periods=12,adjust=False,alpha=2/(1+12)).mean()-df['close'].ewm(min_periods=26,adjust=False,alpha=2/(1+26)).mean()
    df['DEA'] = df['DIF'].ewm(min_periods=9,adjust=False,alpha=2/(1+9)).mean()
    df['macd'] = 2*(df['DIF']-df['DEA'])
    #df['macd'] = ta.MACD(df['close'],12,26,9)[2]
    
    df['max'] = df.apply(lambda x: max(x['close']-x['pre_close'],0),axis=1)
    df['abs'] = df.apply(lambda x: abs(x['close']-x['pre_close']),axis=1)
    df['RSI'] = 100*df['max'].ewm(min_periods=14,adjust=False,alpha=2/(1+14)).mean()/df['abs'].ewm(min_periods=14,adjust=False,alpha=2/(1+14)).mean()
    #df['RSI'] = ta.RSI(df['close'],14)
    
    df['ATR'] = (ta.ATR(df['high'],df['low'],df['close'],10))/df['period']
    df['ADX'] = ta.ADX(df['high'],df['low'],df['close'],14)
    
    df['buy'] = df.apply(lambda x: max(x['high']-x['pre_close'],0),axis=1)+df['close']-df['low']
    df['sell'] = df['buy']+df.apply(lambda x: max(x['pre_close']-x['low'],0),axis=1)+df['high']-df['close']
    df['dmkTD'] = df['buy'].rolling(window=9).sum()/df['sell'].rolling(window=9).sum()
    
    df['pre_low'] = df['low'].shift(1)
    df['l_max'] = df.apply(lambda x: max(x['low']-x['pre_low'],0),axis=1)
    df['l_abs'] = df.apply(lambda x: abs(x['low']-x['pre_low']),axis=1)
    df['sma'] = df['l_abs'].rolling(window=3).mean()/df['l_max'].rolling(window=3).mean()*1000
    df['ema'] = df['sma'].ewm(min_periods=3,adjust=False,alpha=2/(1+3)).mean()
    df['ll'] = df['low'].rolling(window=13).min()
    df['hh'] = df['ema'].rolling(window=13).max()
    df['turn'] = df.apply(lambda x: (x['ema']+x['hh']*2)/2 if x['low']<=x['ll'] else 0,axis=1)
    df['turn'] = df['turn'].ewm(min_periods=3,adjust=False,alpha=2/(1+3)).mean()/618
    df['turn'] = df['turn'].apply(lambda x: 500 if x>500 else x)
    
    df['low_n'] = df['low'].rolling(window=9).min()
    df['high_n'] = df['high'].rolling(window=9).max()
    df['RSV'] = (df['close']-df['low_n'])/(df['high_n']-df['low_n'])*100
    n = len(df)
    K,D,J = [],[],[]
    for i in range(n):
        if df['RSV'].isnull().iloc[i]:
            K.append(50)
            D.append(50)
            J.append(np.nan)
        else:
            K.append(K[-1]*2/3+df['RSV'].iloc[i]/3)
            D.append(D[-1]*2/3+K[-1]/3)
            J.append(3*K[-1]-2*D[-1])
    df['K'] = K
    df['D'] = D
    df['KDJ'] = J
    df['KDJ_1'] = df['KDJ'].shift(1)
    df['KDJ_2'] = df['KDJ'].shift(2)
    df['turn'] = df.apply(lambda x: x['turn'] if ((x['KDJ']>x['KDJ_1']) and (x['KDJ_2']>x['KDJ_1'])) else 0, axis=1)
    
    df['DAY'] = df.index
    up,dw,mid = PandasRollingOLS(df['high'],df['DAY'],15),PandasRollingOLS(df['low'],df['DAY'],15),PandasRollingOLS(df['close'],df['DAY'],15)
    df['upA'],df['upB'],df['dwA'],df['dwB'],df['midA'],df['midB'] = up.alpha,up.beta,dw.alpha,dw.beta,mid.alpha,mid.beta
    df['err_up'] = (df['high']-df['DAY']*df['upB']-df['upA'])/df['high']
    df['err_dw'] = (df['high']-df['DAY']*df['dwB']-df['dwA'])/df['high']
    df['err_mid'] = (df['high']-df['DAY']*df['midB']-df['midA'])/df['high']
    
    df['meanHigh'] = (df['close']-df['high'].rolling(window=15).mean())/df['close']
    df['meanLow'] = (df['close']-df['low'].rolling(window=15).mean())/df['close']
    
    df['rtn'] = (df['close']-df['pre_close'])/df['pre_close']
    df['dwrtn'] = df['rtn'].apply(lambda x: 0 if x>0 else x)
    df['negILLIQ'] = df['dwrtn']/df['volume']
    df['negILLIQ'] = 10**5*df['negILLIQ'].rolling(window=20).sum()/(df['dwrtn']<0).rolling(window=20).sum()
    
    df['rng'] = (df['high']-df['low'])/df['pre_close']
    df['ILLIQ'] = df['rng'].rolling(window=10).mean()
    df['cvILLIQ'] = df['rng'].rolling(window=20).std()/df['rng'].rolling(window=20).mean()
    
    df['vol_quantile'] = df['volume'].rolling(window=40).quantile(.75, interpolation='lower')
    df['vol_max'] = df.apply(lambda x: x['volume'] if x['volume']>x['vol_quantile'] else x['vol_quantile'],axis=1)
    df['vol_increase'] = (df['volume']-df['vol_quantile'])/df['vol_max']
    
    return df[['trade_date','pre_close','HnLOpen','MA','macd','RSI','ATR','ADX','dmkTD','turn',\
               'err_up','err_dw','err_mid','meanHigh','meanLow','negILLIQ','cvILLIQ','ILLIQ','vol_increase']]

#%%

def getReturn(index,signal,x='HnLOpen',xrange=[-0.01,-0.005,0,0.005,0.01]):
    df = pd.merge(index,signal[['trade_date','pre_close',x]],how='left',on='trade_date')
    df.dropna(inplace=True)
    df.reset_index(drop=True,inplace=True)
    
    n = len(xrange)
    range_name = ['≤'+str(xrange[0])]
    range_index = [df[df[x]<=xrange[0]].index]
    for i in range(n-1):
        range_name.append('('+str(xrange[i])+','+str(xrange[i+1])+']')
        range_index.append(df[(df[x]>xrange[i])&(df[x]<=xrange[i+1])].index)
    range_name.append('>'+str(xrange[-1]))
    range_index.append(df[df[x]>xrange[-1]].index)
    
    range_return = {}
    trade_date = [df['trade_date'].loc[0]-datetime.timedelta(days=1)]+list(df['trade_date'])
    original = df['pre_close'].loc[0]
    m = len(df)
    for i in range(n+1):
        index,CC,CO,OC,OO,OCgap1 = [original],[original],[original],[original],[original],[original]
        for j in range(m):
            if j in range_index[i]:
                index.append(df['close'].loc[j]/df['pre_close'].loc[j])
                CC.append((df['close'].loc[j]+df['T1_C'].loc[j]-df['close'].loc[j])/df['pre_close'].loc[j])
                CO.append((df['close'].loc[j]+df['T1_O'].loc[j]-df['close'].loc[j])/df['pre_close'].loc[j])
                OC.append((df['close'].loc[j]+df['T1_C'].loc[j]-df['T1_O'].loc[j])/df['pre_close'].loc[j])
                OO.append((df['close'].loc[j]+df['T2_O'].loc[j]-df['T1_O'].loc[j])/df['pre_close'].loc[j])
                OCgap1.append((df['close'].loc[j]+df['T2_C'].loc[j]-df['T2_O'].loc[j])/df['pre_close'].loc[j])
            else:
                index.append(df['close'].loc[j]/df['pre_close'].loc[j])
                CC.append(index[-1])
                CO.append(index[-1])
                OC.append(index[-1])
                OO.append(index[-1])
                OCgap1.append(index[-1])
        profit = pd.DataFrame({'trade_date':trade_date,'CC':CC,'CO':CO,'OC':OC,'OO':OO,'OCgap1':OCgap1,'index':index})
        profit[['CC','CO','OC','OO','OCgap1','index']] = profit[['CC','CO','OC','OO','OCgap1','index']].cumprod()
        profit[['CC','CO','OC','OO','OCgap1','index']] = profit[['CC','CO','OC','OO','OCgap1','index']].apply(lambda x: x/x['index'],axis=1)
        range_return[range_name[i]] = profit
    
    profit_return = {}
    index_name = ['CC','CO','OC','OO','OCgap1']
    for i in index_name:
        profit = range_return[range_name[0]][['trade_date',i]]
        profit.rename(columns={i:range_name[0]},inplace=True)
        for j in range_name[1:]:
            profit = pd.concat([profit,range_return[j][i]],axis=1)
            profit.rename(columns={i:j},inplace=True)
        profit_return[i] = profit
    
    return profit_return

#%%

def Stat(index):
    df = copy.deepcopy(index)
    df['last'] = df.iloc[:,1].shift(1)
    df = df.fillna(method='ffill',axis=1)
    df['profit'] = (df.iloc[:,1]-df['last'])/df['last']
    dw_profit = list(df[df['profit']<0]['profit'])
    trade_date = list(df.iloc[:,0])
    profit = list(df.iloc[:,1])
    n = (trade_date[-1]-trade_date[0]).days
    
    stat = {}
    stat['累计收益率'] = (profit[-1]-profit[0])/profit[0]*100
    stat['年化收益率'] = stat['累计收益率']/n*365
    stat['年化波动率'] = np.std(df['profit'])*np.sqrt(252)
    stat['年化下偏波动率'] = np.std(dw_profit)*np.sqrt(252)
    stat['夏普比率'] = (stat['年化收益率']/100)/stat['年化波动率']
    stat['索提诺比率'] = (stat['年化收益率']/100)/stat['年化下偏波动率']
    stat['日胜率'] = len(df[df['profit']>0])/(len(df)-1-len(df[df['profit']==0]))
    
    index_j = np.argmax(np.maximum.accumulate(profit) - profit)
    index_i = np.argmax(profit[:index_j])
    stat['最大回撤'] = (profit[index_i] - profit[index_j])
    stat['回撤起始'] = trade_date[index_i]
    stat['回撤结束'] = trade_date[index_j]
    stat['卡玛比率'] = stat['年化收益率']/(100*stat['最大回撤'])
    stat = pd.Series(stat)
    
    return stat

#%%

def getReport(profit):
    index_name = list(profit.keys())
    range_name = list(profit['CC'].columns[1:])
    stat = {}
    for i in index_name:
        series = Stat(profit[i][['trade_date',range_name[0]]])
        series.rename(range_name[0],inplace=True)
        for j in range_name[1:]:
            series = pd.concat([series,Stat(profit[i][['trade_date',j]])],axis=1)
            series.rename(columns={0:j},inplace=True)
        stat[i] = series
    
    return stat

def Visualize(profit,xrange):
    index = list(profit.keys())
    plt.figure(figsize=(12,4))
    for i in index:
        plt.plot(profit[i]['trade_date'],profit[i][xrange],label=i)
    plt.legend(loc='upper left')
    

def save2excel(path,profit,stat):
    writer = pd.ExcelWriter(path)
    sheet_name = profit.keys()
    for i in sheet_name:
        profit[i].to_excel(writer, sheet_name=str(i),index=False)
    sheet_name = stat.keys()
    for i in sheet_name:
        stat[i].to_excel(writer, sheet_name='汇总'+str(i))
    writer.save()

#%%

index = getIndex(IC)
signal = getSignal(IC)
'''
profit_HnLOpen = getReturn(index,signal)
stat_HnLOpen = getReport(profit_HnLOpen)
save2excel(r"E:\200221_江海证券\other\指数低开\高低开.xlsx",profit_HnLOpen,stat_HnLOpen)
profit_RSI = getReturn(index,signal,'RSI',[20,40,50,60,80])
stat_RSI = getReport(profit_RSI)
save2excel(r"E:\200221_江海证券\other\指数低开\RSI.xlsx",profit_RSI,stat_RSI)
profit_TD = getReturn(index,signal,'dmkTD',[0.4,0.5,0.55,0.6,0.7])
stat_TD = getReport(profit_TD)
save2excel(r"E:\200221_江海证券\other\指数低开\TD.xlsx",profit_TD,stat_TD)
profit_turn = getReturn(index,signal,'turn',[0.1,1])
stat_turn = getReport(profit_turn)
save2excel(r"E:\200221_江海证券\other\指数低开\turn.xlsx",profit_turn,stat_turn)
profit_MA = getReturn(index,signal,'MA',[-0.04,-0.02,0,0.02,0.04])
stat_MA = getReport(profit_MA)
save2excel(r"E:\200221_江海证券\other\指数低开\MA.xlsx",profit_MA,stat_MA)
profit_ATR = getReturn(index,signal,'ATR',[0.02,0.025,0.03,0.035,0.04])
stat_ATR = getReport(profit_ATR)
save2excel(r"E:\200221_江海证券\other\指数低开\ATR.xlsx",profit_ATR,stat_ATR)
profit_ADX = getReturn(index,signal,'ADX',[15,20,25,30,35])
stat_ADX = getReport(profit_ADX)
save2excel(r"E:\200221_江海证券\other\指数低开\ADX.xlsx",profit_ADX,stat_ADX)
profit_mid = getReturn(index,signal,'err_mid',[0.01])
stat_mid = getReport(profit_mid)
save2excel(r"E:\200221_江海证券\other\指数低开\high-mid.xlsx",profit_mid,stat_mid)
profit_meanHigh = getReturn(index,signal,'meanHigh',[-0.075,-0.035,0])
stat_meanHigh = getReport(profit_meanHigh)
save2excel(r"E:\200221_江海证券\other\指数低开\meanHigh.xlsx",profit_meanHigh,stat_meanHigh)
profit_cvILLIQ = getReturn(index,signal,'cvILLIQ',[0.52])
stat_cvILLIQ = getReport(profit_cvILLIQ)
save2excel(r"E:\200221_江海证券\other\指数低开\cvILLIQ.xlsx",profit_cvILLIQ,stat_cvILLIQ)
profit_vol = getReturn(index,signal,'vol_increase',[-0.1,-0.05,0,0.07])
stat_vol = getReport(profit_vol)
save2excel(r"E:\200221_江海证券\other\指数低开\volume.xlsx",profit_vol,stat_vol)
'''
#%%
profit_ILLIQ = getReturn(index,signal,'ILLIQ',[0.014,0.024,0.04]) # 计算一个叫ILLIQ的因子在[0.014-0.04]各个区间内累计收益情况
stat_ILLIQ = getReport(profit_ILLIQ)
# save2excel(r"E:\200221_江海证券\other\指数低开\ILLIQ.xlsx",profit_ILLIQ,stat_ILLIQ)

#%%
Visualize(profit_ILLIQ,'≤0.014')
Visualize(profit_ILLIQ,'(0.014,0.024]')
Visualize(profit_ILLIQ,'(0.024,0.04]')
Visualize(profit_ILLIQ,'>0.04')