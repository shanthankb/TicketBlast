//
//  GBDocumentManager.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBEntry.h"
#import "GBTicketData.h"

@interface GBDocumentManager : NSObject

+ (GBDocumentManager *) sharedInstance;

-(void) addEntryForAutoComplete:(NSArray *)ticketDetails;

-(NSArray *) autocompleteDataOfField:(NSString *)type;

@property (strong ,nonatomic) NSArray *ticketData;

@end
