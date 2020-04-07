"""
@title : 百度指数获取
@major : 2016级金融工程
@author: 郑宇浩41621101
"""

import pandas as pd
import tushare as ts
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import matplotlib.pyplot as plt

#%% 数据导入

index_ts=pd.read_excel("E:\Python\data_analysis\情感分析与股价趋势\百度指数获取\百度指数.xlsx",index_col=0)
index_word=index_ts.columns
stock_300=list(reversed(list(ts.get_hist_data("hs300",'2014-03-03','2016-02-29','W')['close'])))

#%% 数据处理

for i in index_word:
    new_name=" "+i
    index_ts[new_name]=index_ts[i].rolling(window=4).mean()

index_word_mavg=index_ts.columns[8:]

#%% 时差相关系数

n=len(index_word_mavg)
ahead_corr={}
for i in index_word_mavg:
    corr=0
    ahead=0
    for j in range(1,10,1):
        matrix=np.array([stock_300[3+j:],index_ts[i][3:-j]])
        if(abs(np.corrcoef(matrix)[0,1])>abs(corr)):
            corr=np.corrcoef(matrix)[0,1]
            ahead=j
    ahead_corr[i]=[corr,ahead]
sort=sorted(ahead_corr.items(),key=lambda x:x[1],reverse=True)
new_ahead_corr={}
for i in range(n):
    new_ahead_corr[sort[i][0]]=sort[i][1]

lag_corr={}
for i in index_word_mavg:
    corr=0
    lag=0
    for j in range(1,10,1):
        matrix=np.array([stock_300[3:-j],index_ts[i][3+j:]])
        if(abs(np.corrcoef(matrix)[0,1])>abs(corr)):
            corr=np.corrcoef(matrix)[0,1]
            lag=j
    lag_corr[i]=[corr,lag]
sort=sorted(lag_corr.items(),key=lambda x:x[1],reverse=True)
new_lag_corr={}
for i in range(n):
    new_lag_corr[sort[i][0]]=sort[i][1]

new_ahead_corr

#%% 利用随机森林实现特征选择

n=len(index_ts.index)
m=len(index_word_mavg)
data=np.zeros(shape=(n-4,m))
for i in range(4,n,1):
    for j in range(m):
        increase=(index_ts[index_word_mavg[j]][i]-index_ts[index_word_mavg[j]][i-1])/index_ts[index_word_mavg[j]][i-1]
        data[i-4][j]=increase

target=np.zeros(n-1)
for i in range(1,n,1):
    increase=(stock_300[i]-stock_300[i-1])/stock_300[i-1]
    if(increase<=0.02 and increase>=-0.02):
        target[i-1]=0
    elif(increase>0):
        if(increase<=0.06):
            target[i-1]=1
        else:
            target[i-1]=2
    else:
        if(increase>=-0.06):
            target[i-1]=-1
        else:
            target[i-1]=-2

score={}
forest=RandomForestClassifier(n_estimators=10000,random_state=0,n_jobs=1)
forest.fit(data,target[3:])
importance=forest.feature_importances_
index_word_mavg=index_word_mavg[importance.argsort()]
importance.sort()
for i in range(m):
    score[index_word_mavg[m-1-i]]=importance[m-1-i]

score

#%% 数据可视化

plt.rcParams['font.sans-serif']=['SimHei']
plt.rcParams['axes.unicode_minus']=False
plt.bar(range(m),importance,align='center')
plt.xticks(range(m),index_word_mavg,rotation=60)
plt.xlim([-1,m])
plt.tight_layout()
plt.show()