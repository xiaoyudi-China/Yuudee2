//
//  HAMCardEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardEditorViewController.h"
#import "HAMFileManager.h"

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
	if (self.cardID) { // editing an existing card
		self.tempCard = [self.config card:self.cardID];
		self.imageView.image = [UIImage imageWithContentsOfFile:self.tempCard.imagePath];
		self.editCardTitleView.hidden = NO; // default state is hidden
		
		NSString *filename = [self.tempCard.cardID stringByAppendingPathExtension:CARD_FILE_EXTENSION];
		NSString *filePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:filename];
		NSString *tempPath = [[HAMFileManager temporaryPath] stringByAppendingPathComponent:filename];
		[[HAMFileManager defaultManager] copyItemAtPath:filePath toPath:tempPath]; // backup the card in the temporary directory
	}
	else { // new card
		self.tempCard = [[HAMCard alloc] initCard];
		// don't allow deletion when creating a card
		self.deleteCardButton.hidden = YES;
		// must specify card name and image before recording
		self.recordButton.enabled = NO;
	}
	self.cardNameField.text = self.cardNameLabel.text = self.tempCard.name;
	
	// detect if camera is available
	if (! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		self.shootImageButton.enabled = NO;
	
	// this won't change in the lifetime of the current view
	self.categoryIDs = [self.config childrenCardIDOfCat:LIB_ROOT_ID];
	
	if (! self.categoryID) // the first category is the 'uncategorized'
		self.categoryID = self.categoryIDs.firstObject;
	HAMCard *category = [self.config card:self.categoryID];
	self.categoryNameLabel.text = category.name;
	self.newCategoryID = self.categoryID;
	
	// initialize the recorder
	self.recorder = [[HAMRecorderViewController alloc] initWithNibName:@"HAMRecorderViewController" bundle:nil];
	self.recorder.config = self.config;
	self.recorder.tempCard = self.tempCard;
	self.recorder.isNewCard = ! self.cardID;
	self.recorder.delegate = self;
	
	// NOTE: these properties may be unintialized
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
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// if we have a card name and an image, then we can proceed to the recording view
	if (self.tempCard.name.length > 0 && [fileManager fileExistsAtPath:self.tempCard.imagePath])
		self.recordButton.enabled = YES;
	else
		self.recordButton.enabled = NO;
	
	// re-enable taking pictures
	self.shootImageButton.enabled = self.pickImageButton.enabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return  NO;
}

- (IBAction)recordButtonPressed:(id)sender {
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
	
	UIImage *tempImage = info[UIImagePickerControllerOriginalImage];
	HAMImageCropperViewController *imageCropper = [[HAMImageCropperViewController alloc] initWithNibName:@"HAMImageCropperViewController" bundle:nil];
	imageCropper.image = tempImage;
	imageCropper.delegate = self;
	
	[picker pushViewController:imageCropper animated:YES];
}

- (void)imageCropper:(HAMImageCropperViewController *)imageCropper didFinishCroppingWithImage:(UIImage *)croppedImage {
	self.imageView.image = croppedImage; // update the displaying
		
	if (! [UIImageJPEGRepresentation(croppedImage, 1.0) writeToFile:self.tempCard.imagePath atomically:YES])
		NSLog(@"failed to save the image");
		
	// can save new card now
	if (self.tempCard.name)
		self.recordButton.enabled = YES;

	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelButtonPressed:(id)sender {
	NSString *filename = [self.tempCard.cardID stringByAppendingPathExtension:CARD_FILE_EXTENSION];
	NSString *filePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:filename];
	NSString *tempPath = [[HAMFileManager temporaryPath] stringByAppendingPathComponent:filename];
	
	// restore the card
	HAMFileManager *fileManager = [HAMFileManager defaultManager];
	[fileManager removeItemAtPath:filePath];
	[fileManager moveItemAtPath:tempPath toPath:filePath];

	[self.delegate cardEditorDidCancelEditing:self];
}

- (void)recorderDidEndRecording:(HAMRecorderViewController *)recorder {
	NSDictionary *attrs = @{@"卡片名称": self.tempCard.name};
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

- (IBAction)deleteCardButtonPressed:(id)sender {
	
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
