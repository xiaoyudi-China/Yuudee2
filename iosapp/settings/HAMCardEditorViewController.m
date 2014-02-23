//
//  HAMCardEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardEditorViewController.h"

@interface HAMCardEditorViewController ()

@property NSString *imageName;
@property NSString *tempImageName;
@property NSString *audioName;
@property NSString *tempAudioName;

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
	
	self.imageName = [NSString stringWithFormat:@"%@.jpg", self.tempCard.UUID];
	self.tempImageName = [NSString stringWithFormat:@"%@-temp.jpg", self.tempCard.UUID];
	self.audioName = [NSString stringWithFormat:@"%@.caf", self.tempCard.UUID];
	self.tempAudioName = [NSString stringWithFormat:@"%@-temp.caf", self.tempCard.UUID];

	
	// update the view accordingly
	if (self.cardID) { // editing card
		// copy the existing image file to the temporary
		NSFileManager *manager = [NSFileManager defaultManager];
		NSError *error;
		NSString *imagePath = [HAMFileTools filePath:self.imageName];
		NSString *tempImagePath = [HAMFileTools filePath:self.tempImageName];
		if (! [manager copyItemAtPath:imagePath toPath:tempImagePath error:&error])
			NSLog(@"%@", error.localizedDescription);
				
		self.tempCard.image.localPath = self.tempImageName; // point to the temporary file
		self.imageView.image = [HAMSharedData imageNamed:self.tempImageName];
		
		self.editCardTitleView.hidden = NO; // default state is hidden
	}
	else { // new card
		// don't allow deletion when creating a card
		self.deleteCardButton.hidden = YES;
		// must specify card name and image before recording
		self.recordButton.enabled = NO;
	}
	
	// detect if camera is available
	if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		self.shootImageButton.enabled = NO;
	
	// this won't change in the lifetime of the current view
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT];
	
	HAMCard *category = [self.config card:self.categoryID];
	self.categoryNameLabel.text = category.name;
	self.newCategoryID = self.categoryID;
	
	self.cardNameField.text = self.cardNameLabel.text = self.tempCard.name;
	
	// initialize the recorder
	self.recorder = [[HAMRecorderViewController alloc] initWithNibName:@"HAMRecorderViewController" bundle:nil];
	self.recorder.config = self.config;
	self.recorder.tempCard = self.tempCard;
	self.recorder.isNewCard = ! self.cardID;
	self.recorder.delegate = self;
	
	// NOTE: this properties may be unintialized
	self.recorder.addCardOnCreation = self.addCardOnCreation;
	self.recorder.parentID = self.parentID;
	self.recorder.index = self.index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// must end text editing before taking images
	self.shootImageButton.enabled = self.pickImageButton.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	self.tempCard.name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.cardNameLabel.text = self.tempCard.name;
	
	// can save new card now
	self.recordButton.enabled = (self.tempCard.name.length && self.tempCard.image) ? YES : NO;
	
	// re-enable taking pictures
	self.shootImageButton.enabled = self.pickImageButton.enabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return  NO;
}

- (IBAction)recordButtonTapped:(id)sender {
	self.recorder.categoryID = self.categoryID;
	self.recorder.newCategoryID = self.newCategoryID;
	
	// !!!
	UIView *background = [self.view.subviews[0] snapshotViewAfterScreenUpdates:NO];
	[self.recorder.view insertSubview:background atIndex:0];

	self.recorder.modalPresentationStyle = UIModalPresentationCurrentContext;
	self.recorder.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:self.recorder animated:YES completion:NULL];
}

- (IBAction)shootImageButtonPressed:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	[self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)pickImageButtonPressed:(id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	UIImage *tempImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	HAMImageCropperViewController *imageCropper = [[HAMImageCropperViewController alloc] initWithNibName:@"HAMImageCropperViewController" bundle:nil];
	imageCropper.image = tempImage;
	imageCropper.delegate = self;
	
	[picker pushViewController:imageCropper animated:YES];
}

- (void)imageCropper:(HAMImageCropperViewController *)imageCropper didFinishCroppingWithImage:(UIImage *)croppedImage {
	
	self.imageView.image = croppedImage; // update the displaying
	
	// save the image to a temporary file
	BOOL success = [UIImageJPEGRepresentation(croppedImage, 1.0) writeToFile:[HAMFileTools filePath:self.tempImageName] atomically:YES];
	
	if (!success) { // something wrong
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法选取图片" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
		[alert show];
		return; //cannot create new card
	}
	else {
		if (! self.tempCard.image)
			self.tempCard.image = [[HAMResource alloc] initWithPath:self.tempImageName];
	}
	
	// can save new card now
	if (self.tempCard.name)
		self.recordButton.enabled = YES;

	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelButtonTapped:(id)sender {
	if (! self.cardID) // cancel card creation
		[self.config deleteCard:self.tempCard.UUID];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSError *error;
	// delete the temporary image file
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.tempImageName]])
		if (! [manager removeItemAtPath:[HAMFileTools filePath:self.tempImageName] error:&error])
			NSLog(@"%@", error.localizedDescription);
	// delete the temporary audio file
	if ([manager fileExistsAtPath:[HAMFileTools filePath:self.tempAudioName]])
		if (! [manager removeItemAtPath:[HAMFileTools filePath:self.tempAudioName] error:&error])
			NSLog(@"%@", error.localizedDescription);
	
	// FIXME: have to switch these members back, WHY ?!!!
	self.tempCard.image.localPath = self.imageName;
	self.tempCard.audio.localPath = self.audioName;

	[self.delegate cardEditorDidCancelEditing:self];
}

- (void)recorderDidEndRecording:(HAMRecorderViewController *)recorder {
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:self.tempCard.name forKey:@"卡片名称"];
	[MobClick event:@"create_card" attributes:attrs]; // trace event
	
	[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
}

- (void)recorderDidCancelRecording:(HAMRecorderViewController *)recorder {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)chooseCategoryButtonPressed:(id)sender {
	UITableViewController *tableViewController = [[UITableViewController alloc] init];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableCell"];
	
	self.categoriesPopover = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
	[self.categoriesPopover presentPopoverFromRect:self.chooseCategoryButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.categoryIDs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
	NSString *categoryID = self.categoryIDs[indexPath.row];
	HAMCard *category = [self.config card:categoryID];
	
	cell.textLabel.text = category.name;
	return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.newCategoryID = self.categoryIDs[indexPath.row];
	HAMCard *category = [self.config card:self.newCategoryID];
	self.categoryNameLabel.text = category.name;
	
	[self.categoriesPopover dismissPopoverAnimated:YES];
}

- (IBAction)deleteCardButtonTapped:(id)sender {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确认删除卡片？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) { // confirm deletion
		NSArray *cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
		NSUInteger cardIndex = [cardIDs indexOfObject:self.cardID];
		[self.config deleteChildOfCatInLib:self.categoryID atIndex:cardIndex];
		
		[self.delegate cardEditorDidEndEditing:self]; // inform the grid view to refresh
	}
}

@end
