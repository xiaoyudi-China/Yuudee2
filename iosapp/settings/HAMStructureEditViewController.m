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
    int selectedTag_;
}
@end

@implementation HAMStructureEditViewController

@synthesize scrollView_;

@synthesize selectorViewController;
@synthesize syncViewController;
@synthesize userViewController;

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
    
    if (refreshFlag)
    {
        currentUUID=config.rootID;
        refreshFlag=NO;
    }
    
    if (currentUUID)
        [self refreshGridView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIBarButtonItem* userBtn = [[UIBarButtonItem alloc] initWithTitle:@"更换用户" style:UIBarButtonItemStyleBordered target:self action:@selector(userBtnClicked:)];
    self.navigationItem.rightBarButtonItem = userBtn;
    
    self.title=@"词条库设置";
    refreshFlag=YES;
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
    userManager=config.userManager;
    HAMUser* currentUser=[userManager currentUser];
    
    //grid view
    HAMViewInfo* viewInfo=[[HAMViewInfo alloc] initWithframe:scrollView_.frame xnum:currentUser.layoutx ynum:currentUser.layouty h:0 minspace:30];
    dragableView=[[HAMEditableGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

-(IBAction) groupClicked:(id)sender{
    int index=[sender tag];
    if (index==-1)
        currentUUID=config.rootID;
    else
        currentUUID=[config childCardIDOfCat:currentUUID atIndex:index];
    
    [self refreshGridView];
}

-(IBAction) leafClicked:(id)sender{
    [HAMViewTool showAlert:@"长按可以进入替换。"];
}

-(IBAction) addClicked:(id)sender
{
    [self gotoSelectorAt:[sender tag]];
}

-(IBAction) editClicked:(id)sender
{
    UIAlertView* editAlert;
    selectedTag_ = [sender tag];
    
    HAMCard* selectedCard = [config card:[config childCardIDOfCat:currentUUID atIndex:selectedTag_]];
    
    if (selectedCard.type == CARD_TYPE_CATEGORY) {
        editAlert =[[UIAlertView alloc] initWithTitle:@"更改" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"编辑该分类",@"清除该分类",nil];
    }
    else{
        NSString* animation;
        switch ([config animationOfCat:currentUUID atIndex:selectedTag_]) {
            case ROOM_ANIMATION_SCALE:
                animation = @"放大效果";
                break;
            
            case ROOM_ANIMATION_SHAKE:
                animation = @"摇晃效果";
                break;
                
            case ROOM_ANIMATION_NONE:
                animation = @"无效果";
                break;
                
            default:
                animation = @"?";
                break;
        }
        
        editAlert =[[UIAlertView alloc] initWithTitle:@"更改" message:[[NSString alloc] initWithFormat:@"当前动画效果为：%@",animation] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"编辑该卡片",@"清除该卡片",@"更改动画效果",nil];
    }
    
    editAlert.tag=2;
    [editAlert show];
}

- (IBAction)newNodeAction:(UIBarButtonItem *)sender {
    UIAlertView* newNodeAlert=[[UIAlertView alloc] initWithTitle:@"新建" message:@"现在新建一个..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"词条",@"分类",nil];
    newNodeAlert.tag=0;
    [newNodeAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int xnum=-1,ynum=-1;
    UIAlertView* changeAnimationAlert;
    int animation;
    switch (alertView.tag) {
        case 0:
            //newNodeAlert
            break;
        
        case 1:
            //changeLayoutAlert
            
            switch (buttonIndex) {
                case 1:
                    //2x2
                    xnum=2;
                    ynum=2;
                    break;
                case 2:
                    //2x3
                    xnum=2;
                    ynum=3;
                    break;
                case 3:
                    //3x3
                    xnum=3;
                    ynum=3;
                    break;
                case 4:
                    //3x4
                    xnum=3;
                    ynum=4;
                    break;
                    
                default:
                    break;
            }
            if (xnum!=-1 && ynum!=-1)
            {
                [userManager updateCurrentUserLayoutxnum:xnum ynum:ynum];
                [dragableView setLayoutWithxnum:xnum ynum:ynum];
                [self refreshGridView];
            }
            break;
            
        case 2:
            //editAlert
            
            switch (buttonIndex) {
                case 1:
                    //edit card here
                    
                    break;
                    
                case 2:
                    //delete card here
                    [config updateRoomOfCat:currentUUID with:nil atIndex:selectedTag_];
                    [dragableView refreshView:currentUUID scrollToFirstPage:NO];
                    break;
                    
                case 3:
                    //change animation here
                    changeAnimationAlert = [[UIAlertView alloc] initWithTitle:@"更改动画效果" message:@"更改为:" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放大效果",@"摇晃效果",@"无效果",nil];
                    changeAnimationAlert.tag = 3;
                    [changeAnimationAlert show];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 3:
            //changeAnimationAlert
            switch (buttonIndex) {
                case 1:
                    //scale
                    animation = ROOM_ANIMATION_SCALE;
                    break;
                    
                case 2:
                    //scale and shake
                    animation = ROOM_ANIMATION_SHAKE;
                    break;
                    
                case 3:
                    //none
                    animation = ROOM_ANIMATION_NONE;
                    break;
                    
                default:
                    //cancel
                    animation = -1;
                    break;
            }
            if (animation != -1)
                [config updateAnimationOfCat:currentUUID with:animation atIndex:selectedTag_];
            
            break;
            
        default:
            break;
    }
    
}

- (IBAction)editNodeAction:(UIBarButtonItem *)sender {
    [self gotoSelectorAt:-1];
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

- (IBAction)changeLayoutClicked:(UIBarButtonItem *)sender {
    UIAlertView* changeLayoutAlert=[[UIAlertView alloc] initWithTitle:@"布局" message:@"更改布局为..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"2x2",@"2x3",@"3x3",@"3x4",nil];
    changeLayoutAlert.tag=1;
    [changeLayoutAlert show];
}

-(IBAction)userBtnClicked:(UIBarButtonItem*)sender
{
    if (userViewController==nil)
    {
        userViewController=[[HAMUserViewController alloc]initWithNibName:@"HAMUserViewController" bundle:nil];
        userViewController.userManager=userManager;
    }
    refreshFlag=YES;
    [self.navigationController pushViewController:userViewController animated:YES];
}


#pragma mark -
#pragma mark Goto View

-(void)refreshGridView
{
    [dragableView refreshView:currentUUID scrollToFirstPage:YES];
    //viewArray = dragableView.viewArray_;
}

-(void)gotoSelectorAt:(int)index
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

@end
