# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 08:34:30 2020

@author: yuba316
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv(r"E:\Python\机器学习\案例\案例1-银行理财销售提升\original.csv")

#%% ===========================================================================
#
#                               0. 数据预处理模块
#
# =============================================================================

#%% 0.1 缺失值查找
nan_col = data.isna().any() # 可列出每一列的缺失值情况
print('有'+str(np.sum(nan_col))+'个带缺失值的列')

#%% 0.2 类别变量处理
# 0.2.1 消除每一行都一样的列
n = data.shape[1]
col = data.columns
col_name = []
col_num = []
col_type = []
col_delete = []
for i in range(n):
    num = len(data[col[i]].unique())
    if num==1:
        col_delete.append(col[i])
    else:
        col_name.append(col[i])
        col_num.append(num)
        col_type.append(str(data[col[i]].dtypes))
data.drop(col_delete,axis=1,inplace=True) # 简单删除所有行都相同的列
col_summary = pd.DataFrame({'name':col_name,'num':col_num,'type':col_type})
#%% 0.2.2 规范化二元类别变量
col_dummy_2 = list(col_summary[(col_summary.num==2)&(col_summary.type=='object')].name)
col_dummy_2_unique = {}
for i in col_dummy_2:
    col_dummy_2_unique[i] = data[i].unique()
print(col_dummy_2_unique.values()) # 经观察发现，所有二元类别变量都含有'N'表示False，而表示True的方法不同
data[col_dummy_2] = data[col_dummy_2].applymap(lambda x: 0 if x=='N' else 1) # 将二元类别变量转为0/1表示
#%% 0.2.3 规范化多元类别变量
col_dummy_n = list(col_summary[(col_summary.num>2)&(col_summary.type=='object')].name)
col_dummy_n_unique = {}
for i in col_dummy_n:
    col_dummy_n_unique[i] = data[i].unique()
print(col_dummy_n_unique) # 比较幸运的是只有8个多元类别变量，其中有一些还可化为二元
FUND = ['C_FUND_FLAG','D_FUND_FLAG','S_FUND_FLAG']
data[FUND] = data[FUND].applymap(lambda x: 1 if x=='1' else 0) # 基金的False会表示成'0'和'N'，统一转为0/1表示
data['GENDER'] = data['GENDER'].apply(lambda x: 1 if (x==1 or x=='1') \
    else (0 if (x==0 or x=='0') else np.random.randint(2))) # 性别中存在极少量的未知值'X'，用随机生成的01值代替
LEVEL = ['IDF_TYP_CD','TOP_CARD_LEVEL','CUST_VALUE_CLASS','OCN']
print(data[LEVEL].describe()) # IDF_TYP_CD中'ZR01'占了绝大多数，所以可以将其处理成二元类别变量
data['IDF_TYP_CD'] = data['IDF_TYP_CD'].apply(lambda x: 1 if x=='ZR01' else 0)
print(data.TOP_CARD_LEVEL.value_counts()) # 可能是序数特征
print(data.CUST_VALUE_CLASS.value_counts()) # 可能是标称特征
print(data.OCN.value_counts()) # 不知道是什么鬼
data['TOP_CARD_LEVEL'] = data['TOP_CARD_LEVEL'].apply(lambda x: int(x) if x!='#' else 7) # 未知等级顺位令为7
data['CUST_VALUE_CLASS'] = data['CUST_VALUE_CLASS'].apply(lambda x: ord(x)-65) # 将英文等级转换为对应的ASCII代码值
data['OCN'] = data['OCN'].apply(lambda x: int(x) if x!='X' else 0) # 将未知数转为0

#%% 0.3 降维
def summary(data):
    n = data.shape[1]
    col_num = []
    col_type = []
    col_most = []
    col_freq = []
    for i in range(n):
        frequency = data[col_name[i]].value_counts()
        col_num.append(len(frequency))
        col_type.append(str(data[col_name[i]].dtypes))
        col_most.append(frequency.index[0])
        col_freq.append(frequency.iloc[0])
    col_summary = pd.DataFrame({'name':col_name,'num':col_num,'most':col_most,'freq':col_freq,'type':col_type})
    return col_summary
col_summary = summary(data)
#%% 0.3.1 奇异值处理
decimal,outlier_num = np.logspace(-8,-1,8),[]
for i in decimal:
    outlier_num.append(len(np.where((-1*i<data.values)&(data.values<i))[0]))
plt.figure(figsize=(8,4))
plt.plot(range(-8,0,1),outlier_num,'-o')
plt.xticks(range(-8,0,1),rotation=60)
plt.title('奇异值损失图') # 存在极少数接近0的奇异值，我们将-0.001<x<0.001的奇异值化为0
float_feature = col_summary[col_summary['type']=='float64'][['most','name']].values
n = len(float_feature)
for i in range(n):
    data[float_feature[i,1]] = data[float_feature[i,1]].apply(lambda x: float_feature[i,0] if ((x>-0.001) and (x<0.001)) else x)
#%% 0.3.2 按最高频数值占比删除特征
n = len(col_summary)
col_summary = summary(data)
percent = np.linspace(0.01,0.2,20)
y = []
for i in range(20):
    y.append(n-np.sum(col_summary['freq']>80000*(1-percent[i])))
plt.figure(figsize=(8,4))
plt.plot(percent,y,'-o')
plt.xticks(percent,rotation=60)
plt.title('特征数损失图') # 不难发现，有将近一半的特征数，其频数最大的数值超过了总行数的94%，故认为是无用特征，删去
redundancy = col_summary[col_summary['freq']>80000*0.94]['name']
data.drop(redundancy,axis=1,inplace=True)
#%% 0.3.3 按相关性大小删除特征
corr = data.corr()
def delHighCorr(corr,percent):
    col,row,pct = [],[],[]
    n = len(corr)
    for i in range(n):
        for j in range(n):
            correlation = corr.iloc[j,i]
            if (correlation>percent) and (i!=j):
                col.append(corr.columns[i])
                row.append(corr.index[j])
                pct.append(correlation)
    corr = pd.DataFrame({'col':col,'row':row,'pct':pct})
    return corr

percent = np.linspace(0.5,0.9,9)
correlation = {}
for i in percent:
    correlation[i] = delHighCorr(corr,i)

y = [len(i) for i in correlation.values()]
plt.figure(figsize=(8,4))
plt.plot(percent,y,'-o')
plt.xticks(percent,rotation=60)
plt.title('相关性损失图') # 为了防止更多信息的丢失，仅对相关性>75%的特征进行删除
#%%
corr = correlation[0.75]
feature_delete = corr['col'].value_counts()
n = len(feature_delete)
y = []
for i in range(n):
    index = list(corr[corr['col']==feature_delete.index[i]].index)+list(corr[corr['row']==feature_delete.index[i]].index)
    corr.drop(index,axis=0,inplace=True)
    y.append(len(corr))
index = y.index(0) # 按照高相关性个数多的特征开始删除至无高相关性为止
feature_delete = feature_delete.index[:index]
data.drop(feature_delete,axis=1,inplace=True)
#%%
data.to_csv(r"E:\Python\机器学习\案例\案例1-银行理财销售提升\preprocess.csv",index=False)