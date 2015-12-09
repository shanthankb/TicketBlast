//
//  GBImagePickerViewController.m
//
//  Created by Abhiman Puranik on 01/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBImagePickerViewController.h"

@interface GBImagePickerViewController ()

@end

@implementation GBImagePickerViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationBar.backgroundColor = [UIColor blackColor];
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
	return NO;
}

@end
