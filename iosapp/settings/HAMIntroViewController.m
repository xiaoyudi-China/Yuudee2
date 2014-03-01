//
//  HAMIntroViewController.m
//  iosapp
//
//  Created by 张 磊 on 14-2-28.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMIntroViewController.h"

@interface HAMIntroViewController ()

@end

@implementation HAMIntroViewController

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
	
	if (self.type == HAMIntroTypeTrainGuide) { // default is ProductInfo
		self.productInfoTextView.hidden = YES;
		self.trainGuideTextView.hidden = NO;
		self.backgroundImageView.image = [UIImage imageNamed:@"trainGuidePage"];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quitButtonPressed:(id)sender {
	[self.delegate quitIntro:self];
}

@end
