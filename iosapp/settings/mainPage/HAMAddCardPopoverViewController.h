//
//  HAMAddCardPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMStructureEditViewController.h"

@interface HAMAddCardPopoverViewController : UIViewController
{}

@property HAMStructureEditViewController* mainSettingsViewController;
@property UIPopoverController* popover;

@property int cardIndex;

- (IBAction)addFromLibClicked:(UIButton *)sender;
- (IBAction)createCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;

@end
