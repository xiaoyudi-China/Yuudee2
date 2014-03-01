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

@synthesize mainSettingsViewController_;
@synthesize popover;
@synthesize cardIndex_;
@synthesize config_;
@synthesize parentID_;

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
    [mainSettingsViewController_ enterLibAt:cardIndex_];
}

- (IBAction)createCardClicked:(UIButton *)sender{
    HAMCardEditorViewController* cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
    //mainSettingsViewController.cardEditorViewController = cardEditor;
    
    cardEditor.delegate = self; // NOTE!!!
    cardEditor.addCardOnCreation = YES;
    cardEditor.parentID = parentID_;
    cardEditor.index = cardIndex_;
    cardEditor.config = config_;
    // the card is not categorized by default
    cardEditor.categoryID = UNCATEGORIZED_ID;
    // ‘nil' indicates this is a new card
    cardEditor.cardID = nil;
    
    cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // pretend the card editor is floating above the background view
    UIView *background = [mainSettingsViewController_.view snapshotViewAfterScreenUpdates:NO];
    [cardEditor.view insertSubview:background atIndex:0];
    
    [mainSettingsViewController_ presentViewController:cardEditor animated:YES completion:NULL];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelClicked:(UIButton *)sender{
    [self.popover dismissPopoverAnimated:YES];
}
@end
