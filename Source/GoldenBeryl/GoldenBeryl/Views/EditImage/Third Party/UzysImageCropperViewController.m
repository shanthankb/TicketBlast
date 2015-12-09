//
//  UzysImageCropperViewController.m
//  UzysImageCropper
//
//  Created by Uzys on 11. 12. 13..
//

#import "UzysImageCropperViewController.h"
#import "UIImage-Extension.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@implementation UzysImageCropperViewController
@synthesize cropperView,delegate;

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize withCamera:(NSString *)isAvailable isEditing:(BOOL)isEdit
{
    self = [super init];
	if (self) {
        
        if (frameSize.height < frameSize.width) {                                                                   //handling landscape orientation.
            frameSize.width = [UIScreen mainScreen].bounds.size.width;
            frameSize.height = [UIScreen mainScreen].bounds.size.height - 44.0 - 20;
        }
		
        if((newImage.size.width/2) <= cropSize.width || (newImage.size.height/2) <= cropSize.height)                //if the image size is smaller than the crop size.
        {
            newImage = [newImage imageByScalingProportionallyToSize:CGSizeMake(cropSize.width*2.6, cropSize.height*2.6)];
        }
        
        if ((newImage.size.width > ([UIScreen mainScreen].bounds.size.width * 10))|| (newImage.size.height >([UIScreen mainScreen].bounds.size.height * 5))) {  //if the image is much larger than the screen.
            newImage = [newImage imageByScalingProportionallyToSize:CGSizeMake(cropSize.width*4, cropSize.height*4)];
        }
        
        [self.view setBackgroundColor:[UIColor clearColor]];
        
		_overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y + 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 110)];
        //imageview holding the image showing the crop rect.
        if([[UIScreen mainScreen] bounds].size.height == 568.0f)
            _overlayImageView.image = [UIImage imageNamed:@"overlay_photo_frame_iP5"];          //for 4 inch display.
        else
            _overlayImageView.image = [UIImage imageNamed:@"overlay_photo_frame"];              //for 3.5 inch display.
		[self.view addSubview:_overlayImageView];
        cropperView = [[UzysImageCropper alloc]
                       initWithImage:newImage
                       andframeSize:frameSize
                       andcropSize:cropSize withType:NO];                                       //initialize the cropper, which actually handles the zoom/rotation/cropping.
        
        [self.view addSubview:cropperView];
        
		[self.view bringSubviewToFront:_overlayImageView];
        
        
		UIImageView *navigationBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65.0)];
		navigationBarImageView.image = [UIImage imageNamed:@"navbar_photoEdit"];
		navigationBarImageView.userInteractionEnabled = YES;
		[self.view addSubview:navigationBarImageView];
		
		UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(267, 24, 46, 30)];
		[saveButton addTarget:self action:@selector(finishCropping) forControlEvents:UIControlEventTouchUpInside];
		saveButton.titleLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:20.0];
        [saveButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:10.0/255.0 alpha:1.0] forState:UIControlStateNormal];
		[saveButton setTitle:@"Save" forState:UIControlStateNormal];
		[navigationBarImageView addSubview:saveButton];
        
        if (!isEdit)                                                                            //creates a set of buttons for the view when it appears immediately after the image is selected.
        {
            
            UIImageView *bottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, 320, 45)];
            
            if(self.view.frame.size.height == 568.0 && [[[UIDevice currentDevice]systemVersion]floatValue]<7.0)
               [bottomBar setFrame:CGRectMake(0, self.view.frame.size.height - 45 - 20, 320, 45)];
            bottomBar.image = [UIImage imageNamed:@"bottom_bar_photoEdit"];
            [self.view addSubview:bottomBar];
            
            _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, bottomBar.frame.origin.y + 10, 66, 30)];
            [_cancelButton addTarget:self action:@selector(cancelCropping) forControlEvents:UIControlEventTouchUpInside];
            _cancelButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:18.0];
            [_cancelButton setTitle:@"Retake" forState:UIControlStateNormal];
            [self.view addSubview:_cancelButton];
            
            UIButton *rotateImageButton = [[UIButton alloc] initWithFrame:CGRectMake(290, bottomBar.frame.origin.y + 10, 18, 23)];
            [rotateImageButton addTarget:self action:@selector(actionRotation:) forControlEvents:UIControlEventTouchUpInside];
            [rotateImageButton setImage:[UIImage imageNamed:@"rotate_icon"] forState:UIControlStateNormal];
            [rotateImageButton setImage:[UIImage imageNamed:@"rotate_icon_pressed"] forState:UIControlStateHighlighted];
            [self.view addSubview:rotateImageButton];
            
            UIButton *useOriginalImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 24, 85, 30)];
            [useOriginalImageButton addTarget:self action:@selector(useOriginalImage) forControlEvents:UIControlEventTouchUpInside];
            useOriginalImageButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:18.0];
            [useOriginalImageButton setTitle:@"Original" forState:UIControlStateNormal];
            [navigationBarImageView addSubview:useOriginalImageButton];
            
            UILabel *addPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 26, 130, 30)];
            addPhotoLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:24.0];
            addPhotoLabel.textColor = [UIColor whiteColor];
            addPhotoLabel.backgroundColor = [UIColor clearColor];
            addPhotoLabel.text = @"Add Photo";
            [navigationBarImageView addSubview:addPhotoLabel];
        }
        else                                                                                //creates a set of buttons for the view when 'Edit Photo' option is selected.
        {
            UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 24, 62, 30)];
            [cancelButton addTarget:self action:@selector(cancelPhotoEditing) forControlEvents:UIControlEventTouchUpInside];
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:18.0];
            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [navigationBarImageView addSubview:cancelButton];
            
            UILabel *editPhotoLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 26, 130, 30)];
            editPhotoLabel.font = [UIFont fontWithName:@"GothamNarrow-Medium" size:24.0];
            editPhotoLabel.textColor = [UIColor whiteColor];
            editPhotoLabel.backgroundColor = [UIColor clearColor];
            editPhotoLabel.text = @"Edit Photo";
            [navigationBarImageView addSubview:editPhotoLabel];
            
            UIButton *rotateImageButton = [[UIButton alloc] init];
            if([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0)
            {
                [rotateImageButton setFrame:CGRectMake(142, self.view.frame.origin.y + self.view.frame.size.height - 44.0 , 18, 23)];
            }
            else
            {
                [rotateImageButton setFrame:CGRectMake(142, self.view.frame.origin.y + self.view.frame.size.height - 44.0 - 10.0 , 18, 23)];
            }
            [rotateImageButton addTarget:self action:@selector(actionRotation:) forControlEvents:UIControlEventTouchUpInside];
            [rotateImageButton setImage:[UIImage imageNamed:@"rotate_icon"] forState:UIControlStateNormal];
            [rotateImageButton setImage:[UIImage imageNamed:@"rotate_icon_pressed"] forState:UIControlStateHighlighted];
//            [rotateImageButton setBackgroundImage:[UIImage imageNamed:@"bottom_bar_photoEdit"] forState:UIControlStateNormal];
            [self.view addSubview:rotateImageButton];
        }
    }
    
    return self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
 
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    [super viewWillDisappear:animated];
}

//changes the text of the cancel button based on the source of the image (Camera/Photo album)
- (void)updateCancelButtonTitleForSourceType:(NSInteger)sourceTyoe
{
    
    NSString *cancelButtonTitle;
    
    if (!(sourceTyoe == 1)) {
        cancelButtonTitle = @"Gallery";
    }
    else
        cancelButtonTitle = @"Retake";
    
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];

}

//method returns the originally selected image back to the view controller which presented the cropper.
- (void)useOriginalImage
{
    [delegate imageCropper:self didFinishCroppingWithImage:cropperView.inputImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//method which resets the view to its original zoom scale and rotation.
-(void) actionRestore
{
    [cropperView actionRestore];
}

//method which handles rotation.
-(void) actionRotation:(id) senders
{
	[cropperView actionRotate];
}

- (void)cancelCropping
{
	[delegate imageCropperDidCancel:self];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelPhotoEditing
{
    [delegate imageCropperDidCancel:self];
	[self dismissViewControllerAnimated:YES completion:nil];
}

//method which is called on tap of the 'Use' button. Sends a cropped image to the presenting view controller.
- (void)finishCropping
{
    UIImage *cropped =[cropperView getCroppedImage];
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.cropperView = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotate
{
	return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [cropperView release];
    [super ah_dealloc];
}
@end
