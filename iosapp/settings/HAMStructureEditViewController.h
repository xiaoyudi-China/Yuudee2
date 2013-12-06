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
#import "HAMCoursewareSettingsPopoverViewController.h"
#import "HAMPopoverBgView.h"

@class HAMEditableGridViewTool;

@interface HAMStructureEditViewController : UIViewController
{
    HAMConfig* config;
    HAMUserManager* coursewareManager;
    
    HAMEditableGridViewTool* dragableView;
    
    Boolean refreshFlag;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;

@property (strong,nonatomic) HAMCategorySelectorViewController *selectorViewController;
@property (strong,nonatomic) HAMSyncViewController* syncViewController;
@property (strong,nonatomic) HAMUserViewController* userViewController;

@property (weak, nonatomic) IBOutlet UIButton *endEditButton;
@property (weak, nonatomic) IBOutlet UIButton *createCardButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *libButton;
@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;

@property NSString* currentUUID;

- (void)refreshGridViewAndScrollToFirstPage:(Boolean)scrollToFirstPage;
- (void)setLayoutWithxnum:(int)xnum ynum:(int)ynum;

- (IBAction)endEditClicked:(UIButton *)sender;
- (IBAction)newCardClicked:(UIButton *)sender;
- (IBAction)settingsClicked:(UIButton *)sender;
- (IBAction)libClicked:(UIButton *)sender;

- (IBAction)syncButtonClicked:(id)sender;
- (IBAction)changeLayoutClicked:(UIBarButtonItem *)sender;

@end
