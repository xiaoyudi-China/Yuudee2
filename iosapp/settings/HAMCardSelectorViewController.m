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

@implementation HAMCardSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.selectedCards = [[NSMutableSet alloc] init];
    }
    return self;
}

// FIXME: need optimization
// NOTE: the cards returned contain image and label info
- (NSArray*)getUnclassifiedCards {
	NSArray *categories = self.config.catList;
	NSArray *allCards = self.config.cardList;
	NSMutableSet *classifiedCardIDs = [[NSMutableSet alloc] init];
	
	for (HAMCard *category in categories) {
		NSString *categoryID = category.UUID;
		NSArray *childrenIDs = [self.config childrenOf:categoryID];
		
		for (NSString *childID in childrenIDs)
			[classifiedCardIDs addObject:childID];
	}
	
	NSMutableArray *unclassifiedCards = [[NSMutableArray alloc] init];
	NSMutableArray *allCardIDs = [[NSMutableArray alloc] init];
	for (HAMCard *card in allCards)
		[allCardIDs addObject:card.UUID];
	
	for (NSString *cardID in allCardIDs)
		if (![classifiedCardIDs member:cardID])
			[unclassifiedCards addObject:[self.config card:cardID]];
	
	return (NSArray*) unclassifiedCards;
}

// It's essential to define this accessor method
// ??? Is it?
- (NSArray*) cards {
	if (self.categoryID == nil)
		return [self getUnclassifiedCards];
	else {
		NSArray *childrenIDs = [self.config childrenOf:self.categoryID];
		NSMutableArray *children = [[NSMutableArray alloc] init];
		for (NSString *childID in childrenIDs)
			[children addObject:[self.config card: childID]];
		
		return children;
	}
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
	
	flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
	flowLayout.minimumInteritemSpacing = (gridViewWidth - 3*cellWidth) / 4;
	flowLayout.minimumLineSpacing = (gridViewHeight - 4*cellHeight) / 5;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	flowLayout.sectionInset = UIEdgeInsetsMake(0, interItemSpace, 0, interItemSpace);
    
    [self.collectionView setCollectionViewLayout:flowLayout];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// cannot alter the name of unclassified category
	return (self.cellMode == HAMGridCellModeEdit) && self.categoryID;
}

- (void)viewWillAppear:(BOOL)animated {
	
	// determine which mode we're in
	if (self.slotToReplace == -1)
		self.cellMode = HAMGridCellModeEdit;
	else
		self.cellMode = HAMGridCellModeAdd;
	
	
	if (self.cellMode == HAMGridCellModeEdit) {
		// add a button on the top-right to create new card
		UIBarButtonItem *createCardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(createCardButtonPressed)];
		self.navigationItem.rightBarButtonItem = createCardButton;
	}
	else {
		// FIXME: put this into viewDidLoad?
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
	
	return self.cards.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString* cellID = @"GridCell";
	HAMGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	
	// load the text
	HAMCard *card = self.cards[indexPath.row];
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
	HAMEditNodeViewController *nodeEditor = [[HAMEditNodeViewController alloc] initWithNibName:@"HAMEditNodeViewController" bundle:nil];
	
	nodeEditor.config = self.config;
	// unclassifed cards are directly inserted to the user node
	nodeEditor.parentID = (self.categoryID == nil) ? self.userID : self.categoryID;
	nodeEditor.editMode = HAMCardEditModeCreate;
	nodeEditor.card = nil; //FIXME: this necessary?
	
	[self.navigationController pushViewController:nodeEditor animated:YES];
}

- (void)addCardsButtonPressed {
	// FIXME: this is just testing, should add all the selected cards later
	HAMCard *card = [self.selectedCards anyObject];
	[self.config updateChildOfNode:self.userID with:card.UUID atIndex:self.slotToReplace];
	
	NSArray *viewsInStack = self.navigationController.viewControllers;
	// pop out two views from the navigation stack, including the current one
	[self.navigationController popToViewController:viewsInStack[viewsInStack.count - 3] animated:TRUE];
}

- (void)rightTopButtonPressedForCell:(id)cell {
	HAMGridCell *gridCell = (HAMGridCell*) cell;
	
	if (self.cellMode == HAMGridCellModeAdd) {
		if (gridCell.selected) {
			HAMCard *card = self.cards[gridCell.indexPath.row];
			[self.selectedCards removeObject:card];
			
			gridCell.selected = NO;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"unselected.png"] forState:UIControlStateNormal];
			
			// remove the button on the right of top bar
			if (self.selectedCards.count == 0)
				self.navigationItem.rightBarButtonItem = nil;
		}
		else { // unselected
			// activate the button on the right of top bar
			if (self.selectedCards.count == 0) {
				UIBarButtonItem *addCardsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCardsButtonPressed)];
				self.navigationItem.rightBarButtonItem = addCardsButton;
			}
			
			HAMCard *card = self.cards[gridCell.indexPath.row];
			[self.selectedCards addObject:card];
			
			gridCell.selected = YES;
			[gridCell.rightTopButton setImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
		}
	}
	else { // Mode Edit
		/*HAMEditNodeViewController *nodeEditor = [[HAMEditNodeViewController alloc] initWithNibName:@"HAMEditNodeViewController" bundle:nil];
		
		nodeEditor.config = self.config;
		// unclassifed cards are directly inserted to the user node
		nodeEditor.parentID = (self.categoryID == nil) ? self.userID : self.categoryID;
		nodeEditor.editMode = HAMCardEditModeEdit;
		nodeEditor.card = self.cards[gridCell.indexPath.row];
		
		[self.navigationController pushViewController:nodeEditor animated:YES];*/
		
		HAMCardEditorViewController *cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
		UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:cardEditor];
		navigator.navigationBarHidden = YES;
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:navigator];		
		CGRect rect = CGRectMake(screenWidth/2, screenHeight/2, 1, 1);
		[self.popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

@end
