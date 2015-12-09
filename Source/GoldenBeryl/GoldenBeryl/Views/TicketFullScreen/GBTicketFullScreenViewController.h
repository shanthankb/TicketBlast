//
//  GBTicketFullScreenViewController.h
//  GoldenBeryl
//
//  Created by Mohammed Shahid on 17/05/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBTicketFullScreenViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIImage *ticketImage;

@property (nonatomic,strong) NSString *navTitle;

@end
