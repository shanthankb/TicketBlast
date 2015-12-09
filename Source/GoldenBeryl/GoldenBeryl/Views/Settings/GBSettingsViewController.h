//
//  GBSettingsViewController.h
//  TicketBlastCoverFlow
//
//  Created by Abhiman Puranik on 21/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class GBSettingsViewController;
@protocol SettingsChangedDelegate <NSObject>

-(void) settingsChanged;

@end

@interface GBSettingsViewController : UIViewController <UITableViewDataSource , UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic , assign) NSInteger numberOfTickets;

@property (nonatomic , strong) UITableView *settingsTable;

@property (nonatomic, weak) id <SettingsChangedDelegate> delegate;

@end
