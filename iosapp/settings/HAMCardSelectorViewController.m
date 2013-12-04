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
		
    // Do any additional setup after loading the view from its nib.
	self.title = @"选择卡片";
	[self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"CardCell"];
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
	static NSString* cellID = @"CardCell";
	HAMGridCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	
	// load the text
	HAMCard *card = [self.config card:[self cardIDs][indexPath.row]];
	cell.textLabel.text = card.name;
	
	cell.contentImageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
	cell.frameImageView.image = [UIImage imageNamed:@"cardBG.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"unselected.png"]forState:UIControlStateNormal];
	else { // Mode edit
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
		
		// don't allow editing system-provided categories or cards
		// FIXME: not working
		//if (! card.isRemovable_)
		//	cell.rightTopButton.hidden = TRUE;
	}
	
	cell.indexPath = indexPath;
	cell.selected = NO;
	cell.delegate = self;
	
	return cell;
}

- (void)createCardButtonPressed {
	
	[MobClick event:@"create_card"]; // trace the event
	
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
	
	int animation = [self.config animationOfCat:self.userID atIndex:self.index]; // keep the animation unchanged
	NSMutableArray *rooms = [[NSMutableArray alloc] initWithCapacity:self.selectedCardIDs.count];
	// retain the order of selection
	for (NSString *cardID in [self cardIDs])
		if ([self.selectedCardIDs containsObject:cardID])
			[rooms addObject:[[HAMRoom alloc] initWithCardID:cardID animation:animation]];
	
	// insert all the selected cards
	[self.config insertChildren:rooms intoCat:self.userID atIndex:self.index];
	
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
	[self.collectionView reloadData];
}

@end
