//
//  HAMVoiceRecorderViewController.h
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HAMConfig.h"
#import "HAMConstants.h"

@interface HAMRecorderViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) HAMConfig *config;
@property (weak, nonatomic) HAMCard *tempCard;
@property (weak, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) NSString *cardID; //FIXME: this should NOT exist
@property (weak, nonatomic) NSString *categoryID;

@property (strong, nonatomic) NSArray *categoryIDs;
@property (strong, nonatomic) NSString *tempCategoryID;
@property NSInteger initRow;
@property NSInteger selectedRow;
@property BOOL audioChanged;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)finishButtonPressed:(id)sender;
- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

@end
