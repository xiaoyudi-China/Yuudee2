//
//  HAMAddCardPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-6.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMCardEditorViewController.h"

@class HAMAddCardViewController;
@protocol HAMAddCardViewControllerDelegate <NSObject>

- (void)addCardDismissed:(HAMAddCardViewController *)addCard;

@end

@interface HAMAddCardViewController : UIViewController<HAMCardEditorViewControllerDelegate>

@property (weak, nonatomic) HAMSettingsViewController<HAMAddCardViewControllerDelegate> *delegate;
@property HAMConfig* config_;
@property NSString* parentID_;
@property NSInteger cardIndex_;

- (IBAction)addFromLibClicked:(UIButton *)sender;
- (IBAction)createCardClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;

@end
