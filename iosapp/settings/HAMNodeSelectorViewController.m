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

@synthesize config;
@synthesize parentID;
@synthesize index;
//@synthesize deleteBtn;

@synthesize editNodeController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray*) categories {
	NSMutableArray *categories = [NSMutableArray arrayWithArray:config.catList];
	
	HAMCard *unclassified = [[HAMCard alloc] init];
	unclassified.name = @"未分类";
	unclassified.UUID = nil; // use nil to identify unclassified category
	// put the unclassified category in the first slot
	[categories insertObject:unclassified atIndex:0];
	
	return categories;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Lei: use this before dequeueReusableCell
    [self.collectionView registerClass:[HAMGridCell class] forCellWithReuseIdentifier:@"GridCell"];
	
    // set the layout of collection view
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	
	flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
	flowLayout.minimumInteritemSpacing = interItemSpace;
	flowLayout.minimumLineSpacing = (gridViewHeight - 4*cellHeight) / 5;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	flowLayout.sectionInset = UIEdgeInsetsMake(0, interItemSpace, 0, interItemSpace);
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
}

-(void)viewWillAppear:(BOOL)animated
{
	if (index == -1)	// edit mode
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
		// FIXME: put this into viewDidLoad?
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


<<<<<<< HEAD
-(NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
=======
-(NSMutableArray*)currentList{
    
    switch (mode) {
        case 0:
            //return [config allList];
            break;
            
        case 1:
            //return [config cardList];
            break;
            
        case 2:
            //return [config catList];
            break;
            
        default:
            break;
    }
    return 0;
}

-(HAMCard*)currentListAt:(int)pos
>>>>>>> upstream/master
{
	return self.categories.count;
}


-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID=@"GridCell";
    HAMGridCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
	   
  	HAMCard *category = self.categories[indexPath.row]; // only display categories
    cell.textLabel.text = category.name;
	cell.frameImageView.image = [UIImage imageNamed:@"category.png"];
	if (self.cellMode == HAMGridCellModeAdd)
		[cell.rightTopButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
	else
		[cell.rightTopButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
	
	// don't allow to edit the unclassified category
	if (category.UUID == nil && self.cellMode == HAMGridCellModeEdit)
		cell.rightTopButton.hidden = TRUE;
	
	cell.indexPath = indexPath;
	cell.delegate = self;
	cell.selected = NO; // redundant?
	
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

<<<<<<< HEAD
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
=======
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=[indexPath row];
    NSString* childID;
    if (index!=-1 && row==0)
        childID=nil;
    else
    {
        childID=[[self currentListAt:row] UUID];
    }
    
    if ([childID isEqualToString:config.rootID])
    {
         [cardListTableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (index!=-1)
    {
        [config updateRoomOfCat:parentID with:[[HAMRoom alloc] initWithCardID:childID animation:ROOM_ANIMATION_SCALE] atIndex:index];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self gotoEditNode:childID];
    }
}

-(void)updateTableNewRow:(int)newRowNum oldRow:(int)oldRowNum
>>>>>>> upstream/master
{
	HAMCard *category = self.categories[indexPath.row];
	
	HAMCardSelectorViewController *cardSelector = [[HAMCardSelectorViewController alloc] init];
	//FIXME: should I assign to those properties outside the initializer?
	cardSelector.categoryID = category.UUID;
	cardSelector.config = self.config;
	cardSelector.userID = self.parentID;
	cardSelector.slotToReplace = self.index;
	
	// show cards of the specific category
	[self.navigationController pushViewController:cardSelector animated:YES];
}

- (void)createItemButtonPressed {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建卡片", @"创建分类", nil];
	[actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // create card
		HAMEditNodeViewController *nodeEditor = [[HAMEditNodeViewController alloc] initWithNibName:@"HAMEditNodeViewController" bundle:nil];
		
		nodeEditor.config = self.config;
		// unclassifed cards are directly inserted to the user node
		nodeEditor.parentID = self.parentID;
		nodeEditor.editMode = HAMCardEditModeCreate;
		nodeEditor.card = nil; //FIXME: this necessary?
		
		[self.navigationController pushViewController:nodeEditor animated:YES];
	}
	else if (buttonIndex == 1) { // create category
		// TODO
	}
	NSLog(@"%d", buttonIndex);
}

- (void)rightTopButtonPressedForCell:(id)cell {
	HAMGridCell *gridCell = (HAMGridCell*) cell;
	
	if (self.cellMode == HAMGridCellModeAdd) {
		HAMCard *category = self.categories[gridCell.indexPath.row];
		
		[config updateChildOfNode:parentID with:category.UUID atIndex:index];
		[self.navigationController popViewControllerAnimated:TRUE];
	}
	else { // Mode Edit
		HAMCategoryEditorViewController *categoryEditor = [[HAMCategoryEditorViewController alloc] initWithNibName:@"HAMCategoryEditorViewController" bundle:nil];
		
		self.popover = [[UIPopoverController alloc] initWithContentViewController:categoryEditor];
		[self.popover setPopoverContentSize:categoryEditor.view.frame.size];
		CGRect rect = CGRectMake(screenWidth/2, screenHeight/2, 1, 1);
		// FIXME: the arrow direction
		[self.popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
	}
}

@end
