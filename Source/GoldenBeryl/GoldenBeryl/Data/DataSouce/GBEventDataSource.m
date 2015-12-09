//
//  GBEventDataSource.m
//
//  Created by RaghunandanR on 21/01/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBEventDataSource.h"

@implementation GBEventDataSource

#pragma mark - SINGLETON CREATION

+ (GBEventDataSource *) sharedDataSource
{
    static GBEventDataSource *g_sDataSource = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        g_sDataSource = [[GBEventDataSource alloc] init];
        // Do any other initialisation stuff here
    });
    
    return g_sDataSource;
}




#pragma mark -
#pragma mark - Operation Management Methods

- (void) storeOperation:(id) operation forDelegate:(id) delegate
{
	//[[SQLaunchEngine sharedLaunchEngine] storeOperation:operation forDelegate:delegate];
}

- (void) cancelCompletedOperationWithIdentifier:(NSString *) operationIdentifier forDelegate:(id) delegate
{
	//[[SQLaunchEngine sharedLaunchEngine] removeCompletedOperationWithIdentifier:operationIdentifier forDelegate:delegate];
}

- (void) cancelAllOperationsForDelegate:(id) delegate
{
	//[[SQLaunchEngine sharedLaunchEngine] cancelAllOperationsForDelegate:delegate];
}

@end
