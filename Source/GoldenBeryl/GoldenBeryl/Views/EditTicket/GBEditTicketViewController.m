 //
//  GBEditTicketViewController.m
//  TicketBlast
//
//  Created by Mohammed Shahid on 28/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBEditTicketViewController.h"
#import "GBEditTicketCustomCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GBTicketViewController.h"
#import "UIImage+Resize.h"
#import "GBDocumentManager.h"

#define kTicketPhotoHeight 200
#define kDeleteCellHeight 47
#define kCellHeight 44
#define kTextViewHeight 125
#define kDatePicker_Landscape_Height 100
#define kDatePicker_Potrait_Height 300

#define AutoCompleteTableTag 4444
#define EditTableTag 5555
#define Photo_thumbnail_background 1001
#define NotesTextView 2002
#define Photo_thumbnail_Overlay 1008
#define Change_Photo_Label 6006

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kCropRect (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? CGRectMake(10, 167, 300, 247) : CGRectMake(10, 141, 300, 208)


@interface GBEditTicketViewController ()
- (NSString *)documentsPathForFileName:(NSString *)name;
@end

@implementation GBEditTicketViewController
{
	NSArray *_editTicketsArray;
	BOOL _hideDatePicker;
	BOOL _isImagePicked;
	UIDatePicker *_datePicker;
	id _activeField;
	UITextField *_autoCompleteTextField;
	UIButton *_saveView;
	UIButton *_cancelView;
	NSMutableArray *_pastUrls;
	NSMutableArray *_autocompleteUrls;
	NSMutableDictionary *_ticketData;
	NSMutableArray *_ticketCells;
	UIToolbar *_keyboardToolbar;
	CGSize _standardImageSize;
}

@synthesize ticketId = _ticketId;
@synthesize ticketDetailsDict = _ticketDetailsDict;
@synthesize editTicketTable = _editTicketTable;
@synthesize autocompleteTableView = _autocompleteTableView;

- (id)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

-(void)loadView
{
	//Load Fields for TableView
	[self getTicketDetails];
	
	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = mainView;
    
    _screenWidth = self.view.frame.size.width;
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	//Suggestion List Tableview
	self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	self.autocompleteTableView.delegate = self;
	self.autocompleteTableView.dataSource = self;
	self.autocompleteTableView.scrollEnabled = YES;
	self.autocompleteTableView.hidden = YES;
	self.autocompleteTableView.backgroundColor = [UIColor clearColor];
	self.autocompleteTableView.alwaysBounceVertical = NO;
	[self.view addSubview:self.autocompleteTableView];

	self.autocompleteTableView.tag = AutoCompleteTableTag;
	_autocompleteUrls = [[NSMutableArray alloc] init];
    
    self.editTicketTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)  style:UITableViewStyleGrouped];
	
	self.editTicketTable.backgroundView = nil;
    self.editTicketTable.delegate = self;
    self.editTicketTable.dataSource = self;
	self.editTicketTable.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
	self.editTicketTable.tag = EditTableTag;
	
	self.editTicketTable.sectionHeaderHeight = 0.0;
	self.editTicketTable.sectionFooterHeight = 0.0;

    [self.view addSubview:self.editTicketTable];
	
	//TableView Autolayout
	self.editTicketTable.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.editTicketTable attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.editTicketTable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.editTicketTable attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];
	
	tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.editTicketTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
	[self.view addConstraint:tableViewConstraints];

	NSArray *ticketPhoto = [[NSArray alloc]initWithObjects:kEventImage, nil];
	NSArray *tableViewCells = [[NSArray alloc]initWithArray:_ticketCells];
	NSArray *textView = [[NSArray alloc]initWithObjects:kEventNotes,nil];
	NSArray *deleteTicket =[[NSArray alloc]initWithObjects:@"Delete Ticket",nil];
	_editTicketsArray = [[NSArray alloc]initWithObjects:ticketPhoto,tableViewCells,textView,deleteTicket,nil];
	
	//Document Approach
	self.ticketDetailsDict =[[NSMutableDictionary alloc]init];
	
	[self.ticketDetailsDict setObject:self.doc.ticketdata.venue forKey:kEventVenue];
	
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		[self.ticketDetailsDict setObject:self.doc.ticketdata.homeTeam forKey:kHomeTeam];
		[self.ticketDetailsDict setObject:self.doc.ticketdata.opponentTeam forKey:kOpponent];
	}
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		[self.ticketDetailsDict setObject:self.doc.ticketdata.headLine forKey:kHeadline];
	}
	else
	{
		[self.ticketDetailsDict setObject:self.doc.ticketdata.eventName forKey:kEventName];
	}
	[self.ticketDetailsDict setObject:self.doc.ticketdata.eventNotes forKey:kEventNotes];
	[self.ticketDetailsDict setObject:self.doc.ticketdata.eventType forKey:kEventType];
	[self.ticketDetailsDict setObject:self.doc.ticketdata.date forKey:kEventDate];
	
    CGRect selfBounds = self.view.bounds;
	selfBounds.size.height = self.view.bounds.size.height - 44.0;
	
	_progressSpinner = [[OVSpinningProgressViewOverlay alloc] initWithFrameOfEnclosingView:selfBounds];
    [_progressSpinner setHidesWhenStopped:YES];
    [self.view addSubview:_progressSpinner];
	
	CGRect frame = self.editTicketTable.frame;
	frame.size.height = self.editTicketTable.contentSize.height;
	self.editTicketTable.frame = frame;
	self.editTicketTable.contentSize = CGSizeMake(self.view.bounds.size.width, self.editTicketTable.contentSize.height);
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTable:)];            //Initializing the tap gesture to dismiss the keyboard/date picker.
    _tapGesture.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    _isKeyboardShown = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Edit Ticket";
	
	//Save Bar Button
	_saveView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
	[_saveView setTitle:@"Save" forState:UIControlStateNormal];
	_saveView.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:20.0];
	[_saveView addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:_saveView];
	[self.navigationItem setRightBarButtonItem:saveButton];
	
	[self.editTicketTable setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	
	//Cancel Bar Button
	_cancelView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
	[_cancelView setTitle:@"Cancel" forState:UIControlStateNormal];
	_cancelView.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:20.0];
	[_cancelView addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:_cancelView];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
    
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	dispatch_async(queue, ^{
		
		UIImage *image = self.doc.photo;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (image)
			{
				self.selectedImage =image;
				[self.editTicketTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			} else
			{
				self.selectedImage = nil;
			}
		});
	});

	//Date Picker Intialise
	_datePicker = [[UIDatePicker alloc] init];
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _datePicker.datePickerMode = UIDatePickerModeDate;
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
		
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSDate *eventDate = [dateFormatter dateFromString:[self.ticketDetailsDict objectForKey:kEventDate]];
	if (eventDate)
	{
		[_datePicker setDate:eventDate] ;
	}
	self.editTicketTable.scrollsToTop = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	//Orientation for BarButton
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		[_saveView setFrame:CGRectMake(_saveView.frame.origin.x,_saveView.frame.origin.y, 50.0, 30)];
		
		[_cancelView setFrame:CGRectMake(_cancelView.frame.origin.x,_cancelView.frame.origin.y, 70.0, 30.0)];
		
	} else {
		[_saveView setFrame:CGRectMake(_saveView.frame.origin.x,_saveView.frame.origin.y, 50.0, 24.0)];
		
		[_cancelView setFrame:CGRectMake(_cancelView.frame.origin.x,_cancelView.frame.origin.y, 70.0, 24.0)];
		self.autocompleteTableView.hidden = YES;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	 
											 selector:@selector(documentStateChanged:)
	 
												 name:UIDocumentStateChangedNotification object:self.doc];
	[super viewWillAppear:animated];
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Device Orientation

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown ||
		orientation == UIDeviceOrientationFaceUp||              // Device oriented flat, face up
		orientation == UIDeviceOrientationFaceDown) {
        
        return UIDeviceOrientationPortrait;
    }
    
    return orientation;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate
{
	return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//Tweak to Avoid Incorrect Tableview Contentsize
	self.editTicketTable.contentSize = CGSizeMake(self.view.bounds.size.width, self.editTicketTable.contentSize.height);
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		self.autocompleteTableView.hidden = YES;
	}
	
	//Picker has to Rotated when Rotation Takes Place
	if (_hideDatePicker)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.3f];
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			CGSize pickerSize = [_datePicker sizeThatFits:CGSizeZero];
			_datePicker.frame = CGRectMake(0.0, (self.view.frame.size.height-pickerSize.height), pickerSize.width, kDatePicker_Landscape_Height);
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 135.0, 0);
		}
		else if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
		{
			CGSize pickerSize = [_datePicker sizeThatFits:CGSizeZero];
			_datePicker.frame = CGRectMake(0.0, (self.view.frame.size.height-pickerSize.height), pickerSize.width, kDatePicker_Potrait_Height);
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 216.0, 0);
			
		}
		[UIView commitAnimations];
	}
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[_saveView setFrame:CGRectMake(_saveView.frame.origin.x,_saveView.frame.origin.y, 50, 30)];
        [_cancelView setFrame:CGRectMake(_cancelView.frame.origin.x,_cancelView.frame.origin.y, 70.0, 30)];
	}
	else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
	{
		[_saveView setFrame:CGRectMake(_saveView.frame.origin.x,_saveView.frame.origin.y, 50, 24)];
		[_cancelView setFrame:CGRectMake(_cancelView.frame.origin.x,_cancelView.frame.origin.y, 70.0, 24)];
	}
	
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _progressSpinner.center = self.view.center;
}


#pragma mark ScrollView Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.tag == EditTableTag && self.autocompleteTableView.hidden==NO)
	{
		self.autocompleteTableView.hidden = YES;
		[_activeField resignFirstResponder];
	}
}

//Scrolls the table to a position based on the active field in the form
- (void)scrollToPosition
{
    if ([_activeField isKindOfClass:[UITextField class]])
    {
        
        UITextField *activeTextField = (UITextField *)_activeField;
        CGPoint textFieldPointInTable = [activeTextField convertPoint:activeTextField.center toView:_editTicketTable];
        NSIndexPath *indexPathOfParentCell = [_editTicketTable indexPathForRowAtPoint:textFieldPointInTable];
        
        [_editTicketTable scrollToRowAtIndexPath:indexPathOfParentCell atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        UITextView *activeTextField = (UITextView *)_activeField;
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
            
            CGPoint contentOffset = _editTicketTable.contentOffset;
            contentOffset.y = contentOffset.y + offsetBetweenKeyboardAndTextField + 44.0 + 20;
            [UIView animateWithDuration:0.2 animations:^{
                _editTicketTable.contentOffset = contentOffset;
            }];
            
        }
        
    }
    
    
}


#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyBoardRect;
    keyBoardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [_editTicketTable addGestureRecognizer:_tapGesture];
    
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
    
    _editTicketTable.contentInset = UIEdgeInsetsMake(0, 0, _keyBoardRect.size.height, 0);
    
    _isKeyboardShown = YES;
    
    [self scrollToPosition];
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    _editTicketTable.contentInset = UIEdgeInsetsZero;
    _editTicketTable.contentOffset = CGPointZero;
    _keyBoardRect = CGRectZero;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    _isKeyboardShown = NO;
}



#pragma mark - TableView Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (tableView.tag == EditTableTag)
	{
		if (indexPath.section == 0)
		{
			return kTicketPhotoHeight;
		}
		else if(indexPath.section ==1)
		{
			return kCellHeight;
		}
		else if(indexPath.section ==2)
		{
			return kTextViewHeight;
		}
		else
		{
			return kDeleteCellHeight;
		}
	}
	else  {
		
		if (indexPath.row == [_autocompleteUrls count] -1)
        {
            return 53;
        }
		
		return 44;
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView.tag == EditTableTag)
	{
    return [_editTicketsArray count];
	}
	else
	{
		return 1;
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView.tag == EditTableTag)
	{
		return [[_editTicketsArray objectAtIndex:section]count];
	}
	else
	{
		return _autocompleteUrls.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView.tag == EditTableTag) {
		
	 tableView.separatorColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0];
	 tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		
	if ([indexPath section] == 0)
	{
		static NSString *CellIdentifier = @"EditTicketImage";
			
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		UIImageView *imv = nil;
		UIImageView *backgroundOverlayTicketView = nil;
		UILabel *changePhotoLabel = nil;
		if (cell == nil)
		{
			cell = [[GBEditTicketCustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
			[cell setSelectionStyle:UITableViewCellEditingStyleNone];
			UIImageView *backgroundTicketImageView = [[UIImageView alloc]init];
			backgroundOverlayTicketView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"photo_thumbnail_dark_overlay"]];
			changePhotoLabel = [[UILabel alloc]init];
			changePhotoLabel.text = @"Tap to change the photo";
			changePhotoLabel.tag = Change_Photo_Label;
			changePhotoLabel.backgroundColor = [UIColor clearColor];
			changePhotoLabel.font = [UIFont fontWithName:@"GothamNarrow" size:18.0];
		
			[cell.contentView addSubview:backgroundTicketImageView];
		
			imv = [[UIImageView alloc]init];
			imv.tag = Photo_thumbnail_background;
			imv.backgroundColor = [UIColor clearColor];
			imv.contentMode = UIViewContentModeScaleAspectFill;
			
			backgroundOverlayTicketView.tag = Photo_thumbnail_Overlay;
			[backgroundTicketImageView addSubview:backgroundOverlayTicketView];
			[backgroundTicketImageView addSubview:imv];
			
			[backgroundTicketImageView addSubview:changePhotoLabel];
			
			//Background ImageView AutoLayout Constraints
			backgroundTicketImageView.translatesAutoresizingMaskIntoConstraints = NO;

			NSLayoutConstraint *backgroundImageViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundTicketImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
			[cell.contentView addConstraint:backgroundImageViewConstraint];
			
			backgroundImageViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundTicketImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
			[cell.contentView addConstraint:backgroundImageViewConstraint];
			
            
            backgroundImageViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundTicketImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:320];
			
	        [cell.contentView addConstraint:backgroundImageViewConstraint];
            
            backgroundImageViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundTicketImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
            
            [cell.contentView addConstraint:backgroundImageViewConstraint];
			
			
			//Original Ticket Image
			imv.translatesAutoresizingMaskIntoConstraints = NO;
			
			NSLayoutConstraint *ticketImageViewConstraint = [NSLayoutConstraint constraintWithItem:imv attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketImageViewConstraint];
			
			ticketImageViewConstraint = [NSLayoutConstraint constraintWithItem:imv attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketImageViewConstraint];
			
			ticketImageViewConstraint = [NSLayoutConstraint constraintWithItem:imv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketImageViewConstraint];
			
			ticketImageViewConstraint = [NSLayoutConstraint constraintWithItem:imv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketImageViewConstraint];
			
			//Overlay View for Shadow on Top of Image
			backgroundOverlayTicketView.translatesAutoresizingMaskIntoConstraints = NO;
			
			NSLayoutConstraint *ticketOverlayViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundOverlayTicketView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketOverlayViewConstraint];
			
			ticketOverlayViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundOverlayTicketView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketOverlayViewConstraint];
			
			ticketOverlayViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundOverlayTicketView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketOverlayViewConstraint];
			
			ticketOverlayViewConstraint = [NSLayoutConstraint constraintWithItem:backgroundOverlayTicketView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:ticketOverlayViewConstraint];
			
			//Label Constraint
			
			changePhotoLabel.translatesAutoresizingMaskIntoConstraints = NO;
			
			NSLayoutConstraint *changePhotoLabelConstraint =[NSLayoutConstraint constraintWithItem:changePhotoLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
			[backgroundTicketImageView addConstraint:changePhotoLabelConstraint];
			
			
			changePhotoLabelConstraint = [NSLayoutConstraint constraintWithItem:changePhotoLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backgroundTicketImageView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-35.0f];
			[backgroundTicketImageView addConstraint:changePhotoLabelConstraint];
			
			cell.backgroundColor = [UIColor clearColor];
			
			if (self.selectedImage)
			{
				backgroundOverlayTicketView = (UIImageView *)	[cell viewWithTag:Photo_thumbnail_Overlay];
				backgroundOverlayTicketView.hidden = NO;
				
				changePhotoLabel = (UILabel *) [cell viewWithTag:Change_Photo_Label];
				changePhotoLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
			}
			else
			{
				backgroundOverlayTicketView = (UIImageView *)	[cell viewWithTag:Photo_thumbnail_Overlay];
				backgroundOverlayTicketView.hidden = YES;
				
				changePhotoLabel = (UILabel *) [cell viewWithTag:Change_Photo_Label];
				changePhotoLabel.backgroundColor = [UIColor clearColor];
				changePhotoLabel.textColor = [UIColor lightGrayColor];
			}
			
			_standardImageSize = CGSizeMake(backgroundTicketImageView.frame.size.width * 2, backgroundTicketImageView.frame.size.height * 2);
		}
		else {
			imv = (UIImageView *)[cell viewWithTag:Photo_thumbnail_background];
			
			if (self.selectedImage)
			{
				backgroundOverlayTicketView = (UIImageView *)	[cell viewWithTag:Photo_thumbnail_Overlay];
				backgroundOverlayTicketView.hidden = NO;
				
				
				changePhotoLabel = (UILabel *) [cell viewWithTag:Change_Photo_Label];
				changePhotoLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
			}
			else
			{
				backgroundOverlayTicketView = (UIImageView *)	[cell viewWithTag:Photo_thumbnail_Overlay];
				backgroundOverlayTicketView.hidden = YES;
				changePhotoLabel = (UILabel *) [cell viewWithTag:Change_Photo_Label];
				changePhotoLabel.backgroundColor = [UIColor clearColor];
				changePhotoLabel.textColor = [UIColor lightGrayColor];
                
                
			}
		}
        
		if(self.selectedImage)
		{
			imv.image = self.selectedImage;
		}
		else
		{
			imv.image = [UIImage imageNamed:@"ticket_photo_placeholder"];
		}
		cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

		return cell;
	}
	
	else if(indexPath.section == 1)
	{
		static NSString *CellIdentifier = @"EditTicketInfo";
        static NSString *dateCellIdentifier = @"dateCellIdentifier";
			
		GBEditTicketCustomCell *cell;
        UITextField *infoTextField;
        if([[[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row] isEqualToString:kEventDate])
            cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (cell == nil )
		{
			NSString *cellName = [[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row];
            if([cellName isEqualToString:kEventDate])
                cell = [[GBEditTicketCustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:dateCellIdentifier];
            else
                cell = [[GBEditTicketCustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
			[cell setSelectionStyle:UITableViewCellEditingStyleNone];
			cell.backgroundColor = [UIColor whiteColor];
			
			if (![cellName isEqualToString:kEventDate])
			{
				infoTextField = [[UITextField alloc]initWithFrame:CGRectMake(134.0, 1.0, 177.0, cell.frame.size.height)];
				infoTextField.clearButtonMode = YES;
				infoTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
				infoTextField.tag = indexPath.row;
				infoTextField.delegate = self;
				infoTextField.autocorrectionType = UITextAutocorrectionTypeNo;
				infoTextField.font = [UIFont fontWithName:@"Gotham-Book" size:15.0];
				infoTextField.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
				[infoTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
				infoTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
				[cell.contentView addSubview:infoTextField];
			}
		}
        
        if (![[[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row] isEqualToString:kEventDate])
        {
            UITextField *field = [[cell.contentView subviews] objectAtIndex:0];
            [field setText:[self.ticketDetailsDict objectForKey:[[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row]]];
        }
        
		NSString *cellName = [[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0)
        {
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
        }
        else if (indexPath.row == ([[_editTicketsArray objectAtIndex:indexPath.section]count] - 1))
        {
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
        }
        else
        {
            //cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"text_cell_middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)]];
        }
		
		if ([cellName isEqualToString:kEventDate])
		{
			cell.detailTextLabel.text = [self.ticketDetailsDict objectForKey:kEventDate];
			cell.textLabel.text = @"Date";
		}
		else
		{
			cell.textLabel.text = [[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row];
		}
		return cell;
	}
		
	else if(indexPath.section == 2)
	{
			static NSString *CellIdentifier = @"EditTicketNotes";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			UITextView *notesTextView = nil;
			if (cell == nil)
			{
				cell = [[GBEditTicketCustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
				[cell setSelectionStyle:UITableViewCellEditingStyleNone];
				notesTextView = [[UITextView alloc]initWithFrame:cell.frame];
				notesTextView.scrollsToTop = NO;
                
				
				UIToolbar *toolbar = [[UIToolbar alloc]init];
				toolbar.barStyle = UIBarStyleBlackTranslucent;
				[toolbar sizeToFit];
				
				
				UIBarButtonItem *doneleftBarButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarbuttonClicked)];
				UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					   target:nil
																					   action:nil];
				NSArray *array = [NSArray arrayWithObjects:space,doneleftBarButton, nil];
				[toolbar setItems:array];
				notesTextView.inputAccessoryView = toolbar;
				notesTextView.tag = NotesTextView;
				notesTextView.editable = YES;
				notesTextView.delegate = self;
				notesTextView.backgroundColor = [UIColor clearColor];
				notesTextView.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
				notesTextView.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
				[notesTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
				cell.backgroundColor = [UIColor whiteColor];
				[cell.contentView addSubview:notesTextView];
			}
		
			else
			{
				notesTextView = (UITextView *)[cell viewWithTag:NotesTextView];
			}
			if ([[self.ticketDetailsDict objectForKey:kEventNotes] length]>0) {
				notesTextView.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
				notesTextView.text = [self.ticketDetailsDict objectForKey:kEventNotes];
			}
			else
			{
				notesTextView.text = @"Add a note";
				notesTextView.textColor = [UIColor colorWithRed:207.0/255.0 green:206.0/255.0 blue:204.0/255.0 alpha:1.0];
			}
        
			return cell;
	}
	else if(indexPath.section == 3)
	{
		static NSString *CellIdentifier = @"DeleteTicketCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[GBEditTicketCustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
			[cell setSelectionStyle:UITableViewCellEditingStyleNone];
  
            
			 UIButton *deleteTicket = [[UIButton alloc]initWithFrame:CGRectMake(cell.frame.origin.x - 2, cell.frame.origin.y -2, cell.frame.size.width + 4, cell.frame.size.height + 4)];
			[deleteTicket setTitle:@"Delete Ticket" forState:UIControlStateNormal];
			deleteTicket.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:24];
            [deleteTicket setTitleColor:[UIColor colorWithRed:253.0/255.0 green:71.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            deleteTicket.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 5, 0);
			deleteTicket.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
			[deleteTicket addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
			deleteTicket.backgroundColor = [UIColor clearColor];
			deleteTicket.tag = 3003;
			[deleteTicket setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
			[cell.contentView addSubview:deleteTicket];
		}

		return cell;
	}
	return nil;
	}
	else
	{
		UITableViewCell *cell = nil;
		static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
		cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
		[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		if (cell == nil) {
			cell = [[UITableViewCell alloc]
					initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
		}
		
		cell.textLabel.text = [_autocompleteUrls objectAtIndex:indexPath.row];
		cell.textLabel.font = [UIFont fontWithName:@"Gotham-Book" size:20.0];
		cell.textLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		if (indexPath.row == [_autocompleteUrls count] -1)
        {
            cell.backgroundView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"autosuggest_cell_bottom"]];
//			cell.backgroundView.contentMode = UIViewContentModeCenter;
            cell.backgroundColor = [UIColor clearColor];
        }
		else if (indexPath.row == 0)
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"autosuggest_cell_top"]];
//			cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
        }
        else
        {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"autosuggest_cell_middle"]];
//			cell.backgroundView.contentMode = UIViewContentModeCenter;
        }

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (tableView.tag == EditTableTag)
	{
	
		if (indexPath.section == 0 )
		{
			[self didTapAddImageButton];
		}
		
	    else if ([indexPath section]== 1 && [[[_editTicketsArray objectAtIndex:[indexPath section]]objectAtIndex:indexPath.row] isEqualToString:kEventDate])
	    {
			if ([_activeField isFirstResponder])
			{
				[_activeField resignFirstResponder];
			}
			
				[self showDatePicker:indexPath];
			}
		 }
	else
	{
		UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
		_autoCompleteTextField.text = selectedCell.textLabel.text;
		[self.ticketDetailsDict setObject:_autoCompleteTextField.text forKey:[[_editTicketsArray objectAtIndex:1] objectAtIndex:_autoCompleteTextField.tag]];
		self.autocompleteTableView.hidden = YES;
		[UIView animateWithDuration:0.3 animations:^{
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
		}completion:nil];
		[_autoCompleteTextField resignFirstResponder];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if(tableView.tag == EditTableTag && section == 0)
		return 20.0;
	else if(tableView.tag == EditTableTag && section == 1)
		return 10.0;
	else if (tableView.tag == EditTableTag && section == 2 )
		return 10.0;
	else if (tableView.tag == EditTableTag && section == 3 )
		return 10.0;
	else
		return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	if(tableView.tag == EditTableTag && section == 0)
		return 10.0;
	else if (tableView.tag == EditTableTag && section == 1 )
		return 10.0;
	else if (tableView.tag == EditTableTag && section == 2 )
		return 10.0;
	else
		return 0.0;
}

-(void) checkAutocompleteTableView
{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait)
	{
		self.autocompleteTableView.hidden = NO;
	}
	else if (UIInterfaceOrientationIsLandscape(orientation))
	{
		self.autocompleteTableView.hidden = YES;
	}
}

#pragma mark Delete Function

-(void) deleteButtonTapped
{
	NSString *eventName;
    
	//Text Based On Event Type
	if ([[self.ticketDetailsDict objectForKey:kEventType] isEqualToString:kEventTypeConcert])
	{
		eventName = self.doc.ticketdata.headLine;
	}
	else if([[self.ticketDetailsDict objectForKey:kEventType] isEqualToString:kEventTypeGame])
	{
		eventName = [NSString stringWithFormat:@"%@ vs %@",self.doc.ticketdata.homeTeam,self.doc.ticketdata.opponentTeam];
	}
	else
	{
		eventName = self.doc.ticketdata.eventName;
	}
	
	NSString *deleteMessage =[NSString stringWithFormat:@"Are you sure you want to delete \"%@\" from TicketBlast?",eventName];
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Delete Ticket"
						  message:deleteMessage
						  delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:@"Delete", @"Cancel", nil];
	alert.cancelButtonIndex = 1;
	alert.tag = 1;
	[alert show];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1)
	{
		if (buttonIndex == 1)
		{

		}
		else
		{
			NSMutableArray *viewControllers = [[NSMutableArray alloc]initWithArray:[self.navigationController viewControllers]];
				
			if ([viewControllers count] > 2)
			{
				[self.doc closeWithCompletionHandler:^(BOOL success)
				{
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[((GBTicketViewController *)[viewControllers objectAtIndex:[viewControllers count]-2]).delegate ticketEditingDone:YES Ticket:nil];
						[viewControllers removeLastObject];
					});
					
				}];
				
			}
			else
			{
				[self.doc closeWithCompletionHandler:^(BOOL success)
				{
					dispatch_async(dispatch_get_main_queue(), ^{

						[self.delegate editTicketDeleted];
					});
				}];
				
			}
			
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
	else if(alertView.tag == 2)
	{
		if (!(buttonIndex == 1))
		{
			[self saveClicked];
		}
		else
		{
			if (self.doc.documentState == UIDocumentStateNormal)
			{
				[self.doc closeWithCompletionHandler:^(BOOL success) {
					[self.navigationController popViewControllerAnimated:YES];
				}];
			}
			else
			{
				[self.navigationController popViewControllerAnimated:YES];
			}
		}
	}
}

#pragma mark AutoComplete Methods

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
	
	// Put anything that starts with this substring into the _autocompleteUrls array
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
		[self.view bringSubviewToFront:self.autocompleteTableView];
	}
	else
	{
		[self.autocompleteTableView setHidden:YES];
	}
	
	[self.autocompleteTableView reloadData];
}

#pragma mark DoneTool Bar-Keyboard

-(void) doneBarbuttonClicked
{
	[_activeField resignFirstResponder];
	[UIView animateWithDuration:0.3 animations:^{
	self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	}completion:nil];
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

#pragma mark TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
	
	if([[textField text] length] > 0)
	{
        if([[textField text] characterAtIndex:([[textField text] length]-1)] == ' ' &&
           [string isEqualToString:@" "]) return NO;
    }
	
	[self checkAutocompleteTableView];

	NSString *substring = [NSString stringWithString:textField.text];
	substring = [substring
				 stringByReplacingCharactersInRange:range withString:string];
	[self searchAutocompleteEntriesWithSubstring:substring];
	
	CGRect rectInTableView = [self.editTicketTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:1]];
	CGRect rectInSuperview = [self.editTicketTable convertRect:rectInTableView toView:[self.editTicketTable superview]];
	
	if ([_autocompleteUrls count] && ([_autocompleteUrls count] < 3))
	{
		self.autocompleteTableView.frame = CGRectMake(20.0, rectInSuperview.origin.y+44, 280.0, (45.0 * [_autocompleteUrls count]-1)+53.0);
	}
	else
	{
		self.autocompleteTableView.frame = CGRectMake(20.0, rectInSuperview.origin.y+44, 280.0,(45.0 * 2 + 53.0));
	}
	
	NSString *actualTextWithoutWhitespace = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger newLength = [actualTextWithoutWhitespace length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[UIView animateWithDuration:0.3 animations:^{

	self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	}completion:nil];
	return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	_activeField = textField;
	_autoCompleteTextField = textField;
	
	if (_datePicker.hidden == NO)
	{
		[UIView animateWithDuration:0.3 animations:^{
			_datePicker.alpha = 0.0f;
		}completion:^(BOOL finished) {
			[_datePicker setHidden:YES];
		}];
	}
	
	id textFieldSuperView = textField.superview.superview;
    NSIndexPath *cellIndex = [self.editTicketTable indexPathForCell:textFieldSuperView];
	
	[UIView animateWithDuration:0.3 animations:^{
		
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 216.0, 0);
	}
	else if (UIInterfaceOrientationIsLandscape(orientation))
	{
		self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 162.0, 0);
	}
		
	[self.editTicketTable scrollToRowAtIndexPath:cellIndex atScrollPosition:UITableViewScrollPositionTop	animated:NO];
	
	_pastUrls = [[NSMutableArray alloc] initWithArray:[[GBDocumentManager sharedInstance] autocompleteDataOfField:[[_editTicketsArray objectAtIndex:1 ]objectAtIndex:textField.tag]]];
		
		
	}completion:nil];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	self.autocompleteTableView.hidden = YES;
	_activeField = nil;
	_autoCompleteTextField = nil;
	[self.ticketDetailsDict setObject:textField.text forKey:[[_editTicketsArray objectAtIndex:1] objectAtIndex:textField.tag]];
	
	[textField resignFirstResponder];
}

//Hides keyboard/date picker when called.
- (void)dismissPresentedViews
{
    [UIView animateWithDuration:0.2 animations:^{
        _editTicketTable.contentInset = UIEdgeInsetsZero;
        [self.view endEditing:YES];
    }];
    
    [_editTicketTable removeGestureRecognizer:_tapGesture];           //Removes tap gesture from table once keyboard/ date picker is hidden from the view.
    
    if (_hideDatePicker)
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


#pragma mark TextView Delegate Methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{
	_activeField = textView;
	
	if (_datePicker.hidden == NO)
	{
		[UIView animateWithDuration:0.3 animations:^{
			_datePicker.alpha = 0.0f;
		}completion:^(BOOL finished) {
			[_datePicker setHidden:YES];
		}];
	}
		
	if ([textView.text isEqualToString:@"Add a note"])
	{
		textView.text = @"";
		textView.textColor = [UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0];
    }
	
	id textviewSuperview = textView.superview.superview;
    NSIndexPath *cellIndexPath = [self.editTicketTable indexPathForCell:textviewSuperview];
	
	
	[UIView animateWithDuration:0.3 animations:^{
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait)
	{
		self.editTicketTable.contentInset =  UIEdgeInsetsMake(0, 0, 216.0, 0);
	}
	else if (UIInterfaceOrientationIsLandscape(orientation))
	{
		self.editTicketTable.contentInset =  UIEdgeInsetsMake(0, 0, 162.0, 0);
	}
	
	}completion:^(BOOL finished) {
		[self.editTicketTable scrollToRowAtIndexPath:cellIndexPath atScrollPosition:UITableViewScrollPositionTop
											animated:YES];
	}];
	
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
	_activeField = nil;
	
	if ([textView.text hasSuffix:@"\n"])
	{
        textView.text = [textView.text substringToIndex:([textView.text length] - 1)];
    }
    
    NSString *actualTextWithoutWhitespace = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *actualTextWithoutNewlineCharacters = [actualTextWithoutWhitespace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (actualTextWithoutNewlineCharacters.length == 0)
    {
        textView.text = @"Add a note";
        textView.textColor = [UIColor colorWithRed:207.0/255.0 green:206.0/255.0 blue:204.0/255.0 alpha:1.0];
		[self.ticketDetailsDict setObject:@"" forKey:kEventNotes];
    }
	else
	{
		[self.ticketDetailsDict setObject:textView.text forKey:kEventNotes];
	}

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && [text isEqualToString:@" "])
	{
        return NO;
    }
    
    NSString *actualTextWithoutWhitespace = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger newLength = [actualTextWithoutWhitespace length] + [text length] - range.length;
	
    return (newLength > 120) ? NO : YES;
}

#pragma mark Date Picker Fucnrtions

-(void)showDatePicker:(NSIndexPath *)indexpaths
{
	if(!_hideDatePicker)
	{	
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		if (![_editTicketTable.gestureRecognizers containsObject:_tapGesture])
        {
            //Add tap gesture (to dismiss keyboard/date picker on tap) to table if not already added.
            [_editTicketTable addGestureRecognizer:_tapGesture];
        }
		if (UIInterfaceOrientationIsLandscape(orientation)) {
			CGSize pickerSize = [_datePicker sizeThatFits:CGSizeZero];
			_datePicker.frame = CGRectMake(0.0, (self.view.frame.size.height-pickerSize.height), pickerSize.width, kDatePicker_Landscape_Height);
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 135.0, 0);
		}
		else if(orientation == UIInterfaceOrientationPortrait)
		{
			CGSize pickerSize = [_datePicker sizeThatFits:CGSizeZero];
			_datePicker.frame = CGRectMake(0.0, (self.view.frame.size.height-pickerSize.height), pickerSize.width, kDatePicker_Potrait_Height);
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(5.0, 0, 216.0, 0);
		}
		
		[self.editTicketTable scrollToRowAtIndexPath:indexpaths atScrollPosition:UITableViewScrollPositionTop animated:YES];
		[_datePicker addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
		[_datePicker setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
		[self.view addSubview:_datePicker];
		
		[UIView animateWithDuration:0.3f animations:^{
			_datePicker.alpha = 1.0f;
		}];
		
        [_datePicker setHidden:NO];
		_hideDatePicker = YES;
    }
    else
	{

		[UIView animateWithDuration:0.3f animations:^{
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			_datePicker.alpha = 0.0f;
		} completion:^(BOOL finished){
			_datePicker.hidden = YES;
		}];
		_hideDatePicker = NO;
    }
}

//Date Picker Time Set
-(void) dueDateChanged:(UIDatePicker *)sender
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *stringFromDate = [dateFormatter stringFromDate:[sender date]];
	[self.ticketDetailsDict setObject:stringFromDate forKey:kEventDate];
	[self.editTicketTable reloadData];
}


#pragma mark Bar Button Functions

//Save Edited Ticket 
-(void) saveClicked
{
	[_activeField resignFirstResponder];
	
	if (!_datePicker.hidden) {
		[UIView animateWithDuration:0.3f animations:^{
			self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
			_datePicker.alpha = 0.0f;
		} completion:^(BOOL finished){
			_datePicker.hidden = YES;
		}];
	}
	
	_progressSpinner.center = self.view.center;
	[_progressSpinner startAnimating];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
	[self performSelector:@selector(completeSaveAction) withObject:nil afterDelay:0.0];         //Required, otherwise will not show progress indicator on time
}

- (void)completeSaveAction
{
    BOOL isFormComplete = YES;
    
	if (_datePicker.hidden == NO)
	{
		[UIView animateWithDuration:0.3 animations:^{
			_datePicker.alpha = 0.0f;
		}completion:^(BOOL finished) {
			[_datePicker setHidden:YES];
		}];
	}
	
	
	NSString *errorMessage = [NSString stringWithFormat:@"Please enter a"];
	for (int i = 0; i<[[_editTicketsArray objectAtIndex:1]count]; i++)
    {
		NSString *stringWithoutSpaces = [[_ticketDetailsDict objectForKey:[[_editTicketsArray objectAtIndex:1]objectAtIndex:i]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (([stringWithoutSpaces isEqualToString:@""]) || (stringWithoutSpaces.length == 0))
        {
            errorMessage = [NSString stringWithFormat:@"%@ %@ ,",errorMessage,[[_editTicketsArray objectAtIndex:1]objectAtIndex:i]];
            isFormComplete = NO;
        }
	}
	
	if ([errorMessage length] > 0)
		errorMessage = [errorMessage substringToIndex:[errorMessage length] - 1];
	
	if (isFormComplete)
	{
		//Document Approach
		
		self.navigationItem.leftBarButtonItem.enabled = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.view.userInteractionEnabled = NO;
		
		self.doc.ticketdata.venue = [self.ticketDetailsDict objectForKey:kEventVenue];
		
		if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
		{
			self.doc.ticketdata.homeTeam = [self.ticketDetailsDict objectForKey:kHomeTeam];
			self.doc.ticketdata.opponentTeam = [self.ticketDetailsDict objectForKey:kOpponent];
		}
		else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
		{
			self.doc.ticketdata.headLine = [self.ticketDetailsDict objectForKey:kHeadline];
		}
		else
		{
			self.doc.ticketdata.eventName = [self.ticketDetailsDict objectForKey:kEventName];
		}
		
		self.doc.ticketdata.eventNotes = [self.ticketDetailsDict objectForKey:kEventNotes];
		self.doc.ticketdata.eventType = [self.ticketDetailsDict objectForKey:kEventType];
		self.doc.ticketdata.date = [self.ticketDetailsDict objectForKey:kEventDate];
		
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
		
		self.doc.photo = self.selectedImage;
		
		[[NSNotificationCenter defaultCenter] removeObserver:self];

		[self.doc saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
			[self.doc closeWithCompletionHandler:^(BOOL success) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (!success) {
						NSLog(@"Failed to close %@", self.doc.fileURL);
						// Continue anyway...
					}
					else
					{
						NSLog(@"Sucess Saved- %@", self.doc.fileURL);
					}
			
					self.navigationItem.leftBarButtonItem.enabled = YES;
					self.navigationItem.rightBarButtonItem.enabled = YES;
					self.view.userInteractionEnabled = YES;
					
					NSError *err;
					[self.fileURL setResourceValue:newDateForKey forKey:NSURLCreationDateKey error:&err];
					NSLog(@"Setting Value in Edit-%@",newDateForKey);
					NSLog(@"err-%@",err);
					
					[self performSelector:@selector(sendSavedTicketMessage:) withObject:[NSNumber numberWithBool:success] afterDelay:0.0];
				});
			}];
		}];
		
	}
	
	else
	{
        [_progressSpinner stopAnimating];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
		[[GBAlertWindow sharedAlertWindow] showMessage:errorMessage];
	}
}

- (void)sendSavedTicketMessage:(NSNumber *)success {
	
	[self.delegate editTicketSaved:[success boolValue]];
	[self.navigationController popViewControllerAnimated:YES];
}
-(void) cancelClicked
{
	[_activeField resignFirstResponder];
	
	BOOL isDataModified = [self compareTicketData];
	
	if (isDataModified)
	{
		UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"TicketBlast"
						  message:@"Do you want to save the changes?"
						  delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:@"Save", @"Cancel", nil];
		alert.cancelButtonIndex = 1;
		alert.tag =  2;
		[alert show];
	}
	else
	{
		if (self.doc.documentState == UIDocumentStateNormal)
		{
			[self.doc closeWithCompletionHandler:^(BOOL success) {
				[self.navigationController popViewControllerAnimated:YES];
			}];
		}
		else
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

#pragma mark UIImage Picker Functions

- (void)didTapAddImageButton
{
	if ([_activeField isFirstResponder])
	{
		[_activeField resignFirstResponder];
	}
	
	self.editTicketTable.contentInset =  UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
	
	if (_datePicker.hidden == NO)
	{
		[UIView animateWithDuration:0.3 animations:^{
			_datePicker.alpha = 0.0f;
		}completion:^(BOOL finished) {
			[_datePicker setHidden:YES];
		}];
	}

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
    
	if (actionSheet.tag == 2)
	{
		NSInteger source = 2;
		if(buttonIndex == 0)
		{
			source = 1;
			 [self showPicker:source];
		}
		else if(buttonIndex == 1)
		{
			source = 2;
			 [self showPicker:source];
		}
		else
		{
			//do nothing
		}
	}
	else if(actionSheet.tag == 1)
	{
		if (buttonIndex == 0)
		{
			self.selectedImage = nil;
			[self.editTicketTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark ImagePicker 

- (void)showPicker:(NSInteger)source
{
    imagePicker = [[GBImagePickerViewController alloc] init];
    imagePicker.delegate = (id) self;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        imagePicker.navigationBar.translucent = NO;
        imagePicker.navigationBar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0];
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        imagePicker.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0];
    }
	
    if (source == 1)
	{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
             imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    else
	{
		 imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	
	UIImage *pickedImage = [self fixImageOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];       //function call needed so that portrait images do not get rotated in coverflow.
	    
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
    
	[imagePicker pushViewController:imgCropperViewController animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark Utility Functions

//Form the cells needed based on event-type

- (void) getTicketDetails
{
	_ticketCells = [[NSMutableArray alloc]init];
	[_ticketCells addObject:kEventVenue];
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		[_ticketCells addObject:kHomeTeam];
		[_ticketCells addObject:kOpponent];
	}
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		[_ticketCells addObject:kHeadline];
	}
	else
	{
		[_ticketCells addObject:kEventName];
	}
	[_ticketCells addObject:kEventDate];
}

#pragma mark CompareForChange

//Compare Data to Check if there is any Change by the User

-(BOOL) compareTicketData
{
	BOOL isModified = NO;
	
	if (self.doc.photo != self.selectedImage)
	{
		isModified = YES;
	}
	
	else if(![[self.ticketDetailsDict objectForKey:kEventVenue] isEqualToString:self.doc.ticketdata.venue] || ![[self.ticketDetailsDict objectForKey:kEventDate] isEqualToString:self.doc.ticketdata.date] || ![[self.ticketDetailsDict objectForKey:kEventNotes] isEqualToString:self.doc.ticketdata.eventNotes])
	{
		isModified = YES;
	}
	
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame]) {
		
		if (![self.doc.ticketdata.homeTeam isEqualToString:[self.ticketDetailsDict objectForKey:kHomeTeam]] || ![self.doc.ticketdata.opponentTeam isEqualToString:[self.ticketDetailsDict objectForKey:kOpponent]]) {
			isModified = YES;
		}
	}
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		if (![self.doc.ticketdata.headLine isEqualToString:[self.ticketDetailsDict objectForKey:kHeadline]]) {
			isModified = YES;
		}
	}
	else
	{
		if (![self.doc.ticketdata.eventName isEqualToString:[self.ticketDetailsDict objectForKey:kEventName]]) {
			isModified = YES;
		}
	}
	
	return isModified;
}

#pragma mark PhotoEditing
#pragma mark - UzysImageCropperDelegate

- (void)imageCropper:(UzysImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image
{
    self.selectedImage = image;
    [self.editTicketTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.selectedImage = [UIImage imageWithImage:self.selectedImage scaledToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.editTicketTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

- (void)imageCropperDidCancel:(UzysImageCropperViewController *)cropper
{
	
}


#pragma mark Document State Changed

//iCloud Account When Deleted in Settings Causes Error.So Avoid UserInteraction and Pop to Coverflow
- (void)documentStateChanged:(NSNotification *)notificaiton {
		
			[self.ticketDetailsDict setObject:self.doc.ticketdata.venue forKey:kEventVenue];
			
			if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
			{
				[self.ticketDetailsDict setObject:self.doc.ticketdata.homeTeam forKey:kHomeTeam];
				[self.ticketDetailsDict setObject:self.doc.ticketdata.opponentTeam forKey:kOpponent];
			}
			else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
			{
				[self.ticketDetailsDict setObject:self.doc.ticketdata.headLine forKey:kHeadline];
			}
			else
			{
				[self.ticketDetailsDict setObject:self.doc.ticketdata.eventName forKey:kEventName];
			}
			[self.ticketDetailsDict setObject:self.doc.ticketdata.eventNotes forKey:kEventNotes];
			[self.ticketDetailsDict setObject:self.doc.ticketdata.eventType forKey:kEventType];
			[self.ticketDetailsDict setObject:self.doc.ticketdata.date forKey:kEventDate];
	
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			NSDate *eventDate = [dateFormatter dateFromString:[self.ticketDetailsDict objectForKey:kEventDate]];
	
			dispatch_async(dispatch_get_main_queue(), ^{
				if (eventDate)
				{
					[_datePicker setDate:eventDate] ;
				}
				[self.editTicketTable reloadData];
			});
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			
			dispatch_async(queue, ^{
				
				UIImage *image = self.doc.photo;
				
				dispatch_async(dispatch_get_main_queue(), ^{
					
					if (image)
					{
						self.selectedImage =image;
					} else
					{
						self.selectedImage = nil;
					}
					[self.editTicketTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
				});
			});
}

#pragma mark Dealloc
-(void)dealloc
{
	_ticketData = nil;
	self.selectedImage = nil;
    _scaledImageForDisplay = nil;
    _progressSpinner = nil;
	_editTicketsArray = nil;
	_datePicker = nil;
	_autoCompleteTextField = nil;
	_saveView = nil;
	_cancelView = nil;
	_pastUrls = nil;
	_autocompleteUrls = nil;
	_ticketData = nil;
	_ticketCells = nil;
	_keyboardToolbar = nil;
    _tapGesture= nil;
}


@end