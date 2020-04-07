#include <iostream>
using namespace std;
int n;
//The number of periods;
double p,q,r;
//The probabilities of head and tail and an interest rate;
double u,d;
//The multiple for head and tail;
double S0;
//The stock price at time zero;

double V_H(int T,double Y,double S);
double V_T(int T,double Y,double S);
//Define 2 functions for calculating the price of the derivative security at time i;

int main(){
    double V0;
    cout<<"请输入股票上涨概率p："<<endl;
    cin>>p;
    q=1-p;
    cout<<"请输入股票上涨倍数u："<<endl;
    cin>>u;
    cout<<"请输入股票下跌倍数d："<<endl;
    cin>>d;
    cout<<"请输入利率r："<<endl;
    cin>>r;
    cout<<"请输入要计算的衍生证券期数N："<<endl;
    cin>>n;
    double S,Y;
    cout<<"请输入期初股票价格S0："<<endl;
    cin>>S;
    Y=S;
    S0=S;
    V0=(p*V_H(1,Y,S)+q*V_T(1,Y,S))/(1+r);
    cout<<"期初衍生证券价格为V0："<<endl;
    cout<<V0;
    return 0;
}

//Function for calculating the head price of the derivative security;
double V_H(int T,double Y,double S){
    double V;
    S=u*S;
    Y=Y+S;
    if(T==n){
        if(Y/(n+1)-S0>=0){V=Y/(n+1)-S0;}
        else V=0;
    }
    else V=(p*V_H(T+1,Y,S)+q*V_T(T+1,Y,S))/(1+r);
    return V;
}

//Function for calculating the tail price of the derivative security;
double V_T(int T,double Y,double S){
    double V;
    S=d*S;
    Y=Y+S;
    if(T==n){
        if(Y/(n+1)-S0>=0)V=Y/(n+1)-S0;
        else V=0;
    }
    else V=(p*V_H(T+1,Y,S)+q*V_T(T+1,Y,S))/(1+r);
    return V;
}
