//
//  HAMStructureEditViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMStructureEditViewController.h"

@interface HAMStructureEditViewController ()
{
    //NSMutableArray* viewArray;
    UIPopoverController* popover;
    NSMutableArray* coursewareArray;
}
@end

@implementation HAMStructureEditViewController

@synthesize scrollView_;
@synthesize coursewareTableView;
@synthesize coursewareSelectView;
@synthesize inCatWoodImageView;
@synthesize bgImageView;

@synthesize syncViewController;
@synthesize selectorViewController;

@synthesize endEditButton;
@synthesize settingsButton;
@synthesize libButton;
@synthesize coursewareNameLabel;
@synthesize coursewareSelectButton;
@synthesize backToRootButton;

@synthesize currentUUID;

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
        currentUUID= self.config.rootID;
        refreshFlag=NO;
        [self exitCat];
    }
    
    if (currentUUID)
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
	self.aboutOptionsView.hidden = YES;
}

-(void)initWithConfig
{
    self.config=[[HAMConfig alloc] initFromDB];
    if(! self.config)
    {
        [self syncButtonClicked:nil];
        return;
    }
    
    //user
    coursewareManager= self.config.userManager;
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

- (IBAction)libClicked:(UIButton *)sender {
    [self enterLibAt:-1];
}

#pragma mark -
#pragma mark Settings

- (IBAction)settingsClicked:(UIButton *)sender {
    HAMCoursewareSettingsPopoverViewController* coursewareSettingsPopover = [[HAMCoursewareSettingsPopoverViewController alloc] initWithNibName:@"HAMCoursewareSettingsPopoverViewController" bundle:nil];
    coursewareSettingsPopover.mainSettingsViewController = self;
    coursewareSettingsPopover.coursewareManager = coursewareManager;
    
    [self presentPopoverWithPopoverViewController:coursewareSettingsPopover];
}

#pragma mark -
#pragma mark Edit


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (IBAction)syncButtonClicked:(UIBarButtonItem *)sender {
    //check for wifi status
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]==NotReachable){
        [HAMViewTool showAlert:@"无法进行同步：Wi-Fi不可用。"];
        return;
    }

    if (syncViewController==nil)
    {
        syncViewController=[[HAMSyncViewController alloc]initWithNibName:@"HAMSyncViewController" bundle:nil];
    }
    syncViewController.config= self.config;
    refreshFlag=YES;
    [self.navigationController pushViewController:syncViewController animated:YES];
}

#pragma mark -
#pragma mark Grid View

- (void)initGridView
{
    HAMUser* currentUser=[coursewareManager currentUser];
    
    //grid view
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    dragableView=[[HAMEditableGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:self.config delegate:self edit:YES];
}

- (void)refreshGridViewAndScrollToFirstPage:(Boolean)scrollToFirstPage
{
    [dragableView refreshView:currentUUID scrollToFirstPage:scrollToFirstPage];
}

- (void)setLayoutWithxnum:(int)xnum ynum:(int)ynum
{
    [dragableView setLayoutWithxnum:xnum ynum:ynum];
}

- (void)backToRootClicked:(UIButton *)sender{
    currentUUID= self.config.rootID;
    
    [self exitCat];
    
    [self refreshGridViewAndScrollToFirstPage:YES];
}

-(void)exitCat{
    inCatWoodImageView.hidden = YES;
    backToRootButton.hidden = YES;
//    bgImageView.image = [UIImage imageNamed:@"parent_main_bg"];
}

- (void)enterCat{
    inCatWoodImageView.hidden = NO;
    backToRootButton.hidden = NO;
//    bgImageView.image = [UIImage imageNamed:@"child_inCat_blurBG"];
}

#pragma mark -
#pragma mark Courseware Select & Create

- (void)refreshCoursewareSelect
{
    coursewareNameLabel.text = [coursewareManager currentUser].name;
    coursewareArray = [coursewareManager userList];
    [coursewareTableView reloadData];
}

- (IBAction)coursewareSelectClicked:(UIButton *)sender {
    if (coursewareSelectView.hidden) {
        coursewareSelectView.hidden = NO;
        [coursewareSelectButton setImage:[UIImage imageNamed:@"parent_main_titlefoldbtn.png"] forState:UIControlStateNormal];
    }
    else {
        coursewareSelectView.hidden = YES;
        [coursewareSelectButton setImage:[UIImage imageNamed:@"parent_main_titleunfoldbtn.png"] forState:UIControlStateNormal];
    }
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return coursewareArray.count;
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
    HAMUser* courseware = coursewareArray[row];
    cell.textLabel.text = courseware.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAMUser* courseware =coursewareArray[[indexPath row]];
    [coursewareManager setCurrentUser:courseware];
    
    [self initGridView];
    refreshFlag = YES;
    [self viewWillAppear:YES];
    [self coursewareSelectClicked:nil];
}

- (IBAction)coursewareCreateClicked:(UIButton *)sender {
    HAMCreateCoursewarePopoverViewController* createCoursewarePopover = [[HAMCreateCoursewarePopoverViewController alloc] initWithNibName:@"HAMCreateCoursewarePopoverViewController" bundle:nil];
    createCoursewarePopover.mainSettingsViewController = self;
    createCoursewarePopover.coursewareManager = coursewareManager;
    
    [self presentPopoverWithPopoverViewController:createCoursewarePopover];
}

- (IBAction)aboutButtonPressed:(id)sender {
	self.aboutOptionsView.hidden = ! self.aboutOptionsView.hidden; // reverse its state
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

- (void)exportCards { // FIXME: some cards seem to be not exported
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
		[self performSelectorOnMainThread:@selector(updateExportProgress:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:NO];
		
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

#pragma mark -
#pragma mark Goto View

-(void)enterLibAt:(int)index
{
    if (selectorViewController==nil)
    {
        selectorViewController=[[HAMCategorySelectorViewController alloc]initWithNibName:@"HAMGridViewController" bundle:nil];
    }
    selectorViewController.config = self.config;
    selectorViewController.parentID=currentUUID;
    selectorViewController.index=index;
    
    [self.navigationController pushViewController:selectorViewController animated:YES];
}

#pragma mark -
#pragma mark Notification
- (void)newCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    coursewareArray = [coursewareManager userList];
    [coursewareTableView reloadData];
    for (NSUInteger itemCount = 0; itemCount < [coursewareArray count]; itemCount--) {
        NSUInteger index = [coursewareArray count] - itemCount - 1; // 倒序，加快速度
        HAMUser *courseware = coursewareArray[index];
        if ([courseware.UUID isEqualToString:userUUID]) {
            [coursewareManager setCurrentUser:courseware];
            
            [self initGridView];
            refreshFlag = YES;
            [self viewWillAppear:YES];
            [self coursewareSelectClicked:coursewareSelectButton];
            [coursewareTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
            break;
        }
    }
}

- (void)updateCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    HAMUser *courseware = [coursewareManager currentUser];
    if ([courseware.UUID isEqualToString:userUUID]) {
        coursewareNameLabel.text = courseware.name;
        for (NSUInteger index = 0; index < [coursewareArray count]; index++) {
            HAMUser *theCourseware = [coursewareArray objectAtIndex:index];
            if ([theCourseware.UUID isEqualToString:courseware.UUID]) {
                theCourseware.name = courseware.name;
                NSIndexPath  *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
                NSArray      *indexArray=[NSArray  arrayWithObject:indexPath];
                [coursewareTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
}

- (void)updateCoursewareLayoutNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    HAMUser *courseware = [coursewareManager currentUser];
    if ([courseware.UUID isEqualToString:userUUID]) {
        [self setLayoutWithxnum:courseware.layoutx ynum:courseware.layouty];
        [self refreshGridViewAndScrollToFirstPage:YES];
    }
}

- (void)deleteCoursewareNotification:(NSNotification*)notification
{
    NSString *userUUID = [notification object];
    for (NSUInteger index = 0; index < [coursewareArray count]; index++) {
        HAMUser *theCourseware = [coursewareArray objectAtIndex:index];
        if ([theCourseware.UUID isEqualToString:userUUID]) {
            NSInteger lastIndex = index - 1;
            lastIndex = lastIndex >= 0 ? lastIndex : NSNotFound;
            if (lastIndex != NSNotFound) {
                HAMUser *theLastCourseware = [coursewareArray objectAtIndex:lastIndex];
                [coursewareManager setCurrentUser:theLastCourseware];
            } else {
                coursewareNameLabel.text = nil;
                [coursewareManager setCurrentUser:nil];
            }
            
            [self initGridView];
            refreshFlag = YES;
            [self viewWillAppear:YES];
            
            break;
        }
    }
}
@end
