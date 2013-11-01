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
						
@end

@implementation HAMViewController

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
    gridViewTool=[[HAMGridViewTool alloc] initWithView:self.view viewInfo:viewInfo config:config viewController:self edit:NO];
    [gridViewTool refreshView:currentUUID];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)childAtIndex:(int)index
{
    return [config childOf:currentUUID at:index];
}

-(IBAction) groupClicked:(id)sender{
    int index=[sender tag];
    if (index==-1)
        currentUUID=config.rootID;
    else
        currentUUID=[self childAtIndex:index];
    
    [gridViewTool refreshView:currentUUID];
}

-(IBAction) leafClicked:(id)sender{
    
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    [self beginAnimatingLayer:[gridViewTool.layerArray objectAtIndex:[sender tag]]];

    HAMCard* card=[config card:[self childAtIndex:[sender tag]]];
    //NSString *musicPath= [[NSBundle mainBundle] pathForResource:[[card audio] localPath] ofType:@""];
    NSString* musicPath=[HAMFileTools filePath:[[card audio] localPath]];
    
    if (musicPath){
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
}

- (void)beginAnimatingLayer:(CALayer*)highlightLayer
{
    CALayer* superLayer=[highlightLayer superlayer];
    [highlightLayer removeFromSuperlayer];
    [superLayer addSublayer:highlightLayer];
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [pulseAnimation setDuration:1];
    [pulseAnimation setRepeatCount:1];
    
    // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
    // animates between the two scaling transformations.
    //[pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    // Scale the layer to half the size
    CATransform3D transform = CATransform3DMakeScale(3.5, 3.5, 1.0);
    
    // Tell CA to interpolate to this transformation matrix
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
    [pulseAnimation setAutoreverses:YES];
    
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    translation.toValue = [NSValue valueWithCGPoint:CGPointMake(384, 512)];
    [translation setDuration:1];
    [translation setRepeatCount:1];
    [translation setAutoreverses:YES];
    //[translation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
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