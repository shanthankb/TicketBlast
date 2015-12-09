//
//  UIButton+OVConvenienceMethods.m
//  DemoApp
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "UIButton+OVConvenienceMethods.h"
#import "NSObject+OVConvenienceMethods.h"

#define kIsButtonSelected @"isButtonSelected"


@implementation UIButton (OVConvenienceMethods)

- (void)setForAllStatesBackgroundImagesStartingWithName:(NSString *)bgImageName {
	
	[self setForAllStatesBackgroundImagesStartingWithName:bgImageName allowStretching:NO];
}

- (void)setForAllStatesBackgroundImagesStartingWithName:(NSString *)bgImageName allowStretching:(BOOL)mustAllowStretching {
	
	UIImage *btnNormalImage = [UIImage imageNamed:[bgImageName stringByAppendingString:@"_normal"]];
	
	if(mustAllowStretching)
	{
		btnNormalImage = [btnNormalImage stretchableImageWithLeftCapWidth:(btnNormalImage.size.width / 2.0) topCapHeight:0.0];
	}
	
    
	UIImage *btnPressedImage = [UIImage imageNamed:[bgImageName stringByAppendingString:@"_pressed"]];
	
	if(mustAllowStretching)
	{
		btnPressedImage = [btnPressedImage stretchableImageWithLeftCapWidth:(btnPressedImage.size.width / 2.0) topCapHeight:0.0];
	}
    
    
    UIImage *btnSelectedImage = [UIImage imageNamed:[bgImageName stringByAppendingString:@"_selected"]];
    
    if(btnSelectedImage)
    {
        if(mustAllowStretching)
        {
            btnSelectedImage = [btnSelectedImage stretchableImageWithLeftCapWidth:(btnSelectedImage.size.width / 2.0) topCapHeight:0.0];
        }
    }
    else
    {
        btnSelectedImage = btnPressedImage;
    }
    
    
	UIImage *btnDisabledImage = [UIImage imageNamed:[bgImageName stringByAppendingString:@"_disabled"]];
	
	if(mustAllowStretching)
	{
		btnDisabledImage = [btnDisabledImage stretchableImageWithLeftCapWidth:(btnDisabledImage.size.width / 2.0) topCapHeight:0.0];
	}
	
    
	[self setBackgroundImage:btnNormalImage forState:UIControlStateNormal];
	[self setBackgroundImage:btnPressedImage forState:UIControlStateHighlighted];
	[self setBackgroundImage:btnSelectedImage forState:UIControlStateSelected];		
	[self setBackgroundImage:btnDisabledImage forState:UIControlStateDisabled];
}

- (void)removeBackgroundImagesForAllStates {
	
	[self setBackgroundImage:nil forState:UIControlStateNormal];
	[self setBackgroundImage:nil forState:UIControlStateHighlighted];
	[self setBackgroundImage:nil forState:UIControlStateSelected];		
	[self setBackgroundImage:nil forState:UIControlStateDisabled];
}

- (void)setForAllStatesImagesStartingWithName:(NSString *)buttonImageName {
	
	[self setForAllStatesImagesStartingWithName:buttonImageName allowStretching:NO];
}

- (void)setForAllStatesImagesStartingWithName:(NSString *)buttonImageName allowStretching:(BOOL)mustAllowStretching {
	
	UIImage *btnNormalImage = [UIImage imageNamed:[buttonImageName stringByAppendingString:@"_normal"]];
	
	if(mustAllowStretching)
	{
		btnNormalImage = [btnNormalImage stretchableImageWithLeftCapWidth:(btnNormalImage.size.width / 2.0) topCapHeight:0.0];
	}
	
	UIImage *btnPressedImage = [UIImage imageNamed:[buttonImageName stringByAppendingString:@"_pressed"]];
	
	if(mustAllowStretching)
	{
		btnPressedImage = [btnPressedImage stretchableImageWithLeftCapWidth:(btnPressedImage.size.width / 2.0) topCapHeight:0.0];
	}
	
    UIImage *btnSelectedImage = [UIImage imageNamed:[buttonImageName stringByAppendingString:@"_selected"]];
    
    if(btnSelectedImage)
    {
        if(mustAllowStretching)
        {
            btnSelectedImage = [btnSelectedImage stretchableImageWithLeftCapWidth:(btnSelectedImage.size.width / 2.0) topCapHeight:0.0];
        }
    }
    else
    {
        btnSelectedImage = btnPressedImage;
    }
    
	UIImage *btnDisabledImage = [UIImage imageNamed:[buttonImageName stringByAppendingString:@"_disabled"]];
	
	if(mustAllowStretching)
	{
		btnDisabledImage = [btnDisabledImage stretchableImageWithLeftCapWidth:(btnDisabledImage.size.width / 2.0) topCapHeight:0.0];
	}
	
	[self setImage:btnNormalImage forState:UIControlStateNormal];
	[self setImage:btnPressedImage forState:UIControlStateHighlighted];
	[self setImage:btnSelectedImage forState:UIControlStateSelected];	
	[self setImage:btnDisabledImage forState:UIControlStateDisabled];
}

- (void)removeImagesForAllStates {
	
	[self setImage:nil forState:UIControlStateNormal];
	[self setImage:nil forState:UIControlStateHighlighted];
	[self setImage:nil forState:UIControlStateSelected];	
	[self setImage:nil forState:UIControlStateDisabled];	
}

- (void)toggleHighlightedAndNormalStates {
    
    UIImage *normalImage = [[self imageForState:UIControlStateNormal] retain];
    UIImage *highlightedImage = [[self imageForState:UIControlStateHighlighted] retain];
    
    [self setImage:highlightedImage forState:UIControlStateNormal];
    [self setImage:normalImage forState:UIControlStateHighlighted];
    
    [normalImage release];
    [highlightedImage release];
}

- (void)setButtonSelected:(BOOL)isButtonSelected {
    
    BOOL currentButtonSelectedState = [self boolForIVar:kIsButtonSelected];

    if(currentButtonSelectedState != isButtonSelected)
    {
        [self setBool:isButtonSelected forIVar:kIsButtonSelected];
        [self setSelected:isButtonSelected];
        //[self toggleHighlightedAndNormalStates];
    }
}

@end
