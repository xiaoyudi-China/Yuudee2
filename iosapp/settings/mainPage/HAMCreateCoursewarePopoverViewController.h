//
//  HAMCreateCoursewarePopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-10.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMStructureEditViewController.h"
#import "HAMUser.h"

@interface HAMCreateCoursewarePopoverViewController : UIViewController
{
}

@property (weak, nonatomic) IBOutlet UITextField *coursewareNameTextField;

@property HAMStructureEditViewController* mainSettingsViewController;
@property UIPopoverController* popover;
@property HAMUserManager* coursewareManager;

- (IBAction)confirmCreateCourseware:(id)sender;
- (IBAction)cancelCreateCourseware:(UIButton *)sender;



@end
