//
//  GBTicketViewController.h
//  TicketBlast
//
//  Created by Mohammed Shahid on 02/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBEditTicketViewController.h"
#import "REComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GBDocument.h"
#import "GBSettingsViewController.h"
#import "GBCustomNavigationController.h"
#import "Reachability.h"
#import "OVSpinningProgressViewOverlay.h"

@class GBTicketViewController;
@protocol TicketEditedDelegate <NSObject>

-(void) ticketEditingDone :(BOOL)ticketDeleted Ticket:(GBTicketViewController *)ticketViewController;

@end


@interface GBTicketViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,TicketEditStatusDelegate,REComposeViewControllerDelegate, UIAlertViewDelegate>
{
    UIAlertView                        *_facebookAlertView;
    Reachability                           *_internetReach;
    Reachability                               *_wifiReach;
}

@property (nonatomic ,strong) NSString *ticketId;

@property (nonatomic, weak) id <TicketEditedDelegate> delegate;

@property (strong, nonatomic) GBDocument * doc;

@property (strong, nonatomic) NSURL *fileURL;

@end
