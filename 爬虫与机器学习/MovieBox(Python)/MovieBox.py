# -*- coding: utf-8 -*-
"""
Created on Sun Mar  8 10:10:24 2020

@author: yuba
"""

import requests
import re
import pandas as pd
import numpy as np
import datetime
import calendar
from bs4 import BeautifulSoup as bs

#%% 获取年度每日票房

def get_box_by_date(date):
    url = r'http://piaofang.maoyan.com/second-box?beginDate='+date
    res = requests.get(url).json()['data']['list']
    movie_id,movie_name,movie_box = [],[],[]
    for i in res:
        movie_id.append(i['movieId'])
        movie_name.append(i['movieName'])
        movie_box.append(i['boxInfo'])
    df = pd.DataFrame({'movieId':movie_id,'movieName':movie_name,'box':movie_box})
    return df

def get_year_date(year):
    start_date = datetime.datetime.strptime(str(year)+'0101','%Y%m%d')
    isLeap = calendar.isleap(year)
    if isLeap:
        n = 366
    else:
        n = 365
    date_list = []
    for i in range(n):
        date = start_date+datetime.timedelta(days=i)
        date_list.append(datetime.datetime.strftime(date,'%Y%m%d'))
    return date_list

def get_box_by_year(year):
    date = get_year_date(year)
    box_by_date = {}
    for i in date:
        box_by_date[i] = get_box_by_date(i)
    return box_by_date

box_2018 = get_box_by_year(2018)

def get_box_series(box):
    n = len(box)
    date = list(box.keys())
    df = box[date[0]]
    df.rename(columns={'box':date[0]},inplace=True)
    for i in range(1,n,1):
        df = pd.merge(df,box[date[i]],how='outer',on=['movieId','movieName'])
        df.rename(columns={'box':date[i]},inplace=True)
    return df

box_series = get_box_series(box_2018)

#%% 获取电影详细信息

head = """
Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8
Accept-Encoding:gzip, deflate, br
Accept-Language:zh-CN,zh;q=0.8
Cache-Control:max-age=0
Connection:keep-alive
Host:maoyan.com
Upgrade-Insecure-Requests:1
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
User-Agent:Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.86 Safari/537.36
"""

def str_to_dict(head):
    header = {}
    head = head.split('\n')
    for h in head:
        h = h.strip()
        if h:
            k,v = h.split(':',1)
            header[k] = v.strip()
    return header

def get_message_by_id(movieId,header):
    url = r'https://maoyan.com/films/'+str(movieId)
    res = requests.get(url=url,headers=header)
    soup = bs(res.text,'html.parser')
    data = {}
    
    ell = soup.find_all('li',{'class': 'ellipsis'}) # 电影基础信息
    if len(ell)==0:
        data["Country_Length"] = ''
        data["Date"] = ''
    else:
        data["Country_Length"] = ell[1].get_text().replace('\n','').replace(' ','')
        data["Date"] = ell[2].get_text()[:10]
    
    name = soup.find_all('a',{'class': 'name'}) # 职员表
    celebrity = soup.find_all('div',{'class': 'celebrity-type'}) # 职务表
    celebrity_type,celebrity_num = [],[] # 职务及所属员工个数
    n,actor = len(celebrity),[]
    for i in range(n):
        type_num = celebrity[i].get_text().split('（')
        if len(type_num)==2:
            celebrity_type.append(type_num[0].replace('\n','').strip())
            celebrity_num.append(int(type_num[1].split('）')[0]))
    if not '导演' in celebrity_type:
        num_1 = 0
        data['Director'] = ''
    else:
        num_1 = celebrity_num[celebrity_type.index('导演')]
        data['Director'] = name[0].get_text().replace('\n','').strip() # 只返回第一个导演
    if not '演员' in celebrity_type:
        num_2 = 0
    else:
        num_2 = celebrity_num[celebrity_type.index('演员')]
    for i in range(min(num_2,4)): # 最多返回四个演员
        actor.append(name[i+num_1].get_text().replace('\n','').strip())
    data['Actor'] = '、'.join(actor)
    return data

movie_list = box_series[['movieId','movieName']]

def get_movie_message(movie_list,head):
    n = len(movie_list)
    df = get_message_by_id(movie_list['movieId'].iloc[0],head)
    df['movieId'] = movie_list['movieId'].iloc[0]
    df['movieName'] = movie_list['movieName'].iloc[0]
    df = pd.DataFrame(df,index=[0])
    for i in range(1,n,1):
        data = get_message_by_id(movie_list['movieId'].iloc[i],head)
        if data['Date']=='':
            print("after catching "+str(i)+" movies, the website has stopped working, please change your headers")
            df = df[['movieId','movieName','Date','Country_Length','Director','Actor']]
            df.reset_index(drop=True,inplace=True)
            return i,df
        data['movieId'] = movie_list['movieId'].iloc[i]
        data['movieName'] = movie_list['movieName'].iloc[i]
        data = pd.DataFrame(data,index=[0])
        df = pd.concat([df,data])
    df = df[['movieId','movieName','Date','Country_Length','Director','Actor']]
    df.reset_index(drop=True,inplace=True)
    return i,df

n = len(movie_list)
header = str_to_dict(head)
i,movie_message = get_movie_message(movie_list,header)
header['User-Agent'] = "User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; 360SE)"
j,df = get_movie_message(movie_list[i:],header)
movie_message = pd.concat([movie_message,df])

#%% 数据清洗与导出

movie_message['Length'] = movie_message['Country_Length'].apply(lambda x: int(x.split('/')[1].split('分')[0]) if len(x.split('/'))==2 else np.nan)
movie_message['Country'] = movie_message['Country_Length'].apply(lambda x: x.split('/')[0])

def cleanDate(date):
    pattern = re.compile(r'[\u4e00-\u9fa5]')
    date = int(re.sub(pattern, '', date).replace('-',''))
    if date<3000: # 只有上映年份
        date = str(date*10000+1231)
    elif date<300000: # 只有上映年月
        date = str(date*100+1)
    else:
        date = str(date)
    return datetime.datetime.strptime(date, '%Y%m%d')

movie_message['Date'] = movie_message['Date'].apply(cleanDate)
movie_message.drop('Country_Length',axis=1,inplace=True)