//
//  GBUtilities.h
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOL NSIsStringEmpty(NSString* aString);
BOOL isValidHTTPResponseCode(int httpResponseCode);

NSError* _eHiliteDomainErrorForHTTPURLResponse(NSHTTPURLResponse *httpURLResponse);
NSError* _eHiliteDomainErrorForGenericNSError(NSError *error);
NSError* _eHiliteDomainErrorForAPIErrorCode(APIErrorCodes _eHiliteDomainErrorCode);
NSError* _eHiliteDomainErrorForAPIErrorInServiceWithMessage(NSString *serviceName, NSString *errorMessage);
    
NSString* errorDescriptionFor_eHiliteDomainErrorCode(APIErrorCodes _eHiliteDomainErrorCode);
NSString* requestFailureStringForService(NSString *requestMethodName);

CGRect boundsForFrame(CGRect frame);

    
#ifdef __cplusplus
}
#endif