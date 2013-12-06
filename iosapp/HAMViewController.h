//
//  HAMViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HAMGridViewTool.h"
#import "HAMConfig.h"
#import "HAMUserManager.h"
#import "HAMAnimation.h"

@interface HAMViewController : UIViewController <AVAudioPlayerDelegate>
{
    NSString* activeUsername;
    
    AVAudioPlayer *audioPlayer;
    
    HAMGridViewTool* gridViewTool;
    HAMConfig* config;
    HAMUserManager* userManager;
    
    NSString* currentUUID;
}


@property (weak, nonatomic) IBOutlet UIImageView *blurBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *inCatBgImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)backButtonClicked:(UIButton *)sender;

- (IBAction)touchDownEnterEditButton:(UIButton *)sender;
- (IBAction)touchUpEnterEditButton:(UIButton *)sender;

@end
