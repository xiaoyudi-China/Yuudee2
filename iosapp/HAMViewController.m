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
    HAMAnimation* animation;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;
@end

@implementation HAMViewController

@synthesize scrollView_;

@synthesize pressHintImageView1;
@synthesize pressHintImageView2;
@synthesize pressHintImageView3;

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

-(void)viewDidAppear:(BOOL)animated{
    pressHintImageView1.hidden = false;
    pressHintImageView2.hidden = false;
    pressHintImageView3.hidden = false;
    
    HAMAnimation* gifAnimation = [[HAMAnimation alloc] init];
    gifAnimation.gifDelegate_ = self;
    [gifAnimation playGifWithTimeInterval:0.1f totalPicNum:8];
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
    if (animation != nil) {
        if ([animation isRunning]) {
            return;
        }
    }
    
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    int index = [sender tag];
    HAMRoom* room = [config roomOfCat:currentUUID atIndex:index];
    
    HAMCardView* cardView = [[gridViewTool cardViewArray_] objectAtIndex:index];
    HAMCard* card = [config card:room.cardID_];
    
    if (animation == nil) {
        animation = [[HAMAnimation alloc] init];
    }
    [animation setCard:card andCardView:cardView];
    [animation beginAnimation:room.animation_];
    
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

- (void)changeGifImageToPicNum:(int)picNum{
    NSString* hintPicName = [[NSString alloc] initWithFormat:@"child_presshint_p%d.png",picNum];
    UIImage* image = [UIImage imageNamed:hintPicName];
    pressHintImageView1.image = image;
    pressHintImageView2.image = image;
    pressHintImageView3.image = image;
}

- (void)endGif{
    pressHintImageView1.hidden = true;
    pressHintImageView2.hidden = true;
    pressHintImageView3.hidden = true;
}


@end