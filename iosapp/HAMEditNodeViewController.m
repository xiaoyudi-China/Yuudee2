//
//  HAMEditNodeViewController.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditNodeViewController.h"
#import "HAMGridViewTool.h"

@interface HAMEditNodeViewController ()

static UIImage *shrinkImage(UIImage *original, CGSize size);
/*-(void)updateDisplay;
-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;*/
@end

@implementation HAMEditNodeViewController

@synthesize card;
@synthesize config;
@synthesize parentID;

@synthesize nameTextField;
@synthesize imageView;
@synthesize image;
@synthesize shootButton;
@synthesize cameraButton;
@synthesize imageFrame;
@synthesize recordingIndicator;
@synthesize recordButton;
@synthesize playButton;
@synthesize finishButton;
@synthesize imageLabel;
@synthesize popoverController;
@synthesize timeLabel;
@synthesize audioSwitch;
@synthesize switchLabel;
@synthesize progressView;

#pragma mark -
#pragma mark Take Photo

- (IBAction)shootButtonClicked:(UIButton *)sender
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary sender:sender];
}

- (IBAction)cameraButtonClicked:(UIButton *)sender {
    if (![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera])
    {
        [HAMViewTool showAlert:@"您的设备不支持拍摄。"];
        return;
    }
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera sender:sender];
}

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType sender:(UIButton*)sender
{
    NSArray* mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType && [mediaTypes containsObject:@"public.image"]]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        // allows only images but not video
        NSArray* imageType=[NSArray arrayWithObject:@"public.image"];
        imagePicker.mediaTypes=imageType;
        imagePicker.sourceType = sourceType;
        imagePicker.delegate = self;
        imagePicker.allowsEditing=YES;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        [popoverController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        if (sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
            [HAMViewTool showAlert:@"无法打开相册。"];
        else
            [HAMViewTool showAlert:@"无法拍摄照片。"];
    }
    /*NSArray* mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:sourceType];
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count]>0)
    {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker=
        [[UIImagePickerController alloc] init];
        picker.mediaTypes=mediaTypes;
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType=sourceType;
        [self presentModalViewController:picker animated:YES];
    }*/
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* chosenImage=[info objectForKey:UIImagePickerControllerEditedImage];
    UIImage* shrunkenImage=shrinkImage(chosenImage, imageFrame.size);
    self.image=shrunkenImage;
    imageView.image=image;
    [popoverController dismissPopoverAnimated:YES];
    
    //save
    imageFile=[[NSString alloc] initWithFormat:@"%@.jpg",card.UUID];
    BOOL result = [UIImagePNGRepresentation(imageView.image)writeToFile: [HAMFileTools filePath:imageFile] atomically:YES];
    if (!result)
        [HAMViewTool showAlert:@"保存照片出错!"];
}

static UIImage* shrinkImage(UIImage* original,CGSize size)
{
    CGFloat scale=[UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context=CGBitmapContextCreate(NULL, size.width*scale, size.height*scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width*scale, size.height*scale), original.CGImage);
    CGImageRef shrunken =CGBitmapContextCreateImage(context);
    UIImage* final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return final;
}

#pragma mark -
#pragma mark Record Audio

-(void)toggleDisplay
{
    shootButton.hidden=toggle;
    cameraButton.hidden=toggle;
    playButton.hidden=toggle;
    audioSwitch.hidden=toggle;
    finishButton.hidden=toggle;
    switchLabel.hidden=toggle;

    toggle=!toggle;
    recordingIndicator.hidden=toggle;
    if (toggle)
    {
        [recordingIndicator stopAnimating];
        [recordButton setTitle:@"开始录音" forState: UIControlStateNormal];
    }
    else
    {
        [recordButton setTitle:@"停止录音" forState: UIControlStateNormal];
        [recordingIndicator startAnimating];
    }
}

-(void)toggleAudio
{
    Boolean audioOff=!audioSwitch.isOn;
    progressView.hidden=audioOff;
    timeLabel.hidden=audioOff;
    recordButton.hidden=audioOff;
    playButton.hidden=audioOff;
}

- (IBAction)recordButtonClicked:(UIButton *)sender {
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    NSError* error;
    
    if(toggle)
    {
        [self toggleDisplay];
        
        NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        
        audioPath=[[NSString alloc] initWithFormat:@"%@.%@",card.UUID,@"caf"];
        NSURL* recordFile=[HAMFileTools fileURL:audioPath];
        
        recorder = [[ AVAudioRecorder alloc] initWithURL:recordFile settings:recordSetting error:&error];
        [recorder setDelegate:self];
        [recorder prepareToRecord];
        [recorder recordForDuration:(NSTimeInterval) 30];
        [self startProgress:30];
    }
    else
    {
        [self stopProgress];
    }
}

- (IBAction)playButtonClicked:(UIButton *)sender {
    if (audioPlayer!=nil)
        if ([audioPlayer isPlaying])
        {
            return;
        }
    
    if (audioPath){
        NSURL *musicURL = [NSURL fileURLWithPath:[HAMFileTools filePath:audioPath]];
        audioPlayer = [[AVAudioPlayer alloc]  initWithContentsOfURL:musicURL  error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
        [self startProgress:audioPlayer.duration];
    }
}

- (IBAction)deleteAudioButtonClicked:(UIButton *)sender {
    audioPath=nil;
    
}

- (IBAction)audioSwitched:(UISwitch *)sender{
    if(!audioSwitch.isOn)
    {
        if (audioPath!=nil)
        {
            [[[UIAlertView alloc] initWithTitle:@"关闭语音" message:@"确定要删除已有的录音文件吗？" delegate:self cancelButtonTitle:@"不要" otherButtonTitles:@"是的",nil] show];
            return;
        }
    }
    [self toggleAudio];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:{
            //TODO: Maybe need delete file
            //if (newFlag>=0)
            //{
            //}
            audioPath=nil;
            [self toggleAudio];
        }break;
        default:
        {
            audioSwitch.on=YES;
            break;
        }
    }
}

-(void)startProgress:(double)totalTime{
    self.progressView.progress=0.0f;
    time=0;
    timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTEVAL target:self selector:@selector(timeChanged:) userInfo:nil repeats:YES];
    progressInc=TIME_INTEVAL/totalTime;
}

-(void)stopProgress
{
    [timer invalidate];
    if (!toggle)
    {
        [recorder stop];
        [self toggleDisplay];
    }
}

-(IBAction)timeChanged:(id)sender{
    if (1-self.progressView.progress<progressInc)
    {
        [self stopProgress];
    }
    
    time+=TIME_INTEVAL;
    if (((int)time)<10)
    {
        timeLabel.text=[[NSString alloc] initWithFormat:@"0:0%d",(int)time];
    }
    else
    {
        timeLabel.text=[[NSString alloc] initWithFormat:@"0:%d",(int)time];
    }
    self.progressView.progress += progressInc;
}

#pragma mark
#pragma mark Other Actions

- (IBAction)finishButtonClicked:(UIButton *)sender {
    
    NSString* name=nameTextField.text;
    if (name.length>6)
    {
        [HAMViewTool showAlert:@"名称不能超过6个字(12字符)，请修改"];
        return;
    }
    
    if (self.editMode == HAMCardEditModeEdit)
        [config updateCard:card name:nameTextField.text audio:audioPath image:imageFile];
    else
    {
        [config newCardWithID:card.UUID name:nameTextField.text type:1 audio:audioPath image:imageFile]; // type 1 indicates card
		NSInteger numChildren = [config childrenCardIDOfCat:parentID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:card.UUID animation:ROOM_ANIMATION_NONE];
        [config updateRoomOfCat:parentID with:room atIndex:numChildren];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Default Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageFrame=imageView.frame;
    
    //Instanciate an instance of the AVAudioSession object.
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    //Setup the audioSession for playback and record.
    //We could just use record and then switch it to playback leter, but
    //since we are going to do both lets set it up once.
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    //Activate the session
    [audioSession setActive:YES error: &error];
}

-(void)viewWillAppear:(BOOL)animated
{
	if (self.editMode == HAMCardEditModeCreate) {
		self.title = @"新建卡片";
		audioSwitch.on = NO;
		
		self.card = [[HAMCard alloc] initNewCard];
		self.nameTextField.text = nil;
		audioPath = nil;
		image = [UIImage imageNamed:@"nopic.png"];
	}
	else if (self.editMode == HAMCardEditModeEdit) {
		self.title = @"编辑卡片";
		self.card = [config card:card.UUID];
		
		audioPath = card.audio.localPath;
		audioSwitch.on = audioPath ? YES : NO;
		
		image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
	}
	else {
		// something wrong
	}
	   
    imageFile=nil;
    [self.imageView setImage:image];
    self.progressView.progress=0;
    timeLabel.text=@"0:00";
    
    toggle=NO;
    [self toggleDisplay];
    [self toggleAudio];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
