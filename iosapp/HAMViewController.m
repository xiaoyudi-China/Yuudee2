//
//  HAMViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMViewController.h"
#import "HAMFileTools.h"
#import "HAMChildInCatViewController.h"

@interface HAMViewController ()
{
    int multiTouchCount;
    Boolean multiTouchOn[4];
    HAMAnimation* animation;
    HAMAnimation* catAnimation;
}

@end

@implementation HAMViewController

@synthesize scrollView_;

@synthesize pressHintImageView1;
@synthesize pressHintImageView2;
@synthesize pressHintImageView3;

@synthesize inCatView;
@synthesize blurBgImageView;
@synthesize inCatBgImageView;
@synthesize backButton;
@synthesize inCatScrollView;

- (void)viewDidLoad{
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
    
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    
    gridViewTool = [[HAMGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:config delegate:self edit:NO];
    [gridViewTool refreshView:currentUUID scrollToFirstPage:YES];
    inCatGridViewTool = [[HAMGridViewTool alloc] initWithView:inCatScrollView viewInfo:viewInfo config:config delegate:self edit:NO];
    
    multiTouchCount = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    for (int i = 0; i < 4; i++) {
        multiTouchOn[i] = NO;
    }
    
    pressHintImageView1.hidden = false;
    pressHintImageView2.hidden = false;
    pressHintImageView3.hidden = false;
    blurBgImageView.hidden = true;
    
    HAMAnimation* gifAnimation = [[HAMAnimation alloc] init];
    gifAnimation.gifDelegate_ = self;
    [gifAnimation playGifWithTimeInterval:0.1f totalPicNum:8];
    
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark In & out Cat

- (void)refreshGridViewForCat:(NSString*)catID
{
    currentUUID = catID;
    [inCatGridViewTool refreshView:currentUUID scrollToFirstPage:YES];
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    currentUUID = config.rootID;
    blurBgImageView.hidden = true;
    [catAnimation moveView:inCatView toPosition:CGPointMake(768, 0)];
}

-(void) groupClicked:(id)sender{
    NSString* catID = [config childCardIDOfCat:currentUUID atIndex:[sender tag]];
    [self refreshGridViewForCat:catID];
    blurBgImageView.hidden = false;
    
    if (catAnimation == nil) {
        catAnimation = [[HAMAnimation alloc] init];
    }
    
    [catAnimation moveView:inCatView toPosition:CGPointMake(-117, 0)];
    /*
     if (inCatViewController_ == nil){
     inCatViewController_ = [[HAMChildInCatViewController alloc] initWithNibName:@"HAMChildInCatViewController" bundle:nil];
     }
     
     //    UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:inCatViewController_];
     //	navigator.navigationBarHidden = YES;
     NSLog(@"%@",self.navigationController);
     
     //	inCatViewController_.modalPresentationStyle = UIModalPresentationCurrentContext;
     //	inCatViewController_.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     //	[self presentViewController:navigator animated:YES completion:NULL];
     [self.navigationController pushViewController:inCatViewController_ animated:YES];*/
}

#pragma mark -
#pragma mark Card Actions

-(void) leafClicked:(id)sender{
    
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
    
    HAMCardView* cardView = [gridViewTool cardViewArray_][index];
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

#pragma mark -
#pragma mark Multi Touch


- (IBAction)touchDownEnterEditButton:(UIButton *)sender {
    if (multiTouchOn[sender.tag] == YES) {
        return;
    }
    
    multiTouchCount ++;
    multiTouchOn[sender.tag] = YES;
    
    if (multiTouchCount >= 3) {
        HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
        [delegate turnToParentView];
    }
}

- (IBAction)touchUpEnterEditButton:(UIButton *)sender {
    multiTouchOn[sender.tag] = NO;
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