//
//  GBEditTicketViewController.h
//  TicketBlast
//
//  Created by Mohammed Shahid on 28/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBImagePickerViewController.h"
#import "OVSpinningProgressViewOverlay.h"
#import "UzysImageCropperViewController.h"
#import "GBDocument.h"
#import "GBTicketData.h"

@class GBEditTicketViewController;
@protocol TicketEditStatusDelegate <NSObject>

-(void) editTicketSaved:(BOOL)saveStatus;

@optional
- (void) editTicketDeleted;

@end

@interface GBEditTicketViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate,UzysImageCropperDelegate>

{
    NSInteger                  _sourceType;
    UIImage        *_scaledImageForDisplay;
    BOOL                   _isImageChanged;
	GBImagePickerViewController *imagePicker;
    OVSpinningProgressViewOverlay   *_progressSpinner;
    UITapGestureRecognizer                    *_tapGesture;
    CGRect                                   _keyBoardRect;
    CGFloat                                   _screenWidth;
    BOOL                                  _isKeyboardShown;
    BOOL                                    _isPickerShown;


}

@property (strong, nonatomic) GBDocument * doc;

@property (strong,nonatomic) NSURL *fileURL;

@property (nonatomic ,strong) NSMutableDictionary *ticketDetailsDict;

@property (nonatomic,strong) UITableView *editTicketTable;

@property (nonatomic,strong) UITableView *autocompleteTableView;

@property (nonatomic,strong) NSString *ticketId;

@property (nonatomic, weak) id <TicketEditStatusDelegate> delegate;

@property (nonatomic,strong) UIImage  *selectedImage;

@end
