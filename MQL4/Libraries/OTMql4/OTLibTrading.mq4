// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

#property copyright "Copyright 2013 OpenTrading"
#property link      "https://github.com/OpenTrading/"
#property library

#include <stdlib.mqh>
#include <stderror.mqh>
#include <OTMql4/OTLibLog.mqh>
#include <OTMql4/OTLibConstants.mqh>
#include <OTMql4/OTLibServerErrors.mqh>

int iOTOrderSelect(int iIndex, int iSelect, int iPool=MODE_TRADES) {
    // returns 1 on success, 0 or -iError on failure
    bool bRetval;

    bRetval=OrderSelect(iIndex, iSelect, iPool);
    if (bRetval != true) {
        int iError=GetLastError();
        vWarn("Error selecting order # "+iIndex+
              ": "+ErrorDescription(iError) +"("+iError+")");
        return(-iError);
    }
    return(1);
}

int iOTOrderSend(string sSymbol, int cmd,
                 double volume, double price,
                 int slippage, double stoploss, double takeprofit,
                 string comment="", int magic=0, datetime expiration=0,
                 color arrow_color=CLR_NONE) {
    // Returns number of the ticket assigned to the order by the trade server or -1 if it fails.
    int iRetval;
    bool bContinuable = true;
    int iError;
    int iTick = 0;

    iTick=0;
    iError=0;
    while (bContinuable==true && iTick < OT_MAX_TICK_RETRIES) {
        iTick += 1;

        if (iOTSetTradeIsBusy() != 1) {
            vWarn(" Unable to acquire the trade context. Retrying (try #" + iTick + ")");
            continue;
        }

        iRetval = OrderSend(sSymbol, cmd, volume, price, slippage, stoploss,
                          takeprofit, comment, magic, expiration, arrow_color);
        iOTSetTradeIsNotBusy();

        if (iRetval > 0) {return(iRetval);}

        iError=GetLastError();
        vWarn("Error sending order: " +ErrorDescription(iError) +"("+iError+")");
        // what about "no error"
        bContinuable = bOTLibServerErrorIsContinuable(iError);
        iRetval = -iError;
    }
    return(iRetval);
}

int iOTOrderClose(int iTicket,  double fLots, double fPrice, int iSlippage, color cColor=CLR_NONE) {

    // returns 1 on success, 0 or -iError on failure
    bool bRetval;
    bool bContinuable = true;
    int iError;
    int iTick=0;

    iTick=0;
    iError=0;
    while (bContinuable == true && iTick < OT_MAX_TICK_RETRIES) {
        iTick += 1;
        if (iOTSetTradeIsBusy() != 1) {
            vWarn(" Unable to acquire the trade context. Retrying (try #" +
                  iTick + ")");
            continue;
        }

        bRetval = OrderClose(iTicket, fLots, fPrice, iSlippage, cColor);
        iOTSetTradeIsNotBusy();
        if (bRetval == true) {
            return(1);
        }
        iError=GetLastError();
        vWarn("Error closing order # "+iTicket+
              ": "+ErrorDescription(iError) +"("+iError+")");

        // what about "no error"
        bContinuable = bOTLibServerErrorIsContinuable(iError);
    }

    return(-iError);
}

bool bOTIsTradeAllowed() {
    /*
      Wait for the trade context to become free.
      Returns true if the trade context is free.

      Warning: RefreshRates can take a long time.
    */
    int iTicks = 0;
    
    if (IsTesting() || IsOptimization()) return (true);

    while( IsTradeAllowed() == false && iTicks < OT_MAX_TICK_RETRIES) {
        iTicks += 1;
        Sleep(OT_TICK_SLEEP_MSEC); // Cycle delay
        RefreshRates();
    }
    if (iTicks >= OT_MAX_TICK_RETRIES) {
        vWarn("Unable to acquire trade context for : "+Symbol()+
              " in " + OT_MAX_TICK_RETRIES + " tries.");
        return(false);
    }
    return (true);
}

/*
  from http://articles.mql4.com/141

  The function sets the global variable fTradeIsBusy value 0 with 1.
  If TradeIsBusy = 1 at the moment of launch, the function waits
  until TradeIsBusy is 0, and then replaces it with 1.0.
  If there is no global variable TradeIsBusy, the function creates it.

  Return codes:
   1 - successfully completed. The global variable TradeIsBusy was assigned with value 1
  -1 - TradeIsBusy = 1 at the moment of launch of the function, the waiting was interrupted by the user
       (the expert was removed from the chart, the terminal was closed, the chart period and/or symbol
       was changed, etc.)
  -2 - TradeIsBusy = 1 at the moment of launch of the function, the waiting limit was exceeded (60 sec)
  -3 - No connection to server
*/
int iOTSetTradeIsBusy( int iMaxWaitingSeconds = 60 ) {

    if(IsTesting()) return(1);
    if(!bOTIsTradeAllowed()) return(-3);

    int iError = 0;
    int StartWaitingTime = GetTickCount();

    // Check whether a global variable exists and, if not, create it
    while(true) {
        // if the expert was terminated by the user, stop operation
        if(IsStopped()) {return(-1);}

        // if the waiting time exceeds that specified in the variable
        // iMaxWaitingSeconds, stop operation, as well
        if ((GetTickCount() - StartWaitingTime) > iMaxWaitingSeconds * 1000) {
            vWarn("Waiting time (" + iMaxWaitingSeconds + " sec.) exceeded!");
            return(-2);
        }
        // check whether the global variable exists
        // if it does, leave the loop and go to the block of changing
        // TradeIsBusy value
        if(GlobalVariableCheck( "fTradeIsBusy" )) break;

        // if the GlobalVariableCheck returns FALSE, it means that it does not exist or
        // an error has occurred during checking

        iError = GetLastError();
        // if it is still an error, display information, wait for 0.1 second, and
        // restart checking
        if(iError != 0) {
            vWarn(" Error in TradeIsBusy GlobalVariableCheck(\"TradeIsBusy\"): " +
                  ErrorDescription(iError) );
            Sleep(OT_TRADE_ORDER_SLEEP_MSEC);
            continue;
        }

        // if there is no error, it means that there is just no global variable,
        // try to create it
        // if the GlobalVariableSet > 0, it means that the global variable
        // has been successfully created. Leave the function.
        if(GlobalVariableSet( "fTradeIsBusy", 1.0 ) > 0 )
            return(1);

        // if the GlobalVariableSet has returned a value <= 0,
        // it means that an error occurred at creation of the variable
        iError = GetLastError();
        // display information, wait for 0.1 second, and try again
        if(iError != 0) {
            vWarn("Error in TradeIsBusy GlobalVariableSet(\"TradeIsBusy\",0.0 ): " +
                  ErrorDescription(iError) );
            Sleep(OT_TRADE_ORDER_SLEEP_MSEC);
            continue;
        }
    }

    // If the function execution has reached this point, it means that
    // the global variable variable exists. Wait until the TradeIsBusy
    // becomes = 0 and change the value of TradeIsBusy to 1

    while(true) {
        // if the expert was terminated by the user, stop operation
        if(IsStopped()) return(-1);

        // if the waiting time exceeds that specified in the variable
        // iMaxWaitingSeconds, stop operation, as well
        if(GetTickCount() - StartWaitingTime > iMaxWaitingSeconds * 1000) {
            vWarn("Waiting time (" + iMaxWaitingSeconds + " sec.) exceeded!");
            return(-2);
        }
        // try to change the value of the TradeIsBusy from 0 to 1
        // if succeed, leave the function returning 1 ("successfully completed")
        if (GlobalVariableSetOnCondition( "fTradeIsBusy", 1.0, 0.0 )) {
            return(1);
	}
        // if not, 2 reasons for it are possible: TradeIsBusy = 1 (then one has to wait), or

        // an error occurred (this is what we will check)

        iError = GetLastError();
        // if it is still an error, display information and try again
        if(iError != 0) {
            vWarn("Error in TradeIsBusy GlobalVariableSetOnCondition(\"TradeIsBusy\",1.0,0.0 ):" +
                  ErrorDescription(iError) );
            continue;
        }

        // if there is no error, it means that TradeIsBusy = 1 (another expert is trading),
        // then display information and wait...
        vInfo("Waiting for the trade context to become free...");
        Sleep(OT_TRADE_ORDER_SLEEP_MSEC);
    }
    /* should be unreached */
    return(0);

}


/*
  The function sets the value of the global variable fTradeIsBusy = 0.
  If the fTradeIsBusy does not exist, the function creates it.
*/
int iOTSetTradeIsNotBusy() {
    int iError;
    // if testing, there is no sense to divide the trade context -
    // just terminate the function
    if(IsTesting()) return(0);

    while(true) {
        // if the expert was terminated by the user,
        if(IsStopped()) return(-1);

        // try to set the global variable value = 0
        // (or create the global variable)
        // if the GlobalVariableSet returns a value > 0, it means that everything
        // has succeeded. Leave the function
        if (GlobalVariableSet( "fTradeIsBusy", 0.0 ) > 0)
            return(1);

        // if the GlobalVariableSet returns a value <= 0,
        // this means that an error has occurred.
        // Display information, wait, and try again
        iError = GetLastError();
        if (iError != 0 ) {
            vWarn("Error in TradeIsNotBusy GlobalVariableSet(\"TradeIsBusy\",0.0): " +
                  ErrorDescription(iError) );
	}

        Sleep(OT_TRADE_ORDER_SLEEP_MSEC);
    }
    /* should be unreached */
    return(0);
}


/*
fOTExposedEcuInMarket shows how much worse thing could get, unlike
AccountMargin which shows how bad things are now.  It's the worst case sum
of Open against the order's stoploss * return value < 0 means we have
exposure * iOrderEAMagic=0 gives us exposed margin for ALL orders, ours or not.
*/

double fOTExposedEcuInMarket(int iOrderEAMagic = 0) {
    string sSymbol=Symbol(); // Symbol
    int i;
    int iRetval;
    double fExposedEcu=0.0;

    int iLotSize = MarketInfo(sSymbol, MODE_LOTSIZE);
    if (iLotSize < 0) {
        return(-iLotSize);
    }

    for(i=OrdersTotal()-1; i>=0; i--) {

        iRetval=iOTOrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (iRetval <= 0) {
            vWarn("Select order failed " +
                  " for order " + i +
                  ": " + ErrorDescription(GetLastError()));
            continue;
        }

        if(OrderSymbol()!=Symbol()) continue;
        if (iOrderEAMagic > 0 && OrderMagicNumber() != iOrderEAMagic) continue;

        double fStopLoss=OrderStopLoss();
        if (fStopLoss == 0.0) {
            fExposedEcu=AccountFreeMargin();
            break;
        }

        int iType=OrderType(); // Order type
        double fOrderLots=OrderLots();
        double fOpenPrice=OrderOpenPrice();
        double fMarginRequired=MarketInfo(Symbol(), MODE_MARGINREQUIRED);
        double fWorstCase;
        if (iType == OP_BUY) {
            if (fStopLoss < Bid) {
                fWorstCase=(Bid-fStopLoss)/Bid*fMarginRequired;
                fExposedEcu+=fWorstCase * fOrderLots;
                vDebug("Exposure on order # "+i+
                       " fExposure="+ (fWorstCase * fOrderLots)+
                       " Bid="+Bid+
                       " fStopLoss="+fStopLoss+
                       " lots fMarginRequired="+fMarginRequired*fOrderLots);
            }
        } else if (iType == OP_SELL) {
            if (fStopLoss > Ask) {
                fWorstCase=(fStopLoss-Ask)/Ask*fMarginRequired;
                fExposedEcu+=fWorstCase * fOrderLots;
                vDebug("Exposure on order # "+i+
                       " fExposure="+ (fWorstCase * fOrderLots)+
                       " Ask="+Ask+
                       " fStopLoss="+fStopLoss+
                       " lots fMarginRequired="+fMarginRequired*fOrderLots);
            }
        }
    }

    return(fExposedEcu);
}


int iOTMarketInfo(string s, int iMode) {
    /*
      Before using the MarketInfo() we use the function  RefreshRates()
      to be sure that we getting the up-to-date market data.
      returns 0 or -iError on failure

      int iTicks=0;
      while(RefreshRates()==false && iTicks < OFMAX_TICK_RETRIES) {
      iTicks+=1;
      Sleep(OFMAX_TICK_SLEEP); // Cycle delay
      }

      if (iTicks >= OFMAX_TICK_RETRIES) {
      vWarn("Unable to refresh rates for : "+s+
      " in "+OFMAX_TICK_RETRIES+"tries.");
      return(-1);
      }
    */
    if (s=="") {
        vWarn("iOTMarketInfo - Empty symbol for getting "+iMode);
        return(-1);
    }
    if (iMode <= 0) {
        vWarn("iOTMarketInfo - Negative mode for getting "+iMode+" for "+s);
        return(-1);
    }
    int iRetval=MarketInfo(s, iMode);
    int iError=GetLastError();
    if (iError > 0) {
        vWarn("Error getting " +iMode +" for " +s
              +": "+ErrorDescription(iError));
        return(-iError);
    }
    return(iRetval);
}

bool bOTModifyTrailingStopLoss(int iTrailingStopLossPoints,
                             datetime tExpiration=0) {
    // return value of false signals an error
    string sSymbol=Symbol(); // Symbol
    string sMsg;
    bool bRetval=true;
    int iRetval;
    int iType;
    double fTakeProfit;
    double fPrice;
    int iTicket;
    double fStopLoss;
    double fTrailingStopLoss;
    bool bModify;

    int iMinDistance=MarketInfo(sSymbol, MODE_STOPLEVEL);
    if (iMinDistance < 0) {return(false);}

    for(int i=OrdersTotal()-1; i>=0; i++) {
        iRetval=OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
        if (iRetval < 0) {bRetval=false; continue;}

        // Analysis of orders:
        iType = OrderType(); // Order type
        if (OrderSymbol()!=sSymbol || iType > 1) continue;

        fTakeProfit = OrderTakeProfit(); // TakeProfit of the selected order
        fPrice = OrderOpenPrice(); // Price of the selected order
        iTicket = OrderTicket(); // Ticket of the selected order
        fStopLoss = OrderStopLoss(); // SL of the selected order

        fTrailingStopLoss = iTrailingStopLossPoints; // Initial value
        if (fTrailingStopLoss < iMinDistance) {
            // If less than allowed
            fTrailingStopLoss=iMinDistance;
        }

        bModify = false; // Not to be modified
        switch(iType) {
        case OP_BUY: // Order Buy 0
            if (NormalizeDouble(fStopLoss,Digits) < // If it is lower than we want
                NormalizeDouble(Bid-fTrailingStopLoss*Point,Digits) &&
                Bid-fTrailingStopLoss*Point > fTrailingStopLoss*Point/10.0
                ) {
		fStopLoss=Bid-fTrailingStopLoss*Point; // then modify it
		sMsg="Buy "; // Text for Buy
		bModify=true; // To be modified
	    }
            break; // Exit 'switch'
        case OP_SELL: // Order Sell 1
            if (NormalizeDouble(fStopLoss,Digits) > // If it is higher than we want
                NormalizeDouble(Ask+fTrailingStopLoss*Point,Digits) &&
                Ask+fTrailingStopLoss*Point > fTrailingStopLoss*Point/10.0) {
                // || NormalizeDouble(fStopLoss,Digits==0)//or equal to zero
		fStopLoss=Ask+fTrailingStopLoss*Point; // then modify it
		sMsg="Sell "; // Text for Sell
		bModify=true; // To be modified
	    }
        }

        if (bModify==false) continue;

        bRetval = bRetval && bOTModifyOrder("Modifiying stoploss "+sMsg,
                                          iTicket, fPrice, fStopLoss, fTakeProfit, tExpiration);
    }

    return(bRetval);
}

bool bOTModifyOrder(string sMsg,
                  int iTicket,
                  double fPrice,
                  double fStopLoss,
                  double fTakeProfit,
                  datetime tExpiration) {
    // FixMe: how do we check and order has been selected?
    int iRetry=0;
    int iTicks;
    bool bAns;
    bool bRetval=false;

    while(iRetry < OT_MAX_TICK_RETRIES) {
        // Modification cycle
        iRetry += 1;
        vInfo(sMsg +iTicket +" at " +Bid
              +" from sl " +OrderStopLoss()+" to " +fStopLoss
              +" from tp " +OrderTakeProfit()+" to " +fTakeProfit
              +". Awaiting response.");
        bAns = OrderModify(iTicket, NormalizeDouble(fPrice, Digits),
                         NormalizeDouble(fStopLoss, Digits),
                         NormalizeDouble(fTakeProfit, Digits),
                         tExpiration);

        if (IsTesting() || IsOptimization() || bAns==true) {
            vInfo("Order " +sMsg+iTicket +" is modified: ");
            return(true);
        }

        if (bOTContinueOnOrderError(iTicket)) {
            iTicks = 0;
            while ( RefreshRates()==false && iTicks < OT_MAX_TICK_RETRIES) {
                // To the new tick
                iTicks +=  1;
                Sleep(OT_TICK_SLEEP_MSEC); // Cycle delay
            }
            if (iTicks >= OT_MAX_TICK_RETRIES) {break;}
        }
    }

    vWarn("Error modifying Order # " +iTicket +": "
          // +" " +ErrorDescription(iError)
          );
    return(bRetval);
}

bool bOTContinueOnOrderError(int iTicket) {
    bool bContinue=false;
    int iError=GetLastError();

    switch(iError) {
        // Overcomable errors
    case 130:
        Print("Wrong stops. Retrying.");
        bContinue=true; break; // At the next iteration
    case 136:
        Print("No prices. Waiting for a new tick..");
        bContinue=true; break; // At the next iteration
    case 146:
        Print("Trading subsystem is busy. Retrying ");
        bContinue=true; break; // At the next iteration
        // Critical errors
    case 1 :
        Print("No error."); // WTF?
        break; // Exit 'switch'
    default:
        bContinue=bOTLibServerErrorIsContinuable(iError);
        break;
    }
    return(bContinue);
}

