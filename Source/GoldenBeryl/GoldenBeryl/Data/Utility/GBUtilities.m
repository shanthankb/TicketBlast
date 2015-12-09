//
//  GBUtilities.m
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "GBUtilities.h"

#import "GBErrors.h"

#define kDBDateFormat12 @"MM/dd/yyyy h-mma"
#define kDBDateFormat24 @"MM/dd/yyyy h-MM"

BOOL NSIsStringEmpty(NSString* aString) {
	
	BOOL empty = NO;
	
	if (aString)
	{
		if([aString length] == 0)
		{
			empty = YES;
		}
	}
	else 
	{
		empty = YES;
	}

	return empty;
}

BOOL isValidHTTPResponseCode(int httpResponseCode) {
	
	if(httpResponseCode == 200 || httpResponseCode == 201 || httpResponseCode == 400)
	{
		return YES;
	}
	else
		return NO;
	
}


NSString* requestFailureStringForService(NSString *serviceName) {
	
	NSString *failureString = @"Request failed";
    
	return failureString;
}


CGRect boundsForFrame(CGRect frame) {
    
    CGRect boundsRect = frame;
    boundsRect.origin.x = 0.0;
    boundsRect.origin.y = 0.0;
    
    return boundsRect;
}


