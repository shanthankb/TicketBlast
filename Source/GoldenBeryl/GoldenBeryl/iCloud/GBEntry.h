//
//  GBEntry.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GBMetadata;
@class GBTicketData;

@interface GBEntry : NSObject

@property (strong) NSURL * fileURL;
@property (strong) GBMetadata * metadata;
@property (strong) GBTicketData *ticketdata;
@property (assign) UIDocumentState state;
@property (strong) NSFileVersion * version;

- (id)initWithFileURL:(NSURL *)fileURL ticketData:(GBTicketData *)ticketData metadata:(GBMetadata *)metadata state:(UIDocumentState)state version:(NSFileVersion *)version;
- (NSString *) description;

@end
