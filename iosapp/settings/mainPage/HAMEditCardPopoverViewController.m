//
//  HAMEditCardPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-4.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditCardPopoverViewController.h"

#define CHECKED_MARK_OFFSET CGPointMake(-4,-23)

@interface HAMEditCardPopoverViewController ()
{
    int changedAnimation;
}

@end

@implementation HAMEditCardPopoverViewController

@synthesize mainSettingsViewController;
@synthesize config;
@synthesize parentID;
@synthesize childIndex;
@synthesize popover;

@synthesize cancelButton;
@synthesize finishButton;

@synthesize animationCheckedMark;
@synthesize animationNoneButton;
@synthesize animationScaleButton;
@synthesize animationShakeButton;

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
    [self.view setBackgroundColor:[UIColor clearColor]];
    
//    [HAMViewTool setHighLightImage:@"parent_editpop_cancelbtn_down" forButton:cancelButton];
//    [HAMViewTool setHighLightImage:@"parent_editpop_confirmbtn_down" forButton:finishButton];
    
    [self showCheckedMarkAtAnimation:[config animationOfCat:parentID atIndex:childIndex]];
    changedAnimation = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Edit In Lib

- (IBAction)editInLibClicked:(UIButton *)sender {

}

#pragma mark -
#pragma mark Change Animation

-(void)showCheckedMarkAtAnimation:(int)animation
{
    UIButton* animationButton;
    
    switch (animation) {
        case ROOM_ANIMATION_SCALE:
            animationButton = animationScaleButton;
            break;
            
        case ROOM_ANIMATION_SHAKE:
            animationButton = animationShakeButton;
            break;
            
        case ROOM_ANIMATION_NONE:
            animationButton = animationNoneButton;
            break;
    }
    
    CGPoint position = animationButton.frame.origin;
    position.x += CHECKED_MARK_OFFSET.x;
    position.y += CHECKED_MARK_OFFSET.y;
    
    CGRect frame = animationCheckedMark.frame;
    frame.origin = position;
    animationCheckedMark.frame = frame;
}

- (IBAction)animationSetToNoClicked:(UIButton *)sender {
    changedAnimation = ROOM_ANIMATION_NONE;
    [self showCheckedMarkAtAnimation:ROOM_ANIMATION_NONE];
}

- (IBAction)animationSetToScaleClicked:(UIButton *)sender {
    changedAnimation = ROOM_ANIMATION_SCALE;
    [self showCheckedMarkAtAnimation:ROOM_ANIMATION_SCALE];
}

- (IBAction)animationSetToShakeClicked:(UIButton *)sender {
    changedAnimation = ROOM_ANIMATION_SHAKE;
    [self showCheckedMarkAtAnimation:ROOM_ANIMATION_SHAKE];
}

#pragma mark -
#pragma mark Remove Card

- (IBAction)removeCardClicked:(UIButton *)sender {
    [config updateRoomOfCat:parentID with:nil atIndex:childIndex];
    [mainSettingsViewController refreshGridViewAndScrollToFirstPage:NO];

    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Finish & Cancel

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishClicked:(UIButton *)sender {
    if (changedAnimation != -1)
        [config updateAnimationOfCat:parentID with:changedAnimation atIndex:childIndex];
    
    [self.popover dismissPopoverAnimated:YES];
}
@end
