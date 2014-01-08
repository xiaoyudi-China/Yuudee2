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

@synthesize mainSettingsViewController_;
@synthesize config_;
@synthesize parentID_;
@synthesize childIndex_;
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
    HAMCardEditorViewController* cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
    //mainSettingsViewController.cardEditorViewController = cardEditor;
    
    cardEditor.delegate = self; // NOTE!!!
    cardEditor.addCardOnCreation = YES;
    cardEditor.parentID = parentID_;
    cardEditor.index = childIndex_;
    cardEditor.config = config_;
    // the card is not categorized by default
    cardEditor.categoryID = UNCATEGORIZED_ID;
    cardEditor.cardID = [config_ childCardIDOfCat:parentID_ atIndex:childIndex_];
    
    cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // pretend the card editor is floating above the background view
    UIView *background = [mainSettingsViewController_.view snapshotViewAfterScreenUpdates:NO];
    [cardEditor.view insertSubview:background atIndex:NO];
    
    [mainSettingsViewController_ presentViewController:cardEditor animated:YES completion:NULL];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)removeCatClicked:(UIButton *)sender {
    [config_ updateRoomOfCat:parentID_ with:nil atIndex:childIndex_];
    [mainSettingsViewController_ refreshGridViewAndScrollToFirstPage:NO];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark CardEditorDelegate

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

@end
