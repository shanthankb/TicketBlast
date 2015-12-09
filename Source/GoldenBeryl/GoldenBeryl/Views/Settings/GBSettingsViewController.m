//
//  GBSettingsViewController.m
//  TicketBlastCoverFlow
//
//  Created by Abhiman Puranik on 21/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBSettingsViewController.h"
#import "GBCoverFlowViewController.h"
#import "GBSettingsDetailViewController.h"

@interface GBSettingsViewController ()

@end

@implementation GBSettingsViewController

{
	NSMutableArray *_settingsArray;
	UIButton *_cancelView;
	
	UIBarButtonItem *_cancelButton;
	BOOL _iCloudPrevStatus;
	UISwitch *_switchview;
	
	NSMutableDictionary *_navBarTitleAttributes;
	UIFont *_navBarTitleFont;
    UILabel *copyRight;
}

- (id)init
{
    self = [super init];
    if (self) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(receiveiCloudChangeNotification:)
													 name:@"iCloudChangeNotification"
												   object:nil];
    }
    return self;
}

- (void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = mainView;
    self.view.userInteractionEnabled = YES;
    self.view.multipleTouchEnabled = YES;
	
	_settingsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44.0 - 20.0)  style:UITableViewStyleGrouped];
	_settingsTable.backgroundView = nil;
    self.settingsTable.delegate = self;
    self.settingsTable.dataSource = self;
	[self.settingsTable setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]]];
    self.settingsTable.userInteractionEnabled = YES;
    [self.view addSubview:self.settingsTable];
    
    
	self.settingsTable.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.settingsTable attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.settingsTable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
	 [self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.settingsTable attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.settingsTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
	[self.view addConstraint:tableViewConstraints];
    
	
	copyRight = [[UILabel alloc]initWithFrame:CGRectMake(42, self.settingsTable.frame.size.height - 35, 235, 30)];
	copyRight.textAlignment = NSTextAlignmentCenter;
	copyRight.text = kCopyRight;
	copyRight.backgroundColor = [UIColor clearColor];
	copyRight.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
	copyRight.font = [UIFont fontWithName:@"GothamNarrow-Light" size:14.0];
    [copyRight setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin];
    [self.settingsTable addSubview:copyRight];
	//Static Cells DataSource
	NSArray *iCloudInfoArray = [[NSArray alloc]initWithObjects:@"Enable iCloud Sync",nil];
	NSArray *settingsInfoArray = [[NSArray alloc]initWithObjects:@"FAQ",@"Help",@"Blog",@"About",@"Contact",@"Visit Our Website",nil];
	_settingsArray = [[NSMutableArray alloc]initWithObjects:iCloudInfoArray,settingsInfoArray,nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Navigation Title
	self.navigationItem.title = @"Settings";
	
	//Cancel
	_cancelView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 30)];
	[_cancelView setTitle:@"Done" forState:UIControlStateNormal];
    [_cancelView setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
    [_cancelView setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateHighlighted];

	_cancelView.titleLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:18.0];
    if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
    {
        _cancelView.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else
    {
        _cancelView.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    }
	[_cancelView addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
	
	_cancelButton = [[UIBarButtonItem alloc] initWithCustomView:_cancelView];
	[self.navigationItem setRightBarButtonItem:_cancelButton];
	
	_iCloudPrevStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	 [self initializeiCloudAccessWithCompletion:^(BOOL available) {
		 [[NSUserDefaults standardUserDefaults] setBool:available forKey:@"iCloudAvailable"];
	 }];
		
    UIButton *leftNavButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
	
	//Orientation for BarButton
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		
		[_cancelView setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width,  31.0)];
	}
	else if(UIInterfaceOrientationIsLandscape(orientation))
	{
		[_cancelView setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 25.0)];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - TableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_settingsArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[_settingsArray objectAtIndex:section]count];
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 20.0;
    return 10.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 1)
        return 40.0;
    return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.0];
		cell.textLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
		[cell setSelectionStyle:UITableViewCellEditingStyleNone];
    }
	
	if (indexPath.section == 0)
	{
		_switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
		 [_switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
		[_switchview setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"]];
        [_switchview setOnTintColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0]];
		cell.accessoryView = _switchview;
		
	}
	else if(indexPath.section == 1)
	{
		cell.accessoryView = [[ UIImageView alloc ]
								initWithImage:[UIImage imageNamed:@"text_field_arrow"]];
		
		if (indexPath.row == 0 && indexPath.section == 1)
		{
			//cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
			//cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
			
		}
		else if (indexPath.row == ([[_settingsArray objectAtIndex:indexPath.section]count] - 1))
		{
			//cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
			//cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
		}
		else
		{
			//cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
			//cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
		}
	}
    else if(indexPath.section ==2)
    {
		
			cell.accessoryType = UITableViewCellAccessoryNone;
			//cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
			//cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
    }
	
	cell.textLabel.text = [[_settingsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
    }
    else if(indexPath.section == 1)
    {
		GBSettingsDetailViewController *settingsDetail = [[GBSettingsDetailViewController alloc]init];
        if (indexPath.row == 0)
        {
			settingsDetail.url = [NSURL URLWithString:@"http://www.ticketblastapp.com/faq"];
			settingsDetail.navTitle = @"FAQ";
			[self.navigationController pushViewController:settingsDetail animated:YES];
        }
        else if(indexPath.row == 1)
        {
            NSString *mailSubject = @"I need help with TicketBlast";
			[self openMailWithSubject:mailSubject];
        }
        else if(indexPath.row == 2)
        {
			settingsDetail.url = [NSURL URLWithString:@"http://www.ticketblastapp.com/blog"];
			settingsDetail.navTitle = @"Blog";
			[self.navigationController pushViewController:settingsDetail animated:YES];
        }
        else if(indexPath.row == 3)
        {
			settingsDetail.url = [NSURL URLWithString:@"http://www.ticketblastapp.com/about"];
			settingsDetail.navTitle = @"About";
			[self.navigationController pushViewController:settingsDetail animated:YES];
        }
        else if(indexPath.row == 4)
        {
            NSString *mailSubject = @"A TicketBlast Comment";
			[self openMailWithSubject:mailSubject];
        }
		else if(indexPath.row == 5)
		{
			settingsDetail.url = [NSURL URLWithString:@"http://www.ticketblastapp.com/"];
			settingsDetail.navTitle = @"Home Page";
			[self.navigationController pushViewController:settingsDetail animated:YES];
		}
		
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark -Mail Composer

- (void)openMailWithSubject:(NSString *)mailSubject
{
	//Custom Font Takes Time and Crashes MailComposer
	_navBarTitleAttributes = nil;
	_navBarTitleFont = nil;
	_navBarTitleAttributes = [[UINavigationBar appearance] titleTextAttributes].mutableCopy;
	_navBarTitleFont = _navBarTitleAttributes[UITextAttributeFont];
	_navBarTitleAttributes[UITextAttributeFont] = [UIFont systemFontOfSize:_navBarTitleFont.pointSize];
	[[UINavigationBar appearance] setTitleTextAttributes:_navBarTitleAttributes];
    
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            UITextAttributeTextColor: [UIColor blackColor],
                                                            /*UITextAttributeTextShadowColor: [UIColor colorWithRed:157.0/255.0 green:102.0/255.0 blue:15.0/255.0 alpha:1.0],
                                                             UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],*/
                                                            UITextAttributeFont: [UIFont fontWithName:@"GothamNarrow-Medium" size:20.0f],
                                                            
                                                            }];
    }
    else
    {
        [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                UITextAttributeTextColor: [UIColor whiteColor],
                                                                /*UITextAttributeTextShadowColor: [UIColor colorWithRed:157.0/255.0 green:102.0/255.0 blue:15.0/255.0 alpha:1.0],
                                                                 UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)],*/
                                                                UITextAttributeFont: [UIFont fontWithName:@"GothamNarrow-Medium" size:20.0f],
                                                                
                                                                }];
    }
	
    if ([MFMailComposeViewController canSendMail])
    {
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObjects:@"info@ticketblastapp.com", nil];
        [mailer setToRecipients:toRecipients];
        [mailer setSubject:mailSubject];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet. Please check that the device has atleast one mail account added."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	_navBarTitleAttributes[UITextAttributeFont] = _navBarTitleFont;
	[[UINavigationBar appearance] setTitleTextAttributes:_navBarTitleAttributes];
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultSaved:{
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
															message:@"Saved to Drafts"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles: nil];
			[alert show];
			}
			break;
		case MFMailComposeResultSent:{
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
															message:@"Mail sent"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles: nil];
			[alert show];
			}
			break;
		case MFMailComposeResultFailed:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
															message:@"Mail sending failed"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles: nil];
			[alert show];
		}
			break;
		default:
		{
			break;
		}
			
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark iCloud Availablity Check

- (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSURL * _iCloudRoot;  _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (_iCloudRoot != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(TRUE);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(FALSE);
            });
        }
    });
}


#pragma mark Switch Function

- (void)updateSwitchAtIndexPath:(UISwitch *)syncSwitch
{
	if ([syncSwitch isOn])
	{
		if (![[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudAvailable"])
		{
			UIAlertView *icloudNotConfiguredAlert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"iCloud is not configured in this device. Please configure iCloud in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			
			[icloudNotConfiguredAlert show];
			[syncSwitch setOn:NO animated:YES];
		}
		else
		{
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloudOn"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
	else
	{
		NSLog(@"Switch is OFF");
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"iCloudOn"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if (_iCloudPrevStatus != [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"])
	{
		[self.delegate settingsChanged];
	}
}

#pragma mark Bar Button Actions

-(void) cancelClicked
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Device Orientation

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate
{
	return YES;
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self resizeNavButtonsOnRotationForOrientation:toInterfaceOrientation];
}


- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	UIButton *leftNavButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		
		[_cancelView setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width,  31.0)];
        [copyRight setFrame:CGRectMake(42, self.settingsTable.frame.size.height - 35, 235, 30)];
	}
	else if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		[_cancelView setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 25.0)];
        if([[UIScreen mainScreen] bounds].size.height == 568.0f)
            [copyRight setFrame:CGRectMake(160, 585, 235, 30)];
        else
            [copyRight setFrame:CGRectMake(120, 500, 235, 30)];
	}
}

#pragma mark - iCloud Change Notification Method

//iCloud Switch to be Toggled "ON" on Receiving this Notification
- (void) receiveiCloudChangeNotification:(NSNotification *) notification
{
	if ([[notification name] isEqualToString:@"iCloudChangeNotification"]){
       
		NSLog (@"iCloud Change Notification");
		[_switchview setOn:YES animated:YES];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"iCloudOn"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark Dealloc

-(void)dealloc
{
	self.settingsTable = nil;
	_settingsArray = nil;
	_cancelView = nil;
	_cancelButton = nil;
	_switchview = nil;
	_navBarTitleAttributes = nil;
	_navBarTitleFont = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
