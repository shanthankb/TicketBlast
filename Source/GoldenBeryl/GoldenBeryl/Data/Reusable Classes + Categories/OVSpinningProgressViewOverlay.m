//
//  OVSpinningProgressViewOverlay.m
//  CitrineEx
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "OVSpinningProgressViewOverlay.h"
#import <QuartzCore/QuartzCore.h>

@implementation OVSpinningProgressViewOverlay

- (id)initWithFrameOfEnclosingView:(CGRect)enclosingViewFrame {
    
    CGRect spinnerFrame;
    
    spinnerFrame.size.width = fmaxf(100.0,enclosingViewFrame.size.width / 3);
    spinnerFrame.size.height = fmaxf(100.0,enclosingViewFrame.size.height / 3);
    
    float commonSize = fminf(spinnerFrame.size.width, spinnerFrame.size.height);
    spinnerFrame.size.width = commonSize;
    spinnerFrame.size.height = commonSize;
    
    spinnerFrame.origin.x = (enclosingViewFrame.size.width - spinnerFrame.size.width)/2.0;
    spinnerFrame.origin.y = (enclosingViewFrame.size.height - spinnerFrame.size.height)/ 2.0;
    
    return [self initWithFrame:spinnerFrame];
}

- (id)initWithFrame:(CGRect)viewFrame {
    if ((self = [super initWithFrame:viewFrame])) {
		mSpinningProgressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		
		float maxSpinnerWidth = mSpinningProgressView.bounds.size.width;
		float spinnerWidth = viewFrame.size.width/3.0;
		if(spinnerWidth>maxSpinnerWidth)
			spinnerWidth = maxSpinnerWidth;
		float spinnerHeight = spinnerWidth;
		
		[mSpinningProgressView setFrame:CGRectMake((viewFrame.size.width-spinnerWidth)/2.0, (viewFrame.size.height-spinnerHeight)/2.0, spinnerWidth, spinnerHeight)];
		[mSpinningProgressView setHidesWhenStopped:NO];
		[mSpinningProgressView stopAnimating];
		[self addSubview:mSpinningProgressView];
	
		mProgressBGImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[mProgressBGImageView setBackgroundColor:[UIColor clearColor]];
		[mProgressBGImageView setContentMode:UIViewContentModeScaleToFill];
		[self addSubview:mProgressBGImageView];
		[self sendSubviewToBack:mProgressBGImageView];
		
		mProgressBGColor = [[[UIColor blackColor] colorWithAlphaComponent:0.6] retain];
		
		mHidesWhenStopped = YES;
		[self setHidden:YES];
        [self.layer setCornerRadius:7.0];
		
		[self setProgressBGImage:nil];
        [self setProgressViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)setFrame:(CGRect)newFrame {
	[super setFrame:newFrame];
	
	float maxSpinnerWidth = mSpinningProgressView.bounds.size.width;
	float spinnerWidth = newFrame.size.width/3.0;
	if(spinnerWidth>maxSpinnerWidth)
		spinnerWidth = maxSpinnerWidth;
	float spinnerHeight = spinnerWidth;
	[mSpinningProgressView setFrame:CGRectMake((newFrame.size.width-spinnerWidth)/2.0, (newFrame.size.height-spinnerHeight)/2.0, spinnerWidth, spinnerHeight)];
	[mProgressBGImageView setFrame:self.bounds];
}

- (void)setProgressBGColor:(UIColor *)bgColor {
	[mProgressBGColor release];
	mProgressBGColor = [bgColor retain];
	
	[self setBackgroundColor:mProgressBGColor];
}

- (void)setProgressViewStyle:(UIActivityIndicatorViewStyle)progressViewStyle {
	[mSpinningProgressView setActivityIndicatorViewStyle:progressViewStyle];
}

- (void)setProgressBGImage:(UIImage *)progressBGImage {
	if(progressBGImage!=nil)
	{
		[mProgressBGImageView setImage:progressBGImage];
		[mProgressBGImageView setHidden:NO];
		[mSpinningProgressView setBackgroundColor:[UIColor clearColor]];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	else
	{
		[mProgressBGImageView setImage:nil];
		[mProgressBGImageView setHidden:YES];
		[self setBackgroundColor:mProgressBGColor];
	}	
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
	mHidesWhenStopped = hidesWhenStopped;
}

- (void)startAnimating {
	[self setHidden:NO];
	[mSpinningProgressView startAnimating];
}

- (BOOL)isAnimating {
	return [mSpinningProgressView isAnimating];
}

- (void)stopAnimating {
	if(mHidesWhenStopped==YES)
		[self setHidden:YES];
	[mSpinningProgressView stopAnimating];	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[mProgressBGColor release];
	[mProgressBGImageView removeFromSuperview];
	[mProgressBGImageView release];
	[mSpinningProgressView stopAnimating];
	[mSpinningProgressView removeFromSuperview];
	[mSpinningProgressView release];
	
    [super dealloc];
}


@end
