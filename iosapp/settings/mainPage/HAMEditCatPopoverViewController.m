//
//  HAMEditCatPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditCatPopoverViewController.h"

@interface HAMEditCatPopoverViewController ()

@end

@implementation HAMEditCatPopoverViewController

@synthesize mainSettingsViewController;
@synthesize config;
@synthesize parentID;
@synthesize childIndex;
@synthesize popover;

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

- (IBAction)editInLibClicked:(UIButton *)sender {
}

- (IBAction)removeCatClicked:(UIButton *)sender {
    [config updateRoomOfCat:parentID with:nil atIndex:childIndex];
    [mainSettingsViewController refreshGridViewAndScrollToFirstPage:NO];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}


@end
