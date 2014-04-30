//
//  HAMCreateCoursewarePopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-10.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCourseware.h"

@class HAMCoursewareManager;
@class HAMSettingsViewController;
@class HAMCreateCoursewareViewController;
@protocol HAMCreateCoursewareViewControllerDelegate <NSObject>

- (void)createCoursewareDismissed:(HAMCreateCoursewareViewController *)createCourseware;

@end

@interface HAMCreateCoursewareViewController : UIViewController

@property (weak, nonatomic) HAMSettingsViewController<HAMCreateCoursewareViewControllerDelegate> *delegate;
@property HAMSettingsViewController* mainSettingsViewController;
@property HAMCoursewareManager* coursewareManager;

@property (weak, nonatomic) IBOutlet UITextField *coursewareNameTextField;

- (IBAction)confirmCreateCourseware:(id)sender;
- (IBAction)cancelCreateCourseware:(UIButton *)sender;



@end
