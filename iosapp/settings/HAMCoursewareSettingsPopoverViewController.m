//
//  HAMSettingsPopoverViewController.m
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCoursewareSettingsPopoverViewController.h"

#define CHECKED_MARK_OFFSET CGPointMake(-4,-23)

@interface HAMCoursewareSettingsPopoverViewController ()
{
    int changedLayout;
}

@end

@implementation HAMCoursewareSettingsPopoverViewController

@synthesize coursewareManager;
@synthesize mainSettingsViewController;
@synthesize popover;

@synthesize coursewareTitleButton;
@synthesize changeTitleTextField;

@synthesize layoutCheckedImageView;
@synthesize layout1x1Button;
@synthesize layout2x2Button;
@synthesize layout3x3Button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    changedLayout = -1;
    
    self.currentCourseware = [coursewareManager currentCourseware];
    [self initTitle:self.currentCourseware.name];
    
    int currentLayout = [HAMViewInfo layoutOfXnum:self.currentCourseware.layoutx ynum:self.currentCourseware.layouty];
    [self showCheckedImageAtlayout:currentLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Title

-(void)initTitle:(NSString*)title
{
    changeTitleTextField.text = title;
    changeTitleTextField.hidden = YES;
    [coursewareTitleButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)changeTitleClicked:(UIButton *)sender {
    changeTitleTextField.hidden = NO;
}

#pragma mark -
#pragma mark Change Layout

-(void)showCheckedImageAtlayout:(int)layout
{
    UIButton* layoutButton;
    
    switch (layout) {
        case VIEWINFO_LAYOUT_1x1:
            layoutButton = layout1x1Button;
            break;
            
        case VIEWINFO_LAYOUT_2x2:
            layoutButton = layout2x2Button;
            break;
            
        case VIEWINFO_LAYOUT_3x3:
            layoutButton = layout3x3Button;
            break;
    }
    
    CGPoint position = layoutButton.frame.origin;
    position.x += CHECKED_MARK_OFFSET.x;
    position.y += CHECKED_MARK_OFFSET.y;
    
    CGRect frame = layoutCheckedImageView.frame;
    frame.origin = position;
    layoutCheckedImageView.frame = frame;
}

- (IBAction)layout1x1Clicked:(UIButton *)sender {
    changedLayout = VIEWINFO_LAYOUT_1x1;
    [self showCheckedImageAtlayout:VIEWINFO_LAYOUT_1x1];
}

- (IBAction)layout2x2Clicked:(UIButton *)sender {
    changedLayout = VIEWINFO_LAYOUT_2x2;
    [self showCheckedImageAtlayout:VIEWINFO_LAYOUT_2x2];
}

- (IBAction)layout3x3Clicked:(UIButton *)sender {
    changedLayout = VIEWINFO_LAYOUT_3x3;
    [self showCheckedImageAtlayout:VIEWINFO_LAYOUT_3x3];
}

#pragma mark -
#pragma makr Delete Courseware

- (IBAction)removeCoursewareClicked:(UIButton *)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认删除该课件？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
	[actionSheet showInView:self.view]; //FIXME: why the actionsheet show from below?
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		self.currentCourseware = [coursewareManager currentCourseware];
		[coursewareManager deleteCourseware:self.currentCourseware];
		
		[self.popover dismissPopoverAnimated:YES];
		[mainSettingsViewController viewWillAppear:NO];
	}
}

#pragma mark -
#pragma makr Cancel & Finish

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishClicked:(UIButton *)sender {
    
    if (changedLayout != -1) {
        int xnum = [HAMViewInfo xnumOfLayout:changedLayout];
        int ynum = [HAMViewInfo ynumOfLayout:changedLayout];
        
        [coursewareManager updateCurrentCoursewareLayoutxnum:xnum ynum:ynum];
    }
    
    if (![self.currentCourseware.name isEqualToString:changeTitleTextField.text]) {
        [coursewareManager updateCurrentCoursewareName:[changeTitleTextField.text copy]];
        [mainSettingsViewController refreshCoursewareSelect];
    }
    [self.popover dismissPopoverAnimated:YES];
}

@end
