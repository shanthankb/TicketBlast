//
//  GBCoverFlowViewController.m
//
//  Created by Abhiman Puranik on 18/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBCoverFlowViewController.h"
#import "GBCustomNavigationController.h"

//Document Approach
#import "GBDocument.h"
#import "NSDate+FormattedStrings.h"
#import "GBEntry.h"
#import "GBMetadata.h"
#import "GBTicketData.h"


#define AddTicketImageHeight 100.0f
#define AddTicketImageWidth 200.0f


#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ACTUAL_SCREEN_SIZE (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? 4.0f : 3.5f

#define WIDE_SCREEN_WIDTH 4.0f

#define kTicketHeight (176.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))
#define kTicketWidth  (176.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))
#define kReflectionHeight (26.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH)))

#define PHOTO_IMG_TAG 007
#define BASE_IMG_TAG  111
#define REFLECTION_IMG_TAG 222
#define HEADLINE_LABEL_TAG 333
#define DATE_LABEL_TAG 444
#define TICKET_BOTTOM_TAG 23232

#define TableViewDisplay NO

@interface GBCoverFlowViewController ()

{
	BOOL   _isEditing;
	UIButton *_settingsView;
	UIView *_addTicketView;
	UIView *_coverFlowView;
    
    UIAlertView *_deleteAlert;
    
    UIButton *_settingButton;
    UIImageView *_screenBottomBar;
    UIButton *_cancelEditingButton;
	UIImageView *_ticketBlastBranding;
	UIImageView *_ticketBlastBrandingBottom;
	
	//Document Approach
	NSURL * _localRoot;
	GBDocument * _selDocument;
	NSURL * _iCloudRoot;
	BOOL _iCloudAvailable;
	NSMetadataQuery * _query;
	BOOL _iCloudURLsReady;
	NSMutableArray * _iCloudURLs;
	NSMutableDictionary *dateArray;
	BOOL _moveLocalToiCloud;
	BOOL _copyiCloudToLocal;
	
	BOOL _isPresented;
	UIActivityIndicatorView *_loadingTicketView;
	NSInteger _localDocumentsCount;
	BOOL _keepLocalCopy;
	
	BOOL _dataCopiedToLocal;
	UIActivityIndicatorView *_activityView;
	UIView *_activitySyncView;
		
	//To Avoid First Notification While Adding
	BOOL _didAddNewTicket;
	
	NSInteger _indexPathToBeScrolledTo;
}

@end

@implementation GBCoverFlowViewController
{
	UIBarButtonItem *addBarButton;
	UIBarButtonItem *settingsBarButton;
	NSInteger indexPathToReload;
}

- (id)init
{
    self = [super init];
    if (self) {
		dateArray = [[NSMutableDictionary alloc]init];
		self.wrap = NO;
         [self addObserver:self forKeyPath:@"DataObjects" options:0 context:nil]; //To Observe Changes For UI -Coverflow/AddNew Ticket
        _isEditing = NO;
        _allowedToRotate = NO;
        
    }
    return self;
}

- (void)loadView
{
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = mainView;
	
	_addTicketView = [[UIView alloc]initWithFrame:self.view.frame];
	_coverFlowView = [[UIView alloc]initWithFrame:self.view.frame];
	
	UIImageView *coverFlowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0,0.0 , _coverFlowView.frame.size.width, _coverFlowView.frame.size.height)];
	[coverFlowImageView setBackgroundColor:[UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0]];
	[coverFlowImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[_coverFlowView addSubview:coverFlowImageView];
	
    [_addTicketView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
	
	[_addTicketView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[_coverFlowView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	[self loadCoverflowview];
	[self loadAddTicketView];
	
	[self.view addSubview:_addTicketView];
	[self.view addSubview:_coverFlowView];
	
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[_coverFlowView addSubview:_activityView];
	_activityView.hidden = NO;
	
	//Sync Activity View
	_activitySyncView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 125.0, 44.0)];
	[_activitySyncView setBackgroundColor:[UIColor clearColor]];
	UILabel *syncLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0, 0.0, 90.0, 44.0)];
	[syncLabel setBackgroundColor:[UIColor clearColor]];
	syncLabel.text = @"Syncing...";
	syncLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
	syncLabel.textColor = [UIColor whiteColor];
	UIActivityIndicatorView *syncActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[syncActivity setFrame:CGRectMake(0.0, 0.0, 25.0, 44.0)];
	[syncActivity startAnimating];
	[_activitySyncView addSubview:syncActivity];
	[_activitySyncView addSubview:syncLabel];
	[_activitySyncView setHidden:YES];
	[_screenBottomBar addSubview:_activitySyncView];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
	//Views for Switching based on Tickets Count
	[self loadNavigationItemsForCoverFlowView];
	[self loadNavigationItemsForAddTicketView];
	
	_objects = [[NSMutableArray alloc] init];
	
	_iCloudURLs = [[NSMutableArray alloc] init];
	[self refresh];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeInActive:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
}

//Refresh iCloud Everytime For Changes
- (void)didBecomeActive:(NSNotification *)notification {
    [self refresh];
}

//Save indexpath in LocalDocuments Mode
-(void)didBecomeInActive:(NSNotification *)notification{
	if (![self iCloudOn]) {
		_indexPathToBeScrolledTo = self.coverFlow.currentItemIndex;
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	if (!self.coverFlow) {
		[self loadCoverflowview];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AppLaunch"]==YES)
	{
		[self.navigationController setNavigationBarHidden:YES animated:NO];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AppLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		//Avoid Blank Screen on App Launch
		UIImageView *splashScreenImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0,0.0 , _coverFlowView.frame.size.width, _coverFlowView.frame.size.height)];
        if([[[UIDevice currentDevice]systemVersion]floatValue]<7)
           [splashScreenImageView setFrame:CGRectMake(0.0, -20, _coverFlowView.frame.size.width, _coverFlowView.frame.size.height+20)];
		[splashScreenImageView setBackgroundColor:[UIColor clearColor]];
		[splashScreenImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        if([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
			[splashScreenImageView setImage:[UIImage imageNamed:@"Default-568h"]];
        }
        else
            [splashScreenImageView setImage:[UIImage imageNamed:@"Default"]];
		[self.view addSubview:splashScreenImageView];
		[self.view bringSubviewToFront:splashScreenImageView];
		[self.coverFlow setUserInteractionEnabled:NO];
	}
	else
	{
		self.objectsCount = _objectsCount;
	}
	if(self.objectsCount>0)
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
	[_query enableUpdates];
	
    if (_isEditing)
    {
        [self didTapCancelEditButton];
    }
	
	//TicketBlast Branding
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (UIInterfaceOrientationIsLandscape(orientation) && !_isEditing)
	{
		[_ticketBlastBrandingBottom setHidden:NO];
		[_ticketBlastBranding setHidden:YES];
	}
	else if(UIInterfaceOrientationIsPortrait(orientation) && !_isEditing)
	{
		[_ticketBlastBrandingBottom setHidden:YES];
		[_ticketBlastBranding setHidden:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_query disableUpdates]; //Stop iCloud Sync Activity in this Controller
}

//Center UIActivity View
-(void) viewDidLayoutSubviews
{
    _activityView.center = self.view.center;
	_activitySyncView.frame = CGRectMake(_screenBottomBar.center.x - 62, _screenBottomBar.bounds.origin.y, 125, 50);
}

-(void) loadAddTicketView
{
	//Add ticket
	UIButton *add = [[UIButton alloc]init];
	[add addTarget:self
			action:@selector(addTickets)
  forControlEvents:UIControlEventTouchUpInside];
	[add setImage:[UIImage imageNamed:@"ticket_icon"] forState:UIControlStateNormal];
	[add setBackgroundColor:[UIColor clearColor]];
    [add setTitle:@"Tap to add a ticket" forState:UIControlStateNormal];
	[add.titleLabel setFont:[UIFont fontWithName:@"GothamNarrow-Light" size:20]];
	[add setTitleColor:[UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	
    add.titleEdgeInsets = UIEdgeInsetsMake(117.0, -135.0, 35.0, 0.0);
    add.imageEdgeInsets = UIEdgeInsetsMake(-20.0, 29.0, 12.0, 10.0);
	[_addTicketView addSubview:add];
	
	//Center the AddNewTicket Button using Autolayout-iOS6
	add.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *addButtonConstraints = [NSLayoutConstraint constraintWithItem:add attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_addTicketView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
	[_addTicketView addConstraint:addButtonConstraints];
	
	addButtonConstraints = [NSLayoutConstraint constraintWithItem:add attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_addTicketView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
	[_addTicketView addConstraint:addButtonConstraints];
	
	addButtonConstraints = [NSLayoutConstraint constraintWithItem:add attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:AddTicketImageWidth];
	[_addTicketView addConstraint:addButtonConstraints];
	
	addButtonConstraints = [NSLayoutConstraint constraintWithItem:add attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:AddTicketImageHeight];
	[_addTicketView addConstraint:addButtonConstraints];
    
    addButtonConstraints = [NSLayoutConstraint constraintWithItem:add attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:_addTicketView attribute:NSLayoutAttributeTop multiplier:1.0f constant:168.0f];
    [_addTicketView addConstraint:addButtonConstraints];
}

-(void) loadCoverflowview
{
	self.navigationItem.title = @"Tickets";
	[self.navigationController setNavigationBarHidden:YES];
	self.navigationItem.hidesBackButton = YES;
		
	//Landscape Mode

	_coverFlow = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0.0, _coverFlowView.bounds.size.width, _coverFlowView.bounds.size.height)];
	[_coverFlow setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    self.coverFlow.delegate = self;
    self.coverFlow.dataSource = self;
    self.coverFlow.type = iCarouselTypeCylinder;
    [_coverFlowView addSubview:self.coverFlow];
	
    _settingButton = [UIButton alloc];
    if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
    {
        _settingButton = [_settingButton initWithFrame:CGRectMake(5.0f, 28.0f, 25.0f, 25.0f)];
    }
    else
    {
        _settingButton = [_settingButton initWithFrame:CGRectMake(5.0f, 8.0f, 25.0f, 25.0f)];
    }
    [_settingButton setImage:[UIImage imageNamed:@"button_settings"] forState:UIControlStateNormal];
    [_settingButton setImage:[UIImage imageNamed:@"button_settings_pressed"] forState:UIControlStateHighlighted];
    [_settingButton addTarget:self action:@selector(didTapSettingsButton) forControlEvents:UIControlEventTouchUpInside];
    [self.coverFlow addSubview:_settingButton];
	
	//TB Logo in -Portrait
	_ticketBlastBranding = [UIImageView alloc];
    UIImage *logoImage = [UIImage imageNamed:@"ticketblast_logo_orange"];
    
    if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
    {
       _ticketBlastBranding = [_ticketBlastBranding initWithFrame:CGRectMake(self.view.frame.size.width/2 - logoImage.size.width/2, 28.0f, logoImage.size.width, logoImage.size.height)];
    }
    else
    {
        _ticketBlastBranding = [_ticketBlastBranding initWithFrame:CGRectMake(self.view.frame.size.width/2 - logoImage.size.width/2, 8.0f,logoImage.size.width, logoImage.size.height)];
    }
	_ticketBlastBranding.image = logoImage;
    [self.coverFlow addSubview:_ticketBlastBranding];
	
    _screenBottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 43.0f  , self.view.frame.size.width, 43.0f)];
	[_screenBottomBar setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
    _screenBottomBar.userInteractionEnabled = YES;
    _screenBottomBar.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
	
	//TB Logo in -LandScape
	_ticketBlastBrandingBottom = [UIImageView alloc];
    if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
    {
        _ticketBlastBrandingBottom = [_ticketBlastBrandingBottom initWithFrame:CGRectMake(self.view.frame.size.height/2 - logoImage.size.width/2, 28.0, logoImage.size.width, logoImage.size.height)];
    }
    else
    {
       _ticketBlastBrandingBottom = [_ticketBlastBrandingBottom initWithFrame:CGRectMake(self.view.frame.size.height/2 - logoImage.size.width/2, 8.0, logoImage.size.width, logoImage.size.height)];
    }
	[_ticketBlastBrandingBottom setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
	_ticketBlastBrandingBottom.image = logoImage;
    [self.coverFlow addSubview:_ticketBlastBrandingBottom];
	[_ticketBlastBrandingBottom setHidden:YES];
    [_coverFlowView addSubview:_screenBottomBar];
	
	_cancelEditingButton = [UIButton alloc];
    
    
    if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
    {
        _cancelEditingButton = [_cancelEditingButton initWithFrame:CGRectMake(_coverFlowView.frame.size.width- 50 - 5, 26.0f, 50.0f, 32.0f)];
    }
    else
    {
        _cancelEditingButton = [_cancelEditingButton initWithFrame:CGRectMake(_coverFlowView.frame.size.width- 50 - 5, 10.0f, 50.0f, 32.0f)];
    }
    
    
	[_cancelEditingButton setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_cancelEditingButton setTitle:@"Done" forState:UIControlStateNormal];
    _cancelEditingButton.titleLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:20.0];
    [_cancelEditingButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_cancelEditingButton addTarget:self action:@selector(didTapCancelEditButton) forControlEvents:UIControlEventTouchUpInside];
    _cancelEditingButton.hidden = YES;
    [_coverFlowView addSubview:_cancelEditingButton];
	
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 7.0f, 33.0f, 30.0f)];
    [editButton setImage:[UIImage imageNamed:@"button_edit"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"button_edit_pressed"] forState:UIControlStateHighlighted];
    [editButton addTarget:self action:@selector(didTapEditButton) forControlEvents:UIControlEventTouchUpInside];
    [_screenBottomBar addSubview:editButton];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenBottomBar.frame.size.width - 33.0f - 5.0f, 7.0f, 33.0f, 30.0f)];
	
	[addButton setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
	
    [addButton setImage:[UIImage imageNamed:@"button_add"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"button_add_pressed"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(didTapAddButton) forControlEvents:UIControlEventTouchUpInside];
    [_screenBottomBar addSubview:addButton];
	
    NSLog(@"screen size %f, %f, %f, %f, %f", ACTUAL_SCREEN_SIZE, kTicketHeight, kTicketWidth, (ACTUAL_SCREEN_SIZE / WIDE_SCREEN_WIDTH), WIDE_SCREEN_WIDTH);
	
	self.coverFlow.hidden = YES;
	_coverFlowView.hidden = YES;
	_addTicketView.hidden = YES;
}

-(void) loadNavigationItemsForAddTicketView
{
	//Settings ButtonView
	_settingsView = [[UIButton alloc] init];
	[_settingsView addTarget:self action:@selector(didTapSettingsButton) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:_settingsView];
	[self.navigationItem setLeftBarButtonItem:settingsButton];
	
	//Navigation Title
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ticketblast_logo_white"]];
    CGRect imageRect = titleImageView.frame;
    imageRect.origin.y -= 4.0;
    titleImageView.frame = imageRect;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleImageView.frame.size.width, titleImageView.frame.size.height)];
    [view addSubview:titleImageView];
    self.navigationItem.titleView = view;
}

-(void) loadNavigationItemsForCoverFlowView
{
    self.title = @"Cover Flow";
}

-(void) viewWillAppearForAddTicketView
{
	if ([[self.navigationController topViewController] isKindOfClass:[GBCoverFlowViewController class]] && _coverFlowView.hidden == YES)
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	//Orientation for BarButton
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		[_settingsView setFrame:CGRectMake(_settingsView.frame.origin.x,_settingsView.frame.origin.y, 25, 25)];
		[_settingsView setImage:[UIImage imageNamed:@"button_settings"] forState:UIControlStateNormal];
        [_settingsView setImage:[UIImage imageNamed:@"button_settings_pressed"] forState:UIControlStateHighlighted];
	} else {
		[_settingsView setFrame:CGRectMake(_settingsView.frame.origin.x,_settingsView.frame.origin.y, 25, 25)];
		[_settingsView setImage:[UIImage imageNamed:@"button_settings"] forState:UIControlStateNormal];
        [_settingsView setImage:[UIImage imageNamed:@"button_settings_pressed"] forState:UIControlStateHighlighted];
	}
}

-(void) viewWillAppearForCoverFlowView
{
	self.coverFlow.hidden = NO;
	
	if ([[self.navigationController topViewController] isKindOfClass:[GBCoverFlowViewController class]])
	{
		[self.navigationController setNavigationBarHidden:YES animated:NO];
	}
}

//Memory Warning Handling- Removing Views From Superview and Release Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	if (self.isViewLoaded)
	{
		if (self.view.window)
		{
			
		}
		else {
			
			[_settingButton removeFromSuperview];
			_settingButton = nil;
			
			
			[_ticketBlastBranding removeFromSuperview];
			_ticketBlastBranding = nil;
			
			[_screenBottomBar removeFromSuperview];
			_screenBottomBar = nil;
			
			[_ticketBlastBrandingBottom removeFromSuperview];
			_ticketBlastBrandingBottom = nil;
			
			[_cancelEditingButton removeFromSuperview];
			_cancelEditingButton = nil;
			
			[self.coverFlow removeFromSuperview];
			self.coverFlow = nil;
		}
	}
	
}


#pragma mark Orientation Support

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//Only Rotate after the SplashScreen is Done
- (BOOL)shouldAutorotate
{
    return _allowedToRotate;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationUnknown|| orientation == UIDeviceOrientationPortraitUpsideDown ||
		orientation == UIDeviceOrientationFaceUp||              // Device oriented flat, face up
		orientation == UIDeviceOrientationFaceDown) {
        
        return UIDeviceOrientationPortrait;
    }
    
    return orientation;
}

#pragma mark Rotation Methods

-(void)willRotateToInterfaceOrientationForAddTicketView:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
	{
		
		[_settingsView setFrame:CGRectMake(_settingsView.frame.origin.x,_settingsView.frame.origin.y, 25.0, 25.0)];
		[_settingsView setImage:[UIImage imageNamed:@"button_settings"] forState:UIControlStateNormal];
        [_settingsView setImage:[UIImage imageNamed:@"button_settings_pressed"] forState:UIControlStateHighlighted];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[_settingsView setFrame:CGRectMake(_settingsView.frame.origin.x, _settingsView.frame.origin.y, 25.0, 25.0)];
		[_settingsView setImage:[UIImage imageNamed:@"button_settings"] forState:UIControlStateNormal];
        [_settingsView setImage:[UIImage imageNamed:@"button_settings_pressed"] forState:UIControlStateHighlighted];
		
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
	{
		[_ticketBlastBrandingBottom setHidden:NO];
		[_ticketBlastBranding setHidden:YES];
	}
	else if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
	{
		[_ticketBlastBrandingBottom setHidden:YES];
		[_ticketBlastBranding setHidden:NO];
	}
	else{
		[_ticketBlastBrandingBottom setHidden:YES];
		[_ticketBlastBranding setHidden:YES];
	}
	
	if ([_objects count] > 0)
	{
		self.coverFlow.hidden = NO;
		[self.navigationController setNavigationBarHidden:YES];
	}
	else
	{
		[self willRotateToInterfaceOrientationForAddTicketView:toInterfaceOrientation];
	}
}

#pragma mark AddNewTicket-Button
-(void) addTickets
{
	GBNewTicketViewController *newTicketViewController = [[GBNewTicketViewController alloc]init];
	newTicketViewController.delegate = self;
	newTicketViewController.numberOfTickets = [_objects count];
	[self.navigationController pushViewController:newTicketViewController animated:YES];
}

#pragma mark CoverFlow-Buttons

-(void)didTapSettingsButton
{
	GBSettingsViewController *settingsViewController = [[GBSettingsViewController alloc]init];
	settingsViewController.delegate =self;
	settingsViewController.numberOfTickets = [self.objects count];
		
	GBCustomNavigationController *rootNavigationController = [[GBCustomNavigationController alloc] initWithRootViewController:settingsViewController];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        [rootNavigationController.navigationBar setTranslucent:NO];
        [rootNavigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0]];
    }
    else
    {
        [rootNavigationController.navigationBar setTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0]];
    }
	rootNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:rootNavigationController animated:YES completion:nil];
}

-(void)didTapAddButton
{
	GBNewTicketViewController *newTicketViewController = [[GBNewTicketViewController alloc]init];
	newTicketViewController.delegate = self;
    newTicketViewController.numberOfTickets = [_objects count];
	[[GBDocumentManager sharedInstance] addEntryForAutoComplete:_objects];
	[self.navigationController pushViewController:newTicketViewController animated:YES];
}

-(void)didTapEditButton
{
	_isEditing = !_isEditing;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_ticketBlastBrandingBottom.hidden = NO;
	}
	else if(orientation == UIInterfaceOrientationPortrait)
	{
		_ticketBlastBranding.hidden = NO;
	}
    _settingButton.hidden = YES;
    _screenBottomBar.hidden = YES;
    _cancelEditingButton.hidden = NO;
    [self.coverFlow reloadData];
}

- (void)didTapCancelEditButton
{
    _isEditing = !_isEditing;
	[self.coverFlow reloadData];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_ticketBlastBrandingBottom.hidden = NO;
	}
	else if(orientation == UIInterfaceOrientationPortrait)
	{
		_ticketBlastBranding.hidden = NO;
	}
    _settingButton.hidden = NO;
    _screenBottomBar.hidden = NO;
    _cancelEditingButton.hidden = YES;
}

//Form the text to show while deleting based on event-type
- (void)deleteTheSelectedItem {
    
    if (self.coverFlow.numberOfItems > 0)
    {
        NSString *eventName;
        GBEntry *entry = [_objects objectAtIndex:self.coverFlow.currentItemIndex];
        //Text Based On Event Type
        if ([entry.ticketdata.eventType isEqualToString:kEventTypeConcert])
        {
            eventName = entry.ticketdata.headLine;
        }
        else if([entry.ticketdata.eventType isEqualToString:kEventTypeGame])
        {
            eventName = [NSString stringWithFormat:@"%@ vs %@",entry.ticketdata.homeTeam,entry.ticketdata.opponentTeam];
        }
        else
        {
            eventName = entry.ticketdata.eventName;
        }
        
        _deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Ticket" message:[NSString stringWithFormat:@"Are you sure you want to delete \"%@\" from TicketBlast?",eventName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
        _deleteAlert.delegate = self;
        [_deleteAlert show];
        
    }
}

#pragma mark AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _deleteAlert)
    {
        if (buttonIndex == 0)
        {
			GBEntry * entry = [_objects objectAtIndex:self.coverFlow.currentItemIndex];
			
			if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"])//Store Deleted Tickets in Sandbox to Delete them while we get to iCloud-ON State
			{
				NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"]];
				[deletedTicketsArray addObject:[entry.fileURL lastPathComponent]];
				[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				NSLog(@"URLs deleted -%@",deletedTicketsArray);
			}
			else if(_keepLocalCopy)
			{
				_keepLocalCopy = NO;
				NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithObject:[entry.fileURL lastPathComponent]];
				[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				NSLog(@"URLs deleted -%@",deletedTicketsArray);
			}
			
			[self deleteEntry:entry];
		    
        }
        else
        {
            
        }
    }
    
}


#pragma mark -
#pragma mark iCarousel methods

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
	indexPathToReload = index;
	
	//Conflict Resolution when both tickets are edited at same time or done in offline mode-Resolving using the Latest Changes
	GBEntry *entry = [_objects objectAtIndex:index];
	if (entry.state & UIDocumentStateInConflict)
	{
		[NSFileVersion removeOtherVersionsOfItemAtURL:entry.fileURL error:nil];
		NSArray* conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:entry.fileURL];
		for (NSFileVersion* fileVersion in conflictVersions) {
			fileVersion.resolved = YES;
		}
	}
	
	//If in Editing Mode Push Directly to Edit Controller
		if (_isEditing)
		{
			if (!_isPresented)
			{
				_loadingTicketView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				
				CGPoint viewCenter = [carousel itemViewAtIndex:index].center;
				viewCenter.y =viewCenter.y - kReflectionHeight;
				
				_loadingTicketView.center =viewCenter;
				[[carousel itemViewAtIndex:index] addSubview:_loadingTicketView];
				[_loadingTicketView startAnimating];
				
				_isPresented = YES;
				GBEditTicketViewController *editTicketViewController = [[GBEditTicketViewController alloc]init];
				editTicketViewController.delegate = self;
				GBEntry * entry = [_objects objectAtIndex:index];
				editTicketViewController.fileURL = entry.fileURL;
							
				[[GBDocumentManager sharedInstance] addEntryForAutoComplete:_objects];
				
				_selDocument = [[GBDocument alloc] initWithFileURL:entry.fileURL];
				[_selDocument openWithCompletionHandler:^(BOOL success) {
					editTicketViewController.doc = _selDocument;
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[self.navigationController pushViewController:editTicketViewController animated:YES];
						_isPresented = NO;
						[_loadingTicketView stopAnimating];
						[_loadingTicketView removeFromSuperview];
						_loadingTicketView = nil;
						
					});
				}];
			}
		
		}
		else
		{
			if (!_isPresented)
			{
				_loadingTicketView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				CGPoint viewCenter = [carousel itemViewAtIndex:index].center;
				viewCenter.y =viewCenter.y - kReflectionHeight;
				
				_loadingTicketView.center =viewCenter;
				[[carousel itemViewAtIndex:index] addSubview:_loadingTicketView];
				[_loadingTicketView startAnimating];
				
				_isPresented = YES;
				GBTicketViewController *ticketViewController = [[GBTicketViewController alloc]init];
				ticketViewController.delegate = self;
				
				[[GBDocumentManager sharedInstance] addEntryForAutoComplete:_objects];
				
				GBEntry * entry = [_objects objectAtIndex:index];
				ticketViewController.fileURL = entry.fileURL;
				_selDocument = [[GBDocument alloc] initWithFileURL:entry.fileURL];
				
				[_selDocument openWithCompletionHandler:^(BOOL success) {
					ticketViewController.doc = _selDocument;
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[self.navigationController pushViewController:ticketViewController animated:YES];
						_isPresented = NO;
						[_loadingTicketView stopAnimating];
						[_loadingTicketView removeFromSuperview];
						_loadingTicketView = nil;
					});
				}];
		     }
		}
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
	return _objects.count;;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	
    UILabel *headlineLabel = nil;
    UILabel *dateLabel = nil;
    
    UIImageView *reflectionImageView = nil;
    UIImageView *baseImageView = nil;
    UIImageView *photoImageView = nil;
	UIImageView *ticketBottomBar = nil;
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //Base view to hold subviews of ticket view // Note: can be removed
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kTicketWidth, kTicketHeight + kReflectionHeight)];
		
		baseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTicketWidth, kTicketHeight)];
		baseImageView.contentMode = UIViewContentModeCenter;
        if ([[UIScreen mainScreen] bounds].size.height == 568.0f) 
        {
            baseImageView.image = [UIImage imageNamed:@"ticket_base_iP5"];
        }
        else
            baseImageView.image = [UIImage imageNamed:@"ticket_base"];
        
		baseImageView.layer.masksToBounds = YES;
        baseImageView.layer.cornerRadius = 10.0;
        baseImageView.clipsToBounds = YES;
        baseImageView.tag = BASE_IMG_TAG;
		
		
		photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTicketWidth, kTicketHeight- (51.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH))))];
		photoImageView.contentMode = UIViewContentModeScaleAspectFill;
		photoImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ticket_icon"]];
        photoImageView.layer.masksToBounds = YES;
        photoImageView.clipsToBounds = YES;
        photoImageView.tag = PHOTO_IMG_TAG;

		
        [view addSubview:baseImageView];
		[baseImageView addSubview:photoImageView];
        
        ticketBottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, baseImageView.frame.size.height - (51.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH))), kTicketWidth, (51.0 * ((ACTUAL_SCREEN_SIZE) / (WIDE_SCREEN_WIDTH))))];
        ticketBottomBar.image = [UIImage imageNamed:@"bottom_bar"];
		ticketBottomBar.tag = TICKET_BOTTOM_TAG;
        [baseImageView addSubview:ticketBottomBar];
		
        
        reflectionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,baseImageView.frame.origin.y + baseImageView.frame.size.height + 1.0, kTicketWidth, kReflectionHeight)];
        reflectionImageView.contentMode = UIViewContentModeScaleToFill;
        reflectionImageView.alpha = 0.5;
        reflectionImageView.layer.masksToBounds = YES;
        reflectionImageView.layer.cornerRadius = 6.0;
        reflectionImageView.tag = REFLECTION_IMG_TAG;
		reflectionImageView.image = [UIImage imageNamed:@"main_bottom_bar"];
		
        
        headlineLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
        headlineLabel.backgroundColor = [UIColor clearColor];
        headlineLabel.textAlignment = NSTextAlignmentCenter;
        headlineLabel.font = [UIFont fontWithName:@"GothamNarrow-Book" size:(ACTUAL_SCREEN_SIZE == WIDE_SCREEN_WIDTH) ? 17.0 : 16.0];
        headlineLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
        headlineLabel.tag = HEADLINE_LABEL_TAG;
		
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont fontWithName:@"GothamNarrow-Light" size:(ACTUAL_SCREEN_SIZE == WIDE_SCREEN_WIDTH) ? 12.0 : 11.0];
        dateLabel.textColor = [UIColor colorWithRed:135.0/255.0 green:135.0/255.0 blue:135.0/255.0 alpha:1.0];
        dateLabel.tag = DATE_LABEL_TAG;
        
        if (ACTUAL_SCREEN_SIZE == WIDE_SCREEN_WIDTH) {
            
            headlineLabel.frame = CGRectMake(6.0 ,6.0 , kTicketWidth - 12.0, 22.0);
			headlineLabel.font = [UIFont fontWithName:@"GothamNarrow-Book" size:17.0];
            
            dateLabel.frame = CGRectMake(2.0f, headlineLabel.frame.origin.y + headlineLabel.frame.size.height +2.0, kTicketWidth  - 4.0f, 14.0);
            dateLabel.font = [UIFont fontWithName:@"GothamNarrow-Light" size:12.0];
        }
        else {
            
            headlineLabel.frame = CGRectMake(6.0 ,6.0 , kTicketWidth - 12.0, 20.0);
            headlineLabel.font = [UIFont fontWithName:@"GothamNarrow-Book" size:16.0];
            
            dateLabel.frame = CGRectMake(2.0, headlineLabel.frame.origin.y + headlineLabel.frame.size.height +2.0, kTicketWidth  - 4.0, 14.0);
            dateLabel.font = [UIFont fontWithName:@"GothamNarrow-Light" size:11.0];
            
            
        }
		
        [ticketBottomBar addSubview:headlineLabel];
        [ticketBottomBar addSubview:dateLabel];
		[view addSubview:reflectionImageView];
        
        
        if (_isEditing) {
            
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(-11.0, -11.0, 35.0, 35.0)];
            [deleteButton setImage:[UIImage imageNamed:@"remove_button"] forState:UIControlStateNormal];
            [deleteButton setImage:[UIImage imageNamed:@"remove_button_pressed"] forState:UIControlStateHighlighted];
            [deleteButton addTarget:self action:@selector(deleteTheSelectedItem) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:deleteButton];
        }
		
		
    }
    else
    {
        //get a reference to the label in the recycled view
        photoImageView = (UIImageView *)[view viewWithTag:PHOTO_IMG_TAG];
		baseImageView = (UIImageView *)[view viewWithTag:BASE_IMG_TAG];
        reflectionImageView = (UIImageView *)[view viewWithTag:REFLECTION_IMG_TAG];
        headlineLabel = (UILabel *)[view viewWithTag:HEADLINE_LABEL_TAG];
        dateLabel = (UILabel *)[view viewWithTag:DATE_LABEL_TAG];
		ticketBottomBar = (UIImageView *)[view viewWithTag:TICKET_BOTTOM_TAG];
    }
    
	GBEntry *entry = [_objects objectAtIndex:index];
	
	//Text Based On Event Type
	if ([entry.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		headlineLabel.text = entry.ticketdata.headLine;
	}
	else if([entry.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		headlineLabel.text = [NSString stringWithFormat:@"%@ vs %@",entry.ticketdata.homeTeam,entry.ticketdata.opponentTeam];
	}
	else
	{
		headlineLabel.text = entry.ticketdata.eventName;
	}
	
    dateLabel.text =entry.ticketdata.date;
    
	if (entry.metadata.thumbnail)
	{
		photoImageView.image = entry.metadata.thumbnail;
	}
	else
	{
		photoImageView.image = [UIImage imageNamed:@"ticket_photo_field_placeholder"];
	}
	//Reflection of the bottombar
	reflectionImageView.image =[self reflectionImageForView : ticketBottomBar];
	   
	return view;
}

- (void)updateTicketReflection:(id)imageViews {
	
	NSArray *imvArray = (NSArray*)imageViews;
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	
    dispatch_async(queue, ^{
		
        UIImage *image = [self reflectionImageForView:(UIImageView*)imvArray[0]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[(UIImageView*)imvArray[1] setImage:image];
		});
    });
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            
            if (ACTUAL_SCREEN_SIZE == WIDE_SCREEN_WIDTH) {
                return value * 1.05f;
            }
            else {
                
                return value * 1.0f;
            }
            
        }
        case iCarouselOptionFadeMax:
        {
            // if (self.coverFlow.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 2.0f;
            }
            return value;
        }
        case iCarouselOptionFadeMin:
        {
            return -2.0;
			
        }
        case iCarouselOptionFadeRange:
        {
            return 0.9;
            
        }
        case iCarouselOptionTilt:
        {
            return value;
        }
        case iCarouselOptionArc:
        {
            return value; //Radius
        }
        case iCarouselOptionOffsetMultiplier:
        {
            return value; //Speed of the scroll
        }
        case iCarouselOptionAngle:
        {
            return value; // Angle of the items
        }
        default:
        {
            return value;
        }
    }
    
}

#pragma mark - Image Reflection

- (UIImage *)reflectionImageForView:(UIView *)view {
    
    UIImage *nomralImageFromView = [self imageWithView:view];
    
	UIImage *reflectedImage = [self reflectedImage:[[UIImageView alloc] initWithImage:nomralImageFromView] withHeight:kReflectionHeight];
    
    return nil;
    
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
		return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}



CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
    
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
    
    return bitmapContext;
}

#pragma mark ChangeView -AddNewTicket/Coverflow

-(void) changeViews :(BOOL)coverFlow
{
	if (coverFlow)
	{
		_coverFlowView.hidden = NO;
		_addTicketView.hidden = YES;
		[self.view bringSubviewToFront:_coverFlowView];
		[self viewWillAppearForCoverFlowView];
	}
	else
	{
		_coverFlowView.hidden = YES;
		_addTicketView.hidden = NO;
		[self.view bringSubviewToFront:_addTicketView];
		[self viewWillAppearForAddTicketView];
	}
    _allowedToRotate = YES;
}

#pragma mark NewTicket Controller Delegate

-(void) newTickedSaved:(GBNewTicketViewController *)newTicketViewController
{
	if ([self iCloudOn]) {
		_didAddNewTicket = YES;
	}
	
	NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:newTicketViewController.doc.fileURL];
	[self addOrUpdateEntryWithURL:newTicketViewController.doc.fileURL ticketData:newTicketViewController.doc.ticketdata  metadata:newTicketViewController.doc.metadata state:newTicketViewController.doc.documentState version:version withScroll:YES];
	if([_objects count] == 0)
	{
		self.objectsCount = 1;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TicketViewController Delegate

-(void) ticketEditingDone :(BOOL)ticketDeleted Ticket:(GBTicketViewController *)ticketViewController
{
	if (ticketDeleted ==YES)
	{
		GBEntry * entry = [_objects objectAtIndex:indexPathToReload];
		
		if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"])//Store Deleted Tickets in Sandbox to Delete them while we get to iCloud-ON State
		{
			NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"]];
			[deletedTicketsArray addObject:[entry.fileURL lastPathComponent]];
			[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSLog(@"URLs deleted -%@",deletedTicketsArray);
		}
		else if(_keepLocalCopy)
		{
			_keepLocalCopy = NO;
			NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithObject:[entry.fileURL lastPathComponent]];
			[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSLog(@"URLs deleted -%@",deletedTicketsArray);
		}
		
		[self deleteEntry:entry];
	}
	else
	{
		NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:ticketViewController.doc.fileURL];
		
		dispatch_async(dispatch_get_main_queue(), ^{
		[self addOrUpdateEntryWithURL:ticketViewController.doc.fileURL ticketData:ticketViewController.doc.ticketdata  metadata:ticketViewController.doc.metadata state:ticketViewController.doc.documentState version:version withScroll:YES];
		});
	}
}

-(void)editTicketSaved:(BOOL)saveStatus
{
	NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:_selDocument.fileURL];
	
	dispatch_async(dispatch_get_main_queue(), ^{
	[self addOrUpdateEntryWithURL:_selDocument.fileURL ticketData:_selDocument.ticketdata  metadata:_selDocument.metadata state:_selDocument.documentState version:version withScroll:YES];
	});
}

-(void)editTicketDeleted
{
	GBEntry * entry = [_objects objectAtIndex:indexPathToReload];
	
	if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"])//Store Deleted Tickets in Sandbox to Delete them while we get to iCloud-ON State
	{
		NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"]];
		[deletedTicketsArray addObject:[entry.fileURL lastPathComponent]];
		[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"URLs deleted -%@",deletedTicketsArray);
	}
	else if(_keepLocalCopy)
	{
		_keepLocalCopy = NO;
		NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithObject:[entry.fileURL lastPathComponent]];
		[[NSUserDefaults standardUserDefaults] setObject:deletedTicketsArray forKey:@"DeletedTickets"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"URLs deleted -%@",deletedTicketsArray);
	}
	
	[self deleteEntry:entry];
}


//When Switch is Changed Respond based on Choice
-(void)settingsChanged
{
	[self refresh];
}

//Count based on Which the UI is Changed
-(void)setObjectsCount:(NSInteger)objectsCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
		
		if (_dataCopiedToLocal) {
			[self changeViews:YES];
			_dataCopiedToLocal = NO;
			[_activityView stopAnimating];
			return ;
		}
		
	if (objectsCount==0)
	{
		[self changeViews:NO];
		[_activityView startAnimating];
	}
	else
	{	
		[self changeViews:YES];
	}
	
	if (objectsCount == 1) {
		[_activityView stopAnimating];
	}
	
	if (([_objects count]-1 == _indexPathToBeScrolledTo) && ![self iCloudOn]) {
		[self performSelector:@selector(scrollToCoverFlow) withObject:nil afterDelay:0.0];
	}
	
	//Sync Acitivity
	if ([_objects count]==0 && [self iCloudOn]) {
		[_activitySyncView setHidden:NO];
	}
	else if ([_objects count] == [_iCloudURLs count] && [self iCloudOn]) {
		[_activitySyncView setHidden:YES];
	}
         });	
	_objectsCount = objectsCount;
}

#pragma mark iCloud-Helpers

- (BOOL)iCloudOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"];
}

- (void)setiCloudOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"iCloudOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)iCloudWasOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudWasOn"];
}

- (void)setiCloudWasOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"iCloudWasOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)iCloudPrompted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudPrompted"];
}

- (void)setiCloudPrompted:(BOOL)prompted {
    [[NSUserDefaults standardUserDefaults] setBool:prompted forKey:@"iCloudPrompted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Keep a Local Copy of iCloud
- (void)iCloudToLocalImpl {
    
    NSLog(@"iCloud => local impl");
	
	if ([_iCloudURLs count]) {
		_dataCopiedToLocal = YES;
	}
	
    for (NSURL * fileURL in _iCloudURLs) {
        
        NSString * fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
        NSURL *destURL = [self getDocURL:[self getDocFilename:fileName uniqueInObjects:YES]];
        
		
		NSError *writingError;
		NSError *readingError;
		NSDate *date = nil;
		[fileURL getResourceValue:&date forKey:NSURLCreationDateKey error:&readingError];
		[destURL setResourceValue:date forKey:NSURLCreationDateKey error:&writingError];
        // Perform copy on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [fileCoordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingWithoutChanges error:nil byAccessor:^(NSURL *newURL) {
                NSFileManager * fileManager = [[NSFileManager alloc] init];
                NSError * error;
                BOOL success = [fileManager copyItemAtURL:fileURL toURL:destURL error:&error];
                
                if (success) {
                    NSLog(@"Copied %@ to %@ (%d)", fileURL, destURL, self.iCloudOn);
                    [self loadDocAtURL:destURL];
                } else {
                    NSLog(@"Failed to copy %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                }
            }];
        });
    }
    
}

// Alert to Give Option to User for iCloud -> Local
- (void)iCloudToLocal {
    NSLog(@"iCloud => local");
    
    // Wait to find out what user wants first
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"You're Not Using iCloud" message:@"What would you like to do with the documents currently on this device?" delegate:self cancelButtonTitle:@"Continue Using iCloud" otherButtonTitles:@"Keep a Local Copy", @"Keep on iCloud Only", nil];
    alertView.tag = 2;
    [alertView show];
}

//Move Local Documents to iCloud
- (void)localToiCloud {
	NSLog(@"local => iCloud");
    
    // If we have a valid list of iCloud files, proceed
    if (_iCloudURLsReady) {
        [self localToiCloudImpl];
    }
    // Have to wait for list of iCloud files to refresh
    else {
        _moveLocalToiCloud = YES;
    }
}

//Move Local Documents to iCloud-Implementation
- (void)localToiCloudImpl {

    NSLog(@"local => iCloud impl");
	
	//Moving LocalDocuments to iCloud
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    for (int i=0; i < localDocuments.count; i++) {
        
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        
		NSString *localFileName = [fileURL lastPathComponent] ;
		
		BOOL isFileFoundIniCloud = NO;
		NSInteger iCloudFileIndex = 0;
		
		for (int i = 0; i < _iCloudURLs.count; i++) {
			
			NSURL * iCloudFileURL = [_iCloudURLs objectAtIndex:i];
			if ([localFileName isEqualToString:[iCloudFileURL lastPathComponent]]) {
				isFileFoundIniCloud = YES;
				iCloudFileIndex = i;
				NSLog(@"Found Matching data %@",localFileName);
			}
			
		}
		
		
		
		if ([[fileURL pathExtension] isEqualToString:TB_EXTENSION] && !isFileFoundIniCloud) {
            
            NSString * fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
            NSURL *destURL = [self getDocURL:[self getDocFilename:fileName uniqueInObjects:NO]];
            
            // Perform actual move in background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                NSError * error;
                BOOL success = [[NSFileManager defaultManager] setUbiquitous:self.iCloudOn itemAtURL:fileURL destinationURL:destURL error:&error];
                if (success) {
                    NSLog(@"Moved %@ to %@", fileURL, destURL);
                    [self loadDocAtURL:destURL];
                } else {
                    NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                }
            });
            
        }
		
		else if([[fileURL pathExtension] isEqualToString:TB_EXTENSION] && isFileFoundIniCloud)//Found File in iCloud & Avoid Duplicates
		{
			__block NSDate *localDocModifiedDate ;
			__block NSDate *iCloudDocModifiedDate ;
			
			__block NSURL *localFileURL = fileURL;
			
			NSURL * iCloudfileURL = [_iCloudURLs objectAtIndex:iCloudFileIndex];
			
			GBDocument * localDoc = [[GBDocument alloc] initWithFileURL:fileURL];
			[localDoc openWithCompletionHandler:^(BOOL success) {
				
				// Check status
				if (!success) {
					NSLog(@"Failed to open %@", fileURL);
					return;
				}
				
				
				NSURL * fileURL = localDoc.fileURL;
				NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
				
				NSLog(@"last local Modified Date-%@", version.modificationDate);
				
				localDocModifiedDate = version.modificationDate;
				
				[localDoc closeWithCompletionHandler:^(BOOL success) {
					
					GBDocument * iCloudDoc = [[GBDocument alloc] initWithFileURL:iCloudfileURL];
					[iCloudDoc openWithCompletionHandler:^(BOOL success) {
						
						// Check status
						if (!success) {
							NSLog(@"Failed to open %@", iCloudfileURL);
							return;
						}
						
						NSURL * fileURL = iCloudDoc.fileURL;
						NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
						
						NSLog(@"last iCloud Modified Date-%@", version.modificationDate);
						
						iCloudDocModifiedDate = version.modificationDate;
						
						NSLog(@"iCloud-%@....Local-%@",iCloudDocModifiedDate,localDocModifiedDate);
						
						
						[iCloudDoc closeWithCompletionHandler:^(BOOL success) {
							
							if (!success) {
								NSLog(@"Failed to open %@", iCloudfileURL);
								return;
							}
							//Date Compare Logic Goes here
							
							if ([iCloudDocModifiedDate compare:localDocModifiedDate]==NSOrderedAscending)
							{
								//iCloudDocModifiedDate is early
								NSString * fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
								NSURL *destURL = [self getDocURL:fileName];
								
								NSError *writingError;
								NSError *readingError;
								NSDate *date = nil;
								[localFileURL getResourceValue:&date forKey:NSURLCreationDateKey error:&readingError];
								[destURL setResourceValue:date forKey:NSURLCreationDateKey error:&writingError];
								
								dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
									
									__block NSURL *destinationURL = destURL;
									
									
									NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
									[fileCoordinator coordinateWritingItemAtURL:iCloudfileURL
																		options:NSFileCoordinatorWritingForReplacing
																		  error:nil
																	 byAccessor:^(NSURL* writingURL) {
																		 // Simple delete to start
                                                                             
																		 BOOL fileReplaced = [[NSFileManager defaultManager]replaceItemAtURL:iCloudfileURL withItemAtURL:localFileURL backupItemName:nil options:0 resultingItemURL:&destinationURL error:nil];
                                                                         
                                                                         
																		 
																		 if (fileReplaced)
																		 {
																			 [self loadDocAtURL:destinationURL];
																			 NSLog(@"Success");
																		 }
																		 else
																		 {
																			 NSLog(@"Failed Replacing");
																		 }
																	 }];
									
									
									
									
									
									
								});
								
							}
							else
							{
								
								// Wrap in file coordinator
								dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
									NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
									[fileCoordinator coordinateWritingItemAtURL:localFileURL
																		options:NSFileCoordinatorWritingForDeleting
																		  error:nil
																	 byAccessor:^(NSURL* writingURL) {
																		 // Simple delete to start
																		 NSFileManager* fileManager = [[NSFileManager alloc] init];
																		 [fileManager removeItemAtURL:localFileURL error:nil];
																	 }];
								});
								//localDocModifiedDate is early
							}
						}];
					}];
					
				}];
				
			}];
		}
    }
}

//iCloud Change Notification
- (void)processiCloudFiles:(NSNotification *)notification {
	
	if (_didAddNewTicket) { //Avoid First Notification When Adding a Ticket -Causes Disappear & Reappear
		_didAddNewTicket = NO;
		return;
	}
    // Always disable updates while processing results
    [_query disableUpdates];
	
    [_iCloudURLs removeAllObjects];
	[dateArray removeAllObjects];
    // The query reports all files found, every time.
    NSArray * queryResults = [_query results];
	
	NSLog(@"Metadata Item-%d",queryResults.count);
	
    for (NSMetadataItem * result in queryResults) {
        NSURL * fileURL = [result valueForAttribute:NSMetadataItemURLKey];
		
		//NSNumber *downloadedPercentage = [result valueForAttribute:NSMetadataUbiquitousItemPercentDownloadedKey];
		
		//NSLog(@"Awesome : %@- %d",result,[downloadedPercentage intValue]);
		
        NSNumber * aBool = nil;
		
		NSDate *aDate = nil;
        // Don't include hidden files
        [fileURL getResourceValue:&aDate forKey:NSURLCreationDateKey error:nil];
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue]) {
//            [_iCloudURLs addObject:fileURL];
			[dateArray setObject:fileURL forKey:aDate];
        }
			
    }
	NSArray * keys = [dateArray allKeys];
	
	// sort it
	NSArray * sorted_keys = [keys sortedArrayUsingSelector:@selector(compare:)];
	
	// now, access the values in order
	for (NSDate * key in sorted_keys)
	{
		// get value
		NSString * your_value = [dateArray objectForKey:key];
		NSLog(@"%@ %@",your_value,key);
		[_iCloudURLs addObject:your_value];
		// perform operations
	}

	NSArray *reversed = [[_iCloudURLs reverseObjectEnumerator] allObjects];
    
	[_iCloudURLs removeAllObjects];
	[_iCloudURLs addObjectsFromArray:reversed];

    NSLog(@"Found %d iCloud files.", _iCloudURLs.count);
    
	if (_iCloudURLs.count > 0 && [self iCloudOn])
	{
		self.objectsCount = _iCloudURLs.count;
	}
	else if (_localDocumentsCount >0 && ![self iCloudOn])
	{
		self.objectsCount = _localDocumentsCount;
	}
	else if(_iCloudURLs.count ==0 && [self iCloudOn])
	{
		self.objectsCount = 0;
	}
	
	
    _iCloudURLsReady = YES;
	
    if ([self iCloudOn]) {
		
        // Remove deleted files
        // Iterate backwards because we need to remove items form the array
        for (int i = _objects.count -1; i >= 0; --i) {
            GBEntry * entry = [_objects objectAtIndex:i];
            if (![_iCloudURLs containsObject:entry.fileURL]) {
                [self removeEntryWithURL:entry.fileURL];
            }
        }
		
		//Deleteing Items in iCloud which was deleted in Local
		NSMutableArray *deletedTicketsArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"]];
		
		NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
		
		
		for (int i = 0; i <[deletedTicketsArray count]; i++)
		{
			for (int iCloudIndex = 0; iCloudIndex < _iCloudURLs.count; iCloudIndex++) {
				
				NSURL * iCloudFileURL = [_iCloudURLs objectAtIndex:iCloudIndex];
				if ([[deletedTicketsArray objectAtIndex:i] isEqualToString:[iCloudFileURL lastPathComponent]]) {
					
					[indexesToDelete addIndex:iCloudIndex];
					
					NSLog(@"Found Matching data %@",[deletedTicketsArray objectAtIndex:i]);
					
					// Wrap in file coordinator
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
						NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
						[fileCoordinator coordinateWritingItemAtURL:iCloudFileURL
															options:NSFileCoordinatorWritingForDeleting
															  error:nil
														 byAccessor:^(NSURL* writingURL) {
															 // Simple delete to start
															 NSFileManager* fileManager = [[NSFileManager alloc] init];
															 [fileManager removeItemAtURL:iCloudFileURL error:nil];
														 }];
					});
				}
			}
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DeletedTickets"]) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DeletedTickets"];
		}
		
		if ([indexesToDelete count])
		{
			[_iCloudURLs removeObjectsAtIndexes:indexesToDelete];
		}
		
        // Add new files
        for (NSURL * fileURL in _iCloudURLs) {
            [self loadDocAtURL:fileURL];
        }
				
    }
	
	if (_moveLocalToiCloud) {
        _moveLocalToiCloud = NO;
        [self localToiCloudImpl];
    }
    else if (_copyiCloudToLocal) {
        _copyiCloudToLocal = NO;
        [self iCloudToLocalImpl];
    }
	
    [_query enableUpdates];
	
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    // @"Automatically store your documents in the cloud to keep them up-to-date across all your devices and the web."
    // Cancel: @"Later"
    // Other: @"Use iCloud"
    if (alertView.tag == 1) {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self setiCloudOn:YES];
            [self refresh];
			
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"iCloudChangeNotification"
			 object:self];
        }
		else if(buttonIndex == alertView.cancelButtonIndex)
		{
			
		}
		
    }
	// @"What would you like to do with the documents currently on this iPad?"
    // Cancel: @"Continue Using iCloud"
    // Other 1: @"Keep a Local Copy"
    // Other 2: @"Keep on iCloud Only"
    else if (alertView.tag == 2) {
        
        if (buttonIndex == alertView.cancelButtonIndex) {
            
            [self setiCloudOn:YES];
            [self refresh];
			
			
			[[NSNotificationCenter defaultCenter]
			 postNotificationName:@"iCloudChangeNotification"
			 object:self];
			
        } else if (buttonIndex == alertView.firstOtherButtonIndex) {
			
			_keepLocalCopy = YES;
            if (_iCloudURLsReady) {
                [self iCloudToLocalImpl];
            } else {
                _copyiCloudToLocal = YES;
            }
            
        } else if (buttonIndex == alertView.firstOtherButtonIndex + 1) {
            
			self.objectsCount = 0;
        }
    }
}

#pragma mark Document-Helpers

- (NSURL *)localRoot {
    if (_localRoot != nil) {
        return _localRoot;
    }
	
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    _localRoot = [paths objectAtIndex:0];
    return _localRoot;
}

- (NSURL *)getDocURL:(NSString *)filename {
	if ([self iCloudOn]) {
        NSURL * docsDir = [_iCloudRoot URLByAppendingPathComponent:@"Documents" isDirectory:YES];
        return [docsDir URLByAppendingPathComponent:filename];
    } else {
        return [self.localRoot URLByAppendingPathComponent:filename];
    }
}

- (BOOL)docNameExistsInObjects:(NSString *)docName {
    BOOL nameExists = NO;
    for (GBEntry * entry in _objects) {
        if ([[entry.fileURL lastPathComponent] isEqualToString:docName]) {
            nameExists = YES;
            break;
        }
    }
    return nameExists;
}

- (NSString*)getDocFilename:(NSString *)prefix uniqueInObjects:(BOOL)uniqueInObjects {
    NSInteger docCount = 0;
    NSString* newDocName = nil;
	
    // At this point, the document list should be up-to-date.
    BOOL done = NO;
    BOOL first = YES;
    while (!done) {
        if (first) {
            first = NO;
            newDocName = [NSString stringWithFormat:@"%@.%@",
                          prefix, TB_EXTENSION];
        } else {
            newDocName = [NSString stringWithFormat:@"%@ %d.%@",
                          prefix, docCount, TB_EXTENSION];
        }
		
        // Look for an existing document with the same name. If one is
        // found, increment the docCount value and try again.
        BOOL nameExists;
        if (uniqueInObjects) {
            nameExists = [self docNameExistsInObjects:newDocName];
        } else {
            nameExists = [self docNameExistsIniCloudURLs:newDocName];
        }
        if (!nameExists) {
            break;
        } else {
            docCount++;
        }
		
    }
	
    return newDocName;
}

- (BOOL)docNameExistsIniCloudURLs:(NSString *)docName {
    BOOL nameExists = NO;
    for (NSURL * fileURL in _iCloudURLs) {
        if ([[fileURL lastPathComponent] isEqualToString:docName]) {
            nameExists = YES;
            break;
        }
    }
    return nameExists;
}


#pragma mark Entry management methods

- (int)indexOfEntryWithFileURL:(NSURL *)fileURL {
    __block int retval = -1;
    [_objects enumerateObjectsUsingBlock:^(GBEntry * entry, NSUInteger idx, BOOL *stop) {
        if ([entry.fileURL isEqual:fileURL]) {
            retval = idx;
            *stop = YES;
        }
    }];
    return retval;
}


//Update Coverflow with Data
- (void)addOrUpdateEntryWithURL:(NSURL *)fileURL ticketData:(GBTicketData*)ticketData metadata:(GBMetadata *)metadata state:(UIDocumentState)state version:(NSFileVersion *)version withScroll:(BOOL)scroll {
	
    int index = [self indexOfEntryWithFileURL:fileURL];
	
    // Not found, so add
    if (index == -1) {
		
		//Sort Tickets Based On Date
		NSSortDescriptor *dateSortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"ticketdata.dateFormat"
													 ascending:NO];
		
		NSSortDescriptor *nameSortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"ticketdata.venue"
																		  ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSortDescriptor,nameSortDescriptor,nil];
		
		
        GBEntry * entry = [[GBEntry alloc] initWithFileURL:fileURL ticketData:ticketData metadata:metadata state:state version:version];
        [_objects addObject:entry];
		
		if ([_objects count] == 1) {
			[self.coverFlow setUserInteractionEnabled:YES];
		}
		
		self.objectsCount = [_objects count];
		
		NSArray *temp = [NSArray arrayWithArray:[_objects sortedArrayUsingDescriptors:sortDescriptors]];
		
		[_objects removeAllObjects];
		_objects = nil;
		_objects = [[NSMutableArray alloc]initWithArray:temp];
		temp = nil;
		
		[self.coverFlow insertItemAtIndex:[_objects indexOfObject:entry] animated:YES];
		
		if (scroll)
		{
			[self.coverFlow scrollToItemAtIndex:[_objects indexOfObject:entry] animated:YES];
		}
    }
	
    // Found, so edit
    else {
		
        GBEntry * entry = [_objects objectAtIndex:index];
        entry.metadata = metadata;
        entry.state = state;
        entry.version = version;
		
		//Date Sort When Updated Date
		if ([entry.ticketdata.dateFormat compare:ticketData.dateFormat]!=NSOrderedSame)
		{
			NSSortDescriptor *dateSortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"ticketdata.dateFormat"
																			  ascending:NO];
			
			NSSortDescriptor *nameSortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"ticketdata.venue"
																			  ascending:YES];
			
			NSArray *sortDescriptors = [NSArray arrayWithObjects:dateSortDescriptor,nameSortDescriptor,nil];

			entry.ticketdata = ticketData;
			NSArray *temp = [NSArray arrayWithArray:[_objects sortedArrayUsingDescriptors:sortDescriptors]];
			[_objects removeAllObjects];
			_objects = nil;
			_objects = [[NSMutableArray alloc]initWithArray:temp];
			temp = nil;
			
			//Inconsistency in ViewsChange on Reload
			NSDictionary *entryDataDict = @{@"entry":entry, @"index":[NSNumber numberWithInt:index]};
			[self performSelector:@selector(refershCoverFlowOnEditingTheTicket:) withObject:entryDataDict afterDelay:0.0];
		}
		else	
		{
			entry.ticketdata = ticketData;
			[self.coverFlow reloadItemAtIndex:index animated:NO];
		}
    }
}

- (void)refershCoverFlowOnEditingTheTicket:(NSDictionary *)entryDatadict {
	
	[self.coverFlow removeItemAtIndex:[[entryDatadict objectForKey:@"index"] intValue] animated:NO];
	[self.coverFlow insertItemAtIndex:[_objects indexOfObject:[entryDatadict objectForKey:@"entry"]] animated:NO];
	[self.coverFlow scrollToItemAtIndex:[_objects indexOfObject:[entryDatadict objectForKey:@"entry"]] animated:YES];
}

- (void)loadDocAtURL:(NSURL *)fileURL {
	
    // Open doc so we can read metadata
    GBDocument * doc = [[GBDocument alloc] initWithFileURL:fileURL];
    [doc openWithCompletionHandler:^(BOOL success) {
		
        // Check status
        if (!success) {
            NSLog(@"Failed to open %@", fileURL);
            return;
        }
		
        // Preload metadata on background thread
        GBMetadata * metadata = doc.metadata;
		GBTicketData *ticketdata = doc.ticketdata;
        NSURL * fileURL = doc.fileURL;
        UIDocumentState state = doc.documentState;
        NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
		
        // Close since we're done with it
		
        [doc closeWithCompletionHandler:^(BOOL success) {
			
            // Check status
            if (!success) {
                // Continue anyway...
            }
			
            // Add to the list of files on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOrUpdateEntryWithURL:fileURL ticketData:ticketdata metadata:metadata state:state version:version withScroll:NO];
            });
        }];
    }];
	
}

#pragma mark Refresh Methods

- (void)loadLocal {
	
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    NSLog(@"Found %d local files.", localDocuments.count);
	
	self.objectsCount = localDocuments.count;
	
	_localDocumentsCount = localDocuments.count;
    
    NSMutableArray *tempLocalDocumentsArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *arrayOfDates = [[NSMutableDictionary alloc] init];
	
    for (int i=0; i < localDocuments.count; i++) {
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        NSNumber * aBool = nil;
		
		NSDate *aDate = nil;
        [fileURL getResourceValue:&aDate forKey:NSURLCreationDateKey error:nil];
        // Don't include hidden files
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue]) {
            //            [_iCloudURLs addObject:fileURL];
			[arrayOfDates setObject:fileURL forKey:aDate];
        }
        
    }
	NSArray * keys = [arrayOfDates allKeys];
	
	// sort it
	NSArray * sorted_keys = [keys sortedArrayUsingSelector:@selector(compare:)];
	
	// now, access the values in order
	for (NSDate * key in sorted_keys)
	{
		// get value
		NSString * your_value = [arrayOfDates objectForKey:key];
		[tempLocalDocumentsArray insertObject:your_value atIndex:0];
		// perform operations
	}
	
    for (int i=0; i < tempLocalDocumentsArray.count; i++) {
		
        NSURL * fileURL = [tempLocalDocumentsArray objectAtIndex:i];
        if ([[fileURL pathExtension] isEqualToString:TB_EXTENSION]) {
            NSLog(@"Found local file: %@", fileURL);
            [self loadDocAtURL:fileURL];
        }
    }
}

-(void)scrollToCoverFlow
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.coverFlow scrollToItemAtIndex:_indexPathToBeScrolledTo animated:YES];
	});
}

//Refresh on Changes
- (void)refresh {
	
	_iCloudURLsReady = NO;
	[_iCloudURLs removeAllObjects];
	
	[_objects removeAllObjects];
    [self.coverFlow reloadData];
	
    [self initializeiCloudAccessWithCompletion:^(BOOL available) {
		
        _iCloudAvailable = available;
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloudAvailable"];
		
		if (!_iCloudAvailable)
		{
			
			// If iCloud isn't available, set promoted to no (so we can ask them next time it becomes available)
			[self setiCloudPrompted:NO];
			
			// If iCloud was toggled on previously, warn user that the docs will be loaded locally
			if ([self iCloudWasOn]) {
				
				if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GBEditTicketViewController class]] || [[self.navigationController.viewControllers lastObject] isKindOfClass:[GBTicketViewController class]]) {
					[self.navigationController popToRootViewControllerAnimated:YES];
					self.navigationController.navigationBar.userInteractionEnabled = YES;
				}
				
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"You're Not Using iCloud" message:@"Your documents were removed from this device but remain stored in iCloud. Configure your iCloud account in Settings to continue using iCloud" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
				[alertView show];
				
			}
			
			// No matter what, iCloud isn't available so switch it to off.
			[self setiCloudOn:NO];
			[self setiCloudWasOn:NO];
			
		} else {
			
			// Ask user if want to turn on iCloud if it's available and we haven't asked already
			if (![self iCloudOn] && ![self iCloudPrompted]) {
				
				[self setiCloudPrompted:YES];
				
				UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"iCloud is Available" message:@"Automatically store your documents in the cloud to keep them up-to-date across all your devices and the web." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Use iCloud", nil];
				alertView.tag = 1;
				[alertView show];
				
			}
			
			// If iCloud newly switched off, move local docs to iCloud
			if ([self iCloudOn] && ![self iCloudWasOn]) {
				[self localToiCloud];
			}
			
			// If iCloud newly switched on, move iCloud docs to local
			if (![self iCloudOn] && [self iCloudWasOn]) {
				[self iCloudToLocal];
			}
			
			// Start querying iCloud for files, whether on or off
                        
            [self startQuery];
			
			// No matter what, refresh with current value of iCloudOn
			[self setiCloudWasOn:[self iCloudOn]];
			
		}
		
		
        if (![self iCloudOn]) {
            [self loadLocal];
        }
		
    }];
}

//iCloud Availabilty
- (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (_iCloudRoot != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud available at: %@", _iCloudRoot);
                completion(TRUE);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud not available");
                completion(FALSE);
            });
        }
    });
}

- (void)removeEntryWithURL:(NSURL *)fileURL
{
    int index = [self indexOfEntryWithFileURL:fileURL];
    [_objects removeObjectAtIndex:index];
	self.objectsCount = [_objects count];
	[self.coverFlow removeItemAtIndex:index animated:YES];
}

//Remove Entry Safely using NSFileCoordinator
- (void)deleteEntry:(GBEntry *)entry {
	
	NSLog(@"Removing item -%@",entry.fileURL);
    // Wrap in file coordinator
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:entry.fileURL
                                            options:NSFileCoordinatorWritingForDeleting
                                              error:nil
                                         byAccessor:^(NSURL* writingURL) {
                                             // Simple delete to start
                                             NSFileManager* fileManager = [[NSFileManager alloc] init];
                                             [fileManager removeItemAtURL:entry.fileURL error:nil];
                                         }];
    });
	
    // Fixup view
    [self removeEntryWithURL:entry.fileURL];
	
}


- (NSMetadataQuery *)documentQuery {
	
    NSMetadataQuery * query = [[NSMetadataQuery alloc] init];
    if (query) {
		
		// Search documents subdir only
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
		
        // Add a predicate for finding the documents
        NSString * filePattern = [NSString stringWithFormat:@"*.%@", TB_EXTENSION];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                             NSMetadataItemFSNameKey, filePattern]];
		
    }
    return query;
	
}

- (void)stopQuery {
	
    if (_query) {
		
        NSLog(@"No longer watching iCloud dir...");
		
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
	
}

- (void)startQuery {
	
    [self stopQuery];
	
    NSLog(@"Starting to watch iCloud dir...");
	
    _query = [self documentQuery];
    
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processiCloudFiles:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processiCloudFiles:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
	
    [_query startQuery];
        
}

-(void)dealloc
{
	 [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
