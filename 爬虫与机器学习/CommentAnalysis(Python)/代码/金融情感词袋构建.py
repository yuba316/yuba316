"""
@title : 金融情感词袋构建
@major : 2016级金融工程
@author: 郑宇浩41621101
"""

import pandas as pd
import matplotlib.pyplot as plt

#%% 数据导入与清洗

import jieba
from string import punctuation as punc
punc=punc+" 、，；：‘’“”—。？！……【】（）《》－"

df=pd.read_excel(r"E:\Python\data_analysis\情感分析与股价趋势\金融情感词袋构建\个股研报.xlsx",encoding = "gb18030")

def cut_words(text):
    clean="".join(w for w in text if w not in punc)
    clean=" ".join(jieba.cut(clean))
    return clean
df["cut_words"]=df["analysis"].apply(cut_words)

#%% 金融词袋建立

from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer

X=df[["analysis"]]
X["cut_words"]=df["cut_words"]
y=df.strategy
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=20190521)

def get_custom_stopwords(stop_words_file):
    with open(stop_words_file,encoding = "utf-8-sig") as f:
        stopwords = f.read()
    stopwords_list = stopwords.split('\n')
    custom_stopwords_list = [i for i in stopwords_list]
    return custom_stopwords_list
stopwords = get_custom_stopwords("E:\Python\data_analysis\情感分析与股价趋势\金融情感词袋构建\stopwordsHIT.txt")
max_df = 0.8
min_df = 3
vect = CountVectorizer(max_df = max_df,min_df = min_df,stop_words=stopwords)
term_matrix = pd.DataFrame(vect.fit_transform(X_train.cut_words).toarray(), columns=vect.get_feature_names())
term_matrix.head()

#%% 分类模型训练

from sklearn.naive_bayes import MultinomialNB
nb = MultinomialNB()
from sklearn.pipeline import make_pipeline
pipe = make_pipeline(vect, nb)
from sklearn.model_selection import cross_val_score
cross_val_score(pipe, X_train.cut_words, y_train, cv=3, scoring='accuracy').mean()

#%% 分类模型测试

pipe.fit(X_train.cut_words, y_train)
from sklearn import metrics
y_pred = pipe.predict(X_test.cut_words)
metrics.accuracy_score(y_true = y_test,y_pred = y_pred)
#metrics.precision_score(y_true = y_test,y_pred = y_pred)
#metrics.f1_score(y_true = y_test,y_pred = y_pred)

#%% 混沌矩阵

from sklearn.metrics import confusion_matrix
import seaborn as sns

sns.set()
mat = confusion_matrix(y_test, y_pred)
sns.heatmap(mat.T, square=True, annot=True, fmt='d', cbar=False,
            xticklabels=[0,1], yticklabels = [0,1])
plt.ylabel('predict label')
plt.xlabel('true label')