#property copyright "Lorne"
#property link      "www@luotao.net"

#include <SystemManager.mqh>

//+------------------------------MA------------------------------------+
 
/*
均线交叉
-10死叉
-7下行加强
-3下行减弱
10金叉
7上行加强
3下行减弱
*/
int CheckMACross(string symbol,int timeframe,int period1,int period2,int mode,int shift)
{
   double Ma1latter=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,1+shift);
   double Ma1former=iMA(symbol,timeframe,period1,0,mode,PRICE_CLOSE,2+shift); 
   double Ma2latter=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,1+shift);
   double Ma2former=iMA(symbol,timeframe,period2,0,mode,PRICE_CLOSE,2+shift);
 
   if (Ma1former>Ma2former && Ma1latter<Ma2latter)//死叉
   {
      return(-10);
   }
   if (Ma1former<Ma2former && Ma1latter>Ma2latter)//金叉
   {
      return(10);
   }
   if (Ma1former>Ma2former && Ma1latter>Ma2latter)//上升趋势
   {
      if(Ma1latter-Ma2latter>Ma1former-Ma2former)
         return(7);
      else
         return(3);
   }
   if (Ma1former<Ma2former && Ma1latter<Ma2latter)//下降趋势
   {
      if(Ma2latter-Ma1latter>Ma2former-Ma1former)
         return(-7);
      else
         return(-3);
   }
   return(0);
}

/*
价格穿越均线  
10上穿 
-10下穿
*/
int PriceCrossMA(string symbol,int timeframe,int maperiod,int mode,int shift)
{
   double ma=iMA(symbol,timeframe,maperiod,0,mode,PRICE_CLOSE,1+shift);
   double array1[][6];
   ArrayCopyRates(array1,symbol, timeframe);
   
   double latteropen=array1[0+shift][1];
   double formerclose=array1[1+shift][1];
   
   if((latteropen<ma)&&(formerclose>ma))//下穿均线
      return(-10);
   if((latteropen>ma)&&(formerclose<ma))//上穿均线
      return(10);
   return(0);
}

//转上升10 转下降-10 一直上升5 一直下降-5
int MADirection(string symbol,int timeframe,int period,int mode,int shift)
{
   double ma0=iMA(symbol,timeframe,period,0,mode,PRICE_CLOSE,1+shift);
   double ma1=iMA(symbol,timeframe,period,0,mode,PRICE_CLOSE,2+shift);
   double ma2=iMA(symbol,timeframe,period,0,mode,PRICE_CLOSE,3+shift);
   
   if(ma2<ma1&&ma1>ma0)return(-10);
   if(ma2>ma1&&ma1>ma0)return(-5);
   if(ma2>ma1&&ma1<ma0)return(10);
   if(ma2<ma1&&ma1<ma0)return(5);
   return(0);
}

//+------------------------------Envnvelops------------------------------------+

 //检查价格是否刺穿EN8
 //向上刺穿 10
 //向下刺穿 -10
 //未刺穿  0
int CheckCrossEnv8(string symbol,int timeframe,int shift)
{
   if(Close[0]>iEnvelopes(symbol, timeframe, 8,MODE_SMA,0,PRICE_CLOSE,0.35,MODE_UPPER,shift+0))
   { 
      return(10); 
   }
   else if(Close[0]<iEnvelopes(symbol, timeframe, 8,MODE_SMA,0,PRICE_CLOSE,0.35,MODE_LOWER,shift+0))
   {
      return(-10); 
   }
   else return(0);
}

//+------------------------------MACD------------------------------------+

//返回MACD柱线数组
void GetMACDHistogam(double& Histogam[],string symbol,int timeframe,int FastEMA,int SlowEMA,int Count,int Shift)
{
   ArrayResize(Histogam,Count);
   for(int i=0; i<Count; i++)
      Histogam[i]=iMA(symbol,timeframe,FastEMA,0,MODE_EMA,PRICE_CLOSE,i+Shift)-iMA(symbol,timeframe,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i+Shift);
}

/*
MACD交叉
-10死叉
-7低位死叉
-5下行增强
-3下行减弱
10金叉
7高位金叉
5上行增强
3上行减弱
*/
int CheckMACDCross(string symbol,int timeframe,int fastEMA,int slowEMA,int signalSMA,int shift)
{
   double     ind_buffer1[];
   double     ind_buffer2[];
   for(int i=0; i<50; i++)
      ind_buffer1[i]=iMA(symbol,timeframe,fastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(symbol,timeframe,slowEMA,0,MODE_EMA,PRICE_CLOSE,i);
   for(i=0; i<50; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,signalSMA,0,MODE_SMA,i);
   //buffer1快线
   //buffer2慢线
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//MACD金叉
   {
      if(ind_buffer2[0]<0)//慢线处在0下方
         return(10);
      else
         return(7);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//MACD死叉
   {
      if(ind_buffer2[0]>0)//慢线处在0上方
         return(-10);
      else
         return(-7);
   }
   if(ind_buffer1[0+shift]>ind_buffer2[0+shift] && ind_buffer1[1+shift]>ind_buffer2[1+shift])//上升趋势
   {
      if(ind_buffer1[0+shift]-ind_buffer2[0+shift] > ind_buffer1[1+shift]-ind_buffer2[1+shift])//上升加强
         return(5);
      else//上升减弱
         return(3);
   }
   if(ind_buffer1[0+shift]<ind_buffer2[0+shift] && ind_buffer1[1+shift]<ind_buffer2[1+shift])//下降趋势
   {
      if(ind_buffer2[0+shift]-ind_buffer1[0+shift] > ind_buffer2[1+shift]-ind_buffer1[1+shift])//下降加强
         return(-5);
      else//下降减弱
         return(-3);
   }
   return(0);
}

//根据一个数组返回一个趋势指数10到-10
int GetArrayTrend(double& arr[])
{  
   double total,up;
   int cnt=ArraySize(arr);
   for(int i=0;i<cnt;i++)
   {
      if(arr[i]>0) up=up+arr[i];
      total=total+MathAbs(arr[i]);
   }
   if(total==0)return(0);
   return((up*10/total-5)*2);
}

//数组中发生了穿越某个值 上穿10 下穿-10
int GetArrCorssValue(double& arr[],int start,double value)
{
   int cnt=ArraySize(arr);
   for(int i=start;i<cnt;i++)
   {
      if(arr[i]>0 && arr[i+1]<0) return(10);
      if(arr[i]<0 && arr[i+1]>0) return(-10);
   }
   return(0);
}

//数组中发生了穿越了另一个数组 arr上穿arr2 10  arr下穿arr2 -10
int GetArrCorssArr(double& arr[],double& arr2[],int start)
{
   int cnt=ArraySize(arr);
   if(ArraySize(arr2)<cnt)cnt=ArraySize(arr2);

   for(int i=start;i<cnt;i++)
   {
      if(arr[i]>arr2[i] && arr[i+1]<arr2[i+1]) return(10);
      if(arr[i]<arr2[i] && arr[i+1]>arr2[i+1]) return(-10);
   }
   return(0);
}

void GetArrInflexion(double& arr[],double& result[][],int start=1)
{
   int arrlength=ArraySize(arr);
   ArrayResize(result,arrlength);
   int cnt;
   for(int i=start+1;i<arrlength;i++)
   {
      if(i==arrlength-2) break;
      if(arr[i]>arr[i-1] && arr[i+1]<arr[i])//顶点 -1
      {
         result[cnt][0]=-1;
         result[cnt][1]=i;
         result[cnt][2]=arr[i];
         cnt++;
      }
      if(arr[i]<arr[i-1] && arr[i+1]>arr[i])//底点 1
      {
         result[cnt][0]=1;
         result[cnt][1]=i;
         result[cnt][2]=arr[i];
         cnt++;
      }
   }
   ArrayResize(result,cnt);
}

//+------------------------------Force Index------------------------------------+
int GetForceIndexDirection(string symbol,int timeframe,int period,int shift)
{
   int result;
   double fi1=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,1+shift);
   double fi2=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,2+shift);
   double fi3=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,3+shift);
   if(MathAbs(fi1+fi2+fi3)/3>0)
   { 
      if(fi3<fi2&& fi2>fi1) result=-10;
      else if(fi3>fi2&& fi2<fi1) result=10;
      else if(fi3>fi2&& fi2>fi1) result=-5;
      else if(fi3<fi2&& fi2<fi1) result=5;
   }
   return(result);
}

//增加了一个量化值，只有在高于这个值的位置发生转向才确认
int GetForceIndexReverse(string symbol,int timeframe,int period,int shift,double threshold)
{
   int result;
   double fi1=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,1+shift);
   double fi2=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,2+shift);
   double fi3=iForce(symbol,timeframe,14,MODE_SMA,PRICE_CLOSE,3+shift);
   if(MathAbs(MathAbs(fi2))>threshold)
   { 
      if(fi3<fi2&& fi2>fi1) result=-10;
      else if(fi3>fi2&& fi2<fi1) result=10;
      else if(fi3>fi2&& fi2>fi1) result=-5;
      else if(fi3<fi2&& fi2<fi1) result=5;
   }
   return(result);
}


//+------------------------------PRICE------------------------------------+

//前shift个timeframe时间K线波动均值是否超过checkPoint 超过10 不超过-10  5即可认为趋势明显
bool CheckPriceActive(int timeframe,int checkPoint,int shift)
{
   int average;
   double price[][6];
   ArrayResize(price,shift+1);
   ArrayCopyRates(price,Symbol(), timeframe);

   for(int i=0;i<shift;i++)
   {
      average=average+Price2Point(MathAbs(price[i+1][2]-price[i+1][3]));
   }
   average=average/shift;
   
   if(average > checkPoint)
      return(true);
   else
   {
      Print("average="+average);
      return(false);
   }
}

int M5Shock(string symbol,int value) 
{
   double price[][6];
   ArrayResize(price,1);
   ArrayCopyRates(price,Symbol(), 5);
   if(Price2Point(price[0][4]-price[0][1])>value) 
      return(10);
   else if(Price2Point(price[0][1]-price[0][4])>value) 
      return(-10);
   else
      return(0);
}