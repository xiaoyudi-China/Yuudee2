//
//  HAMEditCatPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditCatPopoverViewController.h"

@interface HAMEditCatPopoverViewController ()
{
    NSString* catID_;
}

@end

@implementation HAMEditCatPopoverViewController

@synthesize mainSettingsViewController_;
@synthesize config_;
@synthesize parentID_;
@synthesize childIndex_;
@synthesize popover;
@synthesize editInLibButton;

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
}

- (void)viewWillAppear:(BOOL)animated{
    catID_ = [config_ childCardIDOfCat:parentID_ atIndex:childIndex_];
    HAMCard* cat = [config_ card:catID_];
    editInLibButton.enabled = cat.isRemovable_;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editInLibClicked:(UIButton *)sender {
    HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc]
                                                       initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
    categoryEditor.delegate = self;
    categoryEditor.config = self.config_;
    categoryEditor.categoryID = [config_ childCardIDOfCat:parentID_ atIndex:childIndex_];
    
    UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
    [categoryEditor.view insertSubview:background atIndex:0];
    
    categoryEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    categoryEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:categoryEditor animated:YES completion:NULL];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
	// update your grid view if needed
}

- (void)categoryEditorDidCancelEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
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
