//
//  GBErrors.h
//
//  Created by Sourcebits Inc
//  Copyright 2012 Research Habits LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum 
{
	eErrorCodeInternalError		= -999,		//Used in extreme scenarios where 'x' data is _supposed_ to be valid/useable, but is not for whatever reason
	eErrorCodeUnknownError		= -1,	
	
	eErrorCodeNoError			= 0000,
	
	//Connectivity errors
	eErrorCodeNoInternet		= 1001,
	eErrorCodeNoInternetAccess	= 1002,
	eErrorCodeRequestTimeout	= 1003,
	
	//Bad request/response errors
	eErrorCodeBadRequest		= 2001,		//Malformed request, or if request returns a 4xx HTTP response code.
	eErrorCodeBadResponse		= 2002,		//Malformed, empty or undecodable response.
	eErrorCodeRequestAuthFailed	= 2003,	
	eErrorCodeIncompleteResponse = 2004,	//Data is not of the expected size, or expected params are missing, etc.
	
	//Server Errors
	eErrorCodeServerDown		= 3001,		//Server is unreachable
	eErrorCodeServerNotFound	= 3002,		//Server address does not resolve
	eErrorCodeServerFailed		= 3003,		//Server error, such as when a 5xx HTTP response code is received.
	
	eErrorCodeBlocked			= 8001,
	
	//Custom/Scenario-specific errors
    eErrorCodeAPICustom         = 9001,
	eErrorCodeOCRImageCaptureFailed  = 9002,	
    eErrorCodeOCRImageUploadFailed   = 9003,
    eErrorCodeOCRScanFailed       = 9004,
	eErrorCodeFileSystemError	  = 9005,
    eErrorCodeUserNotLoggedIn     = 9006,
    eErrorCodeCitationsNotAvailable = 9007,
	
	eErrorCodeConfigUpdated		  = 9000,
	eErrorCodeSessionAuthFailed	  = 9999
	
} APIErrorCodes;


extern NSString *const CXHTTPResponseErrorDomain;
extern NSString *const CXEHighlighterErrorDomain;


#define kOriginalErrorDomain		@"OriginalErrorDomain"
#define kOriginalErrorCode			@"OriginalErrorCode"
#define kOriginalErrorDescription	@"OriginalErrorDescription"


typedef enum
{
    eTwitter = 0,
    eFacebook
} eNetworkType;