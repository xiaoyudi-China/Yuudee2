//
//  HAMNodeSelectorViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategorySelectorViewController.h"


@interface HAMCategorySelectorViewController ()

@end

@implementation HAMCategorySelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray*) categoryIDs {
	
	// the uncategorized category is not created yet
	// TODO: this should be done in DaiYue's part
	NSArray *catIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	if ([catIDs indexOfObject:UNCATEGORIZED_ID] == NSNotFound) {
		HAMCard *category = [[HAMCard alloc] initWithID:UNCATEGORIZED_ID];
		NSString *categoryName = @"未分类";
		[self.config newCardWithID:category.UUID name:categoryName type:0 audio:nil image:nil]; // type 0 indicates a category
		category.isRemovable_ = NO;
		
		// insert the new category in to library
		NSInteger numChildren = [self.config childrenCardIDOfCat:LIB_ROOT].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:category.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:LIB_ROOT with:room atIndex:numChildren];
		
		return [self.config childrenCardIDOfCat:LIB_ROOT];
	}
	else
		return catIDs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"CategoryCell"];
	self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	if (self.index == -1)	// edit mode
		self.cellMode = HAMGridCellModeEdit;
	else	// select mode
		self.cellMode = HAMGridCellModeAdd;
	
	if (self.cellMode == HAMGridCellModeEdit) {
		self.title = @"编辑卡片/分类";
	}
	else {
		self.title = @"选择分类";
		self.rightTopButton.hidden = YES;
	}
	
	// !!!
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
	if (category.UUID == UNCATEGORIZED_ID) // FIXME: this is inelegant
		category.isRemovable_ = NO;
    cell.textLabel.text = category.name;
	cell.frameImageView.image = [UIImage imageNamed:@"classBG.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
	else { // Mode edit
		// FIXME: should use the file name offered by XingMei
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edititem.png"] forState:UIControlStateNormal];
		
		// don't allow editing system-provided categories or cards
		// FIXME: not working
		//if (! category.isRemovable_)
		//	cell.rightTopButton.hidden = TRUE;
	}
		
	cell.indexPath = indexPath;
	cell.delegate = self;
	cell.selected = NO; // redundant?
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *categoryID = [self categoryIDs][indexPath.row];
	
	HAMCardSelectorViewController *cardSelector = [[HAMCardSelectorViewController alloc] initWithNibName:@"HAMGridViewController" bundle:nil];
	cardSelector.categoryID = categoryID;
	cardSelector.config = self.config;
	cardSelector.userID = self.parentID;
	cardSelector.index = self.index;
	cardSelector.cellMode = self.cellMode;
	
	[self.navigationController pushViewController:cardSelector animated:YES];
}

- (void)rightTopButtonPressed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建分类", @"创建卡片", nil];
	[actionSheet showFromRect:self.rightTopButton.frame inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // create category
		
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.categoryID = nil;
		categoryEditor.config = self.config;
		categoryEditor.delegate = self;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:categoryEditor];
		self.popover.popoverBackgroundViewClass = [HAMPopoverBackgroundView class];
		categoryEditor.popover = self.popover;

		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
		
	}
	else if (buttonIndex == 1) { // create card
		
		HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
		cardEditor.cardID = nil;
		cardEditor.categoryID = UNCATEGORIZED_ID;
		cardEditor.config = self.config;
		
		UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:cardEditor];
		navigator.navigationBarHidden = YES; // don't show navigation bar
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:navigator];
		self.popover.popoverBackgroundViewClass = [HAMPopoverBackgroundView class];
		cardEditor.popover = self.popover;
		
		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

- (void)rightTopButtonPressedForCell:(id)cell {
	HAMGridCell *gridCell = (HAMGridCell*) cell;
	
	if (self.cellMode == HAMGridCellModeAdd) { // Mode Add
		NSString *categoryID = [self categoryIDs][gridCell.indexPath.row];
		
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:categoryID animation:[self.config animationOfCat:self.parentID atIndex:self.index]]; // keep the animation unchanged
		[self.config updateRoomOfCat:self.parentID with:room atIndex:self.index];
		[self.navigationController popViewControllerAnimated:TRUE];
		
		// trace user events
		HAMCard *category = [self.config card:categoryID];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:category.name, @"分类名称", [NSString stringWithFormat:@"%d", self.index], @"添加位置", nil];
		[MobClick event:@"add_category" attributes:attrs];
	}
	else { // Mode Edit
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.categoryID = [self categoryIDs][gridCell.indexPath.row];
		categoryEditor.config = self.config;
		categoryEditor.delegate = self;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:categoryEditor];
		self.popover.popoverBackgroundViewClass = [HAMPopoverBackgroundView class];
		categoryEditor.popover = self.popover;

		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self.collectionView reloadData];
}

@end
