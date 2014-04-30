//
//  HAMGuideViewController.h
//  小雨滴
//
//  Created by 张 磊 on 14-4-22.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMUnlockGuideViewController;
@protocol HAMUnlockGuideViewControllerDelegate <NSObject>

- (void)unlockGuideDismissed:(HAMUnlockGuideViewController *)unlockGuide;

@end


@interface HAMUnlockGuideViewController : UIViewController

@property (weak, nonatomic) id<HAMUnlockGuideViewControllerDelegate> delegate;

- (IBAction)confirmButtonPressed:(id)sender;
- (IBAction)noHintButtonPressed:(id)sender;

@end
