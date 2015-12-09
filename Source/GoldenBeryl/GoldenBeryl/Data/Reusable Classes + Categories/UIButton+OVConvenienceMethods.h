//
//  UIButton+OVConvenienceMethods.h
//  DemoApp
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (OVConvenienceMethods)

- (void)setForAllStatesBackgroundImagesStartingWithName:(NSString *)bgImageName;
- (void)removeBackgroundImagesForAllStates;
- (void)setForAllStatesImagesStartingWithName:(NSString *)buttonImageName;
- (void)removeImagesForAllStates;

- (void)setForAllStatesBackgroundImagesStartingWithName:(NSString *)bgImageName allowStretching:(BOOL)mustAllowStretching;
- (void)setForAllStatesImagesStartingWithName:(NSString *)buttonImageName allowStretching:(BOOL)mustAllowStretching;

- (void)toggleHighlightedAndNormalStates;
- (void)setButtonSelected:(BOOL)isButtonSelected;

@end
