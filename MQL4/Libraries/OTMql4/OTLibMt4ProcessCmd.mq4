// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

/*

This is the replacement for what should be Eval in Mt4:
take a string expression and evaluate it.

I know this is verbose and could be done more compactly,
but it's clean and robust so I'll leave it like this for now.

If you want to extend this for your own functions you have declared in Mql4,
look at how OTLibProcessCmd.mq4 calls zMt4LibProcessCmd and then 
goes on and handles it if zMt4LibProcessCmd didn't.

 */

#property copyright "Copyright 2013 OpenTrading"
#property link      "https://github.com/OpenTrading/"
#property library

#include <stdlib.mqh>
#include <stderror.mqh>
#include <OTMql4/OTLibLog.mqh>
#include <OTMql4/OTLibStrings.mqh>

string zMt4LibProcessCmd(string uMess) {
    /* 
       This is the replacement for what should be Eval in Mt4:
       take a string expression and evaluate it.
       zMt4LibProcessCmd only handles base Mt4 expressions.

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

    vStringToArray(uMess, aArrayAsList, "|");

    iLen = ArraySize(aArrayAsList);
    vDebug("zMt4LibProcessCmd: " +uMess +" ArrayLen " +iLen);

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
    vTrace("zMt4LibProcessCmd uKey: " +uKey +" uCmd: " +uCmd+ " uMark: " +uMark);

    if (uCmd == "OrdersTotal") {
	uRetval = "int|" +OrdersTotal();
    } else if (uCmd == "Period") {
	uRetval = "int|" +Period();
    } else if (uCmd == "RefreshRates") {
	uRetval = "bool|" +RefreshRates();
    } else if (uCmd == "Symbol") {
	uRetval = "string|" +Symbol();
    } else if (uKey == "Ter") {
	uRetval = zProcessCmdTer(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else if (uKey == "Win") {
	uRetval = zProcessCmdWin(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else if (uKey == "Acc") {
	uRetval = zProcessCmdAcc(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else if (uKey == "Glo") {
	uRetval = zProcessCmdGlo(uCmd, uChart, uPeriod, uArg1, uArg2, uArg3, uArg4, uArg5);
    } else {
	vDebug("zMt4LibProcessCmd: UNHANDELED" +uKey +" uCmd: " +uCmd);
	uRetval = "";
    }
    
    return(uRetval);
}

string eOTLibPreProcessCmd (string& aArrayAsList[]) {
    string uType, uChart, uPeriod, uMark, uCmd;
    string uArg1="";
    string uArg2="";
    string uArg3="";
    string uArg4="";
    string uArg5="";
    int iLen;
    string eRetval;
    
    iLen = ArraySize(aArrayAsList);
    if (iLen < 1) {
	eRetval = "eOTLibPreProcessCmd iLen=0: split failed with " +"|";
	return(eRetval);
    }
    uType = StringTrimRight(aArrayAsList[0]);
    
    if (iLen < 2) {
	eRetval = "eOTLibPreProcessCmd: split failed on field 2 ";
	return(eRetval);
    }
    uChart = StringTrimRight(aArrayAsList[1]);

    if (iLen < 3) {
	eRetval = "eOTLibPreProcessCmd: split failed on field 3 ";
	return(eRetval);
    }
    uPeriod = StringTrimRight(aArrayAsList[2]);
    
    if (iLen < 4) {
	eRetval = "eOTLibPreProcessCmd: split failed on field 4 ";
	return(eRetval);
    }
    uMark = StringTrimRight(aArrayAsList[3]);
    if (StringLen(uMark) < 6) {
	eRetval = "eOTLibPreProcessCmd uMark: too short " +uMark;
	return(eRetval);
    }
    if (iLen <= 4) {
	eRetval = "eOTLibPreProcessCmd: split failed on field 5 ";
	return(eRetval);
    }
    uCmd = StringTrimRight(aArrayAsList[4]);
    
    if (iLen > 5) {
	uArg1 = StringTrimRight(aArrayAsList[5]);
	if (iLen > 6) {
	    uArg2 = StringTrimRight(aArrayAsList[6]);
	    if (iLen > 7) {
		uArg3 = StringTrimRight(aArrayAsList[7]);
		if (iLen > 8) {
		    uArg4 = StringTrimRight(aArrayAsList[8]);
		    if (iLen > 9) {
			uArg5 = StringTrimRight(aArrayAsList[9]);
		    }
		}
	    }
	}
    }
    ArrayResize(aArrayAsList, 10);
    aArrayAsList[0] = uType;
    aArrayAsList[1] = uChart;
    aArrayAsList[2] = uPeriod;
    aArrayAsList[3] = uMark;
    aArrayAsList[4] = uCmd;
    aArrayAsList[5] = uArg1;
    aArrayAsList[6] = uArg2;
    aArrayAsList[7] = uArg3;
    aArrayAsList[8] = uArg4;
    aArrayAsList[9] = uArg5;
    return("");
}


string zProcessCmdTer(string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="";

    if (uCmd == "TerminalCompany") {
	uRetval = "string|" +TerminalCompany();
    } else if (uCmd == "TerminalName") {
	uRetval = "string|" +TerminalName();
    } else if (uCmd == "TerminalPath") {
	uRetval = "string|" +TerminalPath();
    } else {
	uMsg = "Unrecognized action: " +uCmd;
	vWarn("zProcessCmdTer: " +uMsg);
	uRetval = "";
    }

    return (uRetval);
}

string zProcessCmdWin(string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="none|";
    int iIndex, iPeriod;

    if (uCmd == "WindowBarsPerChart") {
	uRetval = "int|" +WindowBarsPerChart();
    } else if (uCmd == "WindowFind") {
	uRetval = "string|" +WindowFind(uArg1);
    } else if (uCmd == "WindowFirstVisibleBar") {
	uRetval = "int|" +WindowFirstVisibleBar();
    } else if (uCmd == "WindowHandle") {
	iPeriod=StrToInteger(uArg2);
	uRetval = "int|" +WindowHandle(uArg1, iPeriod);
    } else if (uCmd == "WindowIsVisible") {
	iIndex=StrToInteger(uArg1);
	uRetval = "bool|" +WindowIsVisible(iIndex);
    } else if (uCmd == "WindowOnDropped") {
	uRetval = "int|" +WindowOnDropped();
    } else if (uCmd == "WindowPriceMax") {
	iIndex=StrToInteger(uArg1);
	uRetval = "double|" +WindowPriceMax(iIndex);
    } else if (uCmd == "WindowPriceMin") {
	iIndex=StrToInteger(uArg1);
	uRetval = "double|" +WindowPriceMin(iIndex);
    } else if (uCmd == "WindowPriceOnDropped") {
	uRetval = "double|" +WindowPriceOnDropped();
    } else if (uCmd == "WindowRedraw") {
	WindowRedraw();
	uRetval = "void|";
	// WindowScreenShot
    } else if (uCmd == "WindowTimeOnDropped") {
	uRetval = "datetime|" +WindowTimeOnDropped();
    } else if (uCmd == "WindowXOnDropped") {
	uRetval = "int|" +WindowXOnDropped();
    } else if (uCmd == "WindowYOnDropped") {
	uRetval = "int|" +WindowYOnDropped();
    } else if (uCmd == "WindowsTotal") {
	uRetval = "int|" +WindowsTotal();
    } else {
	uMsg="Unrecognized action: " +uCmd;
	vWarn("zProcessCmdWin: " +uMsg);
	uRetval = "";
    }

    return (uRetval);
}


string zProcessCmdAcc(string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="none|";
    string uSymbol;
    int iCmd;
    double fVolume;

    if (uCmd == "AccountBalance") {
	uRetval = "double|" +AccountBalance();
    } else if (uCmd == "AccountCompany") {
	uRetval = "string|" +AccountCompany();
    } else if (uCmd == "AccountCredit") {
	uRetval = "double|" +AccountCredit();
    } else if (uCmd == "AccountCurrency") {
	uRetval = "string|" +AccountCurrency();
    } else if (uCmd == "AccountEquity") {
	uRetval = "double|" +AccountEquity();
    } else if (uCmd == "AccountFreeMargin") {
	uRetval = "double|" +AccountFreeMargin();
    } else if (uCmd == "AccountFreeMarginCheck") {
	// assert
	uSymbol=uArg1;
	iCmd=StrToInteger(uArg2);
	fVolume=StrToDouble(uArg3);
	uRetval = "double|" +AccountFreeMarginCheck(uSymbol, iCmd, fVolume);
    } else if (uCmd == "AccountFreeMarginMode") {
	uRetval = "double|" +AccountFreeMarginMode();
    } else if (uCmd == "AccountLeverage") {
	uRetval = "int|" +AccountLeverage();
    } else if (uCmd == "AccountMargin") {
	uRetval = "double|" +AccountMargin();
    } else if (uCmd == "AccountName") {
	uRetval = "string|" +AccountName();
    } else if (uCmd == "AccountNumber") {
	uRetval = "int|" +AccountNumber();
    } else if (uCmd == "AccountProfit") {
	uRetval = "double|" +AccountProfit();
    } else if (uCmd == "AccountServer") {
	uRetval = "string|" +AccountServer();
    } else if (uCmd == "AccountStopoutLevel") {
	uRetval = "int|" +AccountStopoutLevel();
    } else if (uCmd == "AccountStopoutMode") {
	uRetval = "int|" +AccountStopoutMode();
    } else {
	uMsg="Unrecognized action: " +uCmd;
	vWarn("zProcessCmdAcc: " +uMsg);
	uRetval="";
    }

    return (uRetval);
}

string zProcessCmdGlo(string uCmd, string uChart, string uPeriod, string uArg1, string uArg2, string uArg3, string uArg4, string uArg5) {
    string uMsg;
    string uRetval="none|";
    string sName;
    double fValue;

    if (uCmd == "GlobalVariableCheck") {
	// assert
	sName = uArg1;
	uRetval = "bool|" +GlobalVariableCheck(sName);
    } else if (uCmd == "GlobalVariableDel") {
	// assert
	sName = uArg1;
	uRetval = "bool|" +GlobalVariableDel(sName);
    } else if (uCmd == "GlobalVariableGet") {
	// assert
	sName = uArg1;
	uRetval = "double|" +GlobalVariableGet(sName);
    } else if (uCmd == "GlobalVariableSet") {
	// assert
	sName = uArg1;
	fValue = StrToDouble(uArg2);
	uRetval = "double|" +GlobalVariableSet(sName, fValue);
    } else {
	uMsg = "Unrecognized action: " +uCmd;
	vWarn("zProcessCmdGlo: " +uMsg);
	uRetval = "";
    }

    return (uRetval);
}
