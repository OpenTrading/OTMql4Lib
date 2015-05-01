// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

#property copyright "Copyright 2015 Open Trading"
#property link      "https://github.com/OpenTrading/"

#import "OTMql4/OTLibMt4ProcessCmd.ex4"

string eOTLibPreProcessCmd(string& aArrayAsList[]);
string zOTLibMt4FormatCmd(string uType, string uChart, int iPeriod, string uMark, string uCmd);
string zOTLibMt4FormatTick(string uType, string uChart, int iPeriod, string uMark, string uInfo);
string zOTLibMt4ProcessCmd(string uMess);
