//
//  GBDocument.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBData;
@class GBMetadata;
@class GBTicketData;


#define TB_EXTENSION @"tkb"


@interface GBDocument : UIDocument

// Data
- (UIImage *)photo;
- (void)setPhoto:(UIImage *)photo;

// Metadata
@property (nonatomic, strong) GBMetadata * metadata;

//TicketData
@property (nonatomic, strong) GBTicketData *ticketdata;

- (NSString *) description;

@end
