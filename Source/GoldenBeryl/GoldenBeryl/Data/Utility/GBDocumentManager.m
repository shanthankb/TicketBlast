//
//  GBDocumentManager.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 21/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBDocumentManager.h"
@implementation GBDocumentManager

static GBDocumentManager * sharedInstanceManager = nil;

#pragma mark Initialization methods

+ (GBDocumentManager *) sharedInstance
{
	@synchronized(self)
	{
		if (sharedInstanceManager == nil)
		{
			sharedInstanceManager = [[GBDocumentManager alloc] init];
		}
	}
    
	return sharedInstanceManager;
}

-(void) addEntryForAutoComplete:(NSArray *)ticketDetails
{
	if (!self.ticketData)
	{
		self.ticketData = [[NSArray alloc]init];
	}
	
     self.ticketData  = ticketDetails;
}


#pragma mark -
#pragma mark AutoCompleteData

//Returns an Array of Data for Autocomplete for given key
//Keys can be like Venue,Name

-(NSArray *) autocompleteDataOfField:(NSString *)type
{
	NSMutableArray *autoCompleteArray = [[NSMutableArray alloc]init];
	
	[self.ticketData enumerateObjectsUsingBlock:^(GBEntry * data, NSUInteger idx, BOOL *stop) {

		if ([type isEqualToString:kEventVenue] && data.ticketdata.venue)
		{
			[autoCompleteArray addObject:data.ticketdata.venue];
		}
		else if ([type isEqualToString:kEventName] && data.ticketdata.eventName)
		{
			[autoCompleteArray addObject:data.ticketdata.eventName];
		}
		else if (([type isEqualToString:kOpponent] && data.ticketdata.opponentTeam )|| ([type isEqualToString:kHomeTeam] && data.ticketdata.homeTeam))
		{
            if (data.ticketdata.opponentTeam) {
                [autoCompleteArray addObject:data.ticketdata.opponentTeam];
            }
			if (data.ticketdata.homeTeam) {
                [autoCompleteArray addObject:data.ticketdata.homeTeam];
            }
            
		}
		else if ([type isEqualToString:kHeadline] && data.ticketdata.headLine)
		{
			[autoCompleteArray addObject:data.ticketdata.headLine];
		}
	}];
	
	NSSet *uniqueEvents = [NSSet setWithArray:autoCompleteArray];

	[autoCompleteArray removeAllObjects];
	
	[autoCompleteArray addObjectsFromArray:[uniqueEvents allObjects]];
	
	NSArray *sortedArray = [autoCompleteArray sortedArrayUsingSelector:
				   @selector(localizedCaseInsensitiveCompare:)];
	
	return sortedArray;
} 

@end
