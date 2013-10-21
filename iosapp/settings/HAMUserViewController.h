//
//  HAMUserViewController.h
//  iosapp
//
//  Created by daiyue on 13-8-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMConfig.h"
#import "HAMUserManager.h"

@interface HAMUserViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray* userlist;
}

@property HAMUserManager* userManager;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UIPickerView *userPickerView;

- (IBAction)changeNameButtonClicked:(UIButton *)sender;
- (IBAction)newUserButtonClicked:(UIButton *)sender;
- (IBAction)deleteUserButtonClicked:(UIButton *)sender;
- (IBAction)setCurrentButtonClicked:(UIButton *)sender;


@end
