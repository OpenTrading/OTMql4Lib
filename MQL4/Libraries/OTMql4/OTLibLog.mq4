// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8; encoding: utf-8-dos -*-

/*
This will provide our logging functions, but is just a
skeleton for now. See OTLibPyLog for logging with Python.
*/

#property copyright "Copyright 2014 Open Trading"
#property link      "https://github.com/OpenTrading/"
#property library

// constants
#define OT_LOG_PANIC 0 // unused
#define OT_LOG_ERROR 1
#define OT_LOG_WARN 2
#define OT_LOG_INFO 3
#define OT_LOG_DEBUG 3
#define OT_LOG_TRACE 4

void vLog(int iLevel, string sMess) {
    Print(sMess);
}

void vError(string sMess) {
  vLog(OT_LOG_ERROR, "ERROR: "+sMess);
}
void vWarn(string sMess) {
  vLog(OT_LOG_WARN, "WARN: "+sMess);
}
void vInfo(string sMess) {
  vLog(OT_LOG_INFO, "INFO: "+sMess);
}
void vDebug(string sMess) {
  vLog(OT_LOG_DEBUG, "DEBUG: "+sMess);
}
void vTrace(string sMess) {
  vLog(OT_LOG_TRACE, "TRACE: "+sMess);
}
