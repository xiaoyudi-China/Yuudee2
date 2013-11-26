//
//  HAMNodeSelectorViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMNodeSelectorViewController.h"


@interface HAMNodeSelectorViewController ()

@end

@implementation HAMNodeSelectorViewController

// FIXME: how to refactor?
CGRect CENTRAL_POINT_RECT;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];	
    if (self) {
        // Custom initialization
		CENTRAL_POINT_RECT = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
    }
    return self;
}

- (NSArray*) categoryIDs {
	
	// the uncategorized category is not created yet
	// FIXME: this should be done in DaiYue's part
	NSArray *catIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	if ([catIDs indexOfObject:UNCATEGORIZED_ID] == NSNotFound) {
		HAMCard *category = [[HAMCard alloc] initWithID:UNCATEGORIZED_ID];
		NSString *categoryName = @"未分类";
		[self.config newCardWithID:category.UUID name:categoryName type:0 audio:nil image:nil]; // type 0 indicates a category
		category.isRemovable_ = NO; // YES in default
		
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
    
    //Lei: use this before dequeueReusableCell
    [self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"GridCell"];
	
    // set the layout of collection view
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	
	flowLayout.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
	flowLayout.minimumInteritemSpacing = INTER_ITEM_SPACING;
	flowLayout.minimumLineSpacing = LINE_SPACE;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	flowLayout.sectionInset = UIEdgeInsetsMake(0, INTER_ITEM_SPACING, 0, INTER_ITEM_SPACING);
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
}

-(void)viewWillAppear:(BOOL)animated
{
	if (self.index == -1)	// edit mode
		self.cellMode = HAMGridCellModeEdit;
	else	// select mode
		self.cellMode = HAMGridCellModeAdd;
	
	if (self.cellMode == HAMGridCellModeEdit) {
		self.title = @"编辑卡片/分类";
		// press this button to create a new card or new category
		UIBarButtonItem *createItemButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createItemButtonPressed)];
		self.navigationItem.rightBarButtonItem = createItemButton;
	}
	else {
		self.title = @"选择分类";
		self.navigationItem.rightBarButtonItem = nil;
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
    static NSString* cellID=@"GridCell";
    HAMGridCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

	NSString *categoryID = [self categoryIDs][indexPath.row];
  	HAMCard *category = [self.config card:categoryID]; // only display categories
    cell.textLabel.text = category.name;
	cell.frameImageView.image = [UIImage imageNamed:@"category.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
	else { // Mode edit
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
		
		// don't allow deleting system-provided categories or cards
		if (! category.isRemovable_)
			cell.rightTopButton.hidden = TRUE;
	}
		
	cell.indexPath = indexPath;
	cell.delegate = self;
	cell.selected = NO; // redundant?
	
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *categoryID = [self categoryIDs][indexPath.row];
	
	HAMCardSelectorViewController *cardSelector = [[HAMCardSelectorViewController alloc] initWithNibName:@"HAMCardSelectorViewController" bundle:nil];
	cardSelector.categoryID = categoryID;
	cardSelector.config = self.config;
	cardSelector.userID = self.parentID;
	cardSelector.index = self.index;
	cardSelector.cellMode = self.cellMode;
	
	[self.navigationController pushViewController:cardSelector animated:YES];
}


- (void)createItemButtonPressed {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建分类", @"创建卡片", nil];
	[actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // create card
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.categoryID = nil;
		categoryEditor.config = self.config;
		categoryEditor.delegate = self;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:categoryEditor];
		categoryEditor.popover = self.popover;

		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
		
	}
	else if (buttonIndex == 1) { // create category
		HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
		cardEditor.cardID = nil;
		cardEditor.categoryID = nil;
		cardEditor.config = self.config;
		
		UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:cardEditor];
		navigator.navigationBarHidden = YES; // don't show navigation bar
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:navigator];
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
	}
	else { // Mode Edit
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		categoryEditor.categoryID = [self categoryIDs][gridCell.indexPath.row];
		categoryEditor.config = self.config;
		categoryEditor.delegate = self;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:categoryEditor];
		categoryEditor.popover = self.popover;

		// FIXME: the arrow direction
		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

- (void)categoryEditorDidEndEditing:(HAMCategoryEditorViewController *)categoryEditor {
	[self.collectionView reloadData];
}

@end
