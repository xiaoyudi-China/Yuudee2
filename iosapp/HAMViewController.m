//
//  HAMViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMViewController.h"
#import "HAMFileTools.h"

@interface HAMViewController ()
{
    int multiTouchCount;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;
@end

@implementation HAMViewController

@synthesize scrollView_;

@synthesize blurBgImageView;
@synthesize inCatBgImageView;
@synthesize backButton;

- (void)viewDidLoad{
    activeUsername=@"hamster";
    multiTouchCount = 0;
}

-(void)viewWillAppear:(BOOL)animated
{    
    config=[[HAMConfig alloc] initFromDB];
    currentUUID=config.rootID;
    [self hideInCat];
    
    if (!config)
        return;
    
    userManager=[HAMUserManager new];
    userManager.config=config;
    
    HAMUser* currentUser=userManager.currentUser;
    
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    
    gridViewTool=[[HAMGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:NO];
    [gridViewTool refreshView:currentUUID scrollToFirstPage:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)refreshGridViewForCat:(NSString*)catID
{
    currentUUID = catID;
    [gridViewTool refreshView:currentUUID scrollToFirstPage:YES];
}

#pragma mark -
#pragma mark In & out Cat

- (void)showInCat
{
    blurBgImageView.hidden = NO;
    inCatBgImageView.hidden = NO;
    backButton.hidden = NO;
}

- (void)hideInCat
{
    blurBgImageView.hidden = YES;
    inCatBgImageView.hidden = YES;
    backButton.hidden = YES;
}

#pragma mark -
#pragma mark Actions

-(IBAction) groupClicked:(id)sender{
    int index = [sender tag];
    NSString* catID = [config childCardIDOfCat:currentUUID atIndex:index];
    [self refreshGridViewForCat:catID];
    [self showInCat];
}

-(IBAction) leafClicked:(id)sender{
    
    //return if another card is on display
    if ([HAMAnimation isRunning]) {
        return;
    }
    
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    int index = [sender tag];
    HAMRoom* room = [config roomOfCat:currentUUID atIndex:index];
    
    UIView* cardView = [[gridViewTool cardViewArray_] objectAtIndex:index];
    [HAMAnimation beginAnimation:room.animation_ onCardView:cardView];
    
    HAMCard* card = [config card:room.cardID_];
    NSString* musicPath=[HAMFileTools filePath:[[card audio] localPath]];
    
    if (musicPath){
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    [self refreshGridViewForCat:config.rootID];
    [self hideInCat];
}

#pragma mark -
#pragma mark Multi Touch


- (IBAction)touchDownEnterEditButton:(UIButton *)sender {
    multiTouchCount ++;
    
    if (multiTouchCount >= 2) {
        HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
        [delegate turnToParentView];
    }
}

- (IBAction)touchUpEnterEditButton:(UIButton *)sender {
    multiTouchCount --;
}


@end