//
//  HAMEditCatPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCategoryEditorViewController.h"

@class HAMSettingsViewController;
@class HAMEditCategoryViewController;
@protocol HAMEditCategoryViewControllerDelegate <NSObject>

- (void)editCategoryDismissed:(HAMEditCategoryViewController *)editCategory;

@end

// TODO: find a better name
@interface HAMEditCategoryViewController : UIViewController<HAMCategoryEditorViewControllerDelegate>

@property HAMConfig* config_;
@property NSString* parentID_;
@property NSInteger childIndex_;
@property (weak, nonatomic) HAMSettingsViewController<HAMEditCategoryViewControllerDelegate> *delegate;
@property (weak, nonatomic) IBOutlet UIButton *editInLibButton;

- (IBAction)editInLibClicked:(UIButton *)sender;
- (IBAction)removeCatClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;

@end
