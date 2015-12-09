//
//  UIImage+Resize.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 23/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

@end
