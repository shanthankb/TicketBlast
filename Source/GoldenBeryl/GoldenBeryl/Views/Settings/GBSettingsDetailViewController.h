//
//  GBSettingsDetailViewController.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 15/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface GBSettingsDetailViewController : UIViewController<UIWebViewDelegate>
{
	Reachability *_internetReach;
	Reachability *_wifiReach;
}

@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) NSString *navTitle;

@end
