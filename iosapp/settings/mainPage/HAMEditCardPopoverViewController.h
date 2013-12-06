//
//  HAMEditCardPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-4.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMConfig.h"
#import "HAMStructureEditViewController.h"

@class HAMStructureEditViewController;

@interface HAMEditCardPopoverViewController : UIViewController
{

}

@property HAMStructureEditViewController* mainSettingsViewController;
@property HAMConfig* config;
@property NSString* parentID;
@property int childIndex;
@property UIPopoverController* popover;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (weak, nonatomic) IBOutlet UIImageView *animationCheckedMark;
@property (weak, nonatomic) IBOutlet UIButton *animationNoneButton;
@property (weak, nonatomic) IBOutlet UIButton *animationScaleButton;
@property (weak, nonatomic) IBOutlet UIButton *animationShakeButton;

- (IBAction)editInLibClicked:(UIButton *)sender;
- (IBAction)animationSetToNoClicked:(UIButton *)sender;
- (IBAction)animationSetToScaleClicked:(UIButton *)sender;
- (IBAction)animationSetToShakeClicked:(UIButton *)sender;
- (IBAction)removeCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;
- (IBAction)finishClicked:(UIButton *)sender;

@end
