//
//  HAMAddCardPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMSettingsViewController.h"
#import "HAMCardEditorViewController.h"

@interface HAMAddCardPopoverViewController : UIViewController<HAMCardEditorViewControllerDelegate>
{}

@property HAMSettingsViewController* mainSettingsViewController_;
@property UIPopoverController* popover;

@property HAMConfig* config_;
@property NSString* parentID_;
@property int cardIndex_;

- (IBAction)addFromLibClicked:(UIButton *)sender;
- (IBAction)createCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;

@end
