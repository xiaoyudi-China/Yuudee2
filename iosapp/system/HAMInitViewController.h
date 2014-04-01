//
//  HAMInitViewController.h
//  iosapp
//
//  Created by Dai Yue on 14-1-15.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const COVER_NAME = @"cover.jpg";

@interface HAMInitViewController : UIViewController
{}

@property (weak, nonatomic) IBOutlet UILabel *copiedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property NSInteger copiedResourcesCount;
@property NSInteger totalResourcesCount;

@end
