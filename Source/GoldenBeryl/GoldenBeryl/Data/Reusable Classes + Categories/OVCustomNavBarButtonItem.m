//
//  OVCustomNavBarButtonItem.m
//  FlexibleWidth
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import "OVCustomNavBarButtonItem.h"
#import "UIButton+OVConvenienceMethods.h"

#define kNavigationButtonHeight 31
#define kNavigationLandscapeButtonHeight 32
#define kNavigationButtonTitleInset 8
#define kDefaultButtonTitleInset 7

@implementation OVCustomNavBarButtonItem

- (id)initCustomNavBarButtonItemOfType:(eCustomNavBarButtonItemType)buttonItemType {
	
	NSString *buttonBGImageBaseName = nil;
	UIEdgeInsets titleEdgeInsets;
	
	switch (buttonItemType) 
	{
		case eCustomNavBarRegularButtonItemType:
			buttonBGImageBaseName = @"button";
			titleEdgeInsets = UIEdgeInsetsMake(0.0, kDefaultButtonTitleInset, 0.0, kDefaultButtonTitleInset);
			break;
			
		case eCustomNavBarBackButtonItemType:
			buttonBGImageBaseName = @"navbar_button_back";
			titleEdgeInsets = UIEdgeInsetsMake(0.0, kNavigationButtonTitleInset+kDefaultButtonTitleInset, 0.0, kDefaultButtonTitleInset);			
			break;
            
            
        case eCustomNavBarSaveButtonItemType:
            buttonBGImageBaseName = @"button_action";
			titleEdgeInsets = UIEdgeInsetsMake(0.0, kDefaultButtonTitleInset, 0.0, kDefaultButtonTitleInset);
			break;
			
		case eCustomNavBarForwardButtonItemType:
			buttonBGImageBaseName = @"btn_white_nav_fwd_arrow";
			titleEdgeInsets = UIEdgeInsetsMake(0.0, kDefaultButtonTitleInset, 0.0, kNavigationButtonTitleInset+kDefaultButtonTitleInset);			
			break;
			
		default:
			break;
	}
	
	mDefaultButtonBackgroundImageBaseName = [buttonBGImageBaseName copy];
	
	OVFlexibleWidthButton *navButton = [[OVFlexibleWidthButton alloc] initFlexibleWidthButtonWithFrame:CGRectMake(0.0, 0.0, 10.0, kNavigationButtonHeight)];
	
	[navButton setBackgroundImage:[UIImage imageNamed:buttonBGImageBaseName] forState:UIControlStateNormal];
    [navButton setBackgroundImage:[UIImage imageNamed:buttonBGImageBaseName] forState:UIControlStateDisabled];
	
	[navButton setTitleEdgeInsets:titleEdgeInsets];
	[[navButton titleLabel] setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:12.0]];
	[navButton setTitleColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1] forState:UIControlStateNormal];
    [navButton setTitleColor:[UIColor colorWithWhite:0.45 alpha:1.0] forState:UIControlStateDisabled];
    
    if (buttonItemType == eCustomNavBarSaveButtonItemType)
    {
//        [navButton setTitleShadowColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateNormal];
//        [navButton setTitleShadowColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateHighlighted];
//        [navButton setTitleShadowColor:[UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1] forState:UIControlStateDisabled];
        [navButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    else
    {
//        [navButton setTitleShadowColor:[UIColor colorWithRed:157/255.0 green:102/255.0 blue:15/255.0 alpha:1] forState:UIControlStateNormal];
//        [navButton setTitleShadowColor:[UIColor colorWithRed:157/255.0 green:102/255.0 blue:15/255.0 alpha:1] forState:UIControlStateHighlighted];
//        [navButton setTitleShadowColor:[UIColor colorWithRed:157/255.0 green:102/255.0 blue:15/255.0 alpha:1] forState:UIControlStateDisabled];
         [navButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
//	[[navButton titleLabel] setShadowOffset:CGSizeMake(0.0, 1.0)];
	
	self = [super initWithCustomView:navButton];
	[navButton release];
	
	return self;
}

- (void)setButtonForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    OVFlexibleWidthButton *backButton = (OVFlexibleWidthButton *)self.customView;
       
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        [[backButton titleLabel] setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:10.0]];
        backButton.frame = CGRectMake(0.0, 0.0, backButton.frame.size.width, kNavigationLandscapeButtonHeight);
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [[backButton titleLabel] setFont:[UIFont fontWithName:@"ProximaNova-Bold" size:12.0]];
        backButton.frame = CGRectMake(0.0, 0.0, backButton.frame.size.width, kNavigationButtonHeight);
    }
    self.customView = backButton;
}


- (OVFlexibleWidthButton *)embeddedButton {
	
	return (OVFlexibleWidthButton *)[self customView];
}

- (NSString *)defaultButtonBackgroundImageBaseName {
	
	return mDefaultButtonBackgroundImageBaseName;
}

- (void)dealloc {
	
	[mDefaultButtonBackgroundImageBaseName release];
	[super dealloc];
}

@end
