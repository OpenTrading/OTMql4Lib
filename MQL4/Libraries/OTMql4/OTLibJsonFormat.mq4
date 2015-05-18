// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

/*

JSON formatting for sending information to clients.
This is simple string formatting: a JSON structure or class is never used.

*/

#property copyright "Copyright 2015 OpenTrading"
#property link      "https://github.com/OpenTrading/"
#property library

#include <stdlib.mqh>
#include <stderror.mqh>
#include <OTMql4/OTLibLog.mqh>
#include <OTMql4/OTLibStrings.mqh>
#include <OTMql4/OTLibTrading.mqh>
#include <OTMql4/OTLibJsonFormat.mqh>

string jOTAccountInformation() {
    string uRetval;
    
    // FixMe: coalesce
    uRetval = "{";
    uRetval += StringFormat("'status': '%s',", "ok");
    uRetval += StringFormat("'balance': %f,", AccountBalance()); // Decimal
    uRetval += StringFormat("'credit': %f,", AccountCredit()); // Decimal
    uRetval += StringFormat("'company': '%s',", AccountCompany());
    uRetval += StringFormat("'currency': '%s',", AccountCurrency());
    uRetval += StringFormat("'equity': %f,", AccountEquity()); // Decimal
    uRetval += StringFormat("'free_margin': %f,", AccountFreeMargin()); // Decimal
    uRetval += StringFormat("'free_margin_mode': '%f',", AccountFreeMarginMode());
    uRetval += StringFormat("'leverage': %i,", AccountLeverage());
    uRetval += StringFormat("'margin': %f,", AccountMargin()); // Decimal
    uRetval += StringFormat("'name': '%s',", AccountName());
    uRetval += StringFormat("'number': %i,", AccountNumber());
    uRetval += StringFormat("'profit': %f,", AccountProfit()); // Decimal
    uRetval += StringFormat("'server': '%s',", AccountServer());
    uRetval += StringFormat("'stopout_level': '%i',", AccountStopoutLevel()); //?
    uRetval += StringFormat("'stopout_mode': '%i',", AccountStopoutMode()); //?
    uRetval += "}";
    return(uRetval);
}    

string jOTOrderTickets() {
    string uRetval;
    int iRetval;
    int i;
    
    uRetval = "[";
    for(i=OrdersTotal()-1; i>=0; i++) {
        iRetval = iOTOrderSelect(i,SELECT_BY_POS, MODE_TRADES);
        if (iRetval < 0) {continue;}
	uRetval += StringFormat("%i, ", iRetval);
    }
    uRetval += "]";
    return(uRetval);
}    

string jOTOrders() {
    string uRetval, uReason;
    int iRetval;
    int i;
    
    uRetval = "[";
    for(i=OrdersTotal()-1; i>=0; i++) {
        iRetval = iOTOrderSelect(i,SELECT_BY_POS, MODE_TRADES);
	if (iRetval <= 0) {
	    uReason = ErrorDescription(GetLastError());
	    vWarn("Select order failed " +
		  " for order " + i + ": " + uReason);
	    uRetval += "{";
	    uRetval += StringFormat("'ticket': '%i',", i);
	    uRetval += StringFormat("'status': '%s',", "failed");
	    uRetval += StringFormat("'reason': '%s',", uReason);
	    uRetval += "}";
	} else {
	    uRetval += jOTOrderInformation(iRetval);
	}
    }
    uRetval += "]";
    return(uRetval);
}    

string jOTOrderInformation(int iTicket) {
    string uRetval, uReason;
    int iRetval;
    
    // FixMe: coalesce
    uRetval = "{";
    iRetval = iOTOrderSelect(iTicket, SELECT_BY_POS, MODE_TRADES);
    if (iRetval <= 0) {
	uReason = ErrorDescription(GetLastError());
	vWarn("Select order failed " +
	      " for order " + iTicket + ": " + uReason);
	uRetval += StringFormat("'status': '%s',", "failed");
	uRetval += StringFormat("'reason': '%s',", uReason);
    } else {
	uRetval += StringFormat("'status': '%s',", "ok");
	uRetval += StringFormat("'ticket': %i,", OrderTicket());
	uRetval += StringFormat("'opentime': %i,", OrderOpenTime());
	uRetval += StringFormat("'type': %i,", OrderType());
	uRetval += StringFormat("'volume': %i,", OrderLots());
	uRetval += StringFormat("'symbol': '%s',", OrderSymbol());
	uRetval += StringFormat("'openprice': %f,", OrderOpenPrice());
	uRetval += StringFormat("'stoploss': %f,", OrderStopLoss());
	uRetval += StringFormat("'takeprofit': %f,", OrderTakeProfit());
	uRetval += StringFormat("'closetime': %i,", OrderCloseTime());
	uRetval += StringFormat("'closeprice': %f,", OrderClosePrice());
	uRetval += StringFormat("'commission': %f,", OrderCommission());
	uRetval += StringFormat("'swap': %f,", OrderSwap());
	uRetval += StringFormat("'profit': %f,", OrderProfit());
	uRetval += StringFormat("'comment': '%s',", OrderComment());
	uRetval += StringFormat("'magicnumber': %i,", OrderMagicNumber());
    }
    uRetval += "}";
    return(uRetval);
}    

string jOTMarketInformation(string uSymbol) {
    string uRetval;
    
    // FixMe: coalesce
    uRetval = "{";
    uRetval += StringFormat("'symbol': '%s',", uSymbol);
    uRetval += StringFormat("'low': %f,", MarketInfo(uSymbol, MODE_LOW));
    uRetval += StringFormat("'high': %f,", MarketInfo(uSymbol, MODE_HIGH));
    uRetval += StringFormat("'time': %d,", MarketInfo(uSymbol, MODE_TIME));//fix
    uRetval += StringFormat("'bid': %f,", MarketInfo(uSymbol, MODE_BID));
    uRetval += StringFormat("'ask': %f,", MarketInfo(uSymbol, MODE_ASK));
    uRetval += StringFormat("'point': %f,", MarketInfo(uSymbol, MODE_POINT));//fix?
    uRetval += StringFormat("'digits': %f,", MarketInfo(uSymbol, MODE_DIGITS));//fix?
    uRetval += StringFormat("'spread': %f,", MarketInfo(uSymbol, MODE_SPREAD));
    uRetval += StringFormat("'stoplevel': %f,", MarketInfo(uSymbol, MODE_STOPLEVEL));
    uRetval += StringFormat("'lotsize': %f,", MarketInfo(uSymbol, MODE_LOTSIZE));
    uRetval += StringFormat("'tickvalue': %f,", MarketInfo(uSymbol, MODE_TICKVALUE));
    uRetval += StringFormat("'ticksize': %f,", MarketInfo(uSymbol, MODE_TICKSIZE));
    uRetval += StringFormat("'swaplong': %f,", MarketInfo(uSymbol, MODE_SWAPLONG));
    uRetval += StringFormat("'swapshort': %f,", MarketInfo(uSymbol, MODE_SWAPSHORT));
    uRetval += StringFormat("'starting': '%s',", (string)MarketInfo(uSymbol, MODE_STARTING));//?
    uRetval += StringFormat("'expiration': '%s',", (string)MarketInfo(uSymbol, MODE_EXPIRATION));//?
    uRetval += StringFormat("'tradeallowed': '%s',", (string)MarketInfo(uSymbol, MODE_TRADEALLOWED));//?
    uRetval += StringFormat("'minlot': '%s',", (string)MarketInfo(uSymbol, MODE_MINLOT));//?
    uRetval += StringFormat("'lotstep': '%s',", (string)MarketInfo(uSymbol, MODE_LOTSTEP));//?
    uRetval += StringFormat("'maxlot': '%s',", (string)MarketInfo(uSymbol, MODE_MAXLOT));//?
    uRetval += StringFormat("'swaptype': '%s',", (string)MarketInfo(uSymbol, MODE_SWAPTYPE));//?
    uRetval += StringFormat("'profitcalcmode': '%s',", (string)MarketInfo(uSymbol, MODE_PROFITCALCMODE));//?
    uRetval += StringFormat("'margincalcmode': '%s',", (string)MarketInfo(uSymbol, MODE_MARGINCALCMODE));//?
    uRetval += StringFormat("'margininit': '%s',", (string)MarketInfo(uSymbol, MODE_MARGININIT));
    uRetval += StringFormat("'marginmaintenance': '%s',", (string)MarketInfo(uSymbol, MODE_MARGINMAINTENANCE));
    uRetval += StringFormat("'marginhedged': '%s',", (string)MarketInfo(uSymbol, MODE_MARGINHEDGED));
    uRetval += StringFormat("'marginrequired': '%s',", (string)MarketInfo(uSymbol, MODE_MARGINREQUIRED));
    uRetval += StringFormat("'freezelevel': '%s',", (string)MarketInfo(uSymbol, MODE_FREEZELEVEL));
    uRetval += "}";
    return(uRetval);
}    

string jOTTickInformation(string uSymbol, int iTimeFrame) {
    string uRetval;
    int iPricePower;
    double fBid, fAsk;
    
    iPricePower = (int) MarketInfo(uSymbol, MODE_DIGITS);
    fBid = NormalizeDouble(MarketInfo(uSymbol, MODE_BID), iPricePower);
    fAsk = NormalizeDouble(MarketInfo(uSymbol, MODE_ASK), iPricePower);
    // FixMe: coalesce
    uRetval = "{";
    uRetval += StringFormat("'currenttime': '%s'", IntegerToString(TimeCurrent()));
    uRetval += StringFormat("'bid': %f,", fBid*MathPow(10, iPricePower));
    uRetval += StringFormat("'ask': %f,", fAsk*MathPow(10, iPricePower));
    
    uRetval += "}";
    return(uRetval);
}    

string jOTBarInformation(string uSymbol, int iTimeFrame, int iBar) {
    string uRetval;
    int iPricePower;
    
    // FixMe: coalesce
    uRetval = "{";
    iPricePower = (int) MarketInfo(uSymbol, MODE_DIGITS);
    
    uRetval += StringFormat("'bartime': '%s'", TimeToStr(iTime(uSymbol, iTimeFrame, iBar)));
    uRetval += StringFormat("'open': %i,", iOpen(uSymbol, iTimeFrame, iBar)*MathPow(10, iPricePower));
    uRetval += StringFormat("'high': %i,", iHigh(uSymbol, iTimeFrame, iBar)*MathPow(10, iPricePower));
    uRetval += StringFormat("'low': %i,", iLow(uSymbol, iTimeFrame, iBar)*MathPow(10, iPricePower));
    uRetval += StringFormat("'close': %i,", iClose(uSymbol, iTimeFrame, iBar)*MathPow(10, iPricePower));
    uRetval += StringFormat("'volume': %i,", iVolume(uSymbol, iTimeFrame, iBar));

    uRetval += "}";
    return(uRetval);
}

string jOTTimerInformation() {
    string uRetval;
    uRetval = "{";
    uRetval += StringFormat("'IsConnected': %i,", IsConnected());
    uRetval += StringFormat("'IsTradeAllowed': %i,", IsTradeAllowed());
    uRetval += StringFormat("'IsTradeContextBusy': %i,", IsTradeContextBusy());

    uRetval += "}";
    return(uRetval);
}
