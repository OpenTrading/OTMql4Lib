// -*-mode: c; c-style: stroustrup; c-basic-offset: 4; coding: utf-8-dos -*-

#property copyright "Copyright 2013 OpenTrading"
#property link      "https://github.com/OpenTrading/"

#import "OTMql4/OTLibTrading.ex4"

int iOTOrderSelect(int iIndex, int iSelect, int iPool);
int iOTOrderSend(string sSymbol, int cmd,
		 double volume, double price,
		 int slippage, double stoploss, double takeprofit,
		 string comment, int magic, datetime expiration,
		 color arrow_color);
int iOTOrderCloseFull(int iTicket, double fPrice, int iSlippage, color cColor=CLR_NONE);
int iOTOrderClose(int iTicket,  double fLots, double fPrice, int iSlippage, color cColor=CLR_NONE);

// int iOTOrderOpen(int iTicket,  double fLots, double fPrice, int iSlippage, color cColor=CLR_NONE);

bool bOTIsTradeAllowed();
int iOTSetTradeIsBusy(int iMaxWaitingSeconds);
int iOTSetTradeIsNotBusy();

double fOTExposedEcuInMarket(int iOrderEAMagic);
int iOTMarketInfo(string s, int iMode);
bool bOTModifyTrailingStopLoss(int iTrailingStopLossPoints,
			       datetime tExpiration);
bool bOTModifyOrder(string sMsg,
		  int iTicket,
		  double fPrice,
		  double fStopLoss,
		  double fTakeProfit,
		  datetime tExpiration);
bool bOTContinueOnOrderError(int iTicket);
