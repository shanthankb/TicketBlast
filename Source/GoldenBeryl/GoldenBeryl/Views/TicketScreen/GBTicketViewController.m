//
//  GBTicketViewController.m
//  TicketBlast
//
//  Created by Mohammed Shahid on 02/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBTicketViewController.h"
#import "GBNotesCustomTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "GBCoverFlowViewController.h"
#import "GBTicketFullScreenViewController.h"
#import <Social/Social.h>

#define HeadLabelHeight 17
#define DateLabelHeight 10
#define ItemsWidth 322
#define TicketImageHeight 200
#define TicketImageWidth 322
#define NotesLabelHeight 100
#define FacebookAppIDKey @"141264476063627"

@interface GBTicketViewController ()
{
	UITextView *sharingTextView;
    NSString *permanentText;
}

-(void)showFBComposer;
-(void)showErrorMessage:(NSString *)errorMessage;
- (void)postMessage:(NSDictionary *)message;

@end

@implementation GBTicketViewController
{
	UIButton *_backView;
	UIButton *_editView;
	UIScrollView *_scrollView;
	GBNotesCustomTextView *_notesTextView;
	NSLayoutConstraint *_notesTextViewHeightConstraint;
	NSLayoutConstraint *_extraImageAlignViewConstraints;
	
	//View Items
	UILabel *_headLabel;
	UILabel *_dateLabel;
	UIImageView *_ticketImageView;
	UILabel *_extraInfoLabel;
	UIImageView *_extraInfoImageView;
	UIImageView *_venueImageView;
	UILabel *_venueLabel;
	UIButton *_shareButton;
	OVSpinningProgressViewOverlay *mProgressSpinner;
	UIActivityIndicatorView *_activityView;
    UIImageView *backgroundTicketImageView;
    UIImageView *separatorView;
	
    //Facebook
    ACAccountStore *accountStore;
    __block ACAccount *facebookAccount;
    ACAccountType *facebookAccountType;
	
}

@synthesize ticketId = _ticketId;

- (id)init
{
    self = [super init];
    if (self) {
	}
    return self;
}

-(void)loadView
{
	
	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	[view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	[view setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]]];
	self.view = view;
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	CGRect selfBounds = self.view.bounds;
	selfBounds.size.height = self.view.bounds.size.height - 44.0;
	
	mProgressSpinner = [[OVSpinningProgressViewOverlay alloc] initWithFrameOfEnclosingView:selfBounds];
    [mProgressSpinner setHidesWhenStopped:YES];
    [self.view addSubview:mProgressSpinner];
	
	//ScrollView
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	[_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *scrollViewConstraints = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
	[self.view addConstraint:scrollViewConstraints];
	
	scrollViewConstraints = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
	[self.view addConstraint:scrollViewConstraints];
	
	scrollViewConstraints = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
	[self.view addConstraint:scrollViewConstraints];
	
	scrollViewConstraints = [NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
	[self.view addConstraint:scrollViewConstraints];
	
	
	_headLabel = [[UILabel alloc]init];
	
	//Head Label Based On Event Type
	if ([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		//headLabel.text = [ticketData objectForKey:kHeadline];
		_headLabel.text = self.doc.ticketdata.headLine;
	}
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		//headLabel.text = [ticketData objectForKey:kHomeTeam];
		_headLabel.text = self.doc.ticketdata.homeTeam;
	}
	else
	{
		//headLabel.text = [ticketData objectForKey:kEventName];
		_headLabel.text = self.doc.ticketdata.eventName;
	}
	
	//Navigation Title
	self.title = @"Ticket";
	
	[_headLabel setFont:[UIFont fontWithName:@"GothamNarrow-Book" size:24]];
	_headLabel.textColor =[UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
	_headLabel.backgroundColor = [UIColor clearColor];
	
	
	_dateLabel = [[UILabel alloc]init];
	_dateLabel.text = self.doc.ticketdata.date;
	[_dateLabel setFont:[UIFont fontWithName:@"GothamNarrow-Light" size:16]];
	_dateLabel.textColor =[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
	_dateLabel.backgroundColor = [UIColor clearColor];
	
	UIView *backgroundView = [[UIView alloc]init];
	
	//Ticket Background
	
	_ticketImageView = [[UIImageView alloc] init];
    _ticketImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ticketImageView.userInteractionEnabled = YES;
	
	_ticketImageView.image = nil;
    
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[_ticketImageView addSubview:_activityView];
	_activityView.hidden = NO;
	[_activityView startAnimating];
	
	
	//Asynchronous Loading of Image
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	dispatch_async(queue, ^{
		
        UIImage *image = self.doc.photo;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[_activityView stopAnimating];
			if (image)
			{
				_ticketImageView.image = image;
			} else
			{
				_ticketImageView.image = [UIImage imageNamed:@"ticket_photo_placeholder"];
			}
		});
    });
	
	
	
	_venueImageView = [[UIImageView alloc] init];
	_venueImageView.image = [UIImage imageNamed:@"icon_venue"];
	
	_venueLabel = [[UILabel alloc]init];
	[_venueLabel setFont:[UIFont fontWithName:@"Georgia-Italic" size:12.0]];
	_venueLabel.text = self.doc.ticketdata.venue;
	_venueLabel.textColor =  [UIColor colorWithRed:131.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0];
	_venueLabel.backgroundColor = [UIColor clearColor];
	
	//Label Based on Extra info for Game Type
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		_extraInfoLabel = [[UILabel alloc]init];
		[_extraInfoLabel setFont:[UIFont fontWithName:@"Georgia-Italic" size:12.0]];
		_extraInfoLabel.text = self.doc.ticketdata.opponentTeam;
		_extraInfoLabel.textAlignment = NSTextAlignmentRight;
		_extraInfoLabel.textColor =  [UIColor colorWithRed:131.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0];
		_extraInfoLabel.backgroundColor = [UIColor clearColor];
		_extraInfoImageView = [[UIImageView alloc] init];
		_extraInfoImageView.image = [UIImage imageNamed:@"icon_opponent"];
		[_scrollView addSubview:_extraInfoImageView];
		[_scrollView addSubview:_extraInfoLabel];
	}
	
	//Notes TextView
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineSpacing = 7;
//    NSDictionary *attrsDictionary = @{NSParagraphStyleAttributeName: paragraphStyle,
//                                      NSFontAttributeName:[UIFont fontWithName:@"Gotham-Book" size:14.0]};
	NSString *text = [NSString stringWithFormat:@"%@",self.doc.ticketdata.eventNotes];
	
	_notesTextView = [[GBNotesCustomTextView alloc]init];
	_notesTextView.text = text;
//    _notesTextView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attrsDictionary];
	[_notesTextView setEditable:NO];
	_notesTextView.textColor = [UIColor colorWithRed:93.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:1.0];
	_notesTextView.backgroundColor = [UIColor clearColor];
	
	UIFont *font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
	_notesTextView.font = font;
    
    
    // Separator

    separatorView = [[UIImageView alloc]init];
    separatorView.image = [UIImage imageNamed:@"separator"];
	
	//Share Button
	_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_shareButton.layer setMasksToBounds:YES];
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"share_button"] forState:UIControlStateNormal];
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"share_button_pressed"] forState:UIControlStateSelected];
	[_shareButton setBackgroundImage:[UIImage imageNamed:@"share_button_pressed"] forState:UIControlStateHighlighted];
	
	[_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	_shareButton.titleLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:18];
	[_shareButton setTitle:@"Share" forState:UIControlStateNormal];
	_shareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	
	[backgroundView addSubview:_ticketImageView];
	
	[_scrollView addSubview:_headLabel];
	[_scrollView addSubview:_dateLabel];
	[_scrollView addSubview:backgroundView];
	[_scrollView addSubview:_venueImageView];
	[_scrollView addSubview:_venueLabel];
    [_scrollView addSubview:separatorView];
	[_scrollView addSubview:_notesTextView];
	[_scrollView addSubview:_shareButton];
	
	[self.view addSubview:_scrollView];
	
	
	//Head Label Autolayout Constraints
	_headLabel.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *headLabelConstraints = [NSLayoutConstraint constraintWithItem:_headLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:10.0f];
	[_scrollView addConstraint:headLabelConstraints];
	
	headLabelConstraints = [NSLayoutConstraint constraintWithItem:_headLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeTop multiplier:1.0f constant:18.0f];
	[_scrollView addConstraint:headLabelConstraints];
    
    headLabelConstraints = [NSLayoutConstraint constraintWithItem:_headLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:ItemsWidth];
	[_scrollView addConstraint:headLabelConstraints];
	
	headLabelConstraints = [NSLayoutConstraint constraintWithItem:_headLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:26.0]; //Getting Trimmed So increased height
	[_scrollView addConstraint:headLabelConstraints];
	
	//Date Label Autolayout Constraints
	_dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *dateLabelConstraints = [NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:10.0f];
	[_scrollView addConstraint:dateLabelConstraints];
	
	dateLabelConstraints = [NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_headLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:7.0f];
	[_scrollView addConstraint:dateLabelConstraints];
    
    dateLabelConstraints = [NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20.0];
	[_scrollView addConstraint:dateLabelConstraints];
	
	dateLabelConstraints = [NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:19.0];
	[_scrollView addConstraint:dateLabelConstraints];
	
	
	//Background View Constraint
	
	backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *backgroundViewConstraints = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:9.0f];
	[_scrollView addConstraint:backgroundViewConstraints];
	
	backgroundViewConstraints = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dateLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:18.0f];
	[_scrollView addConstraint:backgroundViewConstraints];
    
	
    backgroundViewConstraints = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20.0f];
	[_scrollView addConstraint:backgroundViewConstraints];
	
	backgroundViewConstraints = [NSLayoutConstraint constraintWithItem:backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:TicketImageHeight];
    [_scrollView addConstraint:backgroundViewConstraints];
	
	
	//Ticket Image Autolayout Constraints
	_ticketImageView.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *ticketImageConstraints = [NSLayoutConstraint constraintWithItem:_ticketImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
	[backgroundView addConstraint:ticketImageConstraints];
	
	ticketImageConstraints = [NSLayoutConstraint constraintWithItem:_ticketImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeTop multiplier:1.0f constant:10.0f];
	[backgroundView addConstraint:ticketImageConstraints];
    
    ticketImageConstraints = [NSLayoutConstraint constraintWithItem:_ticketImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:ItemsWidth]; //6 + 6 for Frame of Photo
	[backgroundView addConstraint:ticketImageConstraints];
	
	ticketImageConstraints = [NSLayoutConstraint constraintWithItem:_ticketImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:TicketImageHeight];
    [backgroundView addConstraint:ticketImageConstraints];
	
    
	//Venue Image Constraints
    _venueImageView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *venueImageViewConstraints = [NSLayoutConstraint constraintWithItem:_venueImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:6.0f];
	[_scrollView addConstraint:venueImageViewConstraints];
	
	venueImageViewConstraints = [NSLayoutConstraint constraintWithItem:_venueImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:23.0f];
	[_scrollView addConstraint:venueImageViewConstraints];
	
    venueImageViewConstraints = [NSLayoutConstraint constraintWithItem:_venueImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:6.0f];
	[_scrollView addConstraint:venueImageViewConstraints];
	
	venueImageViewConstraints = [NSLayoutConstraint constraintWithItem:_venueImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:11.0];
    [_scrollView addConstraint:venueImageViewConstraints];
	
	//Venue Label Autolayout Constraints
	_venueLabel.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *venuelabelConstraints = [NSLayoutConstraint constraintWithItem:_venueLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_venueImageView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:3.0f];
	[_scrollView addConstraint:venuelabelConstraints];
	
	venuelabelConstraints = [NSLayoutConstraint constraintWithItem:_venueLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_venueImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
	[_scrollView addConstraint:venuelabelConstraints];
	
    venuelabelConstraints = [NSLayoutConstraint constraintWithItem:_venueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:ItemsWidth/2];
	[_scrollView addConstraint:venuelabelConstraints];
	
	venuelabelConstraints = [NSLayoutConstraint constraintWithItem:_venueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:14.0];
    [_scrollView addConstraint:venuelabelConstraints];
	
	//ExtraInfo Label Autolayout Constraints
	
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		_extraInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
		NSLayoutConstraint *extraInfoLabelConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-6.0];
		[_scrollView addConstraint:extraInfoLabelConstraints];
		
		extraInfoLabelConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_venueImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
		[_scrollView addConstraint:extraInfoLabelConstraints];
		
		extraInfoLabelConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:(ItemsWidth/2)-16	];
		[_scrollView addConstraint:extraInfoLabelConstraints];
		
		extraInfoLabelConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:14.0];
		[_scrollView addConstraint:extraInfoLabelConstraints];
		
		//Calculate size for Indention of Image Closer to text
		CGSize extraInfoLabelSize = [self giveTextSizeForText:_extraInfoLabel.text fontSpecification:[UIFont fontWithName:@"Georgia-Italic" size:12.0] forWidth:ItemsWidth/2];
		CGFloat offset = (ItemsWidth/2 - extraInfoLabelSize.width) - 15;
		
		
		_extraInfoImageView.translatesAutoresizingMaskIntoConstraints = NO;
		
		_extraImageAlignViewConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_extraInfoLabel attribute:NSLayoutAttributeLeading multiplier:1.0f constant:offset];
		[_scrollView addConstraint:_extraImageAlignViewConstraints];
		
		NSLayoutConstraint *extraImageViewConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_venueImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
		[_scrollView addConstraint:extraImageViewConstraints];
		
		extraImageViewConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:12.0f];
		[_scrollView addConstraint:extraImageViewConstraints];
		
		extraImageViewConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:10.0];
		[_scrollView addConstraint:extraImageViewConstraints];
    }
    
    
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *separatorViewConstraints = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
	[_scrollView addConstraint:separatorViewConstraints];
	
	separatorViewConstraints = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_venueLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10.0f];
	[_scrollView addConstraint:separatorViewConstraints];
	
    separatorViewConstraints = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:_scrollView.frame.size.width];
	[_scrollView addConstraint:separatorViewConstraints];
	
	separatorViewConstraints = [NSLayoutConstraint constraintWithItem:separatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0];
    [_scrollView addConstraint:separatorViewConstraints];
	
	//Notes TextView Autolayout Constraints
	_notesTextView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *notesTextViewConstraints = [NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:9.0f];
	[_scrollView addConstraint:notesTextViewConstraints];
	
	notesTextViewConstraints = [NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:separatorView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10.0f];
	[_scrollView addConstraint:notesTextViewConstraints];
    
    notesTextViewConstraints = [NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20];
	[_scrollView addConstraint:notesTextViewConstraints];
	
	_notesTextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_notesTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_notesTextView.frame.size.height];
	[_scrollView addConstraint:_notesTextViewHeightConstraint];
	
	
	//Share Button Autolayout Constraints
	_shareButton.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *shareButtonConstraints = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_notesTextView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:14.5f];
	[_scrollView addConstraint:shareButtonConstraints];
	
	shareButtonConstraints = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_notesTextView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
	[_scrollView addConstraint:shareButtonConstraints];
	
	shareButtonConstraints = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-20.0];
	[_scrollView addConstraint:shareButtonConstraints];
	
	shareButtonConstraints = [NSLayoutConstraint constraintWithItem:_shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:46.0f];
	[_scrollView addConstraint:shareButtonConstraints];
	
	_notesTextView.textColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	 permanentText = @"Shared via TicketBlast";
	//back
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 12, 25)];
    [backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back_pressed"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;

	//Edit
	_editView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	[_editView addTarget:self action:@selector(editButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[_editView setImage:[UIImage imageNamed:@"button_edit"] forState:UIControlStateNormal];
    [_editView setImage:[UIImage imageNamed:@"button_edit_pressed"] forState:UIControlStateHighlighted];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:_editView];
	[self.navigationItem setRightBarButtonItem:editButton];
	
	
	UITapGestureRecognizer *ticketTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ticketTapped)];
	[_ticketImageView addGestureRecognizer:ticketTap];
	
	_notesTextView.scrollsToTop = NO;
	_scrollView.scrollsToTop = YES;
}

-(void)viewDidLayoutSubviews
{
	_activityView.center = CGPointMake(backgroundTicketImageView.center.x-15.0, backgroundTicketImageView.center.y-10.0);
}

- (void)viewDidDisappear:(BOOL)animated
{
    _ticketImageView.image = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
	_shareButton.hidden = YES;
	[self.view bringSubviewToFront:mProgressSpinner];
    mProgressSpinner.center = self.view.center;
	[mProgressSpinner startAnimating];
	[self performSelector:@selector(resizeHeightForTextView) withObject:nil afterDelay:0.0];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self resizeNavButtonsOnRotationForOrientation:orientation];
    
    if (_ticketImageView.image == nil) {
		
		//Asynchronous Loading of Image
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		
		dispatch_async(queue, ^{
			
			UIImage *image = self.doc.photo;                //Get the image to be displayed in background, and then display image using the main thread.
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				if (image)
				{
					_ticketImageView.image = image;
				} else
				{
					_ticketImageView.image = [UIImage imageNamed:@"ticket_photo_placeholder"];
				}
			});
		});

    }

	[[NSNotificationCenter defaultCenter] addObserver:self
	 
											 selector:@selector(documentStateChanged:)
	 
												 name:UIDocumentStateChangedNotification object:self.doc];
	
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewWillDisappear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self performSelector:@selector(resizeHeightForTextView) withObject:nil afterDelay:0.0];
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self resizeHeightForTextView];
	
	[self resizeNavButtonsOnRotationForOrientation:toInterfaceOrientation];
}

- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIButton *leftNavButton = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x,leftNavButton.frame.origin.y, 12, 25.0)];
	}
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, 12, 31.0)];
	}
}

#pragma mark Notestextview

- (CGSize)giveTextSizeForText:(NSString *)inputText fontSpecification:(UIFont *)font forWidth:(CGFloat)width
{
	CGSize textSize = { width, 1000 };
	CGSize size = [inputText sizeWithFont:font
						constrainedToSize:textSize
							lineBreakMode:NSLineBreakByCharWrapping];
	
	return size;
}



#pragma mark TextView Height Resizing

//Resize TextView Based on Number of Lines

-(void) resizeHeightForTextView
{
	CGRect frame = _notesTextView.frame;
	frame.size.height = _notesTextView.contentSize.height;
	_notesTextView.frame = frame;
	
	[UIView animateWithDuration:0.0
					 animations:^{
						 
						 _notesTextViewHeightConstraint.constant = _notesTextView.frame.size.height;
						 [self.view layoutIfNeeded];
						 _shareButton.hidden = NO;
						 _notesTextView.textColor = [UIColor colorWithRed:93.0/255.0 green:93.0/255.0 blue:93.0/255.0 alpha:1.0];
					 } completion:^(BOOL finished) {
						 
					 }];
		
	//Remove Align Constraints
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		[_scrollView removeConstraint:_extraImageAlignViewConstraints];
	
		//Calculate size for Indention of Image Closer to text
		CGSize extraInfoLabelSize = [self giveTextSizeForText:_extraInfoLabel.text fontSpecification:[UIFont fontWithName:@"Georgia-Italic" size:12.0] forWidth:ItemsWidth/2];
		CGFloat offset = (ItemsWidth/2 - extraInfoLabelSize.width) - 19;
	
		_extraImageAlignViewConstraints = [NSLayoutConstraint constraintWithItem:_extraInfoImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_extraInfoLabel attribute:NSLayoutAttributeLeading multiplier:1.0f constant:offset];
		[_scrollView addConstraint:_extraImageAlignViewConstraints];
	}
	
	_scrollView.contentSize = CGSizeMake(self.view.frame.size.width,_notesTextView.frame.origin.y + _notesTextView.frame.size.height + 64.0);
	
	[mProgressSpinner stopAnimating];
}

#pragma mark Document State Changed

//iCloud Account When Deleted in Settings Causes Error.So Avoid UserInteraction and Pop to Coverflow
- (void)documentStateChanged:(NSNotification *)notificaiton {

	dispatch_async(dispatch_get_main_queue(), ^{
		[self editTicketSaved:YES];
		[self performSelector:@selector(resizeHeightForTextView) withObject:nil afterDelay:0.0];
	});
}

#pragma mark Bar Button

-(void)backButtonClicked
{
	[self.delegate ticketEditingDone:NO Ticket:self];
	
	if (self.doc.documentState == UIDocumentStateNormal) {
		[self.doc closeWithCompletionHandler:^(BOOL success) {
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
			[self.navigationController popViewControllerAnimated:YES];
		}];
	}
	else
	{
		//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)editButtonClicked
{
	[_scrollView scrollRectToVisible:CGRectMake(1.0,1.0,1.0,1.0) animated:YES];
	GBEditTicketViewController *editViewController = [[GBEditTicketViewController alloc]init];
	editViewController.doc  = self.doc;
	editViewController.delegate = self;
	editViewController.fileURL = self.fileURL;
	[self.navigationController pushViewController:editViewController animated:YES];
}


#pragma mark Edit Controller Delegate

-(void)editTicketSaved:(BOOL)saveStatus
{
	//Notes
	NSString *text = [NSString stringWithFormat:@"%@",self.doc.ticketdata.eventNotes];
	_notesTextView.text = text;

	UIFont *font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
	_notesTextView.font = font;

	//Head Label Based On Event Type
	if ([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
	{
		_headLabel.text = self.doc.ticketdata.headLine;
	}
	else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		_headLabel.text = self.doc.ticketdata.homeTeam;
	}
	else
	{
		_headLabel.text = self.doc.ticketdata.eventName;
	}

	//Date
	_dateLabel.text = self.doc.ticketdata.date;

	if (self.doc.photo)
	{
		_ticketImageView.image = self.doc.photo;
	} else
	{
		_ticketImageView.image = [UIImage imageNamed:@"ticket_photo_placeholder"];
	}
	
	//Venue
	_venueLabel.text = self.doc.ticketdata.venue;

	//Label Based on Extra info for Game Type
	if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
	{
		_extraInfoLabel.text = self.doc.ticketdata.opponentTeam;
	}
}

#pragma mark FB/Twitter Share Methods

-(void) shareButtonPressed
{
	_internetReach = [Reachability reachabilityForInternetConnection];
	[_internetReach startNotifier];
	[self updateInterfaceWithReachability: _internetReach];
}

//Facebook Uses Third Party Composer
//Twitter User Default SLComposer
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if (buttonIndex == 0)
    {
		if (!accountStore) {
			accountStore = [[ACAccountStore alloc] init];
		}
	
		facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
		
		NSArray * permissions = [NSArray arrayWithObjects:@"email",@"user_location", nil];
		// Specify App ID and permissions
		NSDictionary *basicPermissions = @{
							ACFacebookAppIdKey: FacebookAppIDKey,
	   ACFacebookPermissionsKey:permissions,
	   ACFacebookAudienceKey: ACFacebookAudienceFriends
	   };
		
		[accountStore requestAccessToAccountsWithType:facebookAccountType
											  options:basicPermissions completion:^(BOOL granted, NSError *error)
		 {
			 if (granted)
			 {
				 NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
				 
				 facebookAccount = [accounts lastObject];
				 
				 [accountStore renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
					 if (error) {
						 NSLog(@"Err- %@",error);
					 }
				 }];
				 
				 NSArray * permissions = [NSArray arrayWithObjects:@"publish_stream", @"publish_actions",nil];
				 
				 // Specify App ID and permissions
				 NSDictionary *postPermissions = @{
							   ACFacebookAppIdKey: FacebookAppIDKey,
							   ACFacebookPermissionsKey: permissions,
									ACFacebookAudienceKey: ACFacebookAudienceFriends
								};
				 
				 [accountStore requestAccessToAccountsWithType:facebookAccountType
													   options:postPermissions completion:^(BOOL granted, NSError *error)
				  {
					  if (granted)
					  {
						 [self performSelectorOnMainThread:@selector(showFBComposer) withObject:nil waitUntilDone:NO];
					  }
					  
					  else {
						  
						  NSLog(@"error.localizedDescription======= %@", error.localizedDescription);
						  NSString *errorMessage;
						  if (error.code == 6)
						  {
							  errorMessage = @"Please configure your Facebook account in Device Settings";
						  }
						  else if (error.code == 7)
						  {
							  if ([error.localizedDescription isEqualToString:@"The Facebook server could not fulfill this access request: The app must ask for a basic read permission at install time."]) {
								  errorMessage =  @"TicketBlast cannot connect to Facebook";
							  }
							  else
								  return ;
							  
						  }
						  else
						  {
							  errorMessage = @"TicketBlast cannot post on Facebook. Please ensure TicketBlast has access to your account in device Settings";
						  }
						  [self performSelectorOnMainThread:@selector(showErrorMessage:) withObject:errorMessage waitUntilDone:NO];
					  }
					  
				  }];

			 }
			 else {
				
				 NSLog(@"error.localizedDescription======= %@", error.localizedDescription);
                 NSString *errorMessage;
                 if (error.code == 6)
                 {
                    errorMessage = @"Please configure your Facebook account in Device Settings";
                 }
                 else if (error.code == 7)
                 {
                     if ([error.localizedDescription isEqualToString:@"The Facebook server could not fulfill this access request: The app must ask for a basic read permission at install time."]) {
                         errorMessage =  @"TicketBlast cannot connect to Facebook";
                     }
                     else
                         return ;
                 }
                 else
                 {
                    errorMessage = @"TicketBlast cannot post on Facebook. Please ensure TicketBlast has access to your account in device Settings"; 
                 }
                [self performSelectorOnMainThread:@selector(showErrorMessage:) withObject:errorMessage waitUntilDone:NO];
			 }
			 
		 }];
    }
    else if(buttonIndex == 1)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
           SLComposeViewController *twitterComposer = [[SLComposeViewController alloc]init];
            twitterComposer = [SLComposeViewController
                                composeViewControllerForServiceType:SLServiceTypeTwitter];
            [twitterComposer setInitialText:[NSString stringWithFormat:@"\n%@",permanentText]];
			if (self.doc.photo)
			{
				 [twitterComposer addImage:self.doc.photo];
			}
			
			[twitterComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
				
				switch (result) {
					case SLComposeViewControllerResultCancelled:
						
						break;
					case SLComposeViewControllerResultDone:
						{
							UIAlertView *postSuccessfull = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Tweet Successful" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
							[postSuccessfull show];
						}
						break;
						
					default:
						break;
				}
				
				dispatch_async(dispatch_get_main_queue(), ^{
					
					[self dismissViewControllerAnimated:YES completion:^{
					}];					
				});
				
			}];
			
            [self presentViewController:twitterComposer animated:YES completion:^{
				for (UIView *viewLayer1 in twitterComposer.view.subviews) {
					if ([viewLayer1 isKindOfClass:[UIView class]]) {
						for (UIView *viewLayer2 in viewLayer1.subviews) {
							if ([viewLayer2 isKindOfClass:[UIView class]]) {
								for (UIView *viewLayer3 in viewLayer2.subviews) {
									if ([viewLayer3 isKindOfClass:[UITextView class]]) {
										sharingTextView = (UITextView *)viewLayer3;
										sharingTextView.selectedRange = NSMakeRange(0, 0);
									}
								}
							}
						}
					}
				}
			}];
        }
		else
		{
			UIAlertView *twitterAccountAlert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please configure your Twitter account in Device Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[twitterAccountAlert show];
		}
    }
}

-(void)showErrorMessage:(NSString *)errorMessage
{
    UIAlertView *facebookAccountAlert = [[UIAlertView alloc]initWithTitle:@"TicketBlast" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [facebookAccountAlert show];
}


-(void)showFBComposer
{
		REComposeViewController *facebookComposeViewController = [[REComposeViewController alloc] init];
		facebookComposeViewController.title = @"Facebook";
		
		if (self.doc.photo)
		{
			facebookComposeViewController.hasAttachment = YES;
			facebookComposeViewController.attachmentImage = self.doc.photo;
		}
		
		facebookComposeViewController.delegate = self;
		facebookComposeViewController.text = @"";
		[facebookComposeViewController presentFromViewController:self.navigationController];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _facebookAlertView) {
        if (buttonIndex == 0)
        {
            GBSettingsViewController *settingsViewController = [[GBSettingsViewController alloc]init];
			[self.navigationController pushViewController:settingsViewController animated:YES];
        }
    }
}


#pragma mark -
#pragma mark REComposeViewControllerDelegate

- (void)composeViewController:(REComposeViewController *)composeViewController didFinishWithResult:(REComposeResult)result
{
    
    if (result == REComposeResultCancelled) {
        NSLog(@"Cancelled");
    }
    
    if (result == REComposeResultPosted) {
        NSLog(@"Text: %@", composeViewController.text);
        
        [self performSelectorOnMainThread:@selector(showProgressSpinner) withObject:nil waitUntilDone:YES];
        
		NSDictionary *dictToPost = @{kFacebookMessage:composeViewController.text , kFacebookImageData:UIImagePNGRepresentation(composeViewController.attachmentImage)};
		
	   [self performSelectorOnMainThread:@selector(postMessage:) withObject:dictToPost waitUntilDone:NO];
				
    }
    
    [composeViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showProgressSpinner
{
    self.view.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    mProgressSpinner.center = self.view.center;
    [mProgressSpinner startAnimating];
}

#pragma mark Facebook Post

- (void)postMessage:(NSDictionary *)postDict
{
    NSDictionary *parameters = @{kFacebookMessage: [postDict objectForKey:kFacebookMessage]};
    
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
    
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodPOST
                              URL:feedURL
                              parameters:parameters];
    
    [feedRequest addMultipartData: [postDict objectForKey:kFacebookImageData]
                         withName:@"source"
                             type:@"multipart/form-data"
                         filename:@"TestImage"];
    
    feedRequest.account = facebookAccount;
    
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         NSLog(@"responseData %@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
         NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         if ((!error) && ([responseString rangeOfString:@"error"].location == NSNotFound))
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"TicketBlast" message:@"Successfully shared on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [successAlert show];
                 [mProgressSpinner stopAnimating];
                 self.view.userInteractionEnabled = YES;
                 self.navigationItem.leftBarButtonItem.enabled = YES;
                 self.navigationItem.rightBarButtonItem.enabled = YES;
             });
             
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *failureAlert = [[UIAlertView alloc]initWithTitle:@"TicketBlast" message:@"Error while posting message on Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [failureAlert show];
                 [mProgressSpinner stopAnimating];
                 self.view.userInteractionEnabled = YES;
                 self.navigationItem.leftBarButtonItem.enabled = YES;
                 self.navigationItem.rightBarButtonItem.enabled = YES;
             });
         }
     }];
}

#pragma mark Full-Screen Ticket-View

//Full Screen Image and Title for Navigation Accordingly
-(void)ticketTapped
{
	if (self.doc.photo)
	{
		GBTicketFullScreenViewController *fullScreenView = [[GBTicketFullScreenViewController alloc]init];
		fullScreenView.ticketImage = _ticketImageView.image;
		
		//Text Based On Event Type
		if ([self.doc.ticketdata.eventType isEqualToString:kEventTypeConcert])
		{
			fullScreenView.navTitle = self.doc.ticketdata.headLine;
		}
		else if([self.doc.ticketdata.eventType isEqualToString:kEventTypeGame])
		{
			fullScreenView.navTitle = [NSString stringWithFormat:@"%@ vs %@",self.doc.ticketdata.homeTeam,self.doc.ticketdata.opponentTeam];
		}
		else
		{
			fullScreenView.navTitle = self.doc.ticketdata.eventName;
		}
		
		[self.navigationController pushViewController:fullScreenView animated:YES];
	}
}

#pragma mark Internet Check

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
            statusString = @"Network Not Available";
			//Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
			UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle:@"Alert" message:statusString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
			[noInternetAlert show];
            break;
        }
            
        case ReachableViaWWAN:
        {
			UIActionSheet *shareActionSheet = [[UIActionSheet alloc]initWithTitle:@"Share Via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter", nil];
            [shareActionSheet showInView:_scrollView];
            break;
        }
        case ReachableViaWiFi:
        {
			UIActionSheet *shareActionSheet = [[UIActionSheet alloc]initWithTitle:@"Share Via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter", nil];
            [shareActionSheet showInView:_scrollView];
            break;
		}
    }
}

#pragma mark Dealloc

-(void)dealloc
{
	_ticketImageView = nil;
	_facebookAlertView = nil;
	_headLabel = nil;
	_dateLabel = nil;
	_ticketImageView = nil;
	_extraInfoLabel = nil;
	_extraInfoImageView = nil;
	_venueImageView = nil;
	_venueLabel = nil;
	_shareButton = nil;
	mProgressSpinner = nil;
	_backView = nil;
	_editView = nil;
	_scrollView = nil;
	_notesTextView = nil;
}

@end
