//
//  HAMViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMViewController.h"

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
    self.activeUserName=@"hamster";
}

-(void)viewWillAppear:(BOOL)animated
{    
    self.config = [[HAMConfig alloc] initFromDB];
    self.currentUUID = self.config.rootID;
    
    if (! self.config)
        return;
    
    self.userManager = [HAMCoursewareManager new];
    self.userManager.config = self.config;
    
    HAMCourseware* currentUser = self.userManager.currentCourseware;
    
    HAMViewInfo* viewInfo = [[HAMViewInfo alloc] initWithXnum:currentUser.layoutx ynum:currentUser.layouty];
    
    self.gridViewTool = [[HAMGridViewTool alloc] initWithView:scrollView_ viewInfo:viewInfo config:self.config delegate:self edit:NO];
    [self.gridViewTool refreshView:self.currentUUID scrollToFirstPage:YES];
    self.inCatGridViewTool = [[HAMGridViewTool alloc] initWithView:inCatScrollView viewInfo:viewInfo config:self.config delegate:self edit:NO];
    
    multiTouchCount = 0;
}

-(void)viewDidAppear:(BOOL)animated{
    for (int i = 0; i < 4; i++) {
        multiTouchOn[i] = NO;
    }
    blurBgImageView.hidden = true;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark In & out Cat

- (void)refreshGridViewForCat:(NSString*)catID
{
    self.currentUUID = catID;
    [self.inCatGridViewTool refreshView:self.currentUUID scrollToFirstPage:YES];
}

- (IBAction)backButtonClicked:(UIButton *)sender {
    self.currentUUID = self.config.rootID;
    blurBgImageView.hidden = true;
    [catAnimation moveView:inCatView toPosition:CGPointMake(768, 0)];
	self.inCategory = NO;
}

-(void) groupClicked:(id)sender{
    NSString* catID = [self.config childCardIDOfCat:self.currentUUID atIndex:[sender tag]];
    [self refreshGridViewForCat:catID];
    blurBgImageView.hidden = false;
    
    if (catAnimation == nil) {
        catAnimation = [[HAMAnimation alloc] init];
    }
    
    [catAnimation moveView:inCatView toPosition:CGPointMake(-117, 0)];
	self.inCategory = YES;
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
    
    if (self.audioPlayer)
        if ([self.audioPlayer isPlaying])
        {
            return;
        }
    
    NSInteger index = [sender tag];
    HAMRoom* room = [self.config roomOfCat:self.currentUUID atIndex:index];
    
	HAMGridViewTool *currentGridView = self.inCategory ? self.inCatGridViewTool : self.gridViewTool;
    HAMCardView* cardView = currentGridView.cardViewArray[index];
    HAMCard* card = [self.config card:room.cardID];
    
    if (animation == nil) {
        animation = [[HAMAnimation alloc] init];
    }
    [animation setCard:card andCardView:cardView];
    [animation beginAnimation:room.animation];
    
	if (! room.mute) {
		NSString* musicPath = card.audioPath;
		if (musicPath){
			NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
			self.audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
			[self.audioPlayer setDelegate:self];
			[self.audioPlayer play];
		}
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

- (void)unlockGuideDismissed:(HAMUnlockGuideViewController *)unlockGuide {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)unlockButtonPressed:(id)sender {
	// show the unlock guide
	BOOL noUnlockGuide = [[NSUserDefaults standardUserDefaults] boolForKey:NO_UNLOCK_GUIDE_KEY];
	if (! noUnlockGuide) {
		HAMUnlockGuideViewController *unlockGuide = [[HAMUnlockGuideViewController alloc] init];
		unlockGuide.delegate = self;
		unlockGuide.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		
		UIView *background = [self.view snapshotViewAfterScreenUpdates:YES];
		[unlockGuide.view insertSubview:background atIndex:0];
		
		[self presentViewController:unlockGuide animated:YES completion:NULL];
	}
	
    pressHintImageView1.hidden = NO;
    pressHintImageView2.hidden = NO;
    pressHintImageView3.hidden = NO;
	
    HAMAnimation* gifAnimation = [[HAMAnimation alloc] init];
    gifAnimation.gifDelegate_ = self;
    [gifAnimation playGifWithTimeInterval:0.1f totalPicNum:8];
}

@end
