"""
@title : 微博评论获取
@major : 2016级金融工程
@author: 郑宇浩41621101
"""

import datetime
import pandas as pd
import numpy as np
import requests
import re
import jieba
import time as t

#%% 数据结构设计

date_start=datetime.datetime.strptime("2014-03-03",'%Y-%m-%d')
date_end=datetime.datetime.strptime("2016-02-29",'%Y-%m-%d')
date=[]
date.append(date_start.strftime('%Y-%m-%d'))
while date_start<date_end:
    date_start+=datetime.timedelta(days=+1)
    date.append(date_start.strftime('%Y-%m-%d'))

time=['7','9','11','13','15','17','19','21','23']
day=len(date)
hour=len(time)-1

Day=np.repeat(date,hour)
Hour=time[:-1]*day
df=pd.DataFrame({'Day':Day,'Hour':Hour})

#%% 微博评论获取

Raw=[]
for i in range(550,555,1):
    for j in range(hour):
        url=r'https://s.weibo.com/weibo/%25E8%2582%25A1%25E7%25A5%25A8%25E4%25BA%25A4%25E6%2598%2593?q=%E8%82%A1%E7%A5%A8%E4%BA%A4%E6%98%93&scope=ori&suball=1&timescope=custom:'+date[i]+'-'+time[j]+':'+date[i]+'-'+time[j+1] # 股票交易
        # url=r'https://s.weibo.com/weibo/%25E8%2582%25A1%25E7%25A5%25A8%25E4%25BB%25A3%25E7%25A0%2581?q=%E8%82%A1%E7%A5%A8%E4%BB%A3%E7%A0%81&scope=ori&suball=1&timescope=custom:'+date[i]+'-'+time[j]+':'+date[i]+'-'+time[j+1] # 股票代码
        # url=r'https://s.weibo.com/weibo?q=%E8%82%A1%E7%A5%A8%E5%B8%82%E5%9C%BA&scope=ori&suball=1&timescope=custom:'+date[i]+'-'+time[j]+':'+date[i]+'-'+time[j+1] # 股票市场
        r=requests.get(url)
        s=r.text
        Raw.append(s)
    if((i+1)%5==0):
        t.sleep(600)

#%% 数据清洗与情感分析

from string import punctuation as punc
punc=punc+" 、，；：‘’“”—。？！……【】（）《》－"
re_tag=re.compile(r'<(.*?)>')

def comment_clean(text):
    clean=re_tag.sub('',text)
    clean="".join(w for w in clean if w not in punc)
    return clean

positive=open("E:\Python\data_analysis\情感分析与股价趋势\微博评论获取\long.txt","r").read().split()
negative=open("E:\Python\data_analysis\情感分析与股价趋势\微博评论获取\short.txt","r").read().split()
deny=open("E:\Python\data_analysis\情感分析与股价趋势\微博评论获取\否定词.txt","r").read().split()

def get_score(clean):
    clean=list(jieba.cut(clean))
    pos_count=len([w for w in clean if w in positive])
    neg_count=len([w for w in clean if w in negative])
    de_count=len([w for w in clean if w in deny])
    if pos_count==0:
        if neg_count==0:
            score=0
        else:
            score=-1
    else:
        if neg_count==0:
            score=1
        else:
            langda=pos_count/neg_count
            if langda>1.5:
                score=1
            elif 1/langda>1.5:
                score=-1
            else:
                score=0
    if de_count%2!=0:
        score=0-score
    return score

#%% 情感评分

Comment=[]
Score=[]
n=len(Raw)
for i in range(n):
    s=Raw[i]
    pattern=r">\n                    (.*?)\u200b"
    result=re.findall(pattern,s)
    if(result):
        clean_comment=[]
        emotion_score=[]
        for k in result:
            clean_comment.append(comment_clean(k))
        for k in clean_comment:
            emotion_score.append(get_score(k))
        Comment.append(clean_comment)
        Score.append(emotion_score)
    else:
        Comment.append([])
        Score.append([])

#%% 数据导出

new_df=pd.DataFrame({'Day':Day[4400:4440],'Hour':Hour[4400:4440],'comment':Comment,'score':Score})
new_df.to_excel("E:\Python\data_analysis\情感分析与股价趋势\原始评论情感得分.xlsx",index=False)