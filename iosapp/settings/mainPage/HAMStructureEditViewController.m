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
- (void)newCoursewareNotification:(NSNotification*)notification;
- (void)updateCoursewareNotification:(NSNotification*)notification;
- (void)updateCoursewareLayoutNotification:(NSNotification*)notification;
- (void)deleteCoursewareNotification:(NSNotification*)notification;
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
@synthesize createCardButton;
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
    if (!config)
        [self initWithConfig];
    
    [self refreshCoursewareSelect];
    
    if (refreshFlag)
    {
        currentUUID=config.rootID;
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
    createCardButton.hidden = YES;
//    [HAMViewTool setHighLightImage:@"parent_main_settingsbtn_down.png" forButton:settingsButton];
    
    self.coursewareSelectView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCoursewareNotification:) name:HAMUser_NewUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoursewareNotification:) name:HAMUser_UpdateUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoursewareLayoutNotification:) name:HAMUser_UpdateLayout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCoursewareNotification) name:HAMUser_DeleteUser object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initWithConfig
{
    config=[[HAMConfig alloc] initFromDB];
    if(!config)
    {
        [self syncButtonClicked:nil];
        return;
    }
    
    //user
    coursewareManager=config.userManager;
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

- (IBAction)newCardClicked:(UIButton *)sender {

}

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

-(IBAction) editClicked:(id)sender
{
    HAMEditCardPopoverViewController* editCardPopover;
    HAMEditCatPopoverViewController* editCatPopover;
    
    int childIndex = [sender tag];
    HAMCard* card = [config card:[config childCardIDOfCat:currentUUID atIndex:childIndex]];
    
    switch (card.type) {
        case CARD_TYPE_CARD:
            editCardPopover = [[HAMEditCardPopoverViewController alloc] initWithNibName:@"HAMEditCardPopoverViewController" bundle:nil];
            editCardPopover.parentID_ = currentUUID;
            editCardPopover.childIndex_ = childIndex;
            editCardPopover.config_ = config;
            editCardPopover.mainSettingsViewController_ = self;
            
            [self presentPopoverWithPopoverViewController:editCardPopover];
            break;
            
        case CARD_TYPE_CATEGORY:
            editCatPopover = [[HAMEditCatPopoverViewController alloc] initWithNibName:@"HAMEditCatPopoverViewController" bundle:nil];
            editCatPopover.parentID_ = currentUUID;
            editCatPopover.childIndex_ = childIndex;
            editCatPopover.config_ = config;
            editCatPopover.mainSettingsViewController_ = self;
            
            [self presentPopoverWithPopoverViewController:editCatPopover];
            break;
    }
    
}

#pragma mark -
#pragma mark Card Clicked

-(IBAction) groupClicked:(id)sender{
    int index=[sender tag];
    currentUUID=[config childCardIDOfCat:currentUUID atIndex:index];
    
    [self enterCat];
    [self refreshGridViewAndScrollToFirstPage:YES];
}

-(IBAction) leafClicked:(id)sender{
//    [HAMViewTool showAlert:@"长按可以进入替换。"];
}

-(IBAction) addClicked:(id)sender
{
    HAMAddCardPopoverViewController* addCardPopover = [[HAMAddCardPopoverViewController alloc] initWithNibName:@"HAMAddCardPopoverViewController" bundle:nil];
    addCardPopover.mainSettingsViewController_ = self;
    addCardPopover.cardIndex_ = [sender tag];
    addCardPopover.config_ = config;
    addCardPopover.parentID_ = currentUUID;
    
    [self presentPopoverWithPopoverViewController:addCardPopover];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
    syncViewController.config=config;
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
    dragableView=[[HAMEditableGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:YES];
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
    currentUUID=config.rootID;
    
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
    HAMUser* courseware = [coursewareArray objectAtIndex:row];
    cell.textLabel.text = courseware.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HAMUser* courseware =[coursewareArray objectAtIndex:[indexPath row]];
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

#pragma mark -
#pragma mark Goto View

-(void)enterLibAt:(int)index
{
    if (selectorViewController==nil)
    {
        selectorViewController=[[HAMCategorySelectorViewController alloc]initWithNibName:@"HAMGridViewController" bundle:nil];
    }
    selectorViewController.config=config;
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
