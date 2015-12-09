//
//  GBUserDataSource.m
//
//  Created by Sourcebits on 14/01/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBUserDataSource.h"

@implementation GBUserDataSource

static GBUserDataSource *sSharedUserDataSource = nil;

+ (GBUserDataSource *)sharedUserDataSource {
    
    if(!sSharedUserDataSource)
    {
        sSharedUserDataSource = [[GBUserDataSource alloc] init];
    }
    
    return sSharedUserDataSource;
}


- (id)init {
    
    self = [super init];
    
    if(self)
    {
        _firstName = [[NSString alloc]init];
        _lastName = [[NSString alloc]init];
        _deviceId = [[NSString alloc]init];
        _email = [[NSString alloc]init];
        _phoneNumber = [[NSString alloc]init];
        _companyName = [[NSString alloc]init];
        _authToken = [[NSString alloc] init];
        _isInvestor = NO;
        self.spentAmout = 0;
        self.appEnvironment = eEventInProgress;
        self.shouldForceLoadHistory = NO;

        [self loadExistingUserData];
    }
    
    return self;
}


- (void)loadExistingUserData {

}

- (BOOL)isUserLogged {
    
    if(self.userId && self.deviceId)
        return YES;
    else
        return NO;
}

- (void)clearUserCredentials {
    
    self.userId = nil;
    self.deviceId = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.companyName = nil;
    self.phoneNumber = nil;
    self.email = nil;
    self.deviceToken = nil;
    self.authToken = nil;
	self.spentAmout = 0;
    
    [self saveUserData];
}

- (void)saveUserData {
        
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
