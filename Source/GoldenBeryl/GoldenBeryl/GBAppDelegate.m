//
//  GBAppDelegate.m
//  GoldenBeryl
//
//  Created by Abhiman Puranik on 04/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBAppDelegate.h"
#import "GBCustomNavigationController.h"
#import "GBCoverFlowViewController.h"

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sleep(2.5);
	[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AppLaunch"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[UIApplication sharedApplication]setStatusBarHidden:NO];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
	GBCoverFlowViewController *coverFlowController = [[GBCoverFlowViewController alloc]init];
	GBCustomNavigationController *rootNavigationController = [[GBCustomNavigationController alloc] initWithRootViewController:coverFlowController];    
    //[rootNavigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar"] resizableImageWithCapInsets:UIEdgeInsetsZero] forBarMetrics:UIBarMetricsDefault];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        [rootNavigationController.navigationBar setTranslucent:NO];
        [rootNavigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0]];
    }
    else
    {
        [rootNavigationController.navigationBar setTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0]];
    }

    //[rootNavigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar_landscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 0, 5)] forBarMetrics:UIBarMetricsLandscapePhone];
    
	[[UINavigationBar appearance] setTitleTextAttributes: @{
                                UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                          /*UITextAttributeTextShadowColor: [UIColor colorWithRed:157.0/255.0 green:102.0/255.0 blue:15.0/255.0 alpha:1.0],
                         UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],*/
                                     UITextAttributeFont: [UIFont fontWithName:@"GothamNarrow-Medium" size:24.0f],
						
     }];
	
	[[UINavigationBar appearance] setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];

    self.window.rootViewController = rootNavigationController;
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
	
	
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppLaunch"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

@end
