//
//  HAMEditNodeViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "HAMConfig.h"
#import "HAMViewTool.h"

#define TIME_INTEVAL 0.03f

@interface HAMEditNodeViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    NSString* imageFile;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *audioPlayer;
    NSString* audioPath;
    Boolean toggle;
    
    NSTimer *timer;
    double time;
    double progressInc;
}

typedef enum {
	HAMCardEditModeCreate,
	HAMCardEditModeEdit,
} HAMCardEditMode;

@property HAMCardEditMode editMode;
@property int newFlag; // FIXME: this should be deprecated

@property (nonatomic, weak) HAMConfig* config;
@property HAMCard* card;
@property NSString* parentID;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *image;
@property (assign, nonatomic) CGRect imageFrame;
@property (weak, nonatomic) IBOutlet UIButton *shootButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property UIPopoverController* popoverController;

@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;

@property (weak, nonatomic) IBOutlet UIButton *finishButton;

- (IBAction)playButtonClicked:(UIButton *)sender;
- (IBAction)shootButtonClicked:(UIButton *)sender;
- (IBAction)recordButtonClicked:(UIButton *)sender;
- (IBAction)finishButtonClicked:(UIButton *)sender;
- (IBAction)cameraButtonClicked:(UIButton *)sender;
- (IBAction)audioSwitched:(UISwitch *)sender;

@end
