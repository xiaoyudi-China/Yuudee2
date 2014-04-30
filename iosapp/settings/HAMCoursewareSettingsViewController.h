//
//  HAMSettingsPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCoursewareManager.h"
#import "HAMViewInfo.h"

@class HAMSettingsViewController;
@class HAMCoursewareSettingsViewController;
@protocol HAMCoursewareSettingsViewControllerDelegate <NSObject>

- (void)coursewareSettingsDismissed:(HAMCoursewareSettingsViewController *)coursewareSettings;

@end

@interface HAMCoursewareSettingsViewController : UIViewController<UIActionSheetDelegate>

@property HAMCoursewareManager* coursewareManager;
@property (strong, nonatomic) HAMCourseware *currentCourseware;
@property (weak, nonatomic) HAMSettingsViewController<HAMCoursewareSettingsViewControllerDelegate> *delegate;

@property (weak, nonatomic) IBOutlet UIButton *coursewareTitleButton;
@property (weak, nonatomic) IBOutlet UITextField *changeTitleTextField;

@property (weak, nonatomic) IBOutlet UIImageView *layoutCheckedImageView;
@property (weak, nonatomic) IBOutlet UIButton *layout1x1Button;
@property (weak, nonatomic) IBOutlet UIButton *layout2x2Button;
@property (weak, nonatomic) IBOutlet UIButton *layout3x3Button;

- (IBAction)changeTitleClicked:(UIButton *)sender;

- (IBAction)layout1x1Clicked:(UIButton *)sender;
- (IBAction)layout2x2Clicked:(UIButton *)sender;
- (IBAction)layout3x3Clicked:(UIButton *)sender;

- (IBAction)removeCoursewareClicked:(UIButton *)sender;

- (IBAction)cancelClicked:(UIButton *)sender;
- (IBAction)finishClicked:(UIButton *)sender;

@end
