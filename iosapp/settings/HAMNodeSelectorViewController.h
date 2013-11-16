//
//  HAMNodeSelectorViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMViewTool.h"
#import "HAMConfig.h"
#import "HAMEditNodeViewController.h"
#import "HAMCardSelectorViewController.h"
#import "HAMCategoryEditorViewController.h"
#import "HAMGridCell.h"
#import "HAMGridCellDelegate.h"
#import "HAMConstants.h"

@interface HAMNodeSelectorViewController : UIViewController <UICollectionViewDataSource, HAMGridCellDelegate, UITabBarDelegate, UIActionSheetDelegate>
{
    int index;
}

@property (weak, nonatomic) HAMConfig* config;
@property NSString* parentID;
// 1	- edit
// other- replace
@property int index;
@property (nonatomic, assign) HAMGridCellMode cellMode;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *categories;

@property HAMEditNodeViewController* editNodeController;
@property (nonatomic, strong) UIPopoverController *popover;

@end
