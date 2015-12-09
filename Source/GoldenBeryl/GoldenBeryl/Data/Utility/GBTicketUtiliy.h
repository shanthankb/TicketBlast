//
//  GBTicketUtiliy.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 10/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBTicketUtiliy : NSObject

+ (GBTicketUtiliy *) sharedInstance;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

-(NSArray *)cellFieldsForEventType:(NSString *)eventType;

-(NSString *) CoverFlowHeadLineForTicketID :(NSString *)ticketId;

@end
