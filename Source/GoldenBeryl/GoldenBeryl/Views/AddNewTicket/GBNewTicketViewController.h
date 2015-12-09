//
//  GBNewTicketViewController.h
//
//  Created by Abhiman Puranik on 18/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GBEventTypeSelectionViewController.h"
#import "GBImagePickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UzysImageCropperViewController.h"
#import "OVSpinningProgressViewOverlay.h"
#import "GBDocument.h"
#import "GBTicketData.h"
#import "UIImage+Resize.h"


@class GBNewTicketViewController;
@protocol TicketStatusDelegate <NSObject>

-(void) newTickedSaved:(GBNewTicketViewController *)newTicketViewController;

@end

@interface GBNewTicketViewController : UIViewController <UIImagePickerControllerDelegate , UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate , UITextViewDelegate , UIActionSheetDelegate , UIGestureRecognizerDelegate , UINavigationControllerDelegate , UIAlertViewDelegate ,UzysImageCropperDelegate>
{
    BOOL                                    _isPickerShown;
    BOOL                               _isImagePickerShown;
    BOOL                                _didUseImagePicker;
    BOOL                                  _isKeyboardShown;
    UIDatePicker                              *_datePicker;
    CGFloat                                   _screenWidth;
    UITapGestureRecognizer                    *_tapGesture;
    CGRect                                   _keyBoardRect;
    NSString                              *_previousString;
    UITableView                    *_createTicketTableView;
    UITableView                    *_autocompleteTableView;
    id                                  _activeTextElement;
    NSInteger                                  _sourceType;
    UILabel                                *_addImageLabel;
    CGSize                              _standardImageSize;
    UITextField                    *_autoCompleteTextField;
    NSMutableArray                              *_pastUrls;
    UIAlertView                          *_saveTicketAlert;
    NSString                           *_initialTicketDate;
    UIImage                                *_originalImage;
    UIImage                        *_scaledImageForDisplay;
	GBImagePickerViewController               *imagePicker;
    OVSpinningProgressViewOverlay        *_progressSpinner;
    UIBarButtonItem                        *_doneBarButton;
	NSURL                                     *_iCloudRoot;
	NSURL                                      *_localRoot;
}
@property (nonatomic , strong) GBDocument * doc;

@property (nonatomic , strong) NSMutableDictionary *ticketDetails;
@property (nonatomic , strong) NSMutableArray *autocompleteUrls;
@property (nonatomic , strong) NSMutableArray *displayFields;
@property (nonatomic , strong) NSMutableArray *allFields;
@property (nonatomic , assign) NSInteger numberOfTickets;
@property (nonatomic , weak) id <TicketStatusDelegate> delegate;
@property (nonatomic , assign) BOOL shouldClearFields;
@property (nonatomic , strong) UIImage *selectedImage;

@end
