//
//  GBEventTypeSelectionViewController.m
//
//  Created by Abhiman Puranik on 20/03/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
// 

#import "GBEventTypeSelectionViewController.h"
#import "GBNewTicketViewController.h"

@interface GBEventTypeSelectionViewController ()
- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end


@implementation GBEventTypeSelectionViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.view = mainView;
        //Array containig the various categories of tickets.
    _eventTypeArray = [[NSArray alloc] initWithObjects:@"Concert",@"Game",@"Show",@"Movie",@"Other",nil];
    
    _eventTypeTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+20, self.view.frame.size.width, 225)];
    self.eventTypeTableView.delegate = self;
    self.eventTypeTableView.dataSource = self;
    self.eventTypeTableView.backgroundView = nil;
    self.eventTypeTableView.scrollEnabled = FALSE;
    self.eventTypeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.eventTypeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.eventTypeTableView];
    
    
    // Setting Autolayout for the tableview, so that it supports landscape
    
//    NSLayoutConstraint *tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.eventTypeTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
//    [self.view addConstraint:tableViewConstraints];
//    
//    tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.eventTypeTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f];
//    [self.view addConstraint:tableViewConstraints];
//    
//    tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.eventTypeTableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
//    [self.view addConstraint:tableViewConstraints];
//    
//    tableViewConstraints = [NSLayoutConstraint constraintWithItem:self.eventTypeTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
//    [self.view addConstraint:tableViewConstraints];
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Event type";
    
    //Navigation bar back button
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(0, 0, 12, 25)];
    [backButton setImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back_pressed"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [self resizeNavButtonsOnRotationForOrientation:self.interfaceOrientation];
}

- (void)didTapBackButton:(id)sender
{
    self.delegate.shouldClearFields = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventTypeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UILabel *eventTypeLabel;
    UIImageView *selectedOptionImageView;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        eventTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 30)];
        eventTypeLabel.tag = 1111;
        eventTypeLabel.backgroundColor = [UIColor clearColor];
        eventTypeLabel.font = [UIFont fontWithName:@"Gotham-Book" size:16.0];
        eventTypeLabel.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        eventTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:eventTypeLabel];
        
        NSLayoutConstraint *eventTypeLabelConstraint = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:18];
        
        [cell.contentView addConstraint:eventTypeLabelConstraint];
        
        eventTypeLabelConstraint = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        
        [cell.contentView addConstraint:eventTypeLabelConstraint];
        
        eventTypeLabelConstraint = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-10];
        
        [cell.contentView addConstraint:eventTypeLabelConstraint];
        
        eventTypeLabelConstraint = [NSLayoutConstraint constraintWithItem:eventTypeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0];
        
        [cell.contentView addConstraint:eventTypeLabelConstraint];
        
        selectedOptionImageView = [[UIImageView alloc] init];
        selectedOptionImageView.tag = 3333;
        selectedOptionImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:selectedOptionImageView];
        
        NSLayoutConstraint *selectedOptionImageViewConstraint = [NSLayoutConstraint constraintWithItem:selectedOptionImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-19];
        
        [cell.contentView addConstraint:selectedOptionImageViewConstraint];
        
        selectedOptionImageViewConstraint = [NSLayoutConstraint constraintWithItem:selectedOptionImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:16];
        
        [cell.contentView addConstraint:selectedOptionImageViewConstraint];
        
        selectedOptionImageViewConstraint = [NSLayoutConstraint constraintWithItem:selectedOptionImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:16];
        
        [cell.contentView addConstraint:selectedOptionImageViewConstraint];
        
        selectedOptionImageViewConstraint = [NSLayoutConstraint constraintWithItem:selectedOptionImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:12];
        
        [cell.contentView addConstraint:selectedOptionImageViewConstraint];

        
    }
    else
    {
        eventTypeLabel = (UILabel *)[cell.contentView viewWithTag:1111];
        selectedOptionImageView = (UIImageView *)[cell.contentView viewWithTag:3333];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    eventTypeLabel.text = [self.eventTypeArray objectAtIndex:indexPath.row];
    
    if ([self.eventType isEqualToString:[self.eventTypeArray objectAtIndex:indexPath.row]])
    {
        selectedOptionImageView.image = [UIImage imageNamed:@"checkmark"];
    }
    else
    {
        selectedOptionImageView.image = [UIImage imageNamed:@""];        
    }
    
    if (indexPath.row == 0) {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        topLineView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        topLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:topLineView];
    }
    if (indexPath.row == [_eventTypeArray count]-1) {
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height, self.view.bounds.size.width, 1)];
        bottomLineView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:bottomLineView];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        [self.delegate.displayFields removeAllObjects];
        [self.delegate.displayFields addObject:kEventImage];
        [self.delegate.displayFields addObject:kEventType];
        [self.delegate.displayFields addObject:kEventVenue];
        [self.delegate.displayFields addObject:kHeadline];
        [self.delegate.displayFields addObject:kEventDate];
        [self.delegate.displayFields addObject:kEventNotes];
        
        [self.delegate.ticketDetails setObject:kEventTypeConcert forKey:kEventType];
        
    }
    else if (indexPath.row == 1)
    {
        [self.delegate.displayFields removeAllObjects];
        [self.delegate.displayFields addObject:kEventImage];
        [self.delegate.displayFields addObject:kEventType];
        [self.delegate.displayFields addObject:kEventVenue];
        [self.delegate.displayFields addObject:kHomeTeam];
        [self.delegate.displayFields addObject:kOpponent];
        [self.delegate.displayFields addObject:kEventDate];
        [self.delegate.displayFields addObject:kEventNotes];
        
        [self.delegate.ticketDetails setObject:kEventTypeGame forKey:kEventType];
        
    }
    else if (indexPath.row == 2)
    {
        [self.delegate.displayFields removeAllObjects];
        [self.delegate.displayFields addObject:kEventImage];
        [self.delegate.displayFields addObject:kEventType];
        [self.delegate.displayFields addObject:kEventVenue];
        [self.delegate.displayFields addObject:kEventName];
        [self.delegate.displayFields addObject:kEventDate];
        [self.delegate.displayFields addObject:kEventNotes];
        
        [self.delegate.ticketDetails setObject:kEventTypeShow forKey:kEventType];
    }
    else if (indexPath.row == 3)
    {
        [self.delegate.displayFields removeAllObjects];
        [self.delegate.displayFields addObject:kEventImage];
        [self.delegate.displayFields addObject:kEventType];
        [self.delegate.displayFields addObject:kEventVenue];
        [self.delegate.displayFields addObject:kEventName];
        [self.delegate.displayFields addObject:kEventDate];
        [self.delegate.displayFields addObject:kEventNotes];
        
        [self.delegate.ticketDetails setObject:kEventTypeMovie forKey:kEventType];

    }
    else
    {
        [self.delegate.displayFields removeAllObjects];
        [self.delegate.displayFields addObject:kEventImage];
        [self.delegate.displayFields addObject:kEventType];
        [self.delegate.displayFields addObject:kEventVenue];
        [self.delegate.displayFields addObject:kEventName];
        [self.delegate.displayFields addObject:kEventDate];
        [self.delegate.displayFields addObject:kEventNotes];
        
        [self.delegate.ticketDetails setObject:kEventTypeOther forKey:kEventType];
        
    }
    
    if ([self.eventType isEqualToString:[self.delegate.ticketDetails objectForKey:kEventType]])
    {
        self.delegate.shouldClearFields = NO;
    }
    else
    {
        self.delegate.shouldClearFields = YES;
    }
    
    self.eventType = [self.delegate.ticketDetails objectForKey:kEventType];
    
    [self.eventTypeTableView reloadData];

    [self performSelector:@selector(returnToNewTicketScreen) withObject:nil afterDelay:0.5];

}

- (void)returnToNewTicketScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Rotation code

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self resizeNavButtonsOnRotationForOrientation:toInterfaceOrientation];
}

//The following function resizes the navigation bar buttons on change in device orientation
- (void)resizeNavButtonsOnRotationForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIButton *leftNavButton = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x,leftNavButton.frame.origin.y, 12.0, 25.0)];
        
    }
	else if(interfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[leftNavButton setFrame:CGRectMake(leftNavButton.frame.origin.x, leftNavButton.frame.origin.y, 12.0, 31.0)];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
