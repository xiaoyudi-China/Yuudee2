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

static NSString * const kHAMPulseAnimation = @"HAMPulseAnimation";

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
    
    CALayer* cardLayer = [[gridViewTool layerArray] objectAtIndex:index];
    [self beginAnimation:room.animation_ onLayer:cardLayer];
    
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

- (void)beginAnimation:(int)animationType onLayer:(CALayer*)highlightLayer
{
    switch (animationType) {
        case ROOM_ANIMATION_NONE:
            return;
        
        case ROOM_ANIMATION_SCALE:
            
        default:
            break;
    }
    CALayer* superLayer=[highlightLayer superlayer];
    [highlightLayer removeFromSuperlayer];
    [superLayer addSublayer:highlightLayer];
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [pulseAnimation setDuration:1];
    [pulseAnimation setRepeatCount:1];
    
    [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CATransform3D transform = CATransform3DMakeScale(3.5, 3.5, 1.0);
    
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
    [pulseAnimation setAutoreverses:YES];
    
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(384, 512)];
    [translation setDuration:1];
    [translation setRepeatCount:1];
    [translation setAutoreverses:YES];
    
    // Finally... add the explicit animation to the layer... the animation automatically starts.
    [highlightLayer addAnimation:pulseAnimation forKey:kHAMPulseAnimation];
    [highlightLayer addAnimation:translation forKey:@"translation"];
}

- (void)endAnimatingLayer
{
    //[_layer removeAnimationForKey:kBTSPulseAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self endAnimatingLayer];
}


@end