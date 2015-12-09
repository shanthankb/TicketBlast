//
//  GBAlertWindow.h
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBErrors.h"

@interface GBAlertWindow : NSObject {
	
	UIActivityIndicatorView		 *mActivityIndicator;
	UIAlertView							 *mWaitAlert;
	UIAlertView				   *mWaitAlertWithCancel;
	UIView						 *mModelProgressView;
	
	NSMutableDictionary		*mApiErrorCodeDictionary;
}

+ (GBAlertWindow*) sharedAlertWindow;

- (void)showMessage:(NSString*)message;
- (void)showMessage:(NSString *)message forRequestMethod:(NSString *)requestMethod;
- (void)showMessage:(NSString *)message withKey:(APIErrorCodes)errorCode bufferTime:(NSTimeInterval)time;
- (void)showDelegatedMessage:(NSString *)message cancelTitle:(NSString *)cancelText otherTitle:(NSString *)otherText delegate:(id)aDelegate alertId:(int)aAlertId;
- (void)showErrorMessageForErrorCode:(APIErrorCodes)errorCode;

- (void)startProgressIndicator;
- (void)stopProgressIndicator;
- (void)stopModelProgressIndicator;
- (void)startModelProgressIndicator;

- (void)setIsAnimatingStatusBarActivityIndicator:(BOOL)isAnimatingStatusBarActivityIndicator;
- (void)showWaitAlertWithMessage:(NSString *)message;
- (void)hideAlertWithCancel;
- (void)hideWaitAlert;

@end
