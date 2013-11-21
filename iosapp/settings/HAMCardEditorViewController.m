//
//  HAMCardEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardEditorViewController.h"

@interface HAMCardEditorViewController ()

@end

@implementation HAMCardEditorViewController

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
	
	// fit into the popover
	self.preferredContentSize = self.view.frame.size;
	
	if (self.cardID) { // editing card
		self.tempCard = [self.config card:self.cardID];
		self.cardNameField.text = self.tempCard.name;
		self.imageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:self.tempCard.image.localPath]];
	}
	else { // creating card
		self.tempCard = [[HAMCard alloc] initNewCard]; // get a UUID

		// don't allow deletion when creating a card
		self.deleteCardButton.hidden = YES;
		// must specify card name and image before saving
		self.finishButton.enabled = NO;
		// must specify card name and image before recording
		self.recordButton.enabled = NO;
	}
	
	self.cardNameChanged = NO;
	self.cardImageChanged = NO;
	
	// initialize the recorder
	self.recorder = [[HAMRecorderViewController alloc] initWithNibName:@"HAMRecorderViewController" bundle:nil];
	self.recorder.config = self.config;
	self.recorder.tempCard = self.tempCard;
	self.recorder.cardID = self.cardID;
	self.recorder.categoryID = self.categoryID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.tempCard.name = nil;
	
	if (! self.cardID) { // creating card
		if (! [textField.text isEqualToString:@""]) {
			self.tempCard.name = textField.text;
			self.cardNameChanged = YES;
		}
	}
	else { // editing card
		NSString *oldCardName = [self.config card:self.cardID].name;
		if ([textField.text isEqualToString:@""])
			textField.text = oldCardName;
		else if (! [textField.text isEqualToString:oldCardName]) {
			self.tempCard.name = textField.text;
			self.cardNameChanged = YES;
		}
	}
	
	// can save new card now
	self.finishButton.enabled = (self.cardNameChanged && self.cardImageChanged) ? YES : NO;
	self.recordButton.enabled = self.finishButton.enabled;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return  NO;
}

- (IBAction)recordButtonTapped:(id)sender {
	self.recorder.popover = self.popover; // !!!
	[self.navigationController pushViewController:self.recorder animated:YES];
}

- (IBAction)pickImageButtonTapped:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄新照片", @"选取现有的", nil];
	
	// check for availibility of camera
	if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		for (UIView *subview in actionSheet.subviews) {
			
			if ([subview isKindOfClass:[UIButton class]]) {
				UIButton *button = (UIButton*) subview;
				// disable the button for shooting photo
				if ([button.titleLabel.text isEqualToString:@"拍摄新照片"])
					button.enabled = NO;
			}
		}
	}
		
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	if (buttonIndex == 0) // use camera
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	else if (buttonIndex == 1) // use photo library
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	else // cancel
		return;
	
	[self presentViewController:imagePicker animated:YES completion:NULL];
	//self.popover.contentViewController = imagePicker;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	self.imageView.image = tempImage; // update the displaying
	
	NSString *tempImagePath = [[NSString alloc] initWithFormat:@"%@-temp.jpg", self.tempCard.UUID];
	BOOL success = [UIImageJPEGRepresentation(tempImage, 1.0) writeToFile:[HAMFileTools filePath:tempImagePath] atomically:YES];
	if (!success) { // something wrong
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法选取图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		return; //cannot create new card
	}
	else {
		self.tempCard.image = [[HAMResource alloc] initWithPath:tempImagePath];
		self.cardImageChanged = YES;
	}
	
	// can save new card now
	if (self.cardNameChanged) {
		self.finishButton.enabled = YES;
		self.recordButton.enabled = YES;
	}
	
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelButtonTapped:(id)sender {
	[self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishButtonTapped:(id)sender {
	if (self.cardID) { // editing card
		
		if (self.cardImageChanged) { // image was modified
			NSFileManager *manager = [NSFileManager defaultManager];
			NSString *imagePath = [NSString stringWithFormat:@"%@.jpg", self.tempCard.name];
			// copy and then delete the temporary image file
			[manager copyItemAtPath:[HAMFileTools filePath:self.tempCard.image.localPath] toPath:[HAMFileTools filePath:imagePath] error:nil];
			[manager removeItemAtPath:[HAMFileTools filePath:self.tempCard.image.localPath] error:nil];
			
			self.tempCard.image.localPath = imagePath; // point to the new image path
			
			[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
		}
		
		if (self.cardNameChanged) { // card name was modified
			[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
		}
	}
	else { // creating card
		// create the card *into the database*
		// FIXME: why can't I just use the update card method
		[self.config newCardWithID:self.tempCard.UUID name:self.tempCard.name type:1 audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath]; // type 1 indicates a card
		
		// insert this card to a category
		NSString *categoryID = self.categoryID ? self.categoryID : UNCATEGORIZED_ID; // default uncategorized
		NSInteger numChildren = [self.config childrenCardIDOfCat:categoryID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:categoryID with:room atIndex:numChildren];
	}
	
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self];
}

- (IBAction)deleteCardButtonTapped:(id)sender {
	[self.config deleteCard:self.cardID];
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self];
}

@end
