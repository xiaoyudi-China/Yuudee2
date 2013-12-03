//
//  HAMVoiceRecorderViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRecorderViewController.h"

@interface HAMRecorderViewController ()

@property NSString *audioPath;
@property NSString *tempAudioPath;
@property BOOL isNewCard;

@end

@implementation HAMRecorderViewController

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
    // Do any additional setup after loading the view from its nib.
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	// FIXME: error handling
	NSError *error;
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	[audioSession setActive:YES error:&error];
	
	if (self.tempCard.audio) { // audio already exists
		// copy the existing audio file to the temporary file
		NSFileManager *manager = [NSFileManager defaultManager];
		// FIXME: error handling
		[manager copyItemAtPath:[HAMFileTools filePath:self.tempCard.audio.localPath] toPath:[HAMFileTools filePath:self.tempAudioPath] error:nil];
		
		self.tempCard.audio.localPath = self.tempAudioPath; // point to the temp file
	}
	else {
		self.deleteButton.enabled = NO;
		self.playButton.enabled = NO;
	}
		
	NSMutableDictionary* recordSettings = [[NSMutableDictionary alloc] init];
	[recordSettings setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	[recordSettings setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
	[recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
	
	self.audioPath = [NSString stringWithFormat:@"%@.caf", self.tempCard.UUID];
	self.tempAudioPath = [NSString stringWithFormat:@"%@-temp.caf", self.tempCard.UUID];

	// save audio to the temporary file
	self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[HAMFileTools fileURL:self.tempAudioPath] settings:recordSettings error:NULL];
	if (! self.audioRecorder) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动录音设备" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.recordButton.hidden = YES;
	}
	
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	self.initRow = -1;
	// find the card's category
	for (NSString *categoryID in self.categoryIDs) {
		NSArray *cardIDs = [self.config childrenCardIDOfCat:categoryID];
		if ([cardIDs containsObject:self.tempCard.UUID]) {
			self.initRow = [self.categoryIDs indexOfObject:categoryID];
			break;
		}
	}
	self.isNewCard = (self.initRow == -1);
	if (self.isNewCard) {
		if (self.categoryID) // created with a specific category
			self.initRow = [self.categoryIDs indexOfObject:self.categoryID];
		else // default uncategorized
			self.initRow = [self.categoryIDs indexOfObject:UNCATEGORIZED_ID];
	}
	
	[self.pickerView selectRow:self.initRow inComponent:0 animated:NO];
	self.selectedRow = self.initRow;

	// fit into the popover
	self.preferredContentSize = self.view.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishButtonPressed:(id)sender {
	
	if (self.tempCard.audio) { // has audio, either newly recorded or already existing
		NSFileManager *manager = [NSFileManager defaultManager];
		// copy and then delete the temporary audio file
		// FIXME: error handling
		[manager copyItemAtPath:[HAMFileTools filePath:self.tempAudioPath] toPath:[HAMFileTools filePath:self.audioPath] error:NULL];
		[manager removeItemAtPath:[HAMFileTools filePath:self.tempAudioPath] error:NULL];
		
		NSString *imagePath = [NSString stringWithFormat:@"%@.jpg", self.tempCard.UUID];
		NSString *tempImagePath = [NSString stringWithFormat:@"%@-temp.jpg", self.tempCard.UUID];
		// copy and then delete the temporary image file, on behalf of the card editor
		// FIXME: error handling
		[manager copyItemAtPath:[HAMFileTools filePath:tempImagePath] toPath:[HAMFileTools filePath:imagePath] error:NULL];
		[manager removeItemAtPath:[HAMFileTools filePath:tempImagePath] error:NULL];
		
		self.tempCard.audio.localPath = self.audioPath;
		self.tempCard.image.localPath = imagePath;
		[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	}
	
	NSString *newCategoryID = self.categoryIDs[self.selectedRow];
	NSInteger numChildren = [self.config childrenCardIDOfCat:newCategoryID].count;
	HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation: ROOM_ANIMATION_NONE];
	if (self.isNewCard) {
		// add the card to the new category
		[self.config updateRoomOfCat:newCategoryID with:room atIndex:numChildren];
	}
	else if (self.initRow != self.selectedRow) { // category changed for an old card
		// add the card to the new category
		[self.config updateRoomOfCat:newCategoryID with:room atIndex:numChildren];
		// TODO: remove the card from the old category
	}
	
	[self.popover dismissPopoverAnimated:YES];
}

- (IBAction)recordButtonPressed:(id)sender {
	if (self.audioRecorder.recording) { // stop recording
		[self.audioRecorder stop];
		if (! self.tempCard.audio)
			self.tempCard.audio = [[HAMResource alloc] initWithPath:self.tempAudioPath];
		
		[self.recordButton setTitle:@"录音" forState:UIControlStateNormal];
		
		// re-enable other views
		self.playButton.enabled = YES;
		self.deleteButton.enabled = YES;
		self.cancelButton.enabled = YES;
		self.finishButton.enabled = YES;
		self.pickerView.userInteractionEnabled = YES;
	}
	else { // start recording
		// FIXME: error handling
		[self.audioRecorder record];
		[self.recordButton setTitle:@"停止" forState:UIControlStateNormal];
		
		// disable all other views while recording
		self.playButton.enabled = NO;
		self.deleteButton.enabled = NO;
		self.cancelButton.enabled = NO;
		self.finishButton.enabled = NO;
		self.pickerView.userInteractionEnabled = NO;
	}
}

- (IBAction)playButtonPressed:(id)sender {
	NSString *audioToPlayPath = self.tempAudioPath;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[HAMFileTools fileURL:audioToPlayPath] error:NULL];
	if (! self.audioPlayer) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法播放音频" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.playButton.hidden = YES;
	}
	self.audioPlayer.delegate = self; // !!!

	[self.audioPlayer play];
	[self.playButton setTitle:@"停止" forState:UIControlStateNormal];
	
	// disable all other views while playing audio
	self.recordButton.enabled = NO;
	self.deleteButton.enabled = NO;
	self.cancelButton.enabled = NO;
	self.finishButton.enabled = NO;
	self.pickerView.userInteractionEnabled = NO;
}

- (IBAction)deleteButtonPressed:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	// FIXME: what if the audio file doesn't exist?
	[manager removeItemAtPath:[HAMFileTools filePath:self.audioPath] error:nil];
	
	// set the audio path to nil
	self.tempCard.audio = nil;
	// no audio to play or delete now
	self.deleteButton.enabled = NO;
	self.playButton.enabled = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (! flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"音频解码失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
	}
	
	[self.playButton setTitle:@"播放" forState:UIControlStateNormal];
	
	// re-enable other views
	self.recordButton.enabled = YES;
	self.deleteButton.enabled = YES;
	self.cancelButton.enabled = YES;
	self.finishButton.enabled = YES;
	self.pickerView.userInteractionEnabled = YES;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

	self.selectedRow = row;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *categoryID = self.categoryIDs[row];
	return [self.config card:categoryID].name;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.categoryIDs.count;
}

@end
