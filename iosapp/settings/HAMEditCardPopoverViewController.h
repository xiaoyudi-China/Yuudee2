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
#import "HAMSettingsViewController.h"

@class HAMSettingsViewController;

@interface HAMEditCardPopoverViewController : UIViewController<HAMCardEditorViewControllerDelegate>
{

}

@property HAMSettingsViewController* mainSettingsViewController_;
@property HAMConfig* config_;
@property NSString* parentID_;
@property int childIndex_;
@property UIPopoverController* popover;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (weak, nonatomic) IBOutlet UIImageView *animationCheckedMark;
@property (weak, nonatomic) IBOutlet UIButton *animationNoneButton;
@property (weak, nonatomic) IBOutlet UIButton *animationScaleButton;
@property (weak, nonatomic) IBOutlet UIButton *animationShakeButton;
@property (weak, nonatomic) IBOutlet UIButton *editInLibButton;

- (IBAction)editInLibClicked:(UIButton *)sender;
- (IBAction)animationSetToNoClicked:(UIButton *)sender;
- (IBAction)animationSetToScaleClicked:(UIButton *)sender;
- (IBAction)animationSetToShakeClicked:(UIButton *)sender;
- (IBAction)removeCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;
- (IBAction)finishClicked:(UIButton *)sender;

@end
