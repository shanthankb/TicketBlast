//
//  GBCustomNavigationController.m
//
//  Created by prasad devadiga on 11/01/13.
//  Copyright (c) 2013 sourcebits. All rights reserved.
//

#import "GBCustomNavigationController.h"

@interface GBCustomNavigationController ()

@end

@implementation GBCustomNavigationController

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
    
    for (UIView *view in self.navigationBar.subviews) {                                 //exclusive touch for all bar navbar elements
        view.exclusiveTouch = YES;
    }
}


- (void)makeAllBarButtonsExclusiveTouch
{
    for (UIView *view in self.navigationBar.subviews)
    {                                                                       //exclusive touch for all bar navbar elements
        view.exclusiveTouch = YES;
    }
}

-(BOOL)shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self topViewController] preferredInterfaceOrientationForPresentation];
}


-(NSUInteger)supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
