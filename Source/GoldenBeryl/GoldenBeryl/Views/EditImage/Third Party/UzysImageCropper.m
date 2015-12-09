//
//  UzysImageCropper.m
//  UzysImageCropper
//
//  Created by Uzys on 11. 12. 13..
//

#define MAX_ZOOMSCALE 2
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kCropRect (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f) ? CGRectMake(10, 199, 300, 200) : CGRectMake(10, 155, 300, 200)

//#define CROPPERVIEW_IMG

#import "UzysImageCropper.h"
#import "UIImage-Extension.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <QuartzCore/QuartzCore.h>
@interface UzysImageCropper()
- (void)setupGestureRecognizer;
- (void)zoomAction:(UIGestureRecognizer *)sender;
- (void)panAction:(UIPanGestureRecognizer *)gesture;
- (void)RotationAction:(UIGestureRecognizer *)sender;
- (void)DoubleTapAction:(UIGestureRecognizer *)sender;
@end

@implementation UzysImageCropper
@synthesize imgView = _imgView,inputImage=_inputImage,cropRect=_cropRect;

#pragma mark - initialize
- (id)init
{
    self = [super init];
    if (self)
    {
        NSAssert(TRUE,@"Plz initialize using initWithImage:andframeSize:andcropSize: ");
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        NSAssert(TRUE,@"Plz initialize using initWithImage:andframeSize:andcropSize: ");
    }
    return self;
}

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize withType:(NSString *)type
{
    self = [super init];
    if(self)
    {
        //Variable for GestureRecognizer
        _translateX =0;
        _translateY =0;
        
        self.frame = CGRectMake(0, 0, frameSize.width, frameSize.height);
        self.inputImage = newImage;
        
        _imageScale = 310/cropSize.width ;
                
        _imageScale = 0.5;
        
        CGRect imgViewBound = CGRectMake(0, 0, _inputImage.size.width*_imageScale, _inputImage.size.height*_imageScale); 
        _imgView = [[UIImageView alloc] initWithFrame:imgViewBound];
        _imgView.center = self.center;
        _imgView.image = _inputImage;
        _imgView.backgroundColor = [UIColor whiteColor];
        
        _imgViewframeInitValue = _imgView.frame;
        _imgViewcenterInitValue = _imgView.center;
        _realCropsize = cropSize; // _realCropsize = Cropping Size in RealImage
        
        _cropRect = kCropRect;
		
        _cropperView = [[UIView alloc] initWithFrame:_cropRect];
        _cropperView.backgroundColor = [UIColor clearColor];
        _cropperView.alpha = 0.5;
        
        UIImageView *cropimg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cropperview.png"]] autorelease];
        cropimg.center = _cropperView.center;
        cropimg.alpha = 0.7;
        
#ifdef CROPPERVIEW_IMG
        _cropperView.hidden = YES;
#else
        cropimg.hidden = YES;
#endif
        
        [self addSubview:_imgView];
        [self addSubview:cropimg];
        [self addSubview:_cropperView];
        [self setupGestureRecognizer];
        self.clipsToBounds = YES;
		
		//Zoom Out Force
		CGRect imgViewFrame = _imgView.frame;
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
		
		CGFloat lastScale=1;
		CGFloat factor = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue]/2;
        CGFloat currentScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        // CGFloat currentScale = self.imgView.transform.a;
        const CGFloat kMaxScale = 2.0;
        CGFloat newScale = 1 -  (lastScale - factor); // new scale is in the range (0-1)
        newScale = MIN(newScale, kMaxScale / currentScale);
        
        // imgViewFrame
        imgViewFrame.size.width = imgViewFrame.size.width * newScale;
        imgViewFrame.size.height = imgViewFrame.size.height * newScale;
        imgViewFrame.origin.x = self.imgView.center.x - imgViewFrame.size.width/2;
        imgViewFrame.origin.y = self.imgView.center.y - imgViewFrame.size.height/2;
        
        imgViewMaxX= CGRectGetMaxX(imgViewFrame);
        imgViewMaxY= CGRectGetMaxY(imgViewFrame);
        
        NSInteger collideState = 0;
        
        if(imgViewFrame.origin.x >= minX) //left
        {
            collideState = 1;
        }
        else if(imgViewFrame.origin.y >= minY) // up
        {
            collideState = 2;
        }
        else if(imgViewMaxX <= maxX) //right
        {
            collideState = 3;
        }
        else if(imgViewMaxY <= maxY) //down
        {
            collideState = 4;
        }
        
		
        if(collideState >0)
        {
            
            if(lastScale - factor <= 0)
            {
                lastScale = factor;
                CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
                self.imgView.transform = transformN;
            }
            else
            {
                lastScale = factor;
                
                CGPoint newcenter = _imgView.center;
                
                if(collideState ==1 || collideState ==3)
                {
                    newcenter.x = _cropperView.center.x;
                }
                else if(collideState ==2 || collideState ==4)
                {
                    newcenter.y = _cropperView.center.y;
                }
                
                [UIView animateWithDuration:0.5f animations:^(void) {
                    
                    self.imgView.center = newcenter;
                    
                } ];
                
            }
            
        }
        else
        {
            CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
            self.imgView.transform = transformN;
            lastScale = factor;
        }

		
		
		
    }
    return self;
}


#pragma mark - UIGestureAction
- (void)zoomAction:(UIGestureRecognizer *)sender
{
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    static CGFloat lastScale=1;
    
    if([sender state] == UIGestureRecognizerStateBegan)
    {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale =1;
    }
    if ([sender state] == UIGestureRecognizerStateChanged
        || [sender state] == UIGestureRecognizerStateEnded)
    {
        CGRect imgViewFrame = _imgView.frame;
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
        CGFloat currentScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        // CGFloat currentScale = self.imgView.transform.a;
        const CGFloat kMaxScale = 2.0;
        CGFloat newScale = 1 -  (lastScale - factor); // new scale is in the range (0-1)
        newScale = MIN(newScale, kMaxScale / currentScale);
        
        // imgViewFrame
        imgViewFrame.size.width = imgViewFrame.size.width * newScale;
        imgViewFrame.size.height = imgViewFrame.size.height * newScale;
        imgViewFrame.origin.x = self.imgView.center.x - imgViewFrame.size.width/2;
        imgViewFrame.origin.y = self.imgView.center.y - imgViewFrame.size.height/2;
        
        imgViewMaxX= CGRectGetMaxX(imgViewFrame);
        imgViewMaxY= CGRectGetMaxY(imgViewFrame);
        
        NSInteger collideState = 0;
        
        if(imgViewFrame.origin.x >= minX) //left
        {
            collideState = 1;
        }
        else if(imgViewFrame.origin.y >= minY) // up
        {
            collideState = 2;
        }
        else if(imgViewMaxX <= maxX) //right
        {
            collideState = 3;
        }
        else if(imgViewMaxY <= maxY) //down
        {
            collideState = 4;
        }
        
      
        if(collideState >0) 
        {
            
            if(lastScale - factor <= 0) 
            {
                lastScale = factor;
                CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
                self.imgView.transform = transformN;
            }
            else
            {
                lastScale = factor;
                
                CGPoint newcenter = _imgView.center;
                
                if(collideState ==1 || collideState ==3)
                {
                    newcenter.x = _cropperView.center.x;
                }
                else if(collideState ==2 || collideState ==4)
                {
                    newcenter.y = _cropperView.center.y;
                }
                
                [UIView animateWithDuration:0.5f animations:^(void) {
                    
                    self.imgView.center = newcenter;
                    [sender reset];
                    
                } ];
                
            }
            
        }
        else 
        {
            CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
            self.imgView.transform = transformN;
            lastScale = factor;
        }
        
    }
    
}
- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    
    static CGPoint prevLoc;
    CGPoint location = [gesture locationInView:self];
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        prevLoc = location; //Starting position
    }
    
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        
        //calculate offset
        _translateX =  (location.x - prevLoc.x);
        _translateY =  (location.y - prevLoc.y);
        
        CGPoint center = self.imgView.center;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
        center.x =center.x +_translateX;
        center.y = center.y +_translateY;
        
        imgViewMaxX= center.x + _imgView.frame.size.width/2;
        imgViewMaxY= center.y+ _imgView.frame.size.height/2;
        
        if(  (center.x - (_imgView.frame.size.width/2) ) >= minX)
        {
            center.x = minX + (_imgView.frame.size.width/2) ;
        }
        if( center.y - (_imgView.frame.size.height/2) >= minY)
        {
            center.y = minY + (_imgView.frame.size.height/2) ;
        }
        if(imgViewMaxX <= maxX)
        {
            center.x = maxX - (_imgView.frame.size.width/2);
        }
        if(imgViewMaxY <= maxY)
        {
            center.y = maxY - (_imgView.frame.size.height/2);
        }
        
        self.imgView.center = center;
        prevLoc = location;
    }
}
- (void)RotationAction:(UIGestureRecognizer *)sender
{
    UIRotationGestureRecognizer *recognizer = (UIRotationGestureRecognizer *) sender;
    static CGFloat rot=0;
    //float RotationinDegrees = recognizer.rotation * (180/M_PI);
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        rot = recognizer.rotation;
    }
    
    if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, recognizer.rotation - rot);
//        NSLog(@"imgViewFrame : %@",NSStringFromCGRect(self.imgView.frame));
        rot =recognizer.rotation;
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.imgView.frame.size.width < _cropperView.frame.size.width || self.imgView.frame.size.height < _cropperView.frame.size.height)
        {
            double scale = MAX(_cropperView.frame.size.width/self.imgView.frame.size.width,_cropperView.frame.size.height/self.imgView.frame.size.height) + 0.01;
            
            self.imgView.transform = CGAffineTransformScale(self.imgView.transform,scale, scale);
        }
    }
    
}
- (void)DoubleTapAction:(UIGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.2f animations:^(void) {
        
        self.imgView.center = _cropperView.center;
        
    } ];
}


- (void) setupGestureRecognizer
{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)] autorelease];
    [pinchGestureRecognizer setDelegate:self];
    
     UIPanGestureRecognizer *panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)] autorelease];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setDelegate:self];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DoubleTapAction:)] autorelease];
    [doubleTapGestureRecognizer setDelegate:self];
    doubleTapGestureRecognizer.numberOfTapsRequired =2;
        
    [self addGestureRecognizer:pinchGestureRecognizer];
    [self addGestureRecognizer:panGestureRecognizer];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
}

- (UIImage*) getCroppedImage
{
    double zoomScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    double rotationZ = [[self.imgView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    CGPoint cropperViewOrigin = CGPointMake( (_cropperView.frame.origin.x - _imgView.frame.origin.x)  *1/zoomScale ,
                                            ( _cropperView.frame.origin.y - _imgView.frame.origin.y ) * 1/zoomScale
                                            );
    CGSize cropperViewSize = CGSizeMake(_cropperView.frame.size.width * (1/zoomScale) ,_cropperView.frame.size.height * (1/zoomScale));
    
    CGRect CropinView = CGRectMake(cropperViewOrigin.x, cropperViewOrigin.y, cropperViewSize.width  , cropperViewSize.height);
    
    NSLog(@"CropinView : %@",NSStringFromCGRect(CropinView));
    
    CGSize CropinViewSize = CGSizeMake((CropinView.size.width*(1/_imageScale)),(CropinView.size.height*(1/_imageScale)));
    
    
    if((NSInteger)CropinViewSize.width % 2 == 1)
    {
        CropinViewSize.width = ceil(CropinViewSize.width);
    }
    if((NSInteger)CropinViewSize.height % 2 == 1)
    {
        CropinViewSize.height = ceil(CropinViewSize.height);
    }
    
    CGRect CropRectinImage = CGRectMake((NSInteger)(CropinView.origin.x * (1/_imageScale)) ,(NSInteger)( CropinView.origin.y * (1/_imageScale)), (NSInteger)CropinViewSize.width,(NSInteger)CropinViewSize.height);
    
    UIImage *rotInputImage = [_inputImage imageRotatedByRadians:rotationZ];
    CGImageRef tmp = CGImageCreateWithImageInRect([rotInputImage CGImage], CropRectinImage);
    UIImage *newImage = [UIImage imageWithCGImage:tmp scale:self.inputImage.scale orientation:self.inputImage.imageOrientation];
    CGImageRelease(tmp);
    
//    if(newImage.size.width != _realCropsize.width)
//    {
//        newImage = [newImage imageByScalingProportionallyToSize:_realCropsize];
//    }
    
    return newImage;
}
- (BOOL) saveCroppedImage:(NSString *) path
{
    return [UIImagePNGRepresentation([self getCroppedImage]) writeToFile:path atomically:YES];
}
- (void) actionRotate
{
    [UIView animateWithDuration:0.15 animations:^{
        
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform,-M_PI/2);
        
        if(self.imgView.frame.size.width < _cropperView.frame.size.width || self.imgView.frame.size.height < _cropperView.frame.size.height)
        {
            double scale = MAX(_cropperView.frame.size.width/self.imgView.frame.size.width,_cropperView.frame.size.height/self.imgView.frame.size.height) + 0.01;
            
            self.imgView.transform = CGAffineTransformScale(self.imgView.transform,scale, scale);
            
        }
    }];
}

- (void) actionRestore
{
    [UIView animateWithDuration:0.2 animations:^{
        self.imgView.transform = CGAffineTransformIdentity;
        self.imgView.center = _cropperView.center;
    }];
}

- (void)dealloc {
    [_imgView release];
    [_inputImage release];
    [_cropperView release];
    [super ah_dealloc];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
@end
