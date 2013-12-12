//
//  HAMAddCardPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMAddCardPopoverViewController.h"

@interface HAMAddCardPopoverViewController ()

@end

@implementation HAMAddCardPopoverViewController

@synthesize mainSettingsViewController;
@synthesize popover;
@synthesize cardIndex;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFromLibClicked:(UIButton *)sender{
    [self.popover dismissPopoverAnimated:YES];
    [mainSettingsViewController enterLibAt:cardIndex];
}

- (IBAction)createCardClicked:(UIButton *)sender{
}

- (IBAction)cancelClicked:(UIButton *)sender{
    [self.popover dismissPopoverAnimated:YES];
}
@end
