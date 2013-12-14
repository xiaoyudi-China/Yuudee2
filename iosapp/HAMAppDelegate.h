//
//  HAMAppDelegate.h
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMDefaultResources.h"
#import "HAMDBManager.h"

@class HAMStructureEditViewController;
@class HAMViewController;
@class HAMSettingsViewController;

@interface HAMAppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) HAMViewController *viewController;
@property (strong, nonatomic) HAMStructureEditViewController *structureEditViewController;
//@property Boolean urlFlag;

-(void)turnToChildView;
-(void)turnToParentView;

@end
