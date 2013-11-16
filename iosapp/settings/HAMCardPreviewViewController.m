//
//  HAMCardPreviewViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-1.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardPreviewViewController.h"

@interface HAMCardPreviewViewController ()

@end

@implementation HAMCardPreviewViewController

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
	HAMCard *card = [self.config card:self.cardID];
	self.cardImageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
	self.textLabel.text = card.name;
	self.title = @"预览";
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addButtonPressed)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButtonPressed {
	[self.config updateChildOfNode:self.userID with:self.cardID atIndex:self.slotToReplace];
	
	NSArray *viewsInStack = self.navigationController.viewControllers;
	// pop out three views from the navigation stack, including the current one
	[self.navigationController popToViewController:viewsInStack[viewsInStack.count - 4] animated:TRUE];
}

@end
