//
//  GBDocument.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBDocument.h"
#import "GBData.h"
#import "GBMetadata.h"
#import "GBTicketData.h"
#import "UIImageExtras.h"

#define METADATA_FILENAME   @"photo.metadata"
#define DATA_FILENAME       @"photo.data"
#define TICKETDATA_FILENAME @"photo.ticketdata"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ACTUAL_SCREEN_SIZE (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? 4.0f : 3.5f

#define WIDE_SCREEN_WIDTH 4.0f

#define kTicketHeight (176.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))
#define kTicketWidth  (176.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))
#define kReflectionHeight (26.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))


@interface GBDocument()
@property (nonatomic, strong) GBData * data;
@property (nonatomic, strong) NSFileWrapper * fileWrapper;
@end

@implementation GBDocument

@synthesize data = _data;
@synthesize fileWrapper = _fileWrapper;
@synthesize metadata = _metadata;


- (void)encodeObject:(id<NSCoding>)object toWrappers:(NSMutableDictionary *)wrappers preferredFilename:(NSString *)preferredFilename {
    @autoreleasepool {
        NSMutableData * data = [NSMutableData data];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:@"data"];
        [archiver finishEncoding];
        NSFileWrapper * wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	
    if (self.metadata == nil || self.data == nil) {
        return nil;
    }
	
    NSMutableDictionary * wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:self.metadata toWrappers:wrappers preferredFilename:METADATA_FILENAME];
    [self encodeObject:self.data toWrappers:wrappers preferredFilename:DATA_FILENAME];
	[self encodeObject:self.ticketdata toWrappers:wrappers preferredFilename:TICKETDATA_FILENAME];

	NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
	
    return fileWrapper;
	
}

- (id)decodeObjectFromWrapperWithPreferredFilename:(NSString *)preferredFilename {
	
    NSFileWrapper * fileWrapper = [self.fileWrapper.fileWrappers objectForKey:preferredFilename];
    if (!fileWrapper) {
        NSLog(@"Unexpected error: Couldn't find %@ in file wrapper!", preferredFilename);
        return nil;
    }
	
    NSData * data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	
    return [unarchiver decodeObjectForKey:@"data"];
	
}

- (GBTicketData *)ticketdata {
    if (_ticketdata == nil) {
        if (self.fileWrapper != nil) {
            self.ticketdata = [self decodeObjectFromWrapperWithPreferredFilename:TICKETDATA_FILENAME];
        } else {
            self.ticketdata = [[GBTicketData alloc] init];
        }
    }
    return _ticketdata;
}


- (GBMetadata *)metadata {
    if (_metadata == nil) {
        if (self.fileWrapper != nil) {
            self.metadata = [self decodeObjectFromWrapperWithPreferredFilename:METADATA_FILENAME];
        } else {
            self.metadata = [[GBMetadata alloc] init];
        }
    }
    return _metadata;
}

- (GBData *)data {
    if (_data == nil) {
        if (self.fileWrapper != nil) {
            self.data = [self decodeObjectFromWrapperWithPreferredFilename:DATA_FILENAME];
        } else {
            self.data = [[GBData alloc] init];
        }
    }
    return _data;
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	
    self.fileWrapper = (NSFileWrapper *) contents;
	
    // The rest will be lazy loaded...
    self.data = nil;
    self.metadata = nil;
	self.ticketdata = nil;
	
    return YES;
	
}

- (NSString *) description {
    return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
}

#pragma mark Accessors

- (UIImage *)photo {
    return self.data.photo;
}

- (void)setPhoto:(UIImage *)photo {
	
    if ([self.data.photo isEqual:photo]) return;
	
    UIImage * oldPhoto = self.data.photo;
    self.data.photo = photo;
    self.metadata.thumbnail = [self.data.photo imageByScalingAndCroppingForSize:CGSizeMake(kTicketWidth * 2, (kTicketHeight- (51.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH))))*2 + 10)];
    	
    [self.undoManager setActionName:@"Image Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setPhoto:) object:oldPhoto];
}

@end
