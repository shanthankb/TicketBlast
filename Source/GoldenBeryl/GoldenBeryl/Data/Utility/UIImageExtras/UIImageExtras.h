//
//  UIImageExtras.h
//

#import <Foundation/Foundation.h>


@interface UIImage (Extras)

- (UIImage*)imageByBestFitForSize:(CGSize)targetSize;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
