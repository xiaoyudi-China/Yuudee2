//
//  HAMCreateCoursewarePopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-10.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMSettingsViewController.h"
#import "HAMCourseware.h"

@interface HAMCreateCoursewarePopoverViewController : UIViewController
{
}

@property (weak, nonatomic) IBOutlet UITextField *coursewareNameTextField;

@property HAMSettingsViewController* mainSettingsViewController;
@property UIPopoverController* popover;
@property HAMCoursewareManager* coursewareManager;

- (IBAction)confirmCreateCourseware:(id)sender;
- (IBAction)cancelCreateCourseware:(UIButton *)sender;



@end
