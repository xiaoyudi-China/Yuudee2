//
//  HAMStructureEditViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMAppDelegate.h"
#import "HAMViewTool.h"
#import "HAMEditableGridViewTool.h"
#import "HAMFileTools.h"
#import "HAMCategorySelectorViewController.h"
#import "HAMSyncViewController.h"
#import "HAMUserViewController.h"
#import "HAMConfig.h"
#import "HAMUserManager.h"
#import "Reachability.h"
#import "HAMEditCardPopoverViewController.h"
#import "HAMEditCatPopoverViewController.h"
#import "HAMCoursewareSettingsPopoverViewController.h"
#import "HAMAddCardPopoverViewController.h"
#import "HAMCreateCoursewarePopoverViewController.h"
#import "HAMPopoverBgView.h"
#import "HAMIntroViewController.h"

@class HAMEditableGridViewTool;

@interface HAMStructureEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate, HAMIntroViewControllerDelegate>
{
    HAMUserManager* coursewareManager;
    
    HAMEditableGridViewTool* dragableView;
    
    Boolean refreshFlag;
}

@property (strong, nonatomic) HAMConfig *config;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;
@property (weak, nonatomic) IBOutlet UITableView *coursewareTableView;
@property (weak, nonatomic) IBOutlet UIView *coursewareSelectView;
@property (weak, nonatomic) IBOutlet UIImageView *inCatWoodImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (strong,nonatomic) HAMCategorySelectorViewController *selectorViewController;
@property (strong,nonatomic) HAMSyncViewController* syncViewController;

@property (weak, nonatomic) IBOutlet UIButton *endEditButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *libButton;
@property (weak, nonatomic) IBOutlet UIButton *coursewareSelectButton;
@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *backToRootButton;
@property (weak, nonatomic) IBOutlet UIView *aboutOptionsView;
@property (weak, nonatomic) IBOutlet UIProgressView *exportProgressView;

@property NSString* currentUUID;

- (void)refreshGridViewAndScrollToFirstPage:(Boolean)scrollToFirstPage;
- (void)refreshCoursewareSelect;
- (void)setLayoutWithxnum:(int)xnum ynum:(int)ynum;

- (IBAction)endEditClicked:(UIButton *)sender;
- (IBAction)settingsClicked:(UIButton *)sender;
- (IBAction)libClicked:(UIButton *)sender;
- (IBAction)coursewareSelectClicked:(UIButton *)sender;
- (IBAction)coursewareCreateClicked:(UIButton *)sender;
- (IBAction)backToRootClicked:(UIButton *)sender;
- (IBAction)syncButtonClicked:(id)sender;
- (IBAction)aboutButtonPressed:(id)sender;
- (IBAction)productInfoButtonPressed:(id)sender;
- (IBAction)trainGuideButtonPressed:(id)sender;
- (IBAction)feedbackButtonPressed:(id)sender;
- (IBAction)exportCardsButtonPressed:(id)sender;

- (void)enterLibAt:(int)index;

@end
