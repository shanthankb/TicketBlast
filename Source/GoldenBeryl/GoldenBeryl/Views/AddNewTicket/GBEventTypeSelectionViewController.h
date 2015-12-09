//
//  GBEventTypeSelectionViewController.h
//
//  Created by Abhiman Puranik on 20/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBNewTicketViewController;

@interface GBEventTypeSelectionViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>

@property (nonatomic , weak) GBNewTicketViewController *delegate;
@property (nonatomic , strong) UITableView *eventTypeTableView;
@property (nonatomic , strong) NSArray *eventTypeArray;
@property (nonatomic , strong) NSString *eventType;

@end
