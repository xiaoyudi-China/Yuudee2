//
//  HAMStructureEditViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMSettingsViewController.h"

@interface HAMSettingsViewController ()
{
    //NSMutableArray* viewArray;
    UIPopoverController* popover;
}

- (void)newCoursewareNotification:(NSNotification*)notification;
- (void)updateCoursewareNotification:(NSNotification*)notification;
- (void)updateCoursewareLayoutNotification:(NSNotification*)notification;
- (void)deleteCoursewareNotification:(NSNotification*)notification;

@end

@implementation HAMSettingsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    if (! self.config)
        [self initWithConfig];
    
    [self refreshCoursewareSelect];
    
    if (refreshFlag)
    {
        self.currentUUID = self.config.rootID;
        refreshFlag=NO;
        [self exitCategory];
    }
    
    if (self.currentUUID)
        [self refreshGridViewAndScrollToFirstPage:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    refreshFlag=YES;
    
//    [HAMViewTool setHighLightImage:@"parent_main_endbtn_down.png" forButton:endEditButton];
//    [HAMViewTool setHighLightImage:@"parent_main_addbtn_down.png" forButton:createCardButton];
//    createCardButton.hidden = YES;
//    [HAMViewTool setHighLightImage:@"parent_main_settingsbtn_down.png" forButton:settingsButton];
    
    self.coursewareSelectView.hidden = YES;
	self.aboutMenuView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCoursewareNotification:) name:HAMUser_NewUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoursewareNotification:) name:HAMUser_UpdateUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoursewareLayoutNotification:) name:HAMUser_UpdateLayout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCoursewareNotification:) name:HAMUser_DeleteUser object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
}

-(void)initWithConfig
{
    self.config=[[HAMConfig alloc] initFromDB];
    if(! self.config)
    {
        return;
    }
    
    //user
    self.coursewareManager = self.config.userManager;
    [self initGridView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)presentPopoverWithPopoverViewController:(UIViewController*)popoverViewController
{
    UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:popoverViewController];
    navigator.navigationBarHidden = YES;
    
    popover = [[UIPopoverController alloc] initWithContentViewController:navigator];
    [popover setContentViewController:navigator animated:YES];
    //FIXME: not safe here.
    [popoverViewController performSelector:@selector(setPopover:) withObject:popover];
    
    //    popover.popoverContentSize = CGSizeMake(587,781);
    //popover.popoverBackgroundViewClass = [HAMPopoverBgView class];
    popover.popoverContentSize = CGSizeMake(768,1024);
    popover.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    popover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:YES];
}

#pragma mark -
#pragma mark End Edit

- (IBAction)endEditClicked:(UIButton *)sender {
    HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    [delegate turnToChildView];
}

#pragma mark -
#pragma mark Enter Lib

// FIXME: remove this useless method
- (void)newCardClicked:(UIButton *)sender {
}

- (IBAction)libClicked:(UIButton *)sender {
    [self enterLibAt:-1];
}

#pragma mark -
#pragma mark Settings

- (IBAction)settingsClicked:(UIButton *)sender {
    HAMCoursewareSettingsPopoverViewController* coursewareSettingsPopover = [[HAMCoursewareSettingsPopoverViewController alloc] initWithNibName:@"HAMCoursewareSettingsPopoverViewController" bundle:nil];
    coursewareSettingsPopover.mainSettingsViewController = self;
    coursewareSettingsPopover.coursewareManager = self.coursewareManager;
    
    [self presentPopoverWithPopoverViewController:coursewareSettingsPopover];
}

#pragma mark -
#pragma mark Edit

-(void) editClicked:(id)sender
{
    HAMEditCardPopoverViewController* editCardPopover;
    HAMEditCatPopoverViewController* editCatPopover;
    
    NSInteger childIndex = [sender tag];
    HAMCard* card = [self.config card:[self.config childCardIDOfCat:self.currentUUID atIndex:childIndex]];
    
    switch (card.type) {
        case CARD_TYPE_CARD:
            editCardPopover = [[HAMEditCardPopoverViewController alloc] initWithNibName:@"HAMEditCardPopoverViewController" bundle:nil];
            editCardPopover.parentID_ = self.currentUUID;
            editCardPopover.childIndex_ = childIndex;
            editCardPopover.config_ = self.config;
            editCardPopover.mainSettingsViewController_ = self;
            
            [self presentPopoverWithPopoverViewController:editCardPopover];
            break;
            
        case CARD_TYPE_CATEGORY:
            editCatPopover = [[HAMEditCatPopoverViewController alloc] initWithNibName:@"HAMEditCatPopoverViewController" bundle:nil];
            editCatPopover.parentID_ = self.currentUUID;
            editCatPopover.childIndex_ = childIndex;
            editCatPopover.config_ = self.config;
            editCatPopover.mainSettingsViewController_ = self;
            
            [self presentPopoverWithPopoverViewController:editCatPopover];
            break;
    }
    
}

#pragma mark -
#pragma mark Card Clicked

-(void) groupClicked:(id)sender{
    NSInteger index=[sender tag];
    self.currentUUID = [self.config childCardIDOfCat:self.currentUUID atIndex:index];
    
    [self enterCategory];
    [self refreshGridViewAndScrollToFirstPage:YES];
}

// FIXME: remove this useless method
-(void) leafClicked:(id)sender{
	//    [HAMViewTool showAlert:@"长按可以进入替换。"];
}

-(void) addClicked:(id)sender
{
    HAMAddCardPopoverViewController* addCardPopover = [[HAMAddCardPopoverViewController alloc] initWithNibName:@"HAMAddCardPopoverViewController" bundle:nil];
    addCardPopover.mainSettingsViewController_ = self;
    addCardPopover.cardIndex_ = [sender tag];
    addCardPopover.config_ = self.config;
    addCardPopover.parentID_ = self.currentUUID;
    
    [self presentPopoverWithPopoverViewController:addCardPopover];
}

#pragma mark -
#pragma mark Edit


#pragma mark -
#pragma mark Grid View

- (void)initGridView
{
    HAMUser* currentUser = [self.coursewareManager currentUser];
    
    //grid view
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    dragableView=[[HAMEditableGridViewTool alloc] initWithView:self.scrollView viewInfo:viewInfo config:self.config delegate:self edit:YES];
}

- (void)refreshGridViewAndScrollToFirstPage:(Boolean)scrollToFirstPage
{
    [dragableView refreshView:self.currentUUID scrollToFirstPage:scrollToFirstPage];
}

- (void)setLayoutWithxnum:(int)xnum ynum:(int)ynum
{
    [dragableView setLayoutWithxnum:xnum ynum:ynum];
}

- (void)backToRootClicked:(UIButton *)sender{
    self.currentUUID = self.config.rootID;
    
    [self exitCategory];
    
    [self refreshGridViewAndScrollToFirstPage:YES];
}

- (void)exitCategory {
    self.inCatWoodImageView.hidden = YES;
    self.backToRootButton.hidden = YES;
//    bgImageView.image = [UIImage imageNamed:@"parent_main_bg"];
}

- (void)enterCategory {
    self.inCatWoodImageView.hidden = NO;
    self.backToRootButton.hidden = NO;
//    bgImageView.image = [UIImage imageNamed:@"child_inCat_blurBG"];
}

#pragma mark -
#pragma mark Courseware Select & Create

- (void)refreshCoursewareSelect
{
    self.coursewareNameLabel.text = [self.coursewareManager currentUser].name;
    self.coursewareArray = [self.coursewareManager userList];
    [self.coursewareTableView reloadData];
}

- (IBAction)coursewareSelectClicked:(UIButton *)sender {
    if (self.coursewareSelectView.hidden) {
        self.coursewareSelectView.hidden = NO;
        [self.coursewareSelectButton setImage:[UIImage imageNamed:@"parent_main_titlefoldbtn.png"] forState:UIControlStateNormal];
    }
    else {
        self.coursewareSelectView.hidden = YES;
        [self.coursewareSelectButton setImage:[UIImage imageNamed:@"parent_main_titleunfoldbtn.png"] forState:UIControlStateNormal];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coursewareArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellWithIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor colorWithRed:214.0f/255 green:196.0f/255 blue:177.0f/255 alpha:1]];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:52.0f/255 green:25.0f/255 blue:12.0f/255 alpha:1];
    
    NSUInteger row = [indexPath row];
    HAMUser* courseware = self.coursewareArray[row];
    cell.textLabel.text = courseware.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAMUser* courseware = self.coursewareArray[indexPath.row];
    [self.coursewareManager setCurrentUser:courseware];
    
    [self initGridView];
    refreshFlag = YES;
    [self viewWillAppear:YES];
    [self coursewareSelectClicked:nil];
}

- (IBAction)coursewareCreateClicked:(UIButton *)sender {
    HAMCreateCoursewarePopoverViewController* createCoursewarePopover = [[HAMCreateCoursewarePopoverViewController alloc] initWithNibName:@"HAMCreateCoursewarePopoverViewController" bundle:nil];
    createCoursewarePopover.mainSettingsViewController = self;
    createCoursewarePopover.coursewareManager = self.coursewareManager;
    
    [self presentPopoverWithPopoverViewController:createCoursewarePopover];
}

- (IBAction)aboutButtonPressed:(id)sender {
	self.aboutMenuView.hidden = ! self.aboutMenuView.hidden; // reverse its state
}

- (void) displayIntro:(HAMIntroType)type {
	HAMIntroViewController *introPage = [[HAMIntroViewController alloc] init];
	introPage.modalPresentationStyle = UIModalPresentationFullScreen;
	introPage.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	introPage.delegate = self;
	introPage.type = type;
	
	UIView *background = [self.view snapshotViewAfterScreenUpdates:YES];
	[introPage.view insertSubview:background atIndex:0];
	[self presentViewController:introPage animated:YES completion:NULL];

}

- (IBAction)productInfoButtonPressed:(id)sender {
	[self displayIntro:HAMIntroTypeProductInfo];
}

- (IBAction)trainGuideButtonPressed:(id)sender {
	[self displayIntro:HAMIntroTypeTrainGuide];
}

// TODO: not tested yet
- (IBAction)feedbackButtonPressed:(id)sender {
	NSString *appID = @"794832934";
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID]];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
	// Nothing to do, just ensure this method is called
}

// FIXME: some cards seem to be not exported
- (void)exportCards {
	NSMutableArray *allCardIDs = [[NSMutableArray alloc] init];
	NSArray *allCategoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	for (NSString *categoryID in allCategoryIDs) {
		NSArray *cardIDs = [self.config childrenCardIDOfCat:categoryID];
		[allCardIDs addObjectsFromArray:cardIDs];
	}
	
	NSUInteger cardCount = 0;
	for (NSString *cardID in allCardIDs) {
		cardCount ++;
		// update the progress view
		float progress = (float)cardCount / allCardIDs.count;
		[self performSelectorOnMainThread:@selector(updateExportProgress:) withObject:@(progress) waitUntilDone:NO];
		
		HAMCard *card = [self.config card:cardID];
		UIImage *image = [HAMSharedData imageNamed:card.image.localPath];
		UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}
	
	UIAlertView *alertView;
	alertView = [[UIAlertView alloc] initWithTitle:@"素材库已导出" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
	[alertView show];
}

- (void)updateExportProgress:(NSNumber*)progress {
	[self.exportProgressView setProgress:progress.floatValue animated:YES];
}

- (IBAction)exportCardsButtonPressed:(id)sender {
	[self performSelectorInBackground:@selector(exportCards) withObject:nil];
}

- (void)quitIntro:(HAMIntroViewController *)introPage {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)resetButtonPressed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"恢复初始设置？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

// TODO: delete non-default users (coursewares)
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // confirm resetting
		NSArray *categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
		for (NSString *categoryID in categoryIDs) {
			NSArray *cardIDs = [self.config childrenCardIDOfCat:categoryID];
			for (NSString *cardID in cardIDs) {
				HAMCard *card = [self.config card:cardID];
				// delete removable cards
				if (card.isRemovable) {
					NSInteger cardIndex = [cardIDs indexOfObject:cardID];
					[self.config deleteChildOfCatInLib:categoryID atIndex:cardIndex];
				}
			}
			
			HAMCard *category = [self.config card:categoryID];
			// delete removable categories
			if (category.isRemovable) {
				NSInteger categoryIndex = [categoryIDs indexOfObject:categoryID];
				[self.config deleteChildOfCatInLib:LIB_ROOT atIndex:categoryIndex];
			}
		}
		
		NSArray *users = [self.coursewareManager userList];
		for (HAMUser *user in users) {
			// restore to default setting
			[self.coursewareManager updateUser:user withLayoutxnum:USER_DEFAULT_LAYOUTX ynum:USER_DEFAULT_LAYOUTY];
			[self.coursewareManager updateUser:user withMuteState:NO];
		}
		// don't forget to update the current setting immediately
		[self.coursewareManager updateCurrentUserLayoutxnum:USER_DEFAULT_LAYOUTX ynum:USER_DEFAULT_LAYOUTY];
		[self.coursewareManager updateCurrentUserMuteState:NO];
		
		// update the user list
		[self refreshCoursewareSelect];
	}
}

#pragma mark -
#pragma mark Goto View

-(void)enterLibAt:(NSInteger)index
{
    if (! self.selectorViewController)
    {
        self.selectorViewController = [[HAMCategoryGridViewController alloc]initWithNibName:@"HAMGridViewController" bundle:nil];
    }
    self.selectorViewController.config = self.config;
    self.selectorViewController.parentID = self.currentUUID;
    self.selectorViewController.index = index;
    
    [self.navigationController pushViewController:self.selectorViewController animated:YES];
}

#pragma mark -
#pragma mark Notification
- (void)newCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    self.coursewareArray = [self.coursewareManager userList];
    [self.coursewareTableView reloadData];
    for (NSUInteger itemCount = 0; itemCount < [self.coursewareArray count]; itemCount--) {
        NSUInteger index = [self.coursewareArray count] - itemCount - 1; // 倒序，加快速度
        HAMUser *courseware = self.coursewareArray[index];
        if ([courseware.UUID isEqualToString:userUUID]) {
            [self.coursewareManager setCurrentUser:courseware];
            
            [self initGridView];
            refreshFlag = YES;
            [self viewWillAppear:YES];
            [self coursewareSelectClicked:self.coursewareSelectButton];
            [self.coursewareTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            break;
        }
    }
}

- (void)updateCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    HAMUser *courseware = [self.coursewareManager currentUser];
    if ([courseware.UUID isEqualToString:userUUID]) {
        self.coursewareNameLabel.text = courseware.name;
        for (NSUInteger index = 0; index < [self.coursewareArray count]; index++) {
            HAMUser *theCourseware = self.coursewareArray[index];
            if ([theCourseware.UUID isEqualToString:courseware.UUID]) {
                theCourseware.name = courseware.name;
                NSIndexPath  *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                NSArray      *indexArray=@[indexPath];
                [self.coursewareTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
}

- (void)updateCoursewareLayoutNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    HAMUser *courseware = [self.coursewareManager currentUser];
    if ([courseware.UUID isEqualToString:userUUID]) {
        [self setLayoutWithxnum:courseware.layoutx ynum:courseware.layouty];
        [self refreshGridViewAndScrollToFirstPage:YES];
    }
}

- (void)deleteCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    for (NSUInteger index = 0; index < [self.coursewareArray count]; index++) {
        HAMUser *theCourseware = self.coursewareArray[index];
        if ([theCourseware.UUID isEqualToString:userUUID]) {
            NSInteger lastIndex = index - 1;
            lastIndex = lastIndex >= 0 ? lastIndex : NSNotFound;
            if (lastIndex != NSNotFound) {
                HAMUser *theLastCourseware = self.coursewareArray[lastIndex];
                [self.coursewareManager setCurrentUser:theLastCourseware];
            } else {
                self.coursewareNameLabel.text = nil;
                [self.coursewareManager setCurrentUser:nil];
            }
            
            [self initGridView];
            refreshFlag = YES;
            [self viewWillAppear:YES];
            
            break;
        }
    }
}
@end
