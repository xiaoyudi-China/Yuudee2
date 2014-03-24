//
//  HAMNodeSelectorViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategoryGridViewController.h"


@interface HAMCategoryGridViewController ()

@end

@implementation HAMCategoryGridViewController

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
	
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"CategoryCell"];
	self.navigationController.navigationBarHidden = YES;
	
	// the uncategorized category is not created yet
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.index == -1)	// edit mode
		self.cellMode = HAMGridCellModeEdit;
	else	// select mode
		self.cellMode = HAMGridCellModeAdd;
	
	if (self.cellMode == HAMGridCellModeEdit) {
		self.title = @"编辑卡片/分类";
		self.rightTopButton.hidden = NO;
	}
	else {
		self.title = @"选择分类";
		self.rightTopButton.hidden = YES;
	}
	
	// !!!
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self categoryIDs].count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID=@"CategoryCell";
    HAMGridCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

	NSString *categoryID = [self categoryIDs][indexPath.row];
  	HAMCard *category = [self.config card:categoryID]; // only display categories
	
	// FIXME
	if ([category.UUID isEqualToString:UNCATEGORIZED_ID])
		category.isRemovable = NO;
	
    cell.textLabel.text = category.name;
	cell.frameImageView.image = [UIImage imageNamed:@"catBG.png"];
	cell.contentImageView.image = [HAMSharedData imageNamed:category.image.localPath];
	if (! cell.contentImageView.image) // this category has no cover image
		cell.contentImageView.image = [UIImage imageNamed:@"defaultImage.png"];
		
	if (self.cellMode == HAMGridCellModeAdd) {
		[cell.rightTopButton setImage:[UIImage imageNamed:@"+.png"] forState:UIControlStateNormal];
		cell.rightTopButton.hidden = NO;
	}
	else { // Mode edit
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
		// don't allow editing system-provided categories or cards
		cell.rightTopButton.hidden = ! category.isRemovable;
	}
		
	cell.indexPath = indexPath;
	cell.delegate = self;
	cell.selected = NO; // redundant?
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *categoryID = [self categoryIDs][indexPath.row];
	
	HAMCardGridViewController *cardSelector = [[HAMCardGridViewController alloc] initWithNibName:@"HAMGridViewController" bundle:nil];
	cardSelector.config = self.config;
	cardSelector.userID = self.parentID;
	cardSelector.index = self.index;
	cardSelector.cellMode = self.cellMode;
	cardSelector.categoryID = categoryID;
	
	[self.navigationController pushViewController:cardSelector animated:YES];
}

- (void)rightTopButtonPressed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建分类", @"创建卡片", nil];
	[actionSheet showFromRect:self.rightTopButton.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // create category
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.delegate = self;
		categoryEditor.config = self.config;
		categoryEditor.categoryID = nil;
		
		UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
		[categoryEditor.view insertSubview:background atIndex:0];
		
		categoryEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
		categoryEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:categoryEditor animated:YES completion:NULL];
	}
	else if (buttonIndex == 1) { // create card
		HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
		cardEditor.config = self.config;
		cardEditor.delegate = self;
		cardEditor.cardID = nil;
		cardEditor.categoryID = UNCATEGORIZED_ID;
		
		// a little bit hack
		UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
		[cardEditor.view insertSubview:background atIndex:0];
		
		cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
		cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:cardEditor animated:YES completion:NULL];
	}
}

- (void)rightTopButtonPressedForCell:(HAMGridCell*)cell {
	HAMGridCell *gridCell = cell;
	
	if (self.cellMode == HAMGridCellModeAdd) { // Mode Add
		NSString *categoryID = [self categoryIDs][gridCell.indexPath.row];
		
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:categoryID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:self.parentID with:room atIndex:self.index];
		[self.navigationController popViewControllerAnimated:TRUE];
		
		// trace user events
		HAMCard *category = [self.config card:categoryID];
		NSDictionary *attrs = @{@"分类名称": category.name, @"添加位置": @(self.index).stringValue};
		[MobClick event:@"add_category" attributes:attrs];
	}
	else { // Mode Edit
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.delegate = self;
		categoryEditor.config = self.config;
		categoryEditor.categoryID = [self categoryIDs][gridCell.indexPath.row];
		
		UIView *background = [self.view snapshotViewAfterScreenUpdates:NO];
		[categoryEditor.view insertSubview:background atIndex:0];
		
		categoryEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
		categoryEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:categoryEditor animated:YES completion:NULL];
	}
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
	
	// update the categories displayed
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	[self.collectionView reloadData];
}

- (void)categoryEditorDidCancelEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
