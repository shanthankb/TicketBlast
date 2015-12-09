//
//  UzysImageCropperViewController.h
//  UzysImageCropper
//
//  Created by Uzys on 11. 12. 13..
//

#import <UIKit/UIKit.h>
#import "UzysImageCropper.h"
#import "ARCHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"

@protocol UzysImageCropperDelegate;
@class  UzysImageCropper;

@interface UzysImageCropperViewController : UIViewController
{
	UIImageView                    *_overlayImageView;
    UIButton                           *_cancelButton;
}

@property (nonatomic,strong) UzysImageCropper *cropperView;
@property (nonatomic, assign) id <UzysImageCropperDelegate> delegate;
@property (nonatomic , assign) CGSize frameSize;

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize withCamera:(NSString *)isAvailable isEditing:(BOOL)isEdit;
- (void)actionRotation:(id) senders;
- (void)updateCancelButtonTitleForSourceType:(NSInteger)sourceTyoe;
@end

@protocol UzysImageCropperDelegate <NSObject>
- (void)imageCropper:(UzysImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(UzysImageCropperViewController *)cropper;

@end
