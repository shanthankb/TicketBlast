//
//  GBSettingsDetailViewController.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 15/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBSettingsDetailViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface GBSettingsDetailViewController ()
{
	UIWebView *_webView;
	UIActivityIndicatorView *_activityView;
}

@end

@implementation GBSettingsDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)loadView
{
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = mainView;
	[self.view setBackgroundColor:[UIColor whiteColor]];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_webView = [[UIWebView alloc] initWithFrame:self.view.frame];
	[_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	_webView.scalesPageToFit = YES;
	[self.view addSubview:_webView];
	[self.view addSubview:_activityView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = self.navTitle;
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 12, 25)];
    [backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back_pressed"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;

}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_webView.delegate = self;
	
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
	_internetReach = [Reachability reachabilityForInternetConnection];
	[_internetReach startNotifier];
	[self updateInterfaceWithReachability:_internetReach];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self resizeNavButtonsOnRotationForOrientation:orientation];
}

//Activity Indicator Centering
-(void) viewDidLayoutSubviews
{
    _activityView.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Webview Delegate Methods

-(void)webViewDidStartLoad:(UIWebView *)webView
{
	[_activityView startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_activityView stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark BarBackButton

-(void) didTapBackButton
{
	[_webView stopLoading];
	[_activityView stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Rotation Methods

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self resizeNavButtonsOnRotationForOrientation:toInterfaceOrientation];
}

- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIButton *leftNavButton = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x,leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 25.0)];
	}
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 31.0)];
	}
}


#pragma mark Internet Reachablity

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    
	if(curReach == _internetReach)
	{
		[self reachability: curReach];
	}
	if(curReach == _wifiReach)
	{
		[self reachability: curReach];
	}
	
}

- (void) reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Internet is currently unavailable. Please try again later";
			//Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
			UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle:@"TicketBlast" message:statusString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[noInternetAlert show];
            break;
        }
            
        case ReachableViaWWAN:
        {
			[_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
            break;
        }
        case ReachableViaWiFi:
        {
			[_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
            break;
		}
    }
	
}

#pragma mark Internet Unavailable AlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
	_activityView = nil;
	_webView = nil;
}

@end
