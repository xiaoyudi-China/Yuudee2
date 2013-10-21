//
//  HAMUserViewController.m
//  iosapp
//
//  Created by daiyue on 13-8-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMUserViewController.h"

@interface HAMUserViewController ()

@end

@implementation HAMUserViewController

@synthesize userManager;
@synthesize deleteButton;
@synthesize currentUserLabel;
@synthesize nameInput;
@synthesize userPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"用户管理";
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateView
{
    userlist=[userManager userList];
    currentUserLabel.text=[userManager currentUser].name;
    nameInput.text=@"";
    
    if (userlist.count==1)
        deleteButton.hidden=true;
    else
        deleteButton.hidden=false;
    
    [userPickerView reloadAllComponents];
    
}

#pragma mark -
#pragma mark Picker Data Method

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [userlist count];
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    HAMUser* user=[userlist objectAtIndex:row];
    return user.name;
}

- (void)viewDidUnload {
    [self setDeleteButton:nil];
    [self setCurrentUserLabel:nil];
    [self setNameInput:nil];
    [self setUserPickerView:nil];
    [super viewDidUnload];
}

#pragma mark
#pragma mark Actions

- (IBAction)changeNameButtonClicked:(UIButton *)sender {
    NSString* newName=[self inputName];
    if (!newName)
        return;
    
    [userManager updateCurrentUserName:newName];
    [self updateView];
}

- (IBAction)newUserButtonClicked:(UIButton *)sender {
    NSString* newName=[self inputName];
    if (!newName)
        return;
    
    [userManager newUser:newName];
    [self updateView];
}

- (IBAction)deleteUserButtonClicked:(UIButton *)sender {
    [[[UIAlertView alloc] initWithTitle:@"删除用户" message:@"确定要删除用户吗？将清除该用户所有的卡片和分类。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil] show];
}

- (IBAction)setCurrentButtonClicked:(UIButton *)sender {
    int row = [userPickerView selectedRowInComponent:0];
    HAMUser* user=[userlist objectAtIndex:row];
    [userManager setCurrentUser:user];
    
    currentUserLabel.text=[userManager currentUser].name;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:{
            //delete user
            int row = [userPickerView selectedRowInComponent:0];
            HAMUser* user=[userlist objectAtIndex:row];
            
            [userManager deleteUser:user];
            [self updateView];
        }break;
        default:
            break;
    }
}

#pragma mark
#pragma mark User Name Methods

-(NSString*)inputName
{
    NSString* input=nameInput.text;
    if ([self validateUserName:input])
        return input;
    [HAMViewTool showAlert:@"用户名不合法：请输入长度在1~64字符之间的用户名。"];
    return nil;
}

-(Boolean)validateUserName:(NSString*)username
{
    return username.length>0 && username.length<=64;
}

@end
