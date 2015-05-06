// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

#property copyright "Copyright 2015 Open Trading"
#property link      "https://github.com/OpenTrading/"

#import "OTMql4/OTLibSimpleFormatCmd.ex4"

string eOTLibSimpleUnformatCmd(string& aArrayAsList[]);

string zOTLibSimpleFormatCmd(string uType, string uChart, int iPeriod, string uMark, string uCmd);
string zOTLibSimpleFormatTick(string uType, string uChart, int iPeriod, string uMark, string uInfo);
string zOTLibSimpleFormatRetval(string uType, string uChart, int iPeriod, string uMark, string uInfo);
