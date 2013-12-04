//
//  HAMGridViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-12-3.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewController.h"

@interface HAMGridViewController ()

@end

@implementation HAMGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		CENTRAL_POINT_RECT = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
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

- (IBAction)returnButtonPressed:(id)sender {
}

- (IBAction)createButtonPressed:(id)sender {
}
@end
