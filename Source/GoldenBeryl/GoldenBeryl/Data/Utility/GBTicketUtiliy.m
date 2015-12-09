//
//  GBTicketUtiliy.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 10/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBTicketUtiliy.h"
#import "GBManager.h"


@implementation GBTicketUtiliy

static GBTicketUtiliy * sharedInstanceManager = nil;

#pragma mark Initialization methods

+ (GBTicketUtiliy *) sharedInstance
{
	@synchronized(self)
	{
		if (sharedInstanceManager == nil)
		{
			sharedInstanceManager = [[GBTicketUtiliy alloc] init];
		}
	}
    
	return sharedInstanceManager;
}


-(NSArray *)cellFieldsForEventType:(NSString *)eventType
{
	NSArray *cellFields;
	if ([eventType isEqualToString:kEventTypeConcert])
    {
		cellFields = [[NSArray alloc]initWithObjects:kEventVenue,kHeadline,kEventDate,nil];
	}
    else if ([eventType isEqualToString:kEventTypeGame])
    {
		cellFields = [[NSArray alloc]initWithObjects:kEventVenue,kHomeTeam,kOpponent,kEventDate,nil];
    }
    else
    {
        cellFields = [[NSArray alloc]initWithObjects:kEventVenue,kEventName,kEventDate,nil];
    }
	return cellFields;
}

-(NSString *) CoverFlowHeadLineForTicketID :(NSString *)ticketId
{
	NSDictionary *ticketData = [[GBManager sharedInstance] getTicketDetailsForID:ticketId];
	
	if ([[ticketData objectForKey:kEventType]  isEqualToString:kEventTypeConcert])
	{
		return [ticketData objectForKey:kHeadline];
	}
	else if ([[ticketData objectForKey:kEventType]  isEqualToString:kEventTypeGame])
	{
		return [NSString stringWithFormat:@"%@ vs %@",[ticketData objectForKey:kHomeTeam],[ticketData objectForKey:kOpponent]];
	}
	else
	{
		return [ticketData objectForKey:kEventName];
	}

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = newSize.width/newSize.height;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = newSize.height / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = newSize.height;
        }
        else{
            imgRatio = newSize.width / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = newSize.width;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    //UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



@end
