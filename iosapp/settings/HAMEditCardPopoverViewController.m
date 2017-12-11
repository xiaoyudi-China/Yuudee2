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

@property (nonatomic) NSString *cardID;
@property (nonatomic) HAMAnimationType animation;

@end
@implementation HAMEditCardPopoverViewController

@synthesize mainSettingsViewController_;
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
    
    self.animation = [self.config animationOfCat:self.parentID atIndex:self.childIndex];
	[self showCheckedMarkAtAnimation:self.animation];
	self.muteStateSwitch.on = [self.config muteStateOfCat:self.parentID atIndex:self.childIndex];

    self.cardID = [self.config childCardIDOfCat:self.parentID atIndex:self.childIndex];
    HAMCard* card = [self.config card:self.cardID];
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
    cardEditor.parentID = self.parentID;
    cardEditor.index = self.childIndex;
    cardEditor.config = self.config;
	
	// FIXME: couldn't know to which category the card belongs
    cardEditor.categoryID = nil;
    cardEditor.cardID = [self.config childCardIDOfCat:self.parentID atIndex:self.childIndex];
    
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
        case HAMAnimationTypeScale:
            animationButton = animationScaleButton;
            break;
            
        case HAMAnimationTypeShake:
            animationButton = animationShakeButton;
            break;
		
		case HAMAnimationTypeNone:
			animationButton = animationNoneButton;
			break;
			
        default:
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
    self.animation = HAMAnimationTypeNone;
    [self showCheckedMarkAtAnimation:HAMAnimationTypeNone];
}

- (IBAction)animationSetToScaleClicked:(UIButton *)sender {
    self.animation = HAMAnimationTypeScale;
    [self showCheckedMarkAtAnimation:HAMAnimationTypeScale];
}

- (IBAction)animationSetToShakeClicked:(UIButton *)sender {
    self.animation = HAMAnimationTypeShake;
    [self showCheckedMarkAtAnimation:HAMAnimationTypeShake];
}

#pragma mark -
#pragma mark Remove Card

- (IBAction)removeCardClicked:(UIButton *)sender {
    [self.config updateRoomOfCat:self.parentID with:nil atIndex:self.childIndex];
    [mainSettingsViewController_ refreshGridViewAndScrollToFirstPage:NO];

    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Finish & Cancel

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishClicked:(UIButton *)sender {
	[self.config updateAnimationOfCat:self.parentID with:self.animation atIndex:self.childIndex];
	[self.config updateMuteStateOfCat:self.parentID with:self.muteStateSwitch.on atIndex:self.childIndex];
    
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
