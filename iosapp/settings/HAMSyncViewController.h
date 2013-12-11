//
//  HAMSyncViewController.h
//  iosapp
//
//  Created by daiyue on 13-8-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "HAMViewTool.h"
#import "HAMWebTool.h"
#import "HAMFileTools.h"
#import "HAMTools.h"
#import "HAMDBManager.h"
#import "HAMConfig.h"
#import <Foundation/NSURLError.h>

#define ADDRESS @"115.28.35.182:3000/services/data/app"
#define USERNAME @"public"

@interface HAMSyncViewController : UIViewController
{
    HAMWebTool* webTool;
    int currentResourceNum;
    NSMutableArray* idList;
    HAMDBManager* dbManager;
}

@property Boolean wifiStatus;
@property HAMConfig* config;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgressView;


@end
