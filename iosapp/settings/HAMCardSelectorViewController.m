//
//  HAMCardSelectorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-10-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardSelectorViewController.h"

@interface HAMCardSelectorViewController ()

@end

CGRect CENTRAL_POINT_RECT;

@implementation HAMCardSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		CENTRAL_POINT_RECT = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
		self.selectedCardIDs = [[NSMutableSet alloc] init];
    }
    return self;
}

// It's essential to define this accessor method
// ??? Is it?
- (NSArray*) cardIDs {
	return [self.config childrenCardIDOfCat:self.categoryID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"选择卡片";
	
	// note
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"GridCell"];
	
    // Do any additional setup after loading the view from its nib.
	
	// set the layout of collection view
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	
	flowLayout.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
	flowLayout.minimumInteritemSpacing = (GRID_VIEW_WIDTH - 3*CELL_WIDTH) / 4;
	flowLayout.minimumLineSpacing = (GRID_VIEW_HEIGHT - 4*CELL_HEIGHT) / 5;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	flowLayout.sectionInset = UIEdgeInsetsMake(0, INTER_ITEM_SPACING, 0, INTER_ITEM_SPACING);
    
    [self.collectionView setCollectionViewLayout:flowLayout];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// cannot alter the name of unclassified category
	return (self.cellMode == HAMGridCellModeEdit) && self.categoryID;
}

- (void)viewWillAppear:(BOOL)animated {
	
	// determine which mode we're in
	if (self.index == -1)
		self.cellMode = HAMGridCellModeEdit;
	else
		self.cellMode = HAMGridCellModeAdd;
	
	
	if (self.cellMode == HAMGridCellModeEdit) {
		// add a button on the top-right to create new card
		UIBarButtonItem *createCardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(createCardButtonPressed)];
		self.navigationItem.rightBarButtonItem = createCardButton;
	}
	else {
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	return self.cardIDs.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString* cellID = @"GridCell";
	HAMGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	
	// load the text
	HAMCard *card = [self.config card:[self cardIDs][indexPath.row]];
	cell.textLabel.text = card.name;
	
	cell.contentImageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
	cell.frameImageView.image = [UIImage imageNamed:@"card.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"unselected.png"]forState:UIControlStateNormal];
	else
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
	
	cell.indexPath = indexPath;
	cell.selected = NO;
	cell.delegate = self;
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)createCardButtonPressed {
	
	HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
	cardEditor.cardID = nil;
	cardEditor.categoryID = self.categoryID;
	cardEditor.config = self.config;
	cardEditor.delegate = self;
	
	UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:cardEditor];
	navigator.navigationBarHidden = YES;
	
	self.popover = [[UIPopoverController alloc] initWithContentViewController:navigator];
	cardEditor.popover = self.popover;

	[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
}

- (void)addCardsButtonPressed {
	
	// FIXME: this is just testing, should add all the selected cards later
	NSString *cardID = [self.selectedCardIDs anyObject];
	HAMRoom *room = [[HAMRoom alloc] initWithCardID:cardID animation:[self.config animationOfCat:self.userID atIndex:self.index]]; // keep the animation unchanged
	
	[self.config updateRoomOfCat:self.userID with:room atIndex:self.index];
	/*
	int animation = [self.config animationOfCat:self.userID atIndex:self.index]; // keep the animation unchanged
	NSMutableArray *rooms = [[NSMutableArray alloc] initWithCapacity:self.selectedCardIDs.count];
	// FIXME: the order of selection
	for (NSString *cardID in self.selectedCardIDs)
		[rooms addObject:[[HAMRoom alloc] initWithCardID:cardID animation:animation]];
	
	[self.config insertChildren:rooms intoCat:self.userID atIndex:self.index];*/
	
	NSArray *viewsInStack = self.navigationController.viewControllers;
	// pop out two views from the navigation stack, including the current one
	[self.navigationController popToViewController:viewsInStack[viewsInStack.count - 3] animated:TRUE];
}

- (void)rightTopButtonPressedForCell:(id)cell {
	HAMGridCell *gridCell = (HAMGridCell*) cell;
	NSString *cardID = [self cardIDs][gridCell.indexPath.row];
	
	if (self.cellMode == HAMGridCellModeAdd) {
		if (gridCell.selected) {
			[self.selectedCardIDs removeObject:cardID];
			
			gridCell.selected = NO;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"unselected.png"] forState:UIControlStateNormal];
			
			// remove the button on the right of top bar
			if (self.selectedCardIDs.count == 0)
				self.navigationItem.rightBarButtonItem = nil;
		}
		else { // unselected
			// activate the button on the right of top bar
			if (self.selectedCardIDs.count == 0) {
				UIBarButtonItem *addCardsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCardsButtonPressed)];
				self.navigationItem.rightBarButtonItem = addCardsButton;
			}
			
			NSString *cardID = self.cardIDs[gridCell.indexPath.row];
			[self.selectedCardIDs addObject:cardID];
			
			gridCell.selected = YES;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
		}
	}
	else { // Mode Edit
		
		HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
		cardEditor.cardID = cardID;
		cardEditor.categoryID = self.categoryID;
		cardEditor.config = self.config;
		cardEditor.delegate = self;
		
		UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:cardEditor];
		navigator.navigationBarHidden = YES;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:navigator];		
		cardEditor.popover = self.popover;

		[self.popover presentPopoverFromRect:CENTRAL_POINT_RECT inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	// FIXME: sometimes the grid view is not refreshed
	[self.collectionView reloadData];
}

@end
