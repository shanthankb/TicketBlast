//
//  GBTicketData.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBTicketData : NSObject <NSCoding>

@property (strong) NSString * venue;

@property (strong) NSString * eventType;

@property (strong) NSString * date;

@property (strong) NSString * homeTeam;

@property (strong) NSString * opponentTeam;

@property (strong) NSString * eventName;

@property (strong) NSString * headLine;

@property (strong) NSString * eventNotes;

@property (strong) NSDate *dateFormat;

@end
