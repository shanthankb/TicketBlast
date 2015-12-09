//
//  GBUserDataSource.h
//
//  Created by Sourcebits on 14/01/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    eEventCompletelyOver = 0,
    eEventInProgress = 1,
    eEventIntermediatelyOpen = 2
    
} eEventAndLoginState;

@interface GBUserDataSource : NSObject
{
    
}

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, assign) BOOL     isInvestor;
@property (nonatomic , assign) NSInteger  spentAmout;
@property  (nonatomic, retain) NSString  *authToken;
@property (nonatomic, assign) eEventAndLoginState appEnvironment;
@property (nonatomic, assign)BOOL      shouldForceLoadHistory;

+(GBUserDataSource *)sharedUserDataSource;
- (void)saveUserData;
- (BOOL)isUserLogged;
@end
