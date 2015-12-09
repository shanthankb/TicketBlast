//
//  OVCustomNavBarButtonItem.h
//  FlexibleWidth
//
//  Created by Sourcebits Inc
//  Copyright 2012 Sourcebits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OVFlexibleWidthButton.h"

typedef enum {
	eCustomNavBarRegularButtonItemType,
	eCustomNavBarBackButtonItemType,
	eCustomNavBarForwardButtonItemType,
    eCustomNavBarSaveButtonItemType
}eCustomNavBarButtonItemType;

//To set the title or image for the navigation bar button item, get the "-embeddedFlexibleWidthButton" first
//and call the appropriate setTitle:forState: and setImage:forState: methods on that

@interface OVCustomNavBarButtonItem : UIBarButtonItem {

	NSString		*mDefaultButtonBackgroundImageBaseName;
}

- (id)initCustomNavBarButtonItemOfType:(eCustomNavBarButtonItemType)buttonItemType;
- (OVFlexibleWidthButton *)embeddedButton;
- (NSString *)defaultButtonBackgroundImageBaseName;
- (void)setButtonForOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
