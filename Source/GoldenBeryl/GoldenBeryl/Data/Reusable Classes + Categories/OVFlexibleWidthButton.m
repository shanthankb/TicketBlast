//
//  OVFlexibleWidthButton.m
//  FlexibleWidth
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "OVFlexibleWidthButton.h"


@implementation OVFlexibleWidthButton

- (id)initFlexibleWidthButtonWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	
	mLeftCap = 0.0;
	mMinWidth = 0.0;
	mMaxWidth = 0.0;
	
	return self;	
}

- (void)setLeftCap:(float)leftCap {
	
	mLeftCap = leftCap;
}

- (void)setMaxWidth:(float)maxWidth {
	
	mMaxWidth = maxWidth;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
	
	mLeftCap = image.size.width / 2.0;
	UIImage *stretchableImage = [image stretchableImageWithLeftCapWidth:mLeftCap topCapHeight:0.0];
	mMinWidth = stretchableImage.size.width;

	CGRect buttonFrame = self.frame;

	if(buttonFrame.size.width < mMinWidth)
	{
		buttonFrame.size.width = mMinWidth;
		[self setFrame:buttonFrame];
	}
	
	[super setBackgroundImage:stretchableImage forState:state];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	
	[super setTitle:title forState:state];
	
	CGSize titleSize = [title sizeWithFont:(self.titleLabel.font)];
	UIEdgeInsets titleEdgeInset = [self titleEdgeInsets];
	float titleTotalHorizontalInset = titleEdgeInset.left + titleEdgeInset.right;
	CGRect buttonFrame = self.frame;
	buttonFrame.size.width = titleSize.width + titleTotalHorizontalInset;
	
	if(buttonFrame.size.width > mMinWidth && (mMaxWidth == 0.0 || (mMaxWidth > 0.0 && buttonFrame.size.width < mMaxWidth)))
		[self setFrame:buttonFrame];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {

	[super setImage:image forState:state];
	
	CGRect buttonFrame = self.frame;
	UIEdgeInsets imageEdgeInset = [self imageEdgeInsets];
	float imageTotalHorizontalInset = imageEdgeInset.left + imageEdgeInset.right;
	buttonFrame.size.width = image.size.width + imageTotalHorizontalInset;
	
	if(buttonFrame.size.width > mMinWidth && (mMaxWidth == 0.0 || (mMaxWidth > 0.0 && buttonFrame.size.width < mMaxWidth)))
		[self setFrame:buttonFrame];
}

- (void)dealloc {
	
	[super dealloc];
}

@end
