//
//  GBTicketFullScreenViewController.m
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 17/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBTicketFullScreenViewController.h"


@interface GBTicketFullScreenViewController ()

@property (nonatomic, strong) UIImageView *imageView;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation GBTicketFullScreenViewController
{
	BOOL zoomStatus;
}
@synthesize scrollView = _scrollView;

@synthesize imageView = _imageView;

-(id)init
{
	self = [super init];
	if (self) {
		
	}
	return self;
}

-(void)loadView
{
	UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[view setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth];
	self.view = view;
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = self.navTitle;
	self.view.backgroundColor = [UIColor blackColor];
	self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	[self.scrollView setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	self.scrollView.delegate = self;
	
    self.imageView = [[UIImageView alloc] initWithImage:self.ticketImage];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.ticketImage.size};
	[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.scrollView.contentSize = self.ticketImage.size;
	
	[self.view addSubview:self.scrollView];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];

    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 12, 25)];
    [backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back_pressed"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self resizeNavButtonsOnRotationForOrientation:orientation];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self centerScrollViewContents];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
   
	if (!zoomStatus) {
	
	// Get the location within the image view where we tapped
		CGPoint pointInView = [recognizer locationInView:self.imageView];
		
		// Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
		CGFloat newZoomScale = self.scrollView.zoomScale * 2.0f;
		newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
		
		// Figure out the rect we want to zoom to, then zoom to it
		CGSize scrollViewSize = self.scrollView.bounds.size;
		
		CGFloat w = scrollViewSize.width / newZoomScale;
		CGFloat h = scrollViewSize.height / newZoomScale;
		CGFloat x = pointInView.x - (w / 2.0f);
		CGFloat y = pointInView.y - (h / 2.0f);
		
		CGRect rectToZoomTo = CGRectMake(x, y, w, h);
		
		[self.scrollView zoomToRect:rectToZoomTo animated:YES];
		zoomStatus = YES;
	}
	else
	{
		CGFloat newZoomScale = self.scrollView.zoomScale / 2.0f;
		newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
		[self.scrollView setZoomScale:newZoomScale animated:YES];
		zoomStatus = NO;
	}
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

-(BOOL)shouldAutorotate
{
	return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

-(void)backButtonClicked
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
	self.scrollView = nil;
	self.imageView = nil;
}

@end
