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
#include <OTMql4/OTLibSimpleFormatCmd.mqh>

string zOTLibSimpleFormatCmd(string uType, string uChart, int iPeriod, string uMark, string uCmd) {
    string uRetval;
    // uType should be one of: tick retval cmd exec
    uRetval = StringFormat("%s|%s|%d|%s|%s", uType, uChart, iPeriod, uMark, uCmd);
    return(uRetval);
}

// or bar
string zOTLibSimpleFormatTick(string uType, string uChart, int iPeriod, string uMark, string uInfo) {
    string uRetval;
    // uType should be one of: tick bar
    uInfo = Bid +"|" +Ask +"|" +uInfo;
    //? uInfo  = iACCNUM +"|" +uInfo;
    uRetval = StringFormat("%s|%s|%d|%s|%s", uType, uChart, iPeriod, uMark, uInfo);
    return(uRetval);
}

// or bar
string zOTLibSimpleFormatRetval(string uType, string uChart, int iPeriod, string uMark, string uInfo) {
    string uRetval;
    // uType should be one of: retval
    uRetval = StringFormat("%s|%s|%d|%s|%s", uType, uChart, iPeriod, uMark, uInfo);
    return(uRetval);
}

string eOTLibSimpleUnformatCmd (string& aArrayAsList[]) {
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
	eRetval = "eOTLibSimpleUnformatCmd iLen=0: split failed with " +"|";
	return(eRetval);
    }
    uType = StringTrimRight(aArrayAsList[0]);
    
    if (iLen < 2) {
	eRetval = "eOTLibSimpleUnformatCmd: split failed on field 2 ";
	return(eRetval);
    }
    uChart = StringTrimRight(aArrayAsList[1]);

    if (iLen < 3) {
	eRetval = "eOTLibSimpleUnformatCmd: split failed on field 3 ";
	return(eRetval);
    }
    uPeriod = StringTrimRight(aArrayAsList[2]);
    
    if (iLen < 4) {
	eRetval = "eOTLibSimpleUnformatCmd: split failed on field 4 ";
	return(eRetval);
    }
    uMark = StringTrimRight(aArrayAsList[3]);
    if (StringLen(uMark) < 6) {
	eRetval = "eOTLibSimpleUnformatCmd uMark: too short " +uMark;
	return(eRetval);
    }
    if (iLen <= 4) {
	eRetval = "eOTLibSimpleUnformatCmd: split failed on field 5 ";
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

