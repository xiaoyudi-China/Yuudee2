//
//  HAMIntroViewController.h
//  iosapp
//
//  Created by 张 磊 on 14-2-28.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	HAMIntroTypeProductInfo,
	HAMIntroTypeTrainGuide
} HAMIntroType;

@class HAMIntroViewController;
@protocol HAMIntroViewControllerDelegate <NSObject>

- (void)quitIntro:(HAMIntroViewController*)introPage;

@end

@interface HAMIntroViewController : UIViewController

@property (weak, nonatomic) id<HAMIntroViewControllerDelegate> delegate;
@property HAMIntroType type;
@property (weak, nonatomic) IBOutlet UITextView *productInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *trainGuideTextView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)quitButtonPressed:(id)sender;

@end
