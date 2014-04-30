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
#import "HAMCardEditorViewController.h"

@class HAMSettingsViewController;
@class HAMEditCardViewController;
@protocol HAMEditCardViewControllerDelegate <NSObject>

- (void)editCardDismissed:(HAMEditCardViewController *)editCard;

@end

// TODO: find a better name
@interface HAMEditCardViewController : UIViewController<HAMCardEditorViewControllerDelegate>

@property HAMConfig* config;
@property NSString* parentID;
@property NSInteger childIndex;
@property (weak, nonatomic) HAMSettingsViewController<HAMEditCardViewControllerDelegate> *delegate;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIImageView *animationCheckedMark;
@property (weak, nonatomic) IBOutlet UIButton *animationNoneButton;
@property (weak, nonatomic) IBOutlet UIButton *animationScaleButton;
@property (weak, nonatomic) IBOutlet UIButton *animationShakeButton;
@property (weak, nonatomic) IBOutlet UIButton *editInLibButton;
@property (weak, nonatomic) IBOutlet UISwitch *muteStateSwitch;

- (IBAction)editInLibClicked:(UIButton *)sender;
- (IBAction)animationSetToNoClicked:(UIButton *)sender;
- (IBAction)animationSetToScaleClicked:(UIButton *)sender;
- (IBAction)animationSetToShakeClicked:(UIButton *)sender;
- (IBAction)removeCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;
- (IBAction)finishClicked:(UIButton *)sender;

@end