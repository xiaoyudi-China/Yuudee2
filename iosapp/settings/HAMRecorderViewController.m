//
//  HAMVoiceRecorderViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRecorderViewController.h"

@interface HAMRecorderViewController ()

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
	
	// save the audio to a temporary file before committing
	NSString *tempAudioPath = [NSString stringWithFormat:@"%@.caf-temp", self.tempCard.UUID];
	if (! self.tempCard.audio.localPath) { // no audio to play or delete
		self.deleteButton.enabled = NO;
		self.playButton.enabled = NO;
	}
	else {
		NSFileManager *manager = [NSFileManager defaultManager];
		// copy the existing audio file to the temporary file, so we can play it
		[manager copyItemAtPath:[HAMFileTools filePath:self.tempCard.audio.localPath] toPath:[HAMFileTools filePath:tempAudioPath] error:nil];
	}
	self.tempCard.audio = [[HAMResource alloc] initWithPath:tempAudioPath];
	self.audioChanged = NO;
	
	NSMutableDictionary* recordSettings = [[NSMutableDictionary alloc] init];
	[recordSettings setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	[recordSettings setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
	[recordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
	
	self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[HAMFileTools fileURL:self.tempCard.audio.localPath] settings:recordSettings error:NULL];
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
	if (self.initRow == -1) { // new card
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
	
	if (!self.cardID) { // card not created yet
		[self.config newCardWithID:self.tempCard.UUID name:self.tempCard.name type:1 audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath]; // type 1 indicates a card
	}
	
	if (self.audioChanged) {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSString *audioPath = [NSString stringWithFormat:@"%@.caf", self.tempCard.UUID];
		// copy and then delete the temporary audio file
		[manager copyItemAtPath:[HAMFileTools filePath:self.tempCard.audio.localPath] toPath:[HAMFileTools filePath:audioPath] error:NULL];
		[manager removeItemAtPath:[HAMFileTools filePath:self.tempCard.audio.localPath] error:NULL];
		
		self.tempCard.audio.localPath = audioPath;
		[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	}
	
	if (self.selectedRow != self.initRow) { // category was changed
		//NSString *oldCategoryID = self.categoryIDs[self.initRow];
		NSString *newCategoryID = self.categoryIDs[self.selectedRow];
		
		// add the card to the new category
		NSInteger numChildren = [self.config childrenCardIDOfCat:newCategoryID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation: ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:newCategoryID with:room atIndex:numChildren];
		
		// TODO: remove the card from the old category
	}
	
	[self.popover dismissPopoverAnimated:YES];
}

- (IBAction)recordButtonPressed:(id)sender {
	if (self.audioRecorder.recording) { // stop recording
		[self.audioRecorder stop];
		self.recordButton.titleLabel.text = @"录音";
		self.audioChanged = YES;
		self.playButton.enabled = YES; // now we have audio to play
		
		// re-enable other views
		self.playButton.enabled = YES;
		self.deleteButton.enabled = YES;
		self.cancelButton.enabled = YES;
		self.finishButton.enabled = YES;
		self.pickerView.userInteractionEnabled = YES;
	}
	else { // start recording
		[self.audioRecorder record];
		self.recordButton.titleLabel.text = @"停止";
		
		// disable all other views while recording
		self.playButton.enabled = NO;
		self.deleteButton.enabled = NO;
		self.cancelButton.enabled = NO;
		self.finishButton.enabled = NO;
		self.pickerView.userInteractionEnabled = NO;
	}
}

- (IBAction)playButtonPressed:(id)sender {
	NSString *audioToPlayPath = self.tempCard.audio.localPath;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[HAMFileTools fileURL:audioToPlayPath] error:NULL];
	if (! self.audioPlayer) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"播放音频失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		
		self.playButton.hidden = YES;
	}
	
	[self.audioPlayer play];
	self.playButton.titleLabel.text = @"停止";
	
	// disable all other views while playing audio
	self.recordButton.enabled = NO;
	self.deleteButton.enabled = NO;
	self.cancelButton.enabled = NO;
	self.finishButton.enabled = NO;
	self.pickerView.userInteractionEnabled = NO;
}

- (IBAction)deleteButtonPressed:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *audioPath = self.tempCard.audio.localPath;
	BOOL success = [manager removeItemAtPath:[HAMFileTools filePath:audioPath] error:nil];
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除音频失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
	}
	else {
		// set the audio path to nil
		self.tempCard.audio = nil;
		[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (! flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"音频解码失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
	}
	
	self.playButton.titleLabel.text = @"播放";
	
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
