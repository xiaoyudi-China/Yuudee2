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

@synthesize cousewareTitleLabel;

@synthesize layoutCheckedImageView;
@synthesize layout1x1Button;
@synthesize layout2x2Button;
@synthesize layout3x3Button;

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
    
    changedLayout = -1;
    
    [self initTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Title

-(void)initTitle
{
    cousewareTitleLabel.text = [coursewareManager currentUser].name;
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

- (IBAction)removeCoursewareClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)cancelClicked:(UIButton *)sender {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishClicked:(UIButton *)sender {
    if (changedLayout != -1) {
        int xnum, ynum;
        switch (changedLayout) {
            case VIEWINFO_LAYOUT_1x1:
                xnum = 1;
                ynum = 1;
                break;
                
            case VIEWINFO_LAYOUT_2x2:
                xnum = 2;
                ynum = 2;
                break;
                
            case VIEWINFO_LAYOUT_3x3:
                xnum = 3;
                ynum = 3;
                break;
        }
        [coursewareManager updateCurrentUserLayoutxnum:xnum ynum:ynum];
        [mainSettingsViewController setLayoutWithxnum:xnum ynum:ynum];
        [mainSettingsViewController refreshGridViewAndScrollToFirstPage:YES];
    }
    
    [self.popover dismissPopoverAnimated:YES];
}
@end
