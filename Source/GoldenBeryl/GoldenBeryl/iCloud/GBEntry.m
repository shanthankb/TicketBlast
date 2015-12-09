//
//  GBEntry.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBEntry.h"

@implementation GBEntry

@synthesize fileURL = _fileURL;
@synthesize metadata = _metadata;
@synthesize state = _state;
@synthesize version = _version;

- (id)initWithFileURL:(NSURL *)fileURL ticketData:(GBTicketData *)ticketData metadata:(GBMetadata *)metadata state:(UIDocumentState)state version:(NSFileVersion *)version {
	
    if ((self = [super init])) {
        self.fileURL = fileURL;
        self.metadata = metadata;
        self.state = state;
        self.version = version;
		self.ticketdata = ticketData;
    }
    return self;
	
}

- (NSString *) description {
    return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
}


@end
