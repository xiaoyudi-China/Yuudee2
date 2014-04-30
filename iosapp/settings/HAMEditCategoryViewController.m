//
//  HAMEditCatPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditCategoryViewController.h"
#import "HAMSettingsViewController.h"

@interface HAMEditCategoryViewController ()
{
    NSString* catID_;
}

@end

@implementation HAMEditCategoryViewController

@synthesize config_;
@synthesize parentID_;
@synthesize childIndex_;
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
    if (!cat.removable)
    {
        editInLibButton.enabled = false;
        [editInLibButton setTitle:@"(不能编辑系统自带分类)" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
	[self.delegate editCategoryDismissed:self];
}

- (IBAction)editInLibClicked:(UIButton *)sender {
    HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc]
                                                       initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
    categoryEditor.delegate = self;
    categoryEditor.config = self.config_;
    categoryEditor.categoryID = [config_ childCardIDOfCat:parentID_ atIndex:childIndex_];
    
    UIView *background = [self.delegate.view snapshotViewAfterScreenUpdates:NO];
    [categoryEditor.view insertSubview:background atIndex:0];
    
    categoryEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    categoryEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.delegate presentViewController:categoryEditor animated:YES completion:NULL];
	
	[self dismiss];
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
	// update your grid view if needed
}

- (void)categoryEditorDidCancelEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)removeCatClicked:(UIButton *)sender {
    [config_ updateRoomOfCat:parentID_ with:nil atIndex:childIndex_];
    [self.delegate refreshGridViewAndScrollToFirstPage:NO];
    
	[self dismiss];
}

- (IBAction)cancelClicked:(UIButton *)sender {
	[self dismiss];
}

#pragma mark -
#pragma mark CardEditorDelegate

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[self.delegate dismissViewControllerAnimated:YES completion:NULL];
}

@end
