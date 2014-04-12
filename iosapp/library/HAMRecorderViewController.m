//
//  HAMVoiceRecorderViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMRecorderViewController.h"
#import "HAMSharedData.h"

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
	NSError *error;
	if (! [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
		NSLog(@"%@", error.localizedDescription);
	if (! [audioSession setActive:YES error:&error])
		NSLog(@"%@", error.localizedDescription);
		
	NSFileManager *fileManager;
	// audio doesn't exist
	if (! [fileManager fileExistsAtPath:self.tempCard.audioPath]) {
		self.deleteButton.enabled = NO;
		self.playButton.enabled = NO;
	}
		
	NSMutableDictionary* recordSettings = [[NSMutableDictionary alloc] init];
	[recordSettings setValue :@(kAudioFormatAppleIMA4) forKey:AVFormatIDKey];
	[recordSettings setValue:@44110.0f forKey:AVSampleRateKey];
	[recordSettings setValue:@2 forKey:AVNumberOfChannelsKey];
	
	// save audio to the temporary file
	self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.tempCard.audioPath] settings:recordSettings error:&error];
	if (! self.audioRecorder)
		NSLog(@"%@", error.localizedDescription);
	
	self.imageView.image = [UIImage imageWithContentsOfFile:self.tempCard.imagePath];
	self.cardNameLabel.text = self.tempCard.name;
	if (! self.isNewCard) // edit mode
		self.editCardTitleView.hidden = NO; // the default state is hidden
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.delegate recorderDidCancelRecording:self];
}

- (IBAction)finishButtonPressed:(id)sender {
	NSString *filename = [self.tempCard.name stringByAppendingPathExtension:@"xydcard"];
	NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	NSString *categoryName = [self.config card:self.categoryID].name;
	NSString *cardPath = [[documentPath stringByAppendingPathComponent:categoryName] stringByAppendingPathComponent:filename];
		
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	// delete the original card
	if (! [fileManager removeItemAtPath:self.origCardPath error:&error])
		NSLog(@"%@", error.localizedDescription);
	
	// move temporary card to the new position
	if (! [fileManager moveItemAtPath:self.tempCardPath toPath:cardPath error:&error])
		NSLog(@"%@", error.localizedDescription);
	
	self.tempCard.imagePath = [[cardPath stringByAppendingPathComponent:@"images"] stringByAppendingPathComponent:@"1.jpg"];
	self.tempCard.audioPath = [[cardPath stringByAppendingPathComponent:@"audios"] stringByAppendingPathComponent:@"1.caf"];
	// update the database
	if (self.isNewCard)
		[self.config newCardWithID:self.tempCard.cardID name:self.tempCard.name type:HAMCardTypeCard audio:self.tempCard.audioPath image:self.tempCard.imagePath];
	else
		[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audioPath image:self.tempCard.imagePath];
	
	// update the image cache
	[HAMSharedData updateImageAtPath:self.tempCard.imagePath withImage:self.imageView.image];
	
	// update category
	// ------------------
	NSInteger numChildren = [self.config childrenCardIDOfCat:self.newCategoryID].count;
	HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.cardID animation:ROOM_ANIMATION_NONE];
	
	if (self.isNewCard) {
		// if this is a new card, then insert it into a new category
		[self.config updateRoomOfCat:self.newCategoryID with:room atIndex:numChildren];
	}
	else if (! [self.newCategoryID isEqualToString:self.categoryID]) { // category is changed
		// add the card to the new category
		[self.config updateRoomOfCat:self.newCategoryID with:room atIndex:numChildren];
				
		// remove the card from the old category
		NSInteger oldIndex = [[self.config childrenCardIDOfCat:self.categoryID] indexOfObject:self.tempCard.cardID];
		NSInteger numOldCards = [self.config childrenOfCat:self.categoryID].count;
		for (NSInteger index = oldIndex; index < numOldCards; index++) {
			HAMRoom *nextRoom = [self.config roomOfCat:self.categoryID atIndex:index + 1]; // supposed to be nil when exceeding boundary
			[self.config updateRoomOfCat:self.categoryID with:nextRoom atIndex:index];
		}
	}

	// add the card immediately
	if (self.addCardOnCreation) {
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.cardID animation:ROOM_ANIMATION_NONE];
		[self.config insertChildren:@[room] intoCat:self.parentID atIndex:self.index];
	}
	
	[self.delegate recorderDidEndRecording:self]; // inform the grid view to refresh
}

- (IBAction)recordButtonPressed:(id)sender {
	if (self.audioRecorder.recording) { // stop recording
		[self.audioRecorder stop];
				
		[self.recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
		self.statusLabel.text = @"录音结束";
		
		// re-enable other views
		self.playButton.enabled = YES;
		self.deleteButton.enabled = YES;
		self.cancelButton.enabled = YES;
		self.finishButton.enabled = YES;
	}
	else { // start recording
		if (! [self.audioRecorder record])
			NSLog(@"can't start to record");
		
		[self.recordButton setImage:[UIImage imageNamed:@"recordDOWN.png"] forState:UIControlStateNormal];
		self.statusLabel.text = @"录音中...";
		
		// disable all other views while recording
		self.playButton.enabled = NO;
		self.deleteButton.enabled = NO;
		self.cancelButton.enabled = NO;
		self.finishButton.enabled = NO;
	}
}

- (IBAction)playButtonPressed:(id)sender {
	NSURL *audioToPlayURL = [NSURL fileURLWithPath:self.tempCard.audioPath];
	NSError *error;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioToPlayURL error:&error];
	if (! self.audioPlayer)
		NSLog(@"%@", error.localizedDescription);
	
	self.audioPlayer.delegate = self; // !!!
	[self.audioPlayer play];
	// temporarily disable the play button while playing audio
	self.playButton.enabled = NO;
	self.statusLabel.text = @"播放中...";
	
	// disable all other views while playing audio
	self.recordButton.enabled = NO;
	self.deleteButton.enabled = NO;
	self.cancelButton.enabled = NO;
	self.finishButton.enabled = NO;
}

- (IBAction)deleteButtonPressed:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSError *error;
	if (! [manager removeItemAtPath:self.tempCard.audioPath error:&error])
		NSLog(@"%@", error.localizedDescription);
			
		
	// set the audio path to nil
	self.tempCard.audioPath = nil;
	// no audio to play or delete now
	self.deleteButton.enabled = NO;
	self.playButton.enabled = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (! flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"音频解码失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
	}
	
	self.playButton.enabled = YES;
	self.statusLabel.text = @"播放结束";
	
	// re-enable other views
	self.recordButton.enabled = YES;
	self.deleteButton.enabled = YES;
	self.cancelButton.enabled = YES;
	self.finishButton.enabled = YES;
}

@end
