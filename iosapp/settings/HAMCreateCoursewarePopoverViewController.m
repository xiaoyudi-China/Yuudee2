//
//  HAMCreateCoursewarePopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-10.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCreateCoursewarePopoverViewController.h"

@interface HAMCreateCoursewarePopoverViewController ()

@end

@implementation HAMCreateCoursewarePopoverViewController

@synthesize coursewareNameTextField;
@synthesize mainSettingsViewController;
@synthesize popover;
@synthesize coursewareManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(Boolean)validateUserName:(NSString*)username
{
    return username.length>0 && username.length<=64;
}

- (IBAction)confirmCreateCourseware:(id)sender {
    NSString* name = [coursewareNameTextField.text copy];
    if (![self validateUserName:name]){
        [HAMViewTool showAlert:@"用户名不合法：请输入长度在1~64字符之间的用户名。"];
        return;
    }
    [coursewareManager newCourseware:name];
    [popover dismissPopoverAnimated:YES];
}

- (IBAction)cancelCreateCourseware:(UIButton *)sender {
    [popover dismissPopoverAnimated:YES];
}

@end
