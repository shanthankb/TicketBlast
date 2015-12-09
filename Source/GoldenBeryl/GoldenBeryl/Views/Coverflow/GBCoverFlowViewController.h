//
//  GBCoverFlowViewController.h
//  TicketBlastCoverFlow
//
//  Created by Abhiman Puranik on 18/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "GBNewTicketViewController.h"
#import "GBTicketViewController.h"
#import "GBSettingsViewController.h"
#import "GBDocumentManager.h"


@interface GBCoverFlowViewController : UIViewController <iCarouselDataSource , iCarouselDelegate ,TicketStatusDelegate , UITableViewDelegate, UITableViewDataSource,TicketEditedDelegate,TicketEditStatusDelegate , UIAlertViewDelegate,SettingsChangedDelegate>
{
    BOOL                    _allowedToRotate;
}

@property (nonatomic, strong) iCarousel  *coverFlow;

@property (nonatomic, assign) BOOL  wrap;

@property (nonatomic ,strong) NSMutableArray *objects;

@property (nonatomic ) NSInteger objectsCount;

@end
