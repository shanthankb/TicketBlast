//
//  GBNewTicketViewController.m
//
//  Created by Abhiman Puranik on 18/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBNewTicketViewController.h"
#import "GBCoverFlowViewController.h"
#import "UIImage+Resize.h"
#import "GBDocumentManager.h"


#define kTextViewPlaceHolder @"Notes (Max 120 characters)"
#define kAutoCompleteTableTag 4444

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kCropRect (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? CGRectMake(10, 167, 300, 247) : CGRectMake(10, 141, 300, 208)
#define kImageCropperSize (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? CGSizeMake(320,(568 - 20 -44)) : CGSizeMake(320,(480 - 20 -44))

@interface GBNewTicketViewController ()
- (void)scrollToPosition;
- (NSString *)getDateInRequiredFormatForDate:(NSDate *)inDate;
- (void)dismissPresentedViews;
- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)hideDatePicker;
- (UIImage *)fixImageOrientation:(UIImage *)inputImage;
- (void)returnToPreviousView;
@end


@implementation GBNewTicketViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor blackColor];
    self.view = mainView;
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
    _screenWidth = self.view.frame.size.width;
    
    // The main table view which shows the form to add ticket details.
    
    _createTicketTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];          
    _createTicketTableView.delegate = self;
    _createTicketTableView.dataSource = self;
    _createTicketTableView.backgroundView = nil;
    _createTicketTableView.backgroundColor =[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    _createTicketTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _createTicketTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_createTicketTableView];
    
    NSLayoutConstraint *tableViewConstraints = [NSLayoutConstraint constraintWithItem:_createTicketTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    [self.view addConstraint:tableViewConstraints];
    
    tableViewConstraints = [NSLayoutConstraint constraintWithItem:_createTicketTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    [self.view addConstraint:tableViewConstraints];
    
    tableViewConstraints = [NSLayoutConstraint constraintWithItem:_createTicketTableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    [self.view addConstraint:tableViewConstraints];
    
    tableViewConstraints = [NSLayoutConstraint constraintWithItem:_createTicketTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    [self.view addConstraint:tableViewConstraints];
    
    
    // The tableview which handles the autosuggest feature in the form
    
    _autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	_autocompleteTableView.delegate = self;
	_autocompleteTableView.dataSource = self;
	_autocompleteTableView.scrollEnabled = YES;
	_autocompleteTableView.hidden = YES;
    _autocompleteTableView.alwaysBounceVertical = NO;
    _autocompleteTableView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_autocompleteTableView];
    
	_autocompleteTableView.tag = kAutoCompleteTableTag;
	_autocompleteUrls = [[NSMutableArray alloc] init];

    
    _keyBoardRect = CGRectZero;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTable:)];            //Initializing the tap gesture to dismiss the keyboard/date picker. 
    _tapGesture.delegate = self;
    
    self.displayFields = [[NSMutableArray alloc] init];
    
    [self.displayFields addObject:kEventImage];
    [self.displayFields addObject:kEventType];
    [self.displayFields addObject:kEventVenue];
    [self.displayFields addObject:kHomeTeam];
    [self.displayFields addObject:kOpponent];
    [self.displayFields addObject:kEventDate];
    [self.displayFields addObject:kEventNotes];
    
    self.allFields = [[NSMutableArray alloc] init];
    [self.allFields addObject:kEventImage];
    [self.allFields addObject:kEventType];
    [self.allFields addObject:kEventVenue];
    [self.allFields addObject:kHomeTeam];
    [self.allFields addObject:kOpponent];
    [self.allFields addObject:kHeadline];
    [self.allFields addObject:kEventName];
    [self.allFields addObject:kEventDate];
    [self.allFields addObject:kEventNotes];
    
    
    self.ticketDetails = [[NSMutableDictionary alloc] init];
    [self.ticketDetails setObject:@"Game" forKey:kEventType];                                                       //setting default type to game
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"ticket_icon" ofType:@".png"];
    [self.ticketDetails setObject:imgPath forKey:kEventImage];
   
    CGRect selfBounds = self.view.bounds;
	selfBounds.size.height = self.view.bounds.size.height - 44.0;
	
	_progressSpinner = [[OVSpinningProgressViewOverlay alloc] initWithFrameOfEnclosingView:selfBounds];             //The progress indicator which is shown when the form is being added.
    [_progressSpinner setHidesWhenStopped:YES];
    [self.view addSubview:_progressSpinner];
    self.selectedImage = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    _didUseImagePicker = NO;
    _isKeyboardShown = NO;
    self.shouldClearFields = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Ticket";
    
    // Setting the back buttons on the navigation bar.
        
    NSString *previousTitle;     //Title of the back button on the navigation bar.
    
    if (self.numberOfTickets<1)
    {
        previousTitle = @"Add Ticket";
    }
    else
    {
       previousTitle = @"Tickets";
    }
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 12, 25)];
    [backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back_pressed"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
    

    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [doneButton setTitle:@"Save" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:20.0];
    [doneButton addTarget:self action:@selector(didTapDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateDisabled];
    [doneButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateHighlighted];
    _doneBarButton = [[UIBarButtonItem alloc]initWithCustomView:doneButton];
    [self.navigationItem setRightBarButtonItem:_doneBarButton];
    _doneBarButton.enabled = NO;
    _isImagePickerShown = NO;	
	
	[self initializeiCloudAccessWithCompletion:^(BOOL available) {
		
	}];
    
	
}

// Method retrieves the iCloud Ubiquity container URL.
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

// Returns the URL of the directory where the files are stored. 
- (NSURL *)getDocURL:(NSString *)filename {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"]) {
        NSURL * docsDir = [_iCloudRoot URLByAppendingPathComponent:@"Documents" isDirectory:YES];
        return [docsDir URLByAppendingPathComponent:filename];                                      //Returns iCloud documents URL when iCloud is on. 
    } else {
        return [self.localRoot URLByAppendingPathComponent:filename];                               //Returns local documents directory, when iCloud is off.
    }
}

- (NSURL *)localRoot {
    if (_localRoot != nil) {
        return _localRoot;
    }
    
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    _localRoot = [paths objectAtIndex:0];
    return _localRoot;
}



-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	if (!_didUseImagePicker && self.shouldClearFields) {
        
        
        //Clearing ticket details when the view appears. This is done to clear the fields when a new event type is selected.
        
        [self.ticketDetails setObject:@"" forKey:kEventVenue];
        [self.ticketDetails setObject:@"" forKey:kOpponent];
        [self.ticketDetails setObject:@"" forKey:kHomeTeam];
        [self.ticketDetails setObject:@"" forKey:kHeadline];
        [self.ticketDetails setObject:@"" forKey:kEventNotes];
        [self.ticketDetails setObject:@"" forKey:kEventName];
        [self.ticketDetails setObject:[self getDateInRequiredFormatForDate:[NSDate date]] forKey:kEventDate];
        _initialTicketDate = [self.ticketDetails objectForKey:kEventDate];
         _doneBarButton.enabled = NO;
    }
    
     _didUseImagePicker = NO;
        
    [_createTicketTableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
	if (self.numberOfTickets == 0)
	{
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	
	else if ([[self.navigationController viewControllers] count] == 1)
	{
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}

}

- (void)didTapBackButton:(id)sender
{
    BOOL shouldShowAlert = NO;          //BOOL value to indicate if discard form alert should be shown or not.
    
    [self dismissPresentedViews];
    
    //Loop detects if any value in the form was changed/added.
    for (int i = 0; i < [self.ticketDetails.allKeys count]; i++)
    {
       if (![[self.ticketDetails.allKeys objectAtIndex:i] isEqualToString:kEventImage] && ![[self.ticketDetails.allKeys objectAtIndex:i] isEqualToString:kEventDate] && ![[self.ticketDetails.allKeys objectAtIndex:i] isEqualToString:kEventType])
        {
            if (![[self.ticketDetails objectForKey:[self.ticketDetails.allKeys objectAtIndex:i] ] isEqualToString:@""]) {  //Condition for text fields.
                shouldShowAlert = YES;
                break;
            }
        }
        else if([[self.ticketDetails.allKeys objectAtIndex:i] isEqualToString:kEventImage])                                //Condition for imageview.
        {
            if (self.selectedImage != nil)
            {
                shouldShowAlert = YES;
            break;
            }
        }
        else if([[self.ticketDetails.allKeys objectAtIndex:i] isEqualToString:kEventDate])                                 //Condition for date picker.
        {
            if (![[self.ticketDetails objectForKey:kEventDate] isEqualToString:_initialTicketDate]) {
                shouldShowAlert = YES;
                break;
            }
        }
    }
    
    if (shouldShowAlert)
    {
        _saveTicketAlert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Do you want to discard this ticket?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil];
        [_saveTicketAlert show];
    }
    else
        [self returnToPreviousView];
    
}

- (void)returnToPreviousView
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapDoneButton:(id)sender
{
    [self dismissPresentedViews];
    _progressSpinner.center = self.view.center;
    [_progressSpinner startAnimating];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
    [self performSelector:@selector(completeSaveAction) withObject:nil afterDelay:0.0];         //Required, otherwise will not show progress indicator on time.
}

- (void)completeSaveAction
{
    BOOL isFormComplete = YES;
    NSMutableArray *incompleteFields = [[NSMutableArray alloc] init];                           //Array to hold list of incomplete fields.
    for (int i = 0; i < [self.displayFields count]; i++)
    {
        NSString *stringWithoutSpaces = [[self.ticketDetails objectForKey:[self.displayFields objectAtIndex:i]] stringByReplacingOccurrencesOfString:@" " withString:@""];      //Removing spaces.
        if (([stringWithoutSpaces isEqualToString:@""]) || (stringWithoutSpaces.length == 0))
        {
            if (i != ([self.displayFields count] - 1))
            {
                isFormComplete = NO;
                [incompleteFields addObject:[self.displayFields objectAtIndex:i]];
            }
            
        }
    }
    
    if (isFormComplete)
    {
        
        //Check for unnecessary fields
        for (int j = 0; j < [self.displayFields count]; j++)
        {
            if ([[self.ticketDetails objectForKey:[self.allFields objectAtIndex:j]] isEqualToString:@""])
            {
                [self.ticketDetails removeObjectForKey:[self.allFields objectAtIndex:j]];
            }
        }
        
		// Create new document and save to the filename
		NSURL * fileURL = [self getDocURL:[self getDocFilename:[NSDate date]  uniqueInObjects:YES]];
		self.doc = [[GBDocument alloc] initWithFileURL:fileURL];
		self.doc.ticketdata.venue = [self.ticketDetails objectForKey:kEventVenue];
		self.doc.ticketdata.eventNotes = [self.ticketDetails objectForKey:kEventNotes];
		self.doc.ticketdata.eventType = [self.ticketDetails objectForKey:kEventType];
		self.doc.ticketdata.homeTeam = [self.ticketDetails objectForKey:kHomeTeam];
		self.doc.ticketdata.opponentTeam = [self.ticketDetails objectForKey:kOpponent];
		self.doc.ticketdata.eventName = [self.ticketDetails objectForKey:kEventName];
		self.doc.ticketdata.headLine = [self.ticketDetails objectForKey:kHeadline];
		self.doc.ticketdata.date = [self.ticketDetails objectForKey:kEventDate];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		NSDate *eventDate = [dateFormatter dateFromString:self.doc.ticketdata.date];
		
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *components = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:eventDate];
		
		NSInteger day = [components day];
		NSInteger month = [components month];
		NSInteger year = [components year];
		
		NSCalendar *calendarForCurrentDate = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *componentsCurrentDate = [calendarForCurrentDate components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
		
		NSInteger currentHour = [componentsCurrentDate hour];
		NSInteger currentMinute = [componentsCurrentDate minute];
		NSInteger currentSecond = [componentsCurrentDate second];

		
		NSCalendar *calendarForNewDate = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *componentsForNewDate = [[NSDateComponents alloc] init];
		[componentsForNewDate setYear:year];
		[componentsForNewDate setMonth:month];
		[componentsForNewDate setDay:day];
		[componentsForNewDate setHour:currentHour];
		[componentsForNewDate setMinute:currentMinute];
		[componentsForNewDate setSecond:currentSecond];
		
		NSDate *newDateForKey = [calendarForNewDate dateFromComponents:componentsForNewDate];
		
		self.doc.ticketdata.dateFormat =  eventDate;
        
		self.doc.photo =self.selectedImage;
		
		
			    
		[self.doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {              //Saving the document.
		
					[self.doc closeWithCompletionHandler:^(BOOL success) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (!success){
						NSLog(@"Failed to close %@", self.doc.fileURL);
					}
					else{
						NSLog(@"Sucess Saved- %@", self.doc.fileURL);
					}
					NSError *err;
					[fileURL setResourceValue:newDateForKey forKey:NSURLCreationDateKey error:&err];
					NSLog(@"Setting Value-%@",newDateForKey);
					NSLog(@"err-%@",err);
					[self.delegate newTickedSaved:self];
				});
			}];
		}];
		
    }
    else
    {
        [_progressSpinner stopAnimating];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        NSString *incompleteFieldsString = [incompleteFields componentsJoinedByString:@"/"];
        [[GBAlertWindow sharedAlertWindow] showMessage:[NSString stringWithFormat:@"Please enter a %@", incompleteFieldsString]];       //Alert showing list of incomplete fields.
    }
}


// Returns the filename of the document to be stored.
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
		
		break;
        
        // Look for an existing document with the same name. If one is
        // found, increment the docCount value and try again.
        BOOL nameExists;
        if (uniqueInObjects) {
			//  nameExists = [self docNameExistsInObjects:newDocName];
        } else {
			//  nameExists = [self docNameExistsIniCloudURLs:newDocName];
        }
        if (!nameExists) {
            break;
        } else {
            docCount++;
        }
        
    }
    
    return newDocName;
}


-(void)dealloc
{
	[self.ticketDetails removeAllObjects];
	self.ticketDetails = nil;
	[self.displayFields removeAllObjects];
	self.displayFields = nil;
	[self.allFields removeAllObjects];
	self.allFields = nil;
	_createTicketTableView = nil;
	self.selectedImage = nil;
    _datePicker = nil;
   _tapGesture= nil;
    _createTicketTableView= nil;
    _autocompleteTableView= nil;
    _addImageLabel= nil;
    _autoCompleteTextField= nil;
    _pastUrls= nil;
    _saveTicketAlert= nil;
    _originalImage= nil;
    _scaledImageForDisplay= nil;
    _progressSpinner= nil;
    _doneBarButton= nil;
	
}

// Returns the path of local documents directory.
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
	
    return [documentsPath stringByAppendingPathComponent:name];
}

#pragma mark - TableView Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.tag != kAutoCompleteTableTag && _autocompleteTableView.hidden==NO)
	{
        //Hides the autocomplete tableview when the main table is scrolled. 
		_autocompleteTableView.hidden = YES;
		[_activeTextElement resignFirstResponder];
	}
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == kAutoCompleteTableTag)
    {
		return 1;
	}
    else
        return [self.displayFields count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kAutoCompleteTableTag)
    {
        return _autocompleteUrls.count;
    }
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kAutoCompleteTableTag)
    {
        //Create cells for autocomplete tableview.
        UITableViewCell *cell = nil;
		static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
		cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
		[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		if (cell == nil) {
			cell = [[UITableViewCell alloc]
					initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
		}
		
		cell.textLabel.text = [_autocompleteUrls objectAtIndex:indexPath.row];
		cell.textLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"Gotham-Book" size:18.0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
        if (indexPath.row == [_autocompleteUrls count] -1)
        {
            cell.backgroundView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"autosuggest_cell_bottom"]];
//			cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
            cell.backgroundColor = [UIColor clearColor];
        }
        else if (indexPath.row == 0)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"autosuggest_cell_top"]];
//			cell.backgroundView.contentMode = UIViewContentModeCenter;
        }
        else
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"autosuggest_cell_middle"]];
//			cell.backgroundView.contentMode = UIViewContentModeCenter;
        }

        
        return cell;
    }
    else
    {
    if (indexPath.section == 0)
    {
        //Create cell for showing 'Add Image' cell.
        static NSString *CellIdentifier = @"AddImageCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIButton *addImageButton;
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImage *ticketBorderImage = [UIImage imageNamed:@"ticket_placeholder"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, cell.frame.size.width-24, ticketBorderImage.size.height)];
            imageView.image = [ticketBorderImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            UIView *view = [[UIView alloc]initWithFrame:cell.bounds];
            [view addSubview:imageView];
            cell.backgroundView = view;
            cell.backgroundColor = [UIColor clearColor];
            addImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
            addImageButton.tag = 1111;
            addImageButton.translatesAutoresizingMaskIntoConstraints = NO;
            addImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            addImageButton.layer.cornerRadius = 7.0;
            addImageButton.imageEdgeInsets = UIEdgeInsetsMake(18, 86, 40, 86);
            [addImageButton addTarget:self action:@selector(didTapAddImageButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addImageButton];            
            
            NSLayoutConstraint *addImageButtonConstraint = [NSLayoutConstraint constraintWithItem:addImageButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:-1];
            
            [cell.contentView addConstraint:addImageButtonConstraint];
            
            addImageButtonConstraint = [NSLayoutConstraint constraintWithItem:addImageButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:-1];
            
            [cell.contentView addConstraint:addImageButtonConstraint];
            
            addImageButtonConstraint = [NSLayoutConstraint constraintWithItem:addImageButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:2];
            
            [cell.contentView addConstraint:addImageButtonConstraint];
            
            addImageButtonConstraint = [NSLayoutConstraint constraintWithItem:addImageButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:2];
            
            [cell.contentView addConstraint:addImageButtonConstraint];
            
            _standardImageSize = CGSizeMake(addImageButton.frame.size.width * 2, addImageButton.frame.size.height * 2);
            
            _addImageLabel = [[UILabel alloc] init];
            _addImageLabel.backgroundColor = [UIColor clearColor];
			_addImageLabel.tag = 3411;
            _addImageLabel.textColor = [UIColor lightGrayColor];
            _addImageLabel.text = @"Tap to add a photo";
            _addImageLabel.textAlignment = NSTextAlignmentCenter;
            _addImageLabel.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
            _addImageLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [addImageButton addSubview:_addImageLabel];
            
            NSLayoutConstraint *addImageLabelConstraint = [NSLayoutConstraint constraintWithItem:_addImageLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:addImageButton attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
            
            [cell.contentView addConstraint:addImageLabelConstraint];
            
            addImageLabelConstraint = [NSLayoutConstraint constraintWithItem:_addImageLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:addImageButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-11];
            
            [cell.contentView addConstraint:addImageLabelConstraint];
            
            addImageLabelConstraint = [NSLayoutConstraint constraintWithItem:_addImageLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:addImageButton attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0];
            
            [cell.contentView addConstraint:addImageLabelConstraint];
            
            addImageLabelConstraint = [NSLayoutConstraint constraintWithItem:_addImageLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30];
            
            [cell.contentView addConstraint:addImageLabelConstraint];
            
        }
        else
        {
            addImageButton = (UIButton *)[cell.contentView viewWithTag:1111];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.selectedImage)
        {
            addImageButton.backgroundColor = [UIColor blackColor];
            addImageButton.imageEdgeInsets = UIEdgeInsetsZero;
        }
        else
        {
            addImageButton.backgroundColor = [UIColor clearColor];
            addImageButton.imageEdgeInsets = UIEdgeInsetsMake(18, 86, 40, 86);
        }
        
        if ([_addImageLabel.text isEqualToString:@"Tap to add a photo"])
        {
			_addImageLabel = (UILabel *)[cell viewWithTag:3411];
			_addImageLabel.textColor = [UIColor lightGrayColor];
        }
        else
        {
			_addImageLabel = (UILabel *)[cell viewWithTag:3411];
			_addImageLabel.textColor = [UIColor whiteColor];
        }
        
		if (self.selectedImage)
		{
			 [addImageButton setImage:self.selectedImage forState:UIControlStateNormal];
		}
		else
		{	
			[addImageButton setImage:[UIImage imageNamed:@"ticket_icon"] forState:UIControlStateNormal];
		}
       
        return cell;
        
    }
    
    else if (indexPath.section == 1)
    {
        //Create cell for Event type selection.
        static NSString *CellIdentifier = @"EventTypeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *eventTypeLabel;
        UILabel *selectedEventTypeLabel;
        UIImageView *accessoryImageView;
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            eventTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            eventTypeLabel.text = @"Event Type";
            eventTypeLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
            eventTypeLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.0];
            eventTypeLabel.backgroundColor = [UIColor clearColor];
            eventTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:eventTypeLabel];
            
            NSLayoutConstraint *labelConstraints = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f];
            [cell.contentView addConstraint:labelConstraints];
            
            labelConstraints = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5.0f];
            [cell.contentView addConstraint:labelConstraints];
            
            labelConstraints = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-150.0f];
            [cell.contentView addConstraint:labelConstraints];
            
            labelConstraints = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
            [cell.contentView addConstraint:labelConstraints];
            
            accessoryImageView = [[UIImageView alloc] init];
            accessoryImageView.image = [UIImage imageNamed:@"text_field_arrow"];
            accessoryImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:accessoryImageView];
            NSLayoutConstraint *accessoryImageViewConstraint = [NSLayoutConstraint constraintWithItem:accessoryImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20];
            
            [cell.contentView addConstraint:accessoryImageViewConstraint];
            
            accessoryImageViewConstraint = [NSLayoutConstraint constraintWithItem:accessoryImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:14];
            
            [cell.contentView addConstraint:accessoryImageViewConstraint];
            
            accessoryImageViewConstraint = [NSLayoutConstraint constraintWithItem:accessoryImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:10];
            
            [cell.contentView addConstraint:accessoryImageViewConstraint];
            
            accessoryImageViewConstraint = [NSLayoutConstraint constraintWithItem:accessoryImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:14];
            
            [cell.contentView addConstraint:accessoryImageViewConstraint];
            
            selectedEventTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            selectedEventTypeLabel.tag = 2222;
            selectedEventTypeLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
            selectedEventTypeLabel.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
            selectedEventTypeLabel.backgroundColor = [UIColor clearColor];
            selectedEventTypeLabel.textAlignment = NSTextAlignmentRight;
            selectedEventTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:selectedEventTypeLabel];
            
            NSLayoutConstraint *eventTypeConstraints = [NSLayoutConstraint constraintWithItem:selectedEventTypeLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-41.0f];
            [cell.contentView addConstraint:eventTypeConstraints];
            
            eventTypeConstraints = [NSLayoutConstraint constraintWithItem:selectedEventTypeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5.0f];
            [cell.contentView addConstraint:eventTypeConstraints];
            
            eventTypeConstraints = [NSLayoutConstraint constraintWithItem:selectedEventTypeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
            [cell.contentView addConstraint:eventTypeConstraints];
            
            eventTypeConstraints = [NSLayoutConstraint constraintWithItem:selectedEventTypeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
            [cell.contentView addConstraint:eventTypeConstraints];
            
        }
        else
        {
            selectedEventTypeLabel = (UILabel *)[cell.contentView viewWithTag:2222];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        selectedEventTypeLabel.text = [self.ticketDetails objectForKey:kEventType];
        
        return cell;
        
    }
    
    else if (indexPath.section == ([self.displayFields count] - 2))
    {
        //Create cell for Ticket Date selection.
        static NSString *CellIdentifier = @"DateSelectionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *dateLabel;
        UILabel *selectedDateLabel;
        UIButton *selectCellButton;
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
            dateLabel.text = @"Date";
            dateLabel.textColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:125.0/255.0 alpha:1.0];
            dateLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.0];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:dateLabel];
            
            NSLayoutConstraint *dateLabelConstraints = [NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f];
            [cell.contentView addConstraint:dateLabelConstraints];
            
            dateLabelConstraints = [NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:7.0f];
            [cell.contentView addConstraint:dateLabelConstraints];
            
            dateLabelConstraints = [NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:150.0f];
            [cell.contentView addConstraint:dateLabelConstraints];
            
            dateLabelConstraints = [NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
            [cell.contentView addConstraint:dateLabelConstraints];
            
            selectCellButton = [[UIButton alloc] init];
            selectCellButton.backgroundColor = [UIColor clearColor];
            selectCellButton.translatesAutoresizingMaskIntoConstraints = NO;
            selectCellButton.tag = 6666;
            [selectCellButton addTarget:self action:@selector(didTapDateButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:selectCellButton];
            
            NSLayoutConstraint *selectDateConstraints = [NSLayoutConstraint constraintWithItem:selectCellButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:selectDateConstraints];
            
            selectDateConstraints = [NSLayoutConstraint constraintWithItem:selectCellButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:selectDateConstraints];
            
            selectDateConstraints = [NSLayoutConstraint constraintWithItem:selectCellButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:selectDateConstraints];
            
            selectDateConstraints = [NSLayoutConstraint constraintWithItem:selectCellButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:selectDateConstraints];
            
            selectedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, 150, 30)];
            selectedDateLabel.text = @"SelectedDate";
            selectedDateLabel.tag = 3333;
            selectedDateLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
            selectedDateLabel.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
            selectedDateLabel.backgroundColor = [UIColor clearColor];
            selectedDateLabel.textAlignment = NSTextAlignmentRight;
            selectedDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:selectedDateLabel];
            
            NSLayoutConstraint *selectedLabelConstraints = [NSLayoutConstraint constraintWithItem:selectedDateLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-19.0f];
            [cell.contentView addConstraint:selectedLabelConstraints];
            
            selectedLabelConstraints = [NSLayoutConstraint constraintWithItem:selectedDateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:7.0f];
            [cell.contentView addConstraint:selectedLabelConstraints];
            
            selectedLabelConstraints = [NSLayoutConstraint constraintWithItem:selectedDateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:160.0f];
            [cell.contentView addConstraint:selectedLabelConstraints];
            
            selectedLabelConstraints = [NSLayoutConstraint constraintWithItem:selectedDateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
            [cell.contentView addConstraint:selectedLabelConstraints];
            
        }
        else
        {
            selectedDateLabel = (UILabel *)[cell.contentView viewWithTag:3333];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        selectedDateLabel.text = [self.ticketDetails objectForKey:kEventDate];
        return cell;
        
    }
    
    else if (indexPath.section == ([self.displayFields count] - 1))
    {
        //Create cell for adding event notes.
        static NSString *CellIdentifier = @"EventNotesCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UITextView *eventNotesTextView;
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            UIToolbar *toolbar = [[UIToolbar alloc]init];
            toolbar.barStyle = UIBarStyleDefault;
            [toolbar sizeToFit];
            
            
            UIBarButtonItem *doneleftBarButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarbuttonClicked)];
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
            NSArray *array = [NSArray arrayWithObjects:space,doneleftBarButton, nil];
            [toolbar setItems:array];
            
            eventNotesTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 2, 280, 80)];
            eventNotesTextView.inputAccessoryView = toolbar;
            eventNotesTextView.backgroundColor = [UIColor clearColor];
            eventNotesTextView.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
            eventNotesTextView.tag = 4444;
            eventNotesTextView.font = [UIFont fontWithName:@"Gotham-Book" size:16.0];
            eventNotesTextView.delegate = self;
            eventNotesTextView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:eventNotesTextView];
            
            
            NSLayoutConstraint *eventNotesConstraints = [NSLayoutConstraint constraintWithItem:eventNotesTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:15.0f];
            [cell.contentView addConstraint:eventNotesConstraints];
            
            
            
            eventNotesConstraints = [NSLayoutConstraint constraintWithItem:eventNotesTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:5.0f];
            [cell.contentView addConstraint:eventNotesConstraints];
            
            eventNotesConstraints = [NSLayoutConstraint constraintWithItem:eventNotesTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-30.0f];
            [cell.contentView addConstraint:eventNotesConstraints];
            
            eventNotesConstraints = [NSLayoutConstraint constraintWithItem:eventNotesTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:eventNotesConstraints];
            
            NSLog(@"%@", NSStringFromCGRect(eventNotesTextView.frame));
            
        }
        else
        {
            eventNotesTextView = (UITextView *)[cell.contentView viewWithTag:4444];
            eventNotesTextView.text = @"";
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        eventNotesTextView.text = [self.ticketDetails objectForKey:kEventNotes];
        
        if ([eventNotesTextView.text isEqualToString:@""])
        {
            eventNotesTextView.text = kTextViewPlaceHolder;
            eventNotesTextView.textColor = [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        }
        
        return cell;
    }
    
    else
    {
        //Create cells for addition of remaining fields.
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UITextField *cellTextField;
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            
            cellTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 250, 30)];
            cellTextField.backgroundColor = [UIColor clearColor];
            cellTextField.tag = 5555;
            cellTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            cellTextField.delegate = self;
            cellTextField.translatesAutoresizingMaskIntoConstraints = NO;
            cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            cellTextField.font = [UIFont fontWithName:@"Gotham-Book" size:16.0];
            cellTextField.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
            cellTextField.returnKeyType = UIReturnKeyNext;
            [cell.contentView addSubview:cellTextField];
            
            NSLayoutConstraint *cellTextFieldConstraints = [NSLayoutConstraint constraintWithItem:cellTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20.0f];
            [cell.contentView addConstraint:cellTextFieldConstraints];
            
            cellTextFieldConstraints = [NSLayoutConstraint constraintWithItem:cellTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:cellTextFieldConstraints];
            
            cellTextFieldConstraints = [NSLayoutConstraint constraintWithItem:cellTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-10.0f];
            [cell.contentView addConstraint:cellTextFieldConstraints];
            
            cellTextFieldConstraints = [NSLayoutConstraint constraintWithItem:cellTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
            [cell.contentView addConstraint:cellTextFieldConstraints];
            
        }
        else
        {
            cellTextField = (UITextField *)[cell.contentView viewWithTag:5555];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cellTextField.text = @"";
        cellTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        
        if ([[self.displayFields objectAtIndex:indexPath.section] isEqualToString:kHeadline])    
        {
            if (![[self.ticketDetails objectForKey:kHeadline] isEqualToString:@""]) {
                cellTextField.text = [self.ticketDetails objectForKey:kHeadline];
            }
            else
            {
                cellTextField.placeholder = kHeadline;
            }
            
        }
        else if ([[self.displayFields objectAtIndex:indexPath.section] isEqualToString:kEventVenue])
        {
            if (![[self.ticketDetails objectForKey:kEventVenue] isEqualToString:@""]) {
                cellTextField.text = [self.ticketDetails objectForKey:kEventVenue];
            }
            else
            {
                cellTextField.placeholder = kEventVenue;
            }
        }
        else if ([[self.displayFields objectAtIndex:indexPath.section] isEqualToString:kHomeTeam])
        {
            if (![[self.ticketDetails objectForKey:kHomeTeam] isEqualToString:@""]) {
                cellTextField.text = [self.ticketDetails objectForKey:kHomeTeam];
            }
            else
            {
                cellTextField.placeholder = kHomeTeam;
                
            }
        }
        else if ([[self.displayFields objectAtIndex:indexPath.section] isEqualToString:kOpponent])
        {
            if (![[self.ticketDetails objectForKey:kOpponent] isEqualToString:@""])
            {
                cellTextField.text = [self.ticketDetails objectForKey:kOpponent];
            }
            else
            {
                cellTextField.placeholder = kOpponent;
            }
            
        }
        else if ([[self.displayFields objectAtIndex:indexPath.section] isEqualToString:kEventName])
        {
            if (![[self.ticketDetails objectForKey:kEventName] isEqualToString:@""])
            {
                cellTextField.text = [self.ticketDetails objectForKey:kEventName];
            }
            else
            {
                cellTextField.placeholder = kEventName;
            }
            
        }
        
        
        return cell;
    }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kAutoCompleteTableTag) {
        return 1;
    }
    else {
    //values adjusted to make view appear to conform to spec doc
    if (section == 0) {
        return 15.0f;
    }
    else if(section == 1)
    {
        return 14.0f;
    }
    else if(section==3)
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
            return 1.0f;
        else
            return 19.0f;
    else if(section ==4 && [[self.ticketDetails objectForKey:kEventType]isEqualToString:kEventTypeGame])
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
            return 1.0f;
        else
            return 19.0f;
    }
    else
        return 19.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kAutoCompleteTableTag) {
        return 1;
    }
    else {
    if (section == ([self.displayFields count] - 1)) {
        return 20.0f;
    }
    return 1.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    if(section==2)
//        return [self singleLineForCell];
    
    if (tableView.tag == kAutoCompleteTableTag) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    else
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
        {
            if(section==3)
                return [self whiteLineForCell];
            else if(section ==4 && [[self.ticketDetails objectForKey:kEventType]isEqualToString:kEventTypeGame])
            {
                return [self whiteLineForCell];
            }
            else
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        }
        else
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (tableView.tag == kAutoCompleteTableTag) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    else
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
        {
            
            if(section==0)
                return [self sectionSeparatorViewWithHeight:14];
            else if(section == 1)
                return [self sectionSeparatorViewForTwoLinesWithHeight:20];
            else if(section == 2)
                return [self hairLineForCell];
            else if(section == 3)
            {
                if([[self.ticketDetails objectForKey:kEventType]isEqualToString:kEventTypeGame])
                {
                    return [self hairLineForCell];
                }
                else
                {
                    return [self sectionSeparatorViewForTwoLinesWithHeight:20];
                }
            }
            else if(section == [self.displayFields count]-2||section == [self.displayFields count]-3)
                return [self sectionSeparatorViewForTwoLinesWithHeight:20];
            else if(section == [self.displayFields count]-1)
                return [self bottomMostSeparator];
            else
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        }
        else
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == kAutoCompleteTableTag)
    {
        if (indexPath.row == [_autocompleteUrls count] -1)
        {
            return 49;
        }
        
		return 45;
	}
    else
    {
        if (indexPath.section == 0)
        {
            return 137;
        }
        else if (indexPath.section == ([self.displayFields count] - 1))
        {
            return 140;
        }
        
        return 43;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kAutoCompleteTableTag)
    {
        //Populate active text field with autocomplete text.
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
		 _autoCompleteTextField.text = selectedCell.textLabel.text;
		[self.ticketDetails setObject:_autoCompleteTextField.text forKey:_autoCompleteTextField.placeholder];
		_autocompleteTableView.hidden = YES;
    }
    else
    {
        if (indexPath.section == 1)
        {
            //Navigate to event type selection screen.
            GBEventTypeSelectionViewController *eventTypeSelect = [[GBEventTypeSelectionViewController alloc] init];
            eventTypeSelect.delegate = self;
            eventTypeSelect.eventType = [self.ticketDetails objectForKey:kEventType];
            [self.navigationController pushViewController:eventTypeSelect animated:YES];
        }
        else if (indexPath.section == ([self.displayFields count] - 2))
        {
            //Show date picker.
            UIButton *dateButton = (UIButton *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:6666];
            [self didTapDateButton:dateButton];
        }
    }
}

//Function to show date picker.
- (void)didTapDateButton:(id)sender
{
    [_activeTextElement resignFirstResponder];
    UIButton *dateButton = (UIButton *)sender;
    
    CGPoint buttonPointInTable = [dateButton convertPoint:dateButton.center toView:_createTicketTableView];
    NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:buttonPointInTable];
    
    if (!_isPickerShown)
    {
        if (![_createTicketTableView.gestureRecognizers containsObject:_tapGesture])
        {
            //Add tap gesture (to dismiss keyboard/date picker on tap) to table if not already added.
            [_createTicketTableView addGestureRecognizer:_tapGesture];
        }
        
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, 216);
        [_datePicker setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *currentDate = [NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:+100];
        NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
        [comps setYear:-100];
        NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
        
        [_datePicker setMaximumDate:maxDate];
        [_datePicker setMinimumDate:minDate];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.date = [NSDate date];
        
        [_datePicker addTarget:self action:@selector(changeDate)forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_datePicker];
        
        
        CGRect endFrame = _datePicker.frame;
        endFrame.origin.y = endFrame.origin.y - (endFrame.size.height);    //now the end position is slid up by the height of the view, so it will just fit.
        [UIView animateWithDuration:0.2 animations:^{
            
            
            _datePicker.frame = endFrame;
            
            UITableViewCell *cell = [_createTicketTableView cellForRowAtIndexPath:indexPathOfParentCell];
                        
            CGPoint textFieldBottomLeftPoint = CGPointMake(cell.contentView.frame.origin.x, (cell.contentView.frame.origin.y + cell.contentView.frame.size.height + 5));
            
            CGPoint textFieldBottomLeftPointInMainView = [cell.contentView convertPoint:textFieldBottomLeftPoint toView:self.view];
            
            if (textFieldBottomLeftPointInMainView.y > (_datePicker.frame.origin.y - 44.0 - 20))
            {
                CGFloat offsetBetweenKeyboardAndTextField = textFieldBottomLeftPointInMainView.y - _datePicker.frame.origin.y;
                
                CGPoint contentOffset = _createTicketTableView.contentOffset;
                contentOffset.y = contentOffset.y + offsetBetweenKeyboardAndTextField;
                [UIView animateWithDuration:0.2 animations:^{
                    _createTicketTableView.contentOffset = contentOffset;           //change tableview content offset to a point just above the date picker.
                }];
                
            }
            
        }];
        
        
        _isPickerShown = YES;
        
        _createTicketTableView.contentInset = UIEdgeInsetsMake(0, 0, _datePicker.frame.size.height, 0);
        
        [_createTicketTableView deselectRowAtIndexPath:indexPathOfParentCell animated:YES];
    }
    else
    {
        [self dismissPresentedViews];
        
        [_createTicketTableView deselectRowAtIndexPath:indexPathOfParentCell animated:YES];        
    }

}


-(void)changeDate
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:([self.displayFields count] - 2)];
    [self.ticketDetails setObject:[self getDateInRequiredFormatForDate:[_datePicker date]] forKey:kEventDate];
    [_createTicketTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark DoneTool Bar-Keyboard

-(void) doneBarbuttonClicked
{
	[self dismissPresentedViews];
}

#pragma mark AutoComplete Methods

// Method populates the autocomplete tableview by searching previously entered values.
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
	
	// Put anything that starts with this substring into the autocompleteUrls array
	// The items in this array is what will show up in the table view
	[_autocompleteUrls removeAllObjects];
	for(NSString *curString in _pastUrls) {
		NSRange substringRange = [curString rangeOfString:substring options:NSCaseInsensitiveSearch];
		if (substringRange.location == 0) {
			[_autocompleteUrls addObject:curString];
		}
	}
	
	if ([_autocompleteUrls count]>0)
	{
		[self.view bringSubviewToFront:_autocompleteTableView];
	}
	else
	{
		[_autocompleteTableView setHidden:YES];
	}
	
	[_autocompleteTableView reloadData];
}

// Method determines if autocomplete tableview should be shown or not based on orientation. 
-(void) checkAutocompleteTableView
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		_autocompleteTableView.hidden = NO;
	}
	else if (UIInterfaceOrientationIsLandscape(orientation))
	{
		_autocompleteTableView.hidden = YES;
	}
}

#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _autoCompleteTextField = textField;
    if (_isPickerShown)
    {
        [self hideDatePicker];
    }
    
    CGPoint textFieldPointInTable = [textField convertPoint:textField.center toView:_createTicketTableView];
    NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];
    	
    _pastUrls = [[NSMutableArray alloc] initWithArray:[[GBDocumentManager sharedInstance] autocompleteDataOfField:[self.displayFields objectAtIndex:indexPathOfParentCell.section]]]; //returns array of autocomplete results for a particular field.
    _activeTextElement = textField;
    if (!CGRectEqualToRect(_keyBoardRect, CGRectZero))
    {
        [self scrollToPosition];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _autoCompleteTextField = nil;
    _activeTextElement = nil;
    NSString *actualTextWithoutWhitespace = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (actualTextWithoutWhitespace.length == 0)
    {
        textField.text = @"";
    }
    else
    {
        CGPoint textFieldPointInTable = [textField convertPoint:textField.center toView:_createTicketTableView];
        NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];
        
        [self.ticketDetails setObject:textField.text forKey:[self.displayFields objectAtIndex:indexPathOfParentCell.section]];  //Set ticket detail after the data has been entered into the textfield.
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _autocompleteTableView.hidden = YES;
    NSString *actualTextWithoutWhitespace = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (actualTextWithoutWhitespace.length == 0)
    {
        textField.text = @"";
    }
     CGPoint textFieldPointInTable = [textField convertPoint:textField.center toView:_createTicketTableView];
    NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];

    if (indexPathOfParentCell.section != ([self.displayFields count] - 3))                 //Condition to check if the next field is not event notes field.
    {
        NSIndexPath *nextCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPathOfParentCell.section + 1)];
        UITableViewCell *nextTextFieldParentCell = [_createTicketTableView cellForRowAtIndexPath:nextCellIndexPath];
        
        UITextField *nextTextField = (UITextField *)[nextTextFieldParentCell.contentView viewWithTag:5555];
        [nextTextField becomeFirstResponder];
        
        return YES;
    }
    else
    {
        [self.ticketDetails setObject:textField.text forKey:[self.displayFields objectAtIndex:indexPathOfParentCell.section]];
        
        NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:([self.displayFields count] - 1)];
        UITableViewCell *textViewParentCell = [_createTicketTableView cellForRowAtIndexPath:lastCellIndexPath];
        
        UITextView *textView = (UITextView *)[textViewParentCell.contentView viewWithTag:4444];
                
        [textView becomeFirstResponder];
        
        
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;                                                  //Reject whitespace if no other character present in the text field.
    }
    
    [self checkAutocompleteTableView];
    
	NSString *substring = [NSString stringWithString:textField.text];
	substring = [substring
				 stringByReplacingCharactersInRange:range withString:string];
	[self searchAutocompleteEntriesWithSubstring:substring];
    
    CGPoint textFieldPointInTable = [textField convertPoint:textField.center toView:_createTicketTableView];
    NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];
    
    CGRect rectInTableView = [_createTicketTableView rectForRowAtIndexPath:indexPathOfParentCell];
	CGRect rectInSuperview = [_createTicketTableView convertRect:rectInTableView toView:self.view];
	
    
    //Adjust position of autocomplete tableview.
	if ([_autocompleteUrls count] && ([_autocompleteUrls count] < 3))
	{
		_autocompleteTableView.frame = CGRectMake(20.0, rectInSuperview.origin.y+42, 280.0,53 + (45.0 * ([_autocompleteUrls count]-1) ));
	}
	else
	{
		_autocompleteTableView.frame = CGRectMake(20.0, rectInSuperview.origin.y+42, 280.0,53 + (45.0 * 2));
	}
    
    NSString *actualTextWithoutWhitespace = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger newLength = [actualTextWithoutWhitespace length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
}

-(void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    
    CGPoint textFieldPointInTable = [textField convertPoint:textField.center toView:_createTicketTableView];
    NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];
    
    [self.ticketDetails setObject:textField.text forKey:[self.displayFields objectAtIndex:indexPathOfParentCell.section]];
    
    BOOL isFormComplete = [self validateFormCompletion];
    if (!isFormComplete)
    {
        _doneBarButton.enabled = NO;
    }
    else
    {
        _doneBarButton.enabled = YES;
    }

}


#pragma mark - Text View delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
    
    NSString *actualTextWithoutWhitespace = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger newLength = [actualTextWithoutWhitespace length] + [text length] - range.length;
    return (newLength > 120) ? NO : YES;
}


-(void)textViewDidChange:(UITextView *)textView
{
    if ([_previousString isEqualToString:kTextViewPlaceHolder])
    {
        _previousString = @"";
        textView.text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];        
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_isPickerShown)
    {
        [self hideDatePicker];
    }
    
    _activeTextElement = textView;
    if (!CGRectEqualToRect(_keyBoardRect, CGRectZero))
    {
        [self scrollToPosition];
    }
    if ([textView.text isEqualToString:kTextViewPlaceHolder])
    {
        
        textView.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
        textView.text = @"";
        _previousString = kTextViewPlaceHolder;
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _activeTextElement = nil;
    if ([textView.text isEqualToString:@""])
    {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = kTextViewPlaceHolder;               //Adding placeholder to empty textview.
        _previousString = kTextViewPlaceHolder;
    }
    
    if ([textView.text hasSuffix:@"\n"]) {
        textView.text = [textView.text substringToIndex:([textView.text length] - 1)];  //removing new line character at end of text.
    }
    
    NSString *actualTextWithoutWhitespace = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *actualTextWithoutNewlineCharacters = [actualTextWithoutWhitespace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (actualTextWithoutNewlineCharacters.length == 0)
    {
        textView.textColor = [UIColor lightGrayColor];
        textView.text = kTextViewPlaceHolder;
        _previousString = kTextViewPlaceHolder;
    }
    
    if ([textView.text isEqualToString:kTextViewPlaceHolder])
    {
        [self.ticketDetails setObject:@""forKey:kEventNotes];
    }
    else
        [self.ticketDetails setObject:textView.text forKey:kEventNotes];
}

//Method to check if all the required fields in the form have been entered or not.
- (BOOL)validateFormCompletion
{
    BOOL isFormComplete = YES;
    for (int i = 0; i < [self.displayFields count]; i++)
    {
        NSString *stringWithoutSpaces = [[self.ticketDetails objectForKey:[self.displayFields objectAtIndex:i]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (([stringWithoutSpaces isEqualToString:@""]) || (stringWithoutSpaces.length == 0))
        {
            if (i != ([self.displayFields count] - 1))
            {
                isFormComplete = NO;
            }
            
        }
    }
    return isFormComplete;
}

//Scrolls the table to a position based on the active field in the form
- (void)scrollToPosition
{
    if ([_activeTextElement isKindOfClass:[UITextField class]])
    {
        
        UITextField *activeTextField = (UITextField *)_activeTextElement;
        CGPoint textFieldPointInTable = [activeTextField convertPoint:activeTextField.center toView:_createTicketTableView];
        NSIndexPath *indexPathOfParentCell = [_createTicketTableView indexPathForRowAtPoint:textFieldPointInTable];
        
        [_createTicketTableView scrollToRowAtIndexPath:indexPathOfParentCell atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {        
        UITextView *activeTextField = (UITextView *)_activeTextElement;
        CGPoint textFieldBottomLeftPoint;
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            textFieldBottomLeftPoint = CGPointMake(activeTextField.frame.origin.x, (activeTextField.frame.origin.y + activeTextField.frame.size.height + 5));
        }
        else
        {
            textFieldBottomLeftPoint = CGPointMake(activeTextField.frame.origin.x, (activeTextField.frame.origin.y + activeTextField.frame.size.height));
        }
        
        
        CGPoint textFieldBottomLeftPointInMainView = [activeTextField convertPoint:textFieldBottomLeftPoint toView:self.view];
        
        if (textFieldBottomLeftPointInMainView.y > (_keyBoardRect.origin.y - 44.0 - 20))
        {
            CGFloat offsetBetweenKeyboardAndTextField = textFieldBottomLeftPointInMainView.y - _keyBoardRect.origin.y;
            
            CGPoint contentOffset = _createTicketTableView.contentOffset;
            contentOffset.y = contentOffset.y + offsetBetweenKeyboardAndTextField + 44.0 + 20;
            [UIView animateWithDuration:0.2 animations:^{
                _createTicketTableView.contentOffset = contentOffset;
            }];
        
        }
        
    }
    
    
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyBoardRect;
    keyBoardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [_createTicketTableView addGestureRecognizer:_tapGesture];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        _keyBoardRect = CGRectMake(keyBoardRect.origin.y, keyBoardRect.origin.x, keyBoardRect.size.height, keyBoardRect.size.width);
    }
    else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        _keyBoardRect = CGRectMake(keyBoardRect.origin.x, _screenWidth - keyBoardRect.size.width, keyBoardRect.size.height, keyBoardRect.size.width);
    }
    else
    {
        _keyBoardRect = keyBoardRect;
    }
    
    _createTicketTableView.contentInset = UIEdgeInsetsMake(0, 0, _keyBoardRect.size.height, 0);
    
    _isKeyboardShown = YES;
    
    [self scrollToPosition];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _createTicketTableView.contentInset = UIEdgeInsetsZero;
    _createTicketTableView.contentOffset = CGPointZero;
    _keyBoardRect = CGRectZero;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _isKeyboardShown = NO;
}

#pragma mark - Button action methods

- (void)didTapAddImageButton:(id)sender
{
    [self dismissPresentedViews];
	if (self.selectedImage)
	{
		UIActionSheet *editPhotoSelectionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Edit photo",@"Upload New Photo", nil];
		editPhotoSelectionSheet.tag = 1;
		editPhotoSelectionSheet.delegate = self;
		[editPhotoSelectionSheet showInView:self.view];
	}
	else
	{
		UIActionSheet *photoSelectionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Choose Existing", nil];
		photoSelectionSheet.tag = 2;
		photoSelectionSheet.delegate = self;
		[photoSelectionSheet showInView:self.view];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex :(NSInteger)buttonIndex {
    
    NSInteger source = 2;
	if (actionSheet.tag ==2)
	{
	
    if(buttonIndex == 0)
    {
        source = 1;
    }
    else if(buttonIndex == 1)
    {
        source = 2;
    }
    else
    {
        return;         //dont show picker
    }
    [self showPicker:source];
		
	}
	
	else if(actionSheet.tag == 1)
	{
		if (buttonIndex == 0)
		{
			//Delete the Photo
			self.selectedImage = nil;
			_addImageLabel.text = @"Tap to add a photo";
			[_createTicketTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		}
		else if(buttonIndex == 1)
		{
			CGRect cropRect = kCropRect;
            UzysImageCropperViewController *imgCropperViewController;
            
            imgCropperViewController= [[UzysImageCropperViewController alloc] initWithImage:self.selectedImage andframeSize:self.view.frame.size andcropSize:cropRect.size withCamera:@"NO" isEditing:YES];
            
            imgCropperViewController.delegate = self;
            [self presentViewController:imgCropperViewController animated:YES completion:nil];
		}
		else if(buttonIndex == 2)
		{
			UIActionSheet *photoSelectionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Choose Existing", nil];
			photoSelectionSheet.tag = 2;
			photoSelectionSheet.delegate = self;
			[photoSelectionSheet showInView:self.view];
		}
	}

}

//Shows the image picker, and based on sourcetype shows either camera or photo library.
- (void)showPicker:(NSInteger)source
{
    imagePicker = [[GBImagePickerViewController alloc] init];
    imagePicker.delegate = self;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        imagePicker.navigationBar.translucent = NO;
        imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0];
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        imagePicker.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0];
    }
	
	
    if (source == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			imagePicker.showsCameraControls = YES;
        }
        else
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    else
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    _isImagePickerShown = YES;
 
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = [self fixImageOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];       //function call needed so that portrait images do not get rotated in coverflow.
    
    _isImagePickerShown = NO;
    _didUseImagePicker = YES;
    _sourceType = picker.sourceType;
  
	CGRect cropRect = kCropRect;
	UzysImageCropperViewController *imgCropperViewController;              
    
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
	{
		 imgCropperViewController= [[UzysImageCropperViewController alloc] initWithImage:pickedImage andframeSize:self.view.frame.size andcropSize:cropRect.size withCamera:@"YES" isEditing:NO];
	}
	else
	{
        if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
            imgCropperViewController= [[UzysImageCropperViewController alloc] initWithImage:pickedImage andframeSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+20.0) andcropSize:cropRect.size withCamera:@"NO" isEditing:NO];
        else
            imgCropperViewController= [[UzysImageCropperViewController alloc] initWithImage:pickedImage andframeSize:self.view.frame.size andcropSize:cropRect.size withCamera:@"NO" isEditing:NO];
	}
	
	imgCropperViewController.delegate = self;
    [imgCropperViewController updateCancelButtonTitleForSourceType:imagePicker.sourceType];
    
    [imagePicker pushViewController:imgCropperViewController animated:YES];         //Push the edit photo screen to rotate/crop/zoom the selected image.
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == _saveTicketAlert)
	{
		if (buttonIndex == 0)
		{
			[self returnToPreviousView];
		}
		else
		{
		
		}
	}
}

- (UIImage *)fixImageOrientation:(UIImage *)inputImage {
    
    // No-op if the orientation is already correct
    if (inputImage.imageOrientation == UIImageOrientationUp) return inputImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (inputImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, inputImage.size.width, inputImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, inputImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, inputImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (inputImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, inputImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, inputImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, inputImage.size.width, inputImage.size.height,
                                             CGImageGetBitsPerComponent(inputImage.CGImage), 0,
                                             CGImageGetColorSpace(inputImage.CGImage),
                                             CGImageGetBitmapInfo(inputImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (inputImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,inputImage.size.height,inputImage.size.width), inputImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,inputImage.size.width,inputImage.size.height), inputImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
    _isImagePickerShown = NO;
    _didUseImagePicker = YES;
}

// Returns a string with a date in format 'Month Day Year'
- (NSString *)getDateInRequiredFormatForDate:(NSDate *)inDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *returnDateString = [dateFormatter stringFromDate:inDate];
    
    return returnDateString;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//Tweak to Avoid Incorrect Tableview Contentsize
	_createTicketTableView.contentSize = CGSizeMake(self.view.bounds.size.width, _createTicketTableView.contentSize.height);
    [self dismissPresentedViews];
}

//Hides keyboard/date picker when called.
- (void)dismissPresentedViews
{
    [UIView animateWithDuration:0.2 animations:^{
        _createTicketTableView.contentInset = UIEdgeInsetsZero;
        [self.view endEditing:YES];
    }];
    
    [_createTicketTableView removeGestureRecognizer:_tapGesture];           //Removes tap gesture from table once keyboard/ date picker is hidden from the view.
    
    if (_isPickerShown)
    {
        [self hideDatePicker];
    }
    
}

//Hides date picker 
- (void)hideDatePicker
{
    _isPickerShown = NO;
    CGRect endFrame = _datePicker.frame;
    
    endFrame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        _datePicker.frame = endFrame;
    } completion:^(BOOL finished) {
        [_datePicker removeFromSuperview];
        _datePicker = nil;
    }];

}

#pragma mark - Rotation Code

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		_autocompleteTableView.hidden = YES;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _progressSpinner.center = self.view.center;         //ensures the spinner is always on the center of the view, regardless of orientation.
}

- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIButton *rightNavButton = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
    UIButton *leftNavButton = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x,leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 25.0)];
        [rightNavButton setFrame:CGRectMake(rightNavButton.frame.origin.x,rightNavButton.frame.origin.y, rightNavButton.frame.size.width, 25.0)];
	}
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, leftNavButton.frame.size.width, 31.0)];
        [rightNavButton setFrame:CGRectMake(rightNavButton.frame.origin.x, rightNavButton.frame.origin.y, rightNavButton.frame.size.width, 31.0)];
	}
}



#pragma mark - Gesture methods

- (void)didTapOnTable:(UITapGestureRecognizer *)tapGesture
{
    [self dismissPresentedViews];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;                                              //Gesture disabled if the touched view is a button.
    }
    
    return YES;
}

#pragma mark - Photo edit methods

- (void)didFinishImageEditing:(UIImage *)image
{
    self.selectedImage = image;
    [_createTicketTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationUnknown|| orientation == UIDeviceOrientationPortraitUpsideDown ||
		orientation == UIDeviceOrientationFaceUp||              // Device oriented flat, face up
		orientation == UIDeviceOrientationFaceDown) {
        
        return UIDeviceOrientationPortrait;             // Returns portrait if any unsupported orientation is returned by device orientation.
    }
    
    return orientation;
}

-(BOOL)shouldAutorotate
{
	return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{

	return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark PhotoEditing
#pragma mark - UzysImageCropperDelegate

- (void)imageCropper:(UzysImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image
{
    self.selectedImage = image;
    
    [_createTicketTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];              //Setting originally selected image to the table initially, to avoid delay due to scaling done later.
    
     _addImageLabel.text = @"Tap to change the photo";
    _addImageLabel.textColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         self.selectedImage = [UIImage imageWithImage:self.selectedImage scaledToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2)];  //Scaling image
        dispatch_async(dispatch_get_main_queue(), ^{
            [_createTicketTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            _addImageLabel.text = @"Tap to change the photo";
            _addImageLabel.textColor = [UIColor whiteColor];
        });
    });
    
    _didUseImagePicker = YES;
        
}

- (void)imageCropperDidCancel:(UzysImageCropperViewController *)cropper
{
	_didUseImagePicker = YES;
}

-(UIView*) singleLineForCell
{
    UIView *view =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

-(UIView*) whiteLineForCell
{
    UIView *view =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 1)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

-(UIView*) hairLineForCell
{
    UIView *whiteView =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 1)];
    whiteView.backgroundColor = [UIColor whiteColor];
    UIView *view =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0];
    [view addSubview:whiteView];
    return view;
}

-(UIView*) sectionSeparatorViewWithHeight:(CGFloat)height
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height, _createTicketTableView.frame.size.width, 1)];
    bottomLineView.backgroundColor =[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [bottomLineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:bottomLineView];
    return view;
}

-(UIView*) sectionSeparatorViewForTwoLinesWithHeight:(CGFloat)height
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height, _createTicketTableView.frame.size.width, 1)];
    bottomLineView.backgroundColor =[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [bottomLineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:bottomLineView];
    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 1)];
    [topLineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    topLineView.backgroundColor =[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [view addSubview:topLineView];
    return view;
}

-(UIView*) bottomMostSeparator
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 20)];
    view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];

    UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _createTicketTableView.frame.size.width, 1)];
    [topLineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    topLineView.backgroundColor =[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [view addSubview:topLineView];
    return view;
}

@end
