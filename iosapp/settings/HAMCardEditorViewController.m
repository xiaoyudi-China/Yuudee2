//
//  HAMCardEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardEditorViewController.h"

@interface HAMCardEditorViewController ()

@property NSString *imagePath;
@property NSString *tempImagePath;

@end

@interface UIImagePickerController(NoRotation)
- (BOOL)shouldAutorotate;
@end

@implementation UIImagePickerController(NoRotation)

- (BOOL)shouldAutorotate {
	return NO;
}

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
	
	// initialize the temporary card
	if (self.cardID) { // editing card
		self.tempCard = [self.config card:self.cardID];
	}
	else { // creating card
		self.tempCard = [[HAMCard alloc] initNewCard]; // get a UUID
		[self.config newCardWithID:self.tempCard.UUID name:nil type:1 audio:nil image:nil]; // type 1 indicates a card
		self.tempCard.type = 1; // this statement can be removed
		self.tempCard.isRemovable_ = YES;
	}
	
	self.imagePath = [NSString stringWithFormat:@"%@.jpg", self.tempCard.UUID];
	self.tempImagePath = [NSString stringWithFormat:@"%@-temp.jpg", self.tempCard.UUID];
	// update the view accordingly
	if (self.cardID) { // editing card
		// copy the existing image file to the temporary
		// FIXME: *elegant* error handling
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager copyItemAtPath:[HAMFileTools filePath:self.imagePath] toPath:[HAMFileTools filePath:self.tempImagePath] error:nil];
		
		self.cardNameField.text = self.tempCard.name;
		self.tempCard.image.localPath = self.tempImagePath; // point to the temporary file
		self.imageView.image = [UIImage imageWithContentsOfFile:[HAMFileTools filePath:self.tempCard.image.localPath]];
	}
	else { // new card
		// don't allow deletion when creating a card
		self.deleteCardButton.hidden = YES;
		// must specify card name and image before saving
		self.finishButton.enabled = NO;
		// must specify card name and image before recording
		self.recordButton.enabled = NO;
	}
	
	// initialize the recorder
	self.recorder = [[HAMRecorderViewController alloc] initWithNibName:@"HAMRecorderViewController" bundle:nil];
	self.recorder.config = self.config;
	self.recorder.tempCard = self.tempCard;
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
		}
	}
	else { // editing card
		NSString *oldCardName = [self.config card:self.cardID].name;
		if ([textField.text isEqualToString:@""])
			textField.text = oldCardName;
		else if (! [textField.text isEqualToString:oldCardName]) {
			self.tempCard.name = textField.text;
		}
	}
	
	// can save new card now
	self.finishButton.enabled = (self.tempCard.name && self.tempCard.image) ? YES : NO;
	self.recordButton.enabled = self.finishButton.enabled;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return  NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// disable finish button while editing
	self.finishButton.enabled = NO;
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
	imagePicker.allowsEditing = YES;
	
	if (buttonIndex == 0) // use camera
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	else if (buttonIndex == 1) // use photo library
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	else // cancel
		return;
		
	[self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	self.imageView.image = tempImage; // update the displaying
	
	// save the image to a temporary file
	BOOL success = [UIImageJPEGRepresentation(tempImage, 1.0) writeToFile:[HAMFileTools filePath:self.tempImagePath] atomically:YES];
	if (!success) { // something wrong
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法选取图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		return; //cannot create new card
	}
	else {
		if (! self.tempCard.image)
			self.tempCard.image = [[HAMResource alloc] initWithPath:self.tempImagePath];
	}
	
	// can save new card now
	if (self.tempCard.name) {
		self.finishButton.enabled = YES;
		self.recordButton.enabled = YES;
	}

	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelButtonTapped:(id)sender {
	if (! self.cardID) // cancel card creation
		[self.config deleteCard:self.tempCard.UUID];
	
	[self.popover dismissPopoverAnimated:YES];
}

- (IBAction)finishButtonTapped:(id)sender {
		
	NSFileManager *manager = [NSFileManager defaultManager];
	// copy and then delete the temporary image file
	BOOL success = YES;
	// must delete the original file before writing new data to it
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.imagePath]])
		success = success && [manager removeItemAtPath:[HAMFileTools filePath:self.imagePath] error:nil];
	success = success && [manager moveItemAtPath:[HAMFileTools filePath:self.tempImagePath] toPath:[HAMFileTools filePath:self.imagePath] error:nil];
	if (! success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法保存图片" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	self.tempCard.image.localPath = self.imagePath;
	[self.config updateCard:self.tempCard name:self.tempCard.name audio:self.tempCard.audio.localPath image:self.tempCard.image.localPath];
	
	if (! self.cardID) { // if this is a new card, then insert it into a category
		NSString *categoryID = self.categoryID ? self.categoryID : UNCATEGORIZED_ID; // default uncategorized
		NSInteger numChildren = [self.config childrenCardIDOfCat:categoryID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:self.tempCard.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:categoryID with:room atIndex:numChildren];
	}
	
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
}

- (IBAction)deleteCardButtonTapped:(id)sender {
	[self.config deleteCard:self.cardID];
	[self.popover dismissPopoverAnimated:YES];
	[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
}

@end
