//
//  GBAlertWindow.m
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "GBAlertWindow.h"
#import "GBUtilities.h"

static GBAlertWindow *gSharedAlertWindow = nil;


@implementation GBAlertWindow

+ (GBAlertWindow*)sharedAlertWindow {
	
    @synchronized(self) 
	{
        if (gSharedAlertWindow == nil) 
		{
            [[self alloc] init]; // assignment not done here
        }
    }
    return gSharedAlertWindow;
}

+ (id)allocWithZone:(NSZone *)zone {
	
    @synchronized(self) 
	{
        if (gSharedAlertWindow == nil) 
		{
            gSharedAlertWindow = [super allocWithZone:zone];
            return gSharedAlertWindow;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
	
    return self;
}

- (id)retain {
	
    return self;
}

- (unsigned)retainCount {
	
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
	
    //do nothing
}

- (id)autorelease {
	
    return self;
}

- (void)showMessage:(NSString*)message {
	
	if(!NSIsStringEmpty(message) && [[message lowercaseString] rangeOfString:@"twitts"].location==NSNotFound)
	{
		UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertView setMessage:message];
		
		[alertView show];
		
		[alertView release];	
	}
}

- (void)showMessage:(NSString *)message forRequestMethod:(NSString *)requestMethod {
	
	NSString *requestFailureMessage = requestFailureStringForService(requestMethod);
	
	if(!NSIsStringEmpty(message) && !NSIsStringEmpty(requestFailureMessage) && [[message lowercaseString] rangeOfString:@"twitts"].location==NSNotFound)
	{
		UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertView setMessage:[NSString stringWithFormat:@"%@ - %@",requestFailureMessage,message]];
		
		[alertView show];
		
		[alertView release];	
	}
}

- (void) showMessage:(NSString *)message withKey:(APIErrorCodes)errorCode bufferTime:(NSTimeInterval)time {

	if(!NSIsStringEmpty(message) && [[message lowercaseString] rangeOfString:@"twitts"].location==NSNotFound)
	{
		if(mApiErrorCodeDictionary  == nil)
			mApiErrorCodeDictionary = [[NSMutableDictionary alloc] init];
		
		if([mApiErrorCodeDictionary objectForKey:[NSNumber numberWithInt:errorCode]] == nil)
			[mApiErrorCodeDictionary setObject:[[NSDate date] addTimeInterval:-time] forKey:[NSNumber numberWithInt:errorCode]];
		
		NSDate *storedDate = [mApiErrorCodeDictionary objectForKey:[NSNumber numberWithInt:errorCode]];

		if( !NSIsStringEmpty(message) && [[NSDate date] timeIntervalSinceDate:storedDate] > time )
		{
			UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			
			[alertView setMessage:message];
			
			[alertView show];
			
			[alertView release];	
			
			[mApiErrorCodeDictionary setObject:[NSDate date] forKey:[NSNumber numberWithInt:errorCode]];
		}
		else
		{
		}
	}
	
}

- (void)showDelegatedMessage:(NSString *)message cancelTitle:(NSString *)cancelText otherTitle:(NSString *)otherText delegate:(id)aDelegate alertId:(int)aAlertId {

	if(!NSIsStringEmpty(message))
	{
		UIAlertView	*alertView = [[UIAlertView alloc] initWithTitle:kAlertTitle message:@"" delegate:aDelegate cancelButtonTitle:cancelText otherButtonTitles:otherText, nil];
		
		[alertView setMessage:message];
		
		[alertView setTag:aAlertId];
		
		[alertView show];
		
		[alertView release];	
	}
}

- (void)showErrorMessageForErrorCode:(APIErrorCodes)errorCode {
	
	switch (errorCode) 
	{
		case eErrorCodeNoInternet:
		{
			[[GBAlertWindow sharedAlertWindow] showMessage:@"No internet is presently available. Please try again later" withKey:eErrorCodeNoInternet bufferTime:3.0];
			
			break;
		}
		case eErrorCodeServerDown:
		{
			break;
		}
        default:
            [[GBAlertWindow sharedAlertWindow] showMessage:@"Some error. Please excuse us while we call on the elves to fix these issues"];
	}
}

- (void)showWaitAlertWithMessage:(NSString *)message {
	
	if(!mWaitAlert)
	{
		mWaitAlert = [[UIAlertView alloc] initWithTitle:kAlertTitle message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		
		UIActivityIndicatorView* actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
		[actIndicator startAnimating];
		
		actIndicator.frame = CGRectMake(130.0, 90.0, 20.0, 20.0);
		
		[mWaitAlert addSubview:actIndicator];
		
		[actIndicator release];
	}
	
	if (![mWaitAlert isVisible])
	{
		[mWaitAlert setMessage:message];
		
		[mWaitAlert show];		
	}	
}

- (void)hideAlertWithCancel {
	
	if(mWaitAlertWithCancel)
	{
		[mWaitAlertWithCancel dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)hideWaitAlert {
	
	if(mWaitAlert)
	{
		[mWaitAlert dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)startProgressIndicator {
	
	if(!mActivityIndicator)
	{
		mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		
		[mActivityIndicator setCenter:CGPointMake(160,240)];
		
		mActivityIndicator.hidesWhenStopped = YES;
	}
	
	[self stopProgressIndicator];	
	
	[mActivityIndicator startAnimating];
}

- (void)startModelProgressIndicator {
	
	if(!mModelProgressView)
	{	
		mModelProgressView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	}
	
	[self startProgressIndicator];	
}

- (void)stopProgressIndicator {
	
	if([mActivityIndicator isAnimating])
		[mActivityIndicator stopAnimating];
}

- (void)stopModelProgressIndicator {
	
	[self stopProgressIndicator];
	
	if(mModelProgressView && [mModelProgressView superview])
	{
		[mModelProgressView removeFromSuperview];
	}
}

- (void)setIsAnimatingStatusBarActivityIndicator:(BOOL)isAnimatingStatusBarActivityIndicator {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isAnimatingStatusBarActivityIndicator];
}


- (void)dealloc {
	
	if(mApiErrorCodeDictionary)
		[mApiErrorCodeDictionary release];
		
	if(mActivityIndicator)
		[mActivityIndicator release];
	
	if(mWaitAlert)
		[mWaitAlert release];
	
    [super dealloc];
}
@end

