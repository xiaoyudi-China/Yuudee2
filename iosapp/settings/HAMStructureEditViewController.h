//
//  HAMStructureEditViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMEditableGridViewTool.h"
#import "HAMFileTools.h"
#import "HAMNodeSelectorViewController.h"
#import "HAMEditNodeViewController.h"
#import "HAMSyncViewController.h"
#import "HAMUserViewController.h"
#import "HAMConfig.h"
#import "HAMUserManager.h"
#import "Reachability.h"

@class HAMEditableGridViewTool;

@interface HAMStructureEditViewController : UIViewController
{
    HAMConfig* config;
    HAMUserManager* userManager;
    
    HAMEditableGridViewTool* dragableView;
    
    Boolean refreshFlag;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;

@property (strong,nonatomic) HAMNodeSelectorViewController *selectorViewController;
@property (strong,nonatomic) HAMEditNodeViewController* editNodeController;
@property (strong,nonatomic) HAMSyncViewController* syncViewController;
@property (strong,nonatomic) HAMUserViewController* userViewController;

@property NSString* currentUUID;

- (IBAction)newNodeAction:(UIBarButtonItem *)sender;
- (IBAction)editNodeAction:(UIBarButtonItem *)sender;
- (IBAction)syncButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)changeLayoutClicked:(UIBarButtonItem *)sender;

@end
