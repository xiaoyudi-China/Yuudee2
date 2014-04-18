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
    NSString* cardID_;
}

@end

@implementation HAMEditCardPopoverViewController

@synthesize mainSettingsViewController_;
@synthesize config_;
@synthesize parentID_;
@synthesize popover;

@synthesize editInLibButton;
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
    
    [self showCheckedMarkAtAnimation:[config_ animationOfCat:parentID_ atIndex:self.childIndex]];
    changedAnimation = -1;
    
    cardID_ = [config_ childCardIDOfCat:parentID_ atIndex:self.childIndex];
    HAMCard* card = [config_ card:cardID_];
    if (!card.removable)
    {
        editInLibButton.enabled = false;
        [editInLibButton setTitle:@"(不能编辑系统自带卡片)" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Edit In Lib

- (IBAction)editInLibClicked:(UIButton *)sender {
    HAMCardEditorViewController* cardEditor = [[HAMCardEditorViewController alloc] initWithNibName:@"HAMCardEditorViewController" bundle:nil];
    //mainSettingsViewController.cardEditorViewController = cardEditor;
    
    cardEditor.delegate = self; // NOTE!!!
    cardEditor.addCardOnCreation = NO;
    cardEditor.parentID = parentID_;
    cardEditor.index = self.childIndex;
    cardEditor.config = config_;
	
	// FIXME: couldn't know to which category the card belongs
    cardEditor.categoryID = nil;
    cardEditor.cardID = [config_ childCardIDOfCat:parentID_ atIndex:self.childIndex];
    
    cardEditor.modalPresentationStyle = UIModalPresentationCurrentContext;
    cardEditor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // pretend the card editor is floating above the background view
    UIView *background = [mainSettingsViewController_.view snapshotViewAfterScreenUpdates:NO];
    [cardEditor.view insertSubview:background atIndex:NO];
    
    [mainSettingsViewController_ presentViewController:cardEditor animated:YES completion:NULL];
    
    [self.popover dismissPopoverAnimated:YES];

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
    [config_ updateRoomOfCat:parentID_ with:nil atIndex:self.childIndex];
    [mainSettingsViewController_ refreshGridViewAndScrollToFirstPage:NO];

    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Finish & Cancel

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishClicked:(UIButton *)sender {
    if (changedAnimation != -1)
        [config_ updateAnimationOfCat:parentID_ with:changedAnimation atIndex:self.childIndex];
    
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark CardEditorDelegate

- (void)cardEditorDidCancelEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cardEditorDidEndEditing:(HAMCardEditorViewController *)cardEditor {
	[mainSettingsViewController_ dismissViewControllerAnimated:YES completion:NULL];
}

@end
