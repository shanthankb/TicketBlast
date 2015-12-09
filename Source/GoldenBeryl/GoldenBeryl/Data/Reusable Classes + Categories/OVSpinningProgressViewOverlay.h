//
//  OVSpinningProgressViewOverlay.h
//  CitrineEx
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OVSpinningProgressViewOverlay : UIView {
	UIActivityIndicatorView *mSpinningProgressView;
	UIColor *mProgressBGColor;
	UIImageView	*mProgressBGImageView;
	BOOL mHidesWhenStopped;
}

- (id)initWithFrameOfEnclosingView:(CGRect)enclosingViewFrame;
- (id)initWithFrame:(CGRect)viewFrame;
- (void)setFrame:(CGRect)newFrame;

//Defaults to black with 0.8 alpha
- (void)setProgressBGColor:(UIColor *)bgColor;
//Defaults to UIActivityIndicatorViewStyleWhiteLarge
- (void)setProgressViewStyle:(UIActivityIndicatorViewStyle)progressViewStyle;
//Defaults to nil
- (void)setProgressBGImage:(UIImage *)progressBGImage;
- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped;
- (void)startAnimating;
- (BOOL)isAnimating;
- (void)stopAnimating;

@end
