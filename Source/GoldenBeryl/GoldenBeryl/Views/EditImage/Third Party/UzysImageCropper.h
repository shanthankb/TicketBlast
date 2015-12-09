//
//  UzysImageCropper.h
//  UzysImageCropper
//
//  Created by Uzys on 11. 12. 13..
//

#import <UIKit/UIKit.h>
#import "ARCHelper.h"

@interface UzysImageCropper : UIView <UIGestureRecognizerDelegate>
{
    double _imageScale; //frame : image
    double _translateX;
    double _translateY;
    
    CGRect _imgViewframeInitValue; //imgView
    CGPoint _imgViewcenterInitValue;
    CGSize _realCropsize;
    UIView* _cropperView;
	UIImageView              *_overlayImageView;
}
@property (nonatomic,strong) UIImage *inputImage;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,assign) CGRect cropRect;

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize withType:(NSString *)type;
- (UIImage*) getCroppedImage;
- (BOOL) saveCroppedImage:(NSString *)path;

- (void) actionRotate;
- (void) actionRestore;
@end
