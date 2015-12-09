//
//  GBEditTicketCustomCell.m
//  TicketBlast
//
//  Created by Mohammed Shahid on 28/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBEditTicketCustomCell.h"

@implementation GBEditTicketCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
    {
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y - 4.0, self.textLabel.frame.size.width + 28.0, self.textLabel.frame.size.height + 6.0);
    }
    else
    {
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y - 4.0, self.textLabel.frame.size.width + 55.0, self.textLabel.frame.size.height + 6.0);
    }
	self.textLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:17.0];
	self.textLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
	self.textLabel.backgroundColor = [UIColor whiteColor];
    self.textLabel.textAlignment = UITextAlignmentLeft;
	
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
    {
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x+24.0, self.detailTextLabel.frame.origin.y - 2.0,self.detailTextLabel.frame.size.width +42.0,self.detailTextLabel.frame.size.height);
    }
    else
    {
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x+52.0, self.detailTextLabel.frame.origin.y - 2.0,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    }
	self.detailTextLabel.font = [UIFont fontWithName:@"Gotham-Book" size:15.0];
	self.detailTextLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
	self.detailTextLabel.backgroundColor = [UIColor whiteColor];
}


@end
