//
//  OVFlexibleWidthButton.h
//  FlexibleWidth
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>

//Flexible width buttons stretch the background image according to the size of the foreground image or text
//setBackgroundImage:forState: must be called to use flexible width buttons properly
//The normal setTitle:forState: and setImage:forState: methods can be called, and the button will be

//This subclass respects the titleEdgeInset and imageEdgeInset properties of UIButton

@interface OVFlexibleWidthButton : UIButton {
	
	float  mLeftCap;
	float mMinWidth;
	float mMaxWidth;
}

- (id)initFlexibleWidthButtonWithFrame:(CGRect)frame;

//The following properties are set internally, but these setters can be used
//for finer control
- (void)setLeftCap:(float)leftCap;
- (void)setMaxWidth:(float)maxWidth;

@end
