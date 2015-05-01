// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

/*

This is the replacement for what should be Eval in Mt4:
take a string expression and evaluate it.

I know this is verbose and could be done more compactly,
but it's clean and robust so I'll leave it like this for now.

If you want to extend this for your own functions you have declared in Mql4,
look at how zOTLibProcessCmd calls zMt4LibProcessCmd and then 
goes on and handles it if zMt4LibProcessCmd didn't.

 */

#property copyright "Copyright 2013 OpenTrading"
#property link      "https://github.com/OpenTrading/"
#property library

#include <stdlib.mqh>
#include <stderror.mqh>
#include <OTMql4/OTLibLog.mqh>
#include <OTMql4/OTLibStrings.mqh>
#include <OTMql4/OTLibMt4ProcessCmd.mqh>
// extentions from OpenTrading - see uProcessCmdgOT and uProcessCmdOT
#include <OTMql4/OTLibTrading.mqh>

string zOTLibProcessCmd(string uMess) {
    /* 
       This is the replacement for what should be Eval in Mt4:
       take a string expression and evaluate it.
       zMt4LibProcessCmd handles base Mt4 expressions, and
       zOTLibProcessCmd also handles base OpenTrading expressions.

       Returns the result of processing the command.
       Returns "" if there is an error.
    */
   
    string uType, uChart, uPeriod, uMark, uCmd;
    string uArg1="";
    string uArg2="";
    string uArg3="";
    string uArg4="";
    string uArg5="";
    string aArrayAsList[];
    int iLen;
    string uRetval, uKey;
    
    iLen =  StringLen(uMess);
    if (iLen <= 0) {return("");}

    uRetval = zOTLibMt4ProcessCmd(uMess);
    if (uRetval != "") {
	return(uRetval);
    }
    
    vStringToArray(uMess, aArrayAsList, "|");

    iLen = ArraySize(aArrayAsList);
    vDebug("zOTLibProcessCmd: " +uMess +" ArrayLen " +iLen);

    uRetval = eOTLibPreProcessCmd(aArrayAsList);
    if (uRetval != "") {
	vError("eOTLibProcessCmd: preprocess failed with error: " +uRetval);
	return("");
    }
    
    uType   = aArrayAsList[0];
    uChart  = aArrayAsList[1];
    uPeriod = aArrayAsList[2];
    uMark   = aArrayAsList[3];
    uCmd    = aArrayAsList[4];
    uArg1   = aArrayAsList[5];
    uArg2   = aArrayAsList[6];
    uArg3   = aArrayAsList[7];
    uArg4   = aArrayAsList[8];
    uArg5   = aArrayAsList[9];
    
    uKey = StringSubstr(uCmd, 0, 3);
    vTrace("zOTLibProcessCmd uKey: " +uKey +" uCmd: " +uCmd+ " uMark: " +uMark);
    if (uKey == "gOT") {
	// extentions from OpenTrading
	uRetval = uProcessCmdgOT(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else if (StringSubstr(uCmd, 1, 2) == "OT") {
	uRetval = uProcessCmdOT(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else if (StringSubstr(uCmd, 0, 1) == "i") {
	//? are these Mt4 or OT?
	uRetval = uProcessCmdi(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
   } else {
	// vDebug("zOTLibProcessCmd: UNHANDELED" +uKey +" uCmd: " +uCmd);
	uRetval = "";
    }
    
    return(uRetval);

}

string uProcessCmdi (string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="none|";
    string uSymbol;
    int iPeriod, iShift;
    int iType, iCount, iStart;

    uSymbol = uArg1;
    iPeriod = StrToInteger(uArg2);

    // iBarShift
    if (uCmd == "iBars") {
	uRetval = "int|" + iBars(uSymbol, iPeriod);
    } else if (uCmd == "iClose") {
	iShift = StrToInteger(uArg3);
	uRetval = "double|" + iClose(uSymbol, iPeriod, iShift);
    } else if (uCmd == "iHigh") {
	iShift = StrToInteger(uArg3);
	uRetval = "double|" + iHigh(uSymbol, iPeriod, iShift);
    } else if (uCmd == "iHighest") {
	iType = StrToInteger(uArg3);
	iCount = StrToInteger(uArg4);
	iStart = StrToInteger(uArg5);
	uRetval = "int|" + iHighest(uSymbol, iPeriod, iType, iCount, iStart);
    } else if (uCmd == "iLow") {
	iShift=StrToInteger(uArg3);
	uRetval = "double|" + iLow(uSymbol, iPeriod, iShift);
    } else if (uCmd == "iLowest") {
	iType = StrToInteger(uArg3);
	iCount = StrToInteger(uArg4);
	iStart = StrToInteger(uArg5);
	uRetval = "int|" + iLowest(uSymbol, iPeriod, iType, iCount, iStart);
    } else if (uCmd == "iOpen") {
	iShift = StrToInteger(uArg3);
	uRetval = "double|" + iOpen(uSymbol, iPeriod, iShift);
    } else if (uCmd == "iTime") {
	iShift = StrToInteger(uArg3);
	uRetval = "datetime|" + iTime(uSymbol, iPeriod, iShift);
    } else if (uCmd == "iVolume") {
	iShift = StrToInteger(uArg3);
	uRetval = "double|" + iVolume(uSymbol, iPeriod, iShift);
    } else {
	uMsg="Unrecognized action: " + uCmd; vWarn(uMsg);
	uRetval="error|"+uMsg;
    }

    return (uRetval);
}

// OpenTrading additions
// names start with a lower case letter then OT
string uProcessCmdOT (string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="none|";
    int iTicket;
    double fLots;
    double fPrice;
    double fStopLoss;
    double fTakeProfit;
    datetime tExpiration;
    int iMaxWaitingSeconds;
    int iOrderEAMagic;
    int iTrailingStopLossPoints;
    int iSlippage;

    if (uCmd == "iOTOrderSelect") {
	uRetval = "int|" + iOTOrderSelect(StrToInteger(uArg1), StrToInteger(uArg2), StrToInteger(uArg3));
    } else if (uCmd == "iOTOrderClose") {
	iTicket = StrToInteger(uArg1);
	fLots = StrToDouble(uArg2);
	fPrice = StrToDouble(uArg3);
	iSlippage = StrToInteger(uArg4);
	// FixMe:
	color cColor=CLR_NONE;
	uRetval = "int|" + iOTOrderClose(iTicket, fLots, fPrice, iSlippage, cColor);
    } else if (uCmd == "bOTIsTradeAllowed") {
	uRetval = "bool|" + bOTIsTradeAllowed();
    } else if (uCmd == "iOTSetTradeIsBusy") {
	if (StringLen(uArg1) < 1) {
	    uRetval = "int|" + iOTSetTradeIsBusy(60);
	} else {
	    iMaxWaitingSeconds = StrToInteger(uArg1);
	    uRetval = "int|" + iOTSetTradeIsBusy(iMaxWaitingSeconds);
	}
    } else if (uCmd == "iOTSetTradeIsNotBusy") {
	uRetval = "int|" + iOTSetTradeIsNotBusy();
    } else if (uCmd == "fOTExposedEcuInMarket") {
	if (StringLen(uArg1) < 1) {
	    iOrderEAMagic = 0;
	} else {
	    iOrderEAMagic = StrToInteger(uArg1);
	}
	uRetval = "double|" + fOTExposedEcuInMarket(iOrderEAMagic);
    } else if (uCmd == "bModifyTrailingStopLoss") {
	// this implies a selected order
	iTrailingStopLossPoints = StrToInteger(uArg1);
	if (StringLen(uArg2) < 1) {
	    tExpiration = 0;
	} else {
	    // FixMe: StrToDateTime?
	    tExpiration = StrToInteger(uArg2);
	}
	uRetval = "bool|" + bModifyTrailingStopLoss(iTrailingStopLossPoints, tExpiration);
    } else if (uCmd == "bModifyOrder") {
	// this implies a selected order
	iTicket = StrToInteger(uArg2);
	fPrice = StrToDouble(uArg3);
	fStopLoss = StrToDouble(uArg4);
	fTakeProfit = StrToDouble(uArg5);
	// ignores datetime tExpiration
	tExpiration = 0;
	// Notes: Open price and expiration time can be changed only for pending orders.
	uRetval = "bool|" + bModifyOrder(uArg1, iTicket, fPrice,
					 fStopLoss, fTakeProfit, tExpiration);
    } else if (uCmd == "bContinueOnOrderError") {
	iTicket = StrToInteger(uArg1);
	uRetval = "bool|" + bContinueOnOrderError(iTicket);
    } else {
	uMsg = "Unrecognized action: " +uCmd;
	vWarn("uProcessCmdOT: " +uMsg);
	uRetval = "";
    }

    return (uRetval);
}


// Wrap all of the functions that depend on an order being selected
// into a generic gOTWithOrderSelectByTicket and gOTWithOrderSelectByPosition
string uProcessCmdgOT (string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uRetval="none|";
    string uMsg;
    int iError;

    if (uCmd == "gOTWithOrderSelectByTicket") {
	int iTicket=StrToInteger(uArg1);

	if (OrderSelect(iTicket, SELECT_BY_TICKET) == false) {
	    iError=GetLastError();
	    uMsg = "OrderSelect returned an error: " + ErrorDescription(iError)+"("+iError+")";
	    vError(uMsg);
	    uRetval="error|"+uMsg;
	    return(uRetval);
	}
	// drop through
    } else if (uCmd == "gOTWithOrderSelectByPosition") {
	int iPos=StrToInteger(uArg1);

	if (OrderSelect(iPos, SELECT_BY_POS) == false) {
	    iError=GetLastError();
	    uMsg = "OrderSelect returned an error: " + ErrorDescription(iError)+"("+iError+")";
	    vError(uMsg);
	    uRetval="error|"+uMsg;
	    return(uRetval);
	}
	// drop through
    } else {
	uMsg="Unrecognized action: " + uCmd; vWarn(uMsg);
	uRetval="error|"+uMsg;
	return(uRetval);
    }

    string sCommand=uArg2;
    // have a selected order ...
    if (sCommand == "OrderClosePrice" ) {
	uRetval = "double|" + OrderClosePrice();
    } else if (sCommand == "OrderCloseTime" ) {
	uRetval = "datetime|" + OrderCloseTime();
    } else if (sCommand == "OrderComment" ) {
	uRetval = "string|" + OrderComment();
    } else if (sCommand == "OrderCommission" ) {
	uRetval = "double|" + OrderCommission();
    } else if (sCommand == "OrderExpiration" ) {
	uRetval = "datetime|" + OrderExpiration();
    } else if (sCommand == "OrderLots" ) {
	uRetval = "double|" + OrderLots();
    } else if (sCommand == "OrderMagicNumber" ) {
	uRetval = "int|" + OrderMagicNumber();
    } else if (sCommand == "OrderOpenPrice" ) {
	uRetval = "double|" + OrderOpenPrice();
    } else if (sCommand == "OrderOpenTime" ) {
	uRetval = "datetime|" + OrderOpenTime();
    } else if (sCommand == "OrderProfit" ) {
	uRetval = "double|" + OrderProfit();
    } else if (sCommand == "OrderStopLoss" ) {
	uRetval = "double|" + OrderStopLoss();
    } else if (sCommand == "OrderSwap" ) {
	uRetval = "double|" + OrderSwap();
    } else if (sCommand == "OrderSymbol" ) {
	uRetval = "string|" + OrderSymbol();
    } else if (sCommand == "OrderTakeProfit" ) {
	uRetval = "double|" + OrderTakeProfit();
    } else if (sCommand == "OrderTicket" ) {
	uRetval = "int|" + OrderTicket();
    } else if (sCommand == "OrderType" ) {
	//? convert to a string?
	uRetval = "int|" + OrderType();
    } else {
	uMsg="Unrecognized " + uCmd + " command: " + sCommand;
	vWarn("uProcessCmdgOT: " +uMsg);
	uRetval="";
    }

    return (uRetval);
}

