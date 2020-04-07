# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 21:30:48 2020

@author: yuba316
"""

import copy
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv(r"E:\Python\机器学习\案例\案例1-银行理财销售提升\preprocess.csv")
df = copy.deepcopy(data)
df.drop('CUST_ID',axis=1,inplace=True)

#%% ===========================================================================
#
#                                  1. PCA降维
#
# =============================================================================

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

scaler = StandardScaler()
scaler.fit(df)
scaled_df = scaler.transform(df) # 标准化
pca = PCA(n_components=0.9)
pca.fit(scaled_df)
pca_scaled_df = pca.transform(scaled_df) # 降维

plt.figure(figsize=(8,4))
plt.scatter(pca_scaled_df[:,0],pca_scaled_df[:,1])
plt.xlabel("first principal component")
plt.ylabel("second principal component")

pca_scaled_df = pd.DataFrame(pca_scaled_df)

#%% ===========================================================================
#
#                                  2. 聚类分析
#
# =============================================================================

from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

K,meandistortions = range(2,20,1),[]
for k in K:
    KM = KMeans(n_clusters=k,n_init=5)
    KM.fit(pca_scaled_df)
    meandistortions.append(sum(np.min(cdist(pca_scaled_df,KM.cluster_centers_,'euclidean'),axis=1))/np.array(pca_scaled_df).shape[0])
plt.figure(figsize=(8,4))
plt.plot(K,meandistortions,'-o')
plt.xlabel('k')
plt.ylabel('平均畸变程度')
plt.xticks(K)
plt.title('用肘部法则来确定最佳的K值')
plt.show()

KM = KMeans(n_clusters=7,n_init=5,random_state=20200219)
KM.fit(pca_scaled_df)
plt.figure(figsize=(8,4))
plt.scatter(pca_scaled_df.values[:,0],pca_scaled_df.values[:,2],c=KM.labels_)
plt.xlabel("first principal component")
plt.ylabel("third principal component")
label = KM.labels_

#%% ===========================================================================
#
#                                  3. 特征提取
#
# =============================================================================

from sklearn.model_selection import train_test_split
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.feature_selection import SelectFromModel

df_train,df_test,label_train,label_test = train_test_split(df.values,label,test_size=0.2)
ET = ExtraTreesClassifier()
ET = ET.fit(df_train,label_train)
ET.feature_importances_
select = SelectFromModel(ET,prefit=True)
selected_df_train = select.transform(df_train)
selected_df_test = select.transform(df_test)
feature = df.columns[select.get_support()]

#%% ===========================================================================
#
#                                  4. 逻辑回归
#
# =============================================================================

from sklearn.linear_model import Ridge
from sklearn.metrics import r2_score

ridge_models = {}
training_scores = []

for alpha in [100, 10, 1, .01]:
    ridge = Ridge(alpha=alpha).fit(selected_df_train, label_train)
    training_scores.append(ridge.score(selected_df_train, label_train))
    ridge_models[alpha] = ridge

plt.figure(figsize=(8,4))
plt.plot(training_scores, label="training scores")
plt.xticks(range(4), [100, 10, 1, .01])
plt.xlabel('alpha')
plt.legend(loc="best")
#%%
intercept,coef = ridge_models[1].intercept_,ridge_models[1].coef_
label_test_pred = ridge_models[1].predict(selected_df_test)
print("R-squared: "+str(r2_score(label_test,label_test_pred)))
#%%
data = data[['CUST_ID']+list(feature)]
data.to_csv(r"E:\Python\机器学习\案例\案例1-银行理财销售提升\final.csv",index=False)