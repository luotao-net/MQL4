#property copyright "Lorne"
#property link      "www@luotao.net"

#include <SystemManager.mqh>


extern string ____="==================订单参数==================";
extern bool IsEnableAddOrder=false;//启用加仓机制
extern bool IsEnableSubOrder=false;//启用减仓机制

color BuyColor=Red;
color SellColor=Lime;

//订单信息列表
//0 ticket1
//1 ticket2
//2 ticket3
//3 opentime
//4 lot
//5 open price
//6 highest profit
//7 lastOperationTime
double OrdersInfo[10][8];

double LastOpenPrice;//上次开单价位
double LastHighPrice;
double LastLowPrice;


//=========================================================================================

//返回目前持单数量（特定magic）,包含所有货币
int GetTotalOrderCount(int magic)
{
   int result;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic) result++;
      }
   }
   return(result);
}

//返回目前持单数量（特定magic，特定symbol）
int GetOrderCountBySymbol(int magic,string symbol="")
{
   if(symbol=="") symbol=Symbol();
   int cnt=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
            cnt++;
   }
   return(cnt);
}


//先下单再修改止损止盈
int OpenOrderNow(string symbol,int orderType,double lot,int slip,int stopPoint,int profitPoint,string ordercomment,int magic,color c,int shiftPoint)
{
   //Print("OpenOrderNow1 lot:"+lot);
   lot=NormalizeDouble(lot,LotDigits);//截断手数的小数位
   if(lot==0)
   {
      Print("Warning:OpenOrderNow Lot==0!");
      return(-123);
   }
   //计算止损止盈
   double StopLossPrice;
   double TakeProfitPrice;
   if(orderType==0)
   {
      StopLossPrice=Ask-stopPoint*ThisPoint;
      TakeProfitPrice=Ask+profitPoint*ThisPoint;
   }
   else if(orderType==1)
   {
      StopLossPrice=Bid+stopPoint*ThisPoint;
      TakeProfitPrice=Bid-profitPoint*ThisPoint;
   }
   else if(orderType==OP_BUYLIMIT)
   {
      StopLossPrice=NormalizeDouble(Ask-Point2Price(shiftPoint+stopPoint),Digits);
      TakeProfitPrice=NormalizeDouble(Ask-Point2Price(shiftPoint-profitPoint),Digits);
   }
   else if(orderType==OP_SELLLIMIT)
   {
      StopLossPrice=NormalizeDouble(Bid+Point2Price(shiftPoint+stopPoint),Digits);
      TakeProfitPrice=NormalizeDouble(Bid+Point2Price(shiftPoint-profitPoint),Digits);
   }
   else if(orderType==OP_BUYSTOP)
   {
      StopLossPrice=NormalizeDouble(Ask+Point2Price(shiftPoint-stopPoint),Digits);
      TakeProfitPrice=NormalizeDouble(Ask+Point2Price(shiftPoint+profitPoint),Digits);
   }
   else if(orderType==OP_SELLSTOP)
   {
      StopLossPrice=NormalizeDouble(Bid-Point2Price(shiftPoint-stopPoint),Digits);
      TakeProfitPrice=NormalizeDouble(Bid-Point2Price(shiftPoint+profitPoint),Digits);
   }
   if(stopPoint==0) StopLossPrice=0;
   if(profitPoint==0) TakeProfitPrice=0;
   
   int ticket=-1;
   RefreshRates();
   switch(orderType)
   {
      case OP_BUY:
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Ask,Digits),slip,0,0,ordercomment,magic,0,c);
         break;
      case OP_SELL:
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Bid,Digits),slip,0,0,ordercomment,magic,0,c);
         break;
      case OP_BUYLIMIT:
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Ask-Point2Price(shiftPoint),Digits)
            ,slip,StopLossPrice,TakeProfitPrice,ordercomment,magic,0,c);
         break;
      case OP_SELLLIMIT :
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Bid+Point2Price(shiftPoint),Digits)
            ,slip,StopLossPrice,TakeProfitPrice,ordercomment,magic,0,c);
         break;
      case OP_BUYSTOP:
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Ask+Point2Price(shiftPoint),Digits)
            ,slip,StopLossPrice,TakeProfitPrice,ordercomment,magic,0,c);
         break;
      case OP_SELLSTOP:
         ticket=OrderSend(Symbol(),orderType,lot,NormalizeDouble(Bid-Point2Price(shiftPoint),Digits)
            ,slip,StopLossPrice,TakeProfitPrice,ordercomment,magic,0,c);
         break;
      default:
         break;
   }

   if (ticket<=0)
   {
      Print("[OrderSend Failed] "+ErrorDescription(GetLastError()));
      return(ticket);
   }else if(ticket>0 && orderType<2){//挂单才需要改止损止盈
      if(OrderSelect(ticket, SELECT_BY_TICKET))
      {
         if(!OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(StopLossPrice,Digits),NormalizeDouble(TakeProfitPrice,Digits),0,c))
            Print("[OrderModify Failed] "+ErrorDescription(GetLastError()));
      }
   }
   return(ticket);
}

//平仓
int OrderCloseNow(int magic,int ordertype)
{
   //Print(Symbol()+" Close All "+ordertype+" Order");
   int cnt=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && Symbol()==OrderSymbol() && OrderType()==ordertype)
         {
            RefreshRates();
            bool result;
            double openprice=OrderOpenPrice();
            double closeprice;
            string direction;
            string ticket=OrderTicket();
            if(ordertype==OP_BUY)
            {
               closeprice=NormalizeDouble(Bid,Digits);
               result = OrderClose(OrderTicket(),OrderLots(),closeprice,Slip,BuyColor);
               direction=" BUY ";
            }else//空单
            {
               closeprice=NormalizeDouble(Ask,Digits);
               result = OrderClose(OrderTicket(),OrderLots(),closeprice,Slip,SellColor);
               direction=" SELL ";
            }
            
            if(result)
            {
               cnt++;
               SendMail("Golden " + Symbol() + direction +ticket+ "Closed "+openprice+" - "+closeprice, 
                        openprice+" - "+closeprice);
               // todo send mail
            }else{
               string errorStr=ErrorDescription(GetLastError());
               Alert("Golden " + Symbol() +direction, OrderTicket(), " failed to close. Error : "+ errorStr);
               Print("Golden " + Symbol() +direction, OrderTicket(), " failed to close. Error : "+errorStr);
            }
            
         }
      }
   }
   return(cnt);
}

//删除所有挂单
void DeleteAllHangOrder(string symbol="")
{
   if(symbol=="") 
      symbol=Symbol();
      
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==Magic && OrderType()>1 && OrderSymbol()==symbol)
         {
            bool result = OrderDelete(OrderTicket());
            if(result == false)
            {
               string errorStr=ErrorDescription(GetLastError());
               Alert("[Order ", OrderTicket(), " close failed] ", errorStr);
               Print("[Order ", OrderTicket(), " close failed] ", errorStr);
               Sleep(500);
            }
         }
      }
   }
}

//阶梯参数跟踪止损
void CustomStepTrailingStopOrder(int ticket,int trailingstop,int step0,int step1,int step2,int step3)
{
   if(OrderSelect(ticket,SELECT_BY_TICKET))
   {
      double newStopLoss=OrderStopLoss();
      double newTakeProfit=OrderTakeProfit();
      double profit;
      color c;
      
      if(OrderType()==OP_BUY)//多单，往上追踪止损
      {
         c=BuyColor;
         profit=Price2Point(Bid-OrderOpenPrice());
         
         if(profit>step3+step0)//盈利超过step3，改为步进式
         {
            int times=(profit-step3) / step0 - 1;
            newStopLoss=OrderOpenPrice()+Point2Price(step3)+Point2Price(times*step0);
         }
         else if(profit>step3)
            newStopLoss=OrderOpenPrice()+Point2Price(step3-trailingstop);
         else if(profit>step2)
            newStopLoss=OrderOpenPrice()+Point2Price(step2-trailingstop);
         else if(profit>step1)
            newStopLoss=OrderOpenPrice()+Point2Price(step1-trailingstop);
         else if(profit>step0)
            newStopLoss=OrderOpenPrice()+Point2Price(5);
            
         if(Price2Point(OrderTakeProfit()-Bid) < 0.5*step0)//止盈少于step点了,将止盈放远
            newTakeProfit=OrderTakeProfit()+Point2Price(0.5*step0);
         
         if (newStopLoss<OrderStopLoss())//只允许sl往更高调整
            newStopLoss=OrderStopLoss();
         if (newTakeProfit<OrderTakeProfit())
            newTakeProfit=OrderTakeProfit();
      }
      else if(OrderType()==OP_SELL)
      {
         c=SellColor;
         profit=Price2Point(OrderOpenPrice()-Ask);
         
         if(profit>step3+step0)//盈利超过step3，改为步进式
         {
            int times2=(profit-step3) / step0 - 1;
            newStopLoss=OrderOpenPrice()-Point2Price(step3)-Point2Price(times2*step0);
         }
         else if(profit>step3)
            newStopLoss=OrderOpenPrice()-Point2Price(step3-trailingstop);
         else if(profit>step2)
            newStopLoss=OrderOpenPrice()-Point2Price(step2-trailingstop);
         else if(profit>step1)
            newStopLoss=OrderOpenPrice()-Point2Price(step1-trailingstop);
         else if(profit>step0)
            newStopLoss=OrderOpenPrice()-Point2Price(5);
         
         if(Price2Point(Ask-OrderTakeProfit()) < 0.5*step0)//止盈少于step点了,将止盈放远处
            newTakeProfit=OrderTakeProfit()-Point2Price(0.5*step0);
            
         if (newStopLoss>OrderStopLoss())//sell时只允许sl往更低调整
            newStopLoss=OrderStopLoss();
         if (newTakeProfit>OrderTakeProfit())
            newTakeProfit=OrderTakeProfit();
      }
      else
         return;
      
      //浮点数比较会有误差，不能用==判断,新止损比旧止损差距3点以上才会执行
      if(MathAbs(newStopLoss-OrderStopLoss())>3*ThisPoint || MathAbs(newTakeProfit-OrderTakeProfit())>3*ThisPoint)
      {
         if(!OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(newStopLoss,Digits),NormalizeDouble(newTakeProfit,Digits),0,c))
         {
            string errorStr=ErrorDescription(GetLastError());
            Print("[CustomTrailingStop Failed] "+errorStr);
            Sleep(500);
         }else
            Print(ticket+" Profit="+profit+" move profit stop!");
      }
   }
}

//步进型跟踪止损
//每盈利step调整止损至trailingStop处
void StepTrailStop(int ticket,int trailingStop,int step)
{
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return;
   double newStopLoss=OrderStopLoss();
   double newTakeProfit=OrderTakeProfit();
   color c;
   
   if(OrderType()==OP_BUY)//多单，往上追踪止损
   {
      c=BuyColor;
      if(Price2Point(Bid-OrderStopLoss())>step+trailingStop)//现价距止损超过step+trailingStop，移动trailingStop
         newStopLoss=Bid-Point2Price(trailingStop);
      if(Price2Point(OrderTakeProfit()-Bid) < step)//止盈少于step点了,将止盈放远处
         newTakeProfit=OrderTakeProfit()+Point2Price(0.5*trailingStop);
   }else if(OrderType()==OP_SELL){//空单
      c=SellColor;
      if(Price2Point(OrderStopLoss()-Ask)>step+trailingStop)//现价距止损超过step+trailingStop，移动trailingStop
         newStopLoss=Ask+Point2Price(trailingStop);
      if(Price2Point(Ask-OrderTakeProfit()) < step)//止盈少于step点了,将止盈放远处
         newTakeProfit=OrderTakeProfit()-Point2Price(0.5*trailingStop);
   }
   
   //最小点可能会有误差，不能用==判断
   if(MathAbs(newStopLoss-OrderStopLoss())>3*ThisPoint||MathAbs(newTakeProfit-OrderTakeProfit())>3*ThisPoint) 
   {
      //Print(newStopLoss+"!="+OrderStopLoss()+" OrderOpenPrice()="+OrderOpenPrice()+" Point2Price(i*step)="+Point2Price(i*step)+" Point2Price(distance)="+Point2Price(distance)+" ThisPoint="+ThisPoint);
      if(!OrderModify(ticket,OrderOpenPrice(),NormalizeDouble(newStopLoss,Digits),NormalizeDouble(newTakeProfit,Digits),0,c))
      {
         Print("[StepStop Failed] "+ErrorDescription(GetLastError()));
         Sleep(500);
      }
   }
}

//返回总手数
double OrderLotsCount(int magic,string symbol="")
{
   if(symbol=="") symbol=Symbol();
   double lots=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            lots = lots + OrderLots();
         }
      }
   }
   return(lots);
}

//开单总盈利点数
double OrderProfitCount(int magic,string symbol="")
{
   if(symbol=="") symbol=Symbol();
   double profit=0;
   double lots=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            profit = profit + OrderProfit();
            lots = lots + OrderLots();
         }
      }
   }

   if(lots==0) 
      return(0);
   else
      return(profit/lots/10);
}

datetime GetOpenOrderFirstTime(int magic,string symbol="")
{
   if(symbol=="") symbol=Symbol();
   datetime result=0;
   for (int i = OrdersTotal()-1; i >= 0 ; i--)
   {
      if(OrderSelect(i,SELECT_BY_POS))
      {
         if(OrderMagicNumber()==magic && OrderSymbol()==symbol)
         {
            if(result==0||OrderOpenTime()<result) result=OrderOpenTime();
         }
      }
   }
   
   return(result);
}


//空闲的OrdersInfoIndex，供add操作
int AddOrdersInfoIndex()
{
   for(int i=0; i < ArrayRange(OrdersInfo,0) ; i++)
   {
      if(OrdersInfo[i][0]<=0) 
      {
         return(i);
      } 
   }
   return(-1);
}

void AddOrdersInfo(int ticket,double lot)
{
   int i=AddOrdersInfoIndex();
   OrdersInfo[i][0]=ticket;
   OrdersInfo[i][1]=ticket;
   
}

//获取订单数量
int GetOrdersInfoCount()
{
   int result;
   int cnt=ArrayRange(OrdersInfo,0);
   for (int i=0; i < cnt ; i++)
   {
      if(OrdersInfo[i][0]>0) 
         result++;
   }
   return(result);
}

void GetHighLowPrice()
{
   if(LastOpenPrice!=0)
   {
      if(Bid>LastOpenPrice && Bid>LastHighPrice)
         LastHighPrice=Bid;
      if(Ask<LastOpenPrice && Ask<LastLowPrice)
         LastLowPrice=Bid;
   }
}

//获取订单数量
int ClearOrdersInfo()
{
   int cnt=ArrayRange(OrdersInfo,0);
   for (int i=0; i < cnt ; i++)
   {
      OrdersInfo[i][0]=0;
   }
   return(-1);
}


