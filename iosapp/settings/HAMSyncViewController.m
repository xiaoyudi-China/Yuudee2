//
//  HAMSyncViewController.m
//  iosapp
//
//  Created by daiyue on 13-8-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMSyncViewController.h"

@interface HAMSyncViewController ()

@end

@implementation HAMSyncViewController

@synthesize config;
@synthesize infoLabel;
@synthesize titleLabel;
@synthesize wifiStatus;
@synthesize loadingProgressView;
@synthesize loadingSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"网络同步";
    webTool=[HAMWebTool new];
    dbManager=[HAMDBManager new];
    //hostReach =[Reachability reachabilityWithHostName:@"www.baidu.com"];
}

- (void)viewWillAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reachabilityChanged:) name:@"HAMReachabilityChangedNotification" object:nil];
    //[hostReach startNotifier];
    [self viewUpdate:-1];
    [[[UIAlertView alloc] initWithTitle:@"进行同步" message:@"确定要进行同步吗？将清除之前所有的数据。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"同步",nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:{
            //begin sync
            [self manifest];
        }break;
        default:{
            [[self navigationController] popViewControllerAnimated:NO];
        }
            break;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"HAMReachabilityChangedNotification" object:nil];
    //[hostReach stopNotifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    webTool=nil;
    idList=nil;
    dbManager=nil;
    
    [self setInfoLabel:nil];
    [self setLoadingSpinner:nil];
    [self setLoadingProgressView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

#pragma mark
#pragma mark View Update

-(void)viewUpdate:(int)stage
{
    switch (stage) {
        case -1:
            titleLabel.text=@"准备同步";
            infoLabel.text=@"正在等待同步开始……";
            [loadingSpinner startAnimating];
            loadingSpinner.hidden=NO;
            infoLabel.hidden=NO;
            loadingProgressView.hidden=true;
            break;
            
        case 0:
            titleLabel.text=@"同步中: 第1步/共3步";
            infoLabel.text=@"正在加载清单文件……";
            break;
            
        case 1:
            titleLabel.text=@"同步中: 第2步/共3步";
            [loadingSpinner startAnimating];
            loadingProgressView.hidden=false;
            break;
            
        case 2:
        {
            int totalResourceNum=[idList count];
            infoLabel.text=[[NSString alloc] initWithFormat:@"正在加载资源文件: (%d/%d)",currentResourceNum+1,totalResourceNum];
            loadingProgressView.progress=(currentResourceNum+0.0f)/totalResourceNum;
            break;
        }
            
        case 3:
            titleLabel.text=@"同步失败";
            infoLabel.text=@"加载清单文件出错。";
            [loadingSpinner stopAnimating];
            loadingSpinner.hidden=YES;
            break;
            
        case 4:
            titleLabel.text=@"同步中: 第3步/共3步";
            infoLabel.text=@"正在加载数据库脚本……";
            loadingProgressView.hidden=true;
            break;
            
        case 5:
            titleLabel.text=@"同步中: 第3步/共3步";
            infoLabel.text=@"正在执行数据库脚本……";
            break;
            
        case 6:
            titleLabel.text=@"同步完成";
            infoLabel.hidden=YES;
            [loadingSpinner stopAnimating];
            loadingSpinner.hidden=YES;
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark Wi-fi Status

-(void)updateStatus{
    wifiStatus=[[Reachability reachabilityForLocalWiFi]currentReachabilityStatus];
}

-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus status=[curReach currentReachabilityStatus];
    
    if (status==NotReachable)
    {
        [HAMViewTool showAlert:@"无法进行同步：Wi-Fi已断开！"];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark
#pragma mark Resources Sync

-(void)manifest
{
    [self viewUpdate:0];
    [webTool dataFromUrl:[[NSString alloc] initWithFormat:@"http://%@/manifest/%@",ADDRESS,USERNAME] sel:@selector(parseManifest:error:) handle:self];
}

-(void)parseManifest:(NSMutableData*)manifestData error:(NSError*)error
{
    if (error)
    {
        [self viewUpdate:3];
        infoLabel.text=[[NSString alloc] initWithFormat:@"加载清单文件出错: %@",[error localizedDescription]];
        return;
    }
    
    NSDictionary* manifest=[HAMTools jsonFromData:manifestData];
    if (!manifest)
    {
        [self viewUpdate:3];
        return;
    }
    //get resourceid list
    NSArray* resources=[manifest objectForKey:@"resources"];
    int i;
    idList=[NSMutableArray arrayWithCapacity:[resources count]];
    NSDictionary* resource;
    int totalResourceNum=[resources count];
    for (i=0;i<totalResourceNum;i++)
    {
        resource=[resources objectAtIndex:i];
        [idList addObject:[resource objectForKey:@"id"]];
    }
    currentResourceNum=0;
    [self viewUpdate:1];
    
    //get each resource
    [self performSelectorInBackground:@selector(resource) withObject:nil];
}

-(void)resource
{
    [self viewUpdate:2];
    //no resource
    if ([idList count]<=currentResourceNum)
    {
        [self SQLScript];
        return;
    }
    
    [webTool dataFromUrl:[[NSString alloc] initWithFormat:@"http://%@/file/%@",ADDRESS,idList[currentResourceNum]] sel:@selector(gotResource:error:) handle:self];
}

-(void)gotResource:(NSMutableData*)resourceData error:(NSError*)error
{
    if (error)
    {
        [self viewUpdate:3];
        infoLabel.text=[[NSString alloc] initWithFormat:@"加载资源文件出错: %@",[error localizedDescription]];
        return;
    }
    
    [resourceData writeToFile:[HAMFileTools filePath:idList[currentResourceNum]] atomically:YES];
    
    currentResourceNum++;
    if (currentResourceNum>=[idList count])
    {
        [self SQLScript];
        return;
    }
    [self performSelectorInBackground:@selector(resource) withObject:nil];
}

#pragma mark -
#pragma mark DB Sync

-(void)SQLScript
{
    [self viewUpdate:4];
    [webTool dataFromUrl:[[NSString alloc] initWithFormat:@"http://%@/sql/%@",ADDRESS,USERNAME] sel:@selector(runSQLScript:error:) handle:self];
}

-(void)runSQLScript:(NSMutableData*)scriptData error:(NSError*)error
{
    if (error)
    {
        [self viewUpdate:3];
        infoLabel.text=[[NSString alloc] initWithFormat:@"加载数据库脚本出错: %@",[error localizedDescription]];
        return;
    }
    
    NSString *rawScript=[[NSString alloc] initWithData:scriptData encoding:NSUTF8StringEncoding];
    NSArray* scripts=[rawScript componentsSeparatedByString:@";"];
    int scriptnum=[scripts count];
    int i;
    for (i=0;i<scriptnum;i++)
    {
        [dbManager runSQL:scripts[i]];
    }
    
    if (config)
        [config clear];
    
    [self viewUpdate:6];
}

@end
