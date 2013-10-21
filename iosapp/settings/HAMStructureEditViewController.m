//
//  HAMStructureEditViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMStructureEditViewController.h"

@interface HAMStructureEditViewController ()

@end

@implementation HAMStructureEditViewController

@synthesize selectorViewController;
@synthesize editNodeController;
@synthesize syncViewController;
@synthesize userViewController;

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
        [gridViewTool refreshView:currentUUID];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    CGRect frame = CGRectMake(0, 0, [HAMViewInfo maxx], [HAMViewInfo maxy]-100);
    HAMViewInfo* viewInfo=[[HAMViewInfo alloc] initWithframe:frame xnum:currentUser.layoutx ynum:currentUser.layouty h:0 minspace:30];
    UIView* gridView=[UIView new];
    gridView.frame = frame;
    [self.view addSubview:gridView];
    gridViewTool=[[HAMGridViewTool alloc] initWithView:gridView viewInfo:viewInfo config:config viewController:self edit:YES];
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
        currentUUID=[config childOf:currentUUID at:index];
    
    [gridViewTool refreshView:currentUUID];
}

-(IBAction) leafClicked:(id)sender{
    [HAMViewTool showAlert:@"长按可以进入替换。"];
}

-(IBAction) addClicked:(id)sender
{
    [self gotoSelectorAt:[sender tag]];
}

- (void)longpressStateChanged:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self gotoSelectorAt:[[gestureRecognizer view] tag]];
            break;
        }
        default:
        break;
    }
}

- (IBAction)newNodeAction:(UIBarButtonItem *)sender {
    UIAlertView* newNodeAlert=[[UIAlertView alloc] initWithTitle:@"新建" message:@"现在新建一个..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"词条",@"分类",nil];
    newNodeAlert.tag=0;
    [newNodeAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int xnum=-1,ynum=-1;
    switch (alertView.tag) {
        case 0:
            //newNodeAlert
            switch (buttonIndex) {
                case 1:{
                    [self gotoEditNode:1];
                }break;
                case 2:{
                    [self gotoEditNode:0];
                }break;
                default:
                    break;
            }
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
                [gridViewTool setLayoutWithxnum:xnum ynum:ynum];
                [gridViewTool refreshView:currentUUID];
            }
            
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

-(void)gotoSelectorAt:(int)index
{
    if (selectorViewController==nil)
    {
        selectorViewController=[[HAMNodeSelectorViewController alloc]initWithNibName:@"HAMNodeSelectorViewController" bundle:nil];
    }
    selectorViewController.config=config;
    selectorViewController.parentID=currentUUID;
    selectorViewController.index=index;
    
    [self.navigationController pushViewController:selectorViewController animated:YES];
}

-(void)gotoEditNode:(int)newType
{
    if (editNodeController==nil)
    {
        editNodeController=[[HAMEditNodeViewController alloc]
                            initWithNibName:@"HAMEditNodeViewController" bundle:nil];
        editNodeController.config=config;
    }
    editNodeController.parentID=currentUUID;
    editNodeController.newFlag=newType;
    [self.navigationController pushViewController:editNodeController animated:YES];
}

@end
