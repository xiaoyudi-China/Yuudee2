//
//  HAMGuideViewController.m
//  小雨滴
//
//  Created by 张 磊 on 14-4-22.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import "HAMUnlockGuideViewController.h"
#import "HAMConstants.h"

@interface HAMUnlockGuideViewController ()

@end

@implementation HAMUnlockGuideViewController

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

- (void)dismiss {
	[self.delegate unlockGuideDismissed:self];
}

- (IBAction)confirmButtonPressed:(id)sender {
	[self dismiss];
}

- (IBAction)noHintButtonPressed:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NO_UNLOCK_GUIDE_KEY];
	[self dismiss];
}

@end
