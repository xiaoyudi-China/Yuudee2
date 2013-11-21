//
//  HAMViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//768*1000
//

#import "HAMViewController.h"
#import "HAMFileTools.h"

@interface HAMViewController ()
						
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;
@end

@implementation HAMViewController
@synthesize scrollView_;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    activeUsername=@"hamster";
}

-(void)viewWillAppear:(BOOL)animated
{    
    config=[[HAMConfig alloc] initFromDB];
    currentUUID=config.rootID;
    if (!config)
        return;
    
    userManager=[HAMUserManager new];
    userManager.config=config;
    
    HAMUser* currentUser=userManager.currentUser;
    
    HAMViewInfo* viewInfo=[[HAMViewInfo alloc] initWithframe:[self.view frame] xnum:currentUser.layoutx ynum:currentUser.layouty h:0 minspace:30];    
    gridViewTool=[[HAMGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:NO];
    [gridViewTool refreshView:currentUUID];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(IBAction) groupClicked:(id)sender{
    int index=[sender tag];
    if (index==-1)
        currentUUID=config.rootID;
    else
        currentUUID=[config childCardIDOfCat:currentUUID atIndex:index];
    
    [gridViewTool refreshView:currentUUID];
}

-(IBAction) leafClicked:(id)sender{
    
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    int index = [sender tag];
    HAMRoom* room = [config roomOfCat:currentUUID atIndex:index];
    
    UIView* cardView = [[gridViewTool viewArray] objectAtIndex:index];
    [HAMAnimation beginAnimation:room.animation_ onCardView:cardView];
    
    //NSString *musicPath= [[NSBundle mainBundle] pathForResource:[[card audio] localPath] ofType:@""];
    HAMCard* card = [config card:room.cardID_];
    NSString* musicPath=[HAMFileTools filePath:[[card audio] localPath]];
    
    if (musicPath){
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
}

@end