#include <iostream>
using namespace std;
int n;
//The number of periods;
double p,q,r;
//The probabilities of head and tail and an interest rate;
double u,d;
//The multiple for head and tail;

double V_H(int T,double M,double S);
double V_T(int T,double M,double S);
//Define 2 functions for calculating the price of the derivative security at time i;

int main(){
    double V0;
    cout<<"�������Ʊ���Ǹ���p��"<<endl;
    cin>>p;
    q=1-p;
    cout<<"�������Ʊ���Ǳ���u��"<<endl;
    cin>>u;
    cout<<"�������Ʊ�µ�����d��"<<endl;
    cin>>d;
    cout<<"����������r��"<<endl;
    cin>>r;
    cout<<"������Ҫ���������֤ȯ����N��"<<endl;
    cin>>n;
    double S,M;
    cout<<"�������ڳ���Ʊ�۸�S0��"<<endl;
    cin>>S;
    M=S;
    V0=(p*V_H(1,M,S)+q*V_T(1,M,S))/(1+r);
    cout<<"�ڳ�����֤ȯ�۸�ΪV0��"<<endl;
    cout<<V0;
    return 0;
}

//Function for calculating the head price of the derivative security;
double V_H(int T,double M,double S){
    double V;
    if(M<=u*S){M=u*S;}
    S=u*S;
    if(T==n){V=M-S;}
    else V=(p*V_H(T+1,M,S)+q*V_T(T+1,M,S))/(1+r);
    return V;
}

//Function for calculating the tail price of the derivative security;
double V_T(int T,double M,double S){
    double V;
    if(M<=d*S){M=d*S;}
    S=d*S;
    if(T==n){V=M-S;}
    else V=(p*V_H(T+1,M,S)+q*V_T(T+1,M,S))/(1+r);
    return V;
}
