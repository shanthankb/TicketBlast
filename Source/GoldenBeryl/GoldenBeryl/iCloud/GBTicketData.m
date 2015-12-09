//
//  GBTicketData.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBTicketData.h"

@implementation GBTicketData

@synthesize venue = _venue;
@synthesize eventType = _eventType;
@synthesize date = _date;
@synthesize headLine = _headLine;
@synthesize homeTeam = _homeTeam;
@synthesize opponentTeam = _opponentTeam;
@synthesize eventName = _eventName;
@synthesize eventNotes =_eventNotes;
@synthesize dateFormat = _dateFormat;

- (id)initWithVenue:(NSString *)venue EventType:(NSString *)eventType date:(NSString *)date headLine:(NSString *)headLine homeTeam:(NSString *)homeTeam opponentTeam:(NSString *)opponentTeam eventName:(NSString *)eventName eventNotes:(NSString *)eventNotes dateFormat:(NSDate *)dateFormat{
    if ((self = [super init])) {
        self.venue = venue;
		self.eventType = eventType;
		self.date = date;
		self.eventName = eventName;
		self.opponentTeam = opponentTeam;
		self.homeTeam = homeTeam;
		self.headLine = headLine;
		self.eventNotes = eventNotes;
		self.dateFormat = dateFormat;
    }
    return self;
}

- (id)init {
    return [self initWithVenue:nil EventType:nil date:nil headLine:nil homeTeam:nil opponentTeam:nil eventName:nil eventNotes:nil dateFormat:nil];
}

#pragma mark NSCoding

#define kVersionKey @"Version"
#define kVenueKey @"Venue"
#define kEventTypeKey @"EventType"
#define kDateKey @"Day"
#define kHeadLineKey @"HeadLine"
#define kHomeTeamKey @"HomeTeam"
#define kOpponentTeamKey @"OpponentTeam"
#define kEventNameKey  @"EventName"
#define kEventNotesKey @"EventNotes"
#define kEventDateKey @"EventDate"


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:1 forKey:kVersionKey];
	[encoder encodeObject:self.venue forKey:kVenueKey];
	[encoder encodeObject:self.eventType forKey:kEventTypeKey];
	[encoder encodeObject:self.date forKey:kDateKey];
	[encoder encodeObject:self.headLine forKey:kHeadLineKey];
	[encoder encodeObject:self.homeTeam forKey:kHomeTeamKey];
	[encoder encodeObject:self.opponentTeam forKey:kOpponentTeamKey];
	[encoder encodeObject:self.eventName forKey:kEventNameKey];
	[encoder encodeObject:self.eventNotes forKey:kEventNotesKey];
	[encoder encodeObject:self.dateFormat forKey:kEventDateKey];
	
}

- (id)initWithCoder:(NSCoder *)decoder
{
    [decoder decodeIntForKey:kVersionKey];
    NSString * venue = [decoder decodeObjectForKey:kVenueKey];
	NSString * eventType = [decoder decodeObjectForKey:kEventTypeKey];
	NSString * date = [decoder decodeObjectForKey:kDateKey];
	NSString * headLine = [decoder decodeObjectForKey:kHeadLineKey];
	NSString * homeTeam = [decoder decodeObjectForKey:kHomeTeamKey];
	NSString * opponentTeam = [decoder decodeObjectForKey:kOpponentTeamKey];
	NSString * eventName = [decoder decodeObjectForKey:kEventNameKey];
	NSString * eventNotes = [decoder decodeObjectForKey:kEventNotesKey];
	NSDate * eventDate = [decoder decodeObjectForKey:kEventDateKey];
	
    return [self initWithVenue:venue EventType:eventType date:date headLine:headLine homeTeam:homeTeam opponentTeam:opponentTeam eventName:eventName eventNotes:eventNotes dateFormat:eventDate] ;
}


@end
