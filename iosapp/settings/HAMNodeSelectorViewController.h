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

@interface HAMNodeSelectorViewController : UIViewController
{
    int index;
    //0 - all 1 - leaf only 2 - group only
    int mode;
}

@property (strong, nonatomic) HAMConfig* config;
@property NSString* parentID;
// -1 - edit other - replace
@property int index;
@property (weak, nonatomic) IBOutlet UITableView *cardListTableView;
@property UIBarButtonItem* deleteBtn;

@property HAMEditNodeViewController* editNodeController;

@end
