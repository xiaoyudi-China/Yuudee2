//
//  HAMCategoryEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategoryEditorViewController.h"
#import "HAMSharedData.h"
#import "HAMFileManager.h"

@interface HAMCategoryEditorViewController ()

@end

@implementation HAMCategoryEditorViewController

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
	if (! self.categoryID) { // creating new category
		self.deleteButton.hidden = YES; // don't allow deletion of category being created
		self.finishButton.enabled = NO; // must input category name before finishing
		self.pickCoverButton.enabled = NO;
		self.createCategoryTitleView.hidden = NO;
		self.categoryCoverView.image = [UIImage imageNamed:@"defaultImage.png"];
	}
	else { // editing
		HAMCard *category = [self.config card:self.categoryID];
		self.categoryNameField.text = category.name;
		self.categoryCoverView.image = [HAMSharedData imageAtPath:category.imagePath];
		if (! self.categoryCoverView.image) // if there's no image, just display the xiaoyudi logo
			self.categoryCoverView.image = [UIImage imageNamed:@"defaultImage.png"];
	}
	self.categoryNameLabel.text = self.categoryNameField.text;
	self.preferredContentSize = self.view.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButtonPressed:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"该分类下所有卡片均会被删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
	[alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1) { // confirm deletion
		// delete all cards under this category
		NSArray *cardIDs = [self.config childrenCardIDOfCat:self.categoryID];
		for (NSInteger index = 0; index < cardIDs.count; index++) {
			[self.config deleteChildOfCatInLib:self.categoryID atIndex:index];
		}
		
		NSArray *catIDs = [self.config childrenCardIDOfCat:LIB_ROOT_ID];
		NSUInteger catIndex = [catIDs indexOfObject:self.categoryID];
		[self.config deleteChildOfCatInLib:LIB_ROOT_ID atIndex:catIndex];
		
		[self.delegate categoryEditorDidEndEditing:self]; // ask the grid to refresh
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.categoryNameLabel.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.finishButton.enabled = self.categoryNameLabel.text.length ? YES : NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// disable finish button while editing
	self.finishButton.enabled = NO;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self.delegate categoryEditorDidCancelEditing:self];
}

- (IBAction)finishButtonPressed:(id)sender {
	HAMFileManager *fileManager = [HAMFileManager defaultManager];
	NSData *imageData = UIImageJPEGRepresentation(self.categoryCoverView.image, 1.0);
	HAMCard *category;
	
	if (self.categoryID) { // editing category
		category = [self.config card:self.categoryID];
		category.name = self.categoryNameLabel.text;
		
		[fileManager removeItemAtPath:category.imagePath]; // delete the old image
		if (! [imageData writeToFile:category.imagePath atomically:YES]) // save the new image
			NSLog(@"failed to save image");
				
		// update database
		[self.config updateCard:category name:category.name audio:nil image:category.imagePath];
	}
	else { // creating category
		category = [[HAMCard alloc] initCategory];
		category.name = self.categoryNameLabel.text;
		
		if (! [imageData writeToFile:category.imagePath atomically:YES])
			NSLog(@"failed to save image");
		
		// update database
		[self.config newCardWithID:category.cardID name:category.name type:HAMCardTypeCategory audio:nil image:category.imagePath];
		
		// insert the new category into library
		NSInteger numChildren = [self.config childrenCardIDOfCat:LIB_ROOT_ID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:category.cardID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:LIB_ROOT_ID with:room atIndex:numChildren];

		// collect user statistics
		NSDictionary *attrs = @{@"分类名称": category.name};
		[MobClick event:@"create_category" attributes:attrs]; // trace event
	}
	// update the image cache
	[HAMSharedData updateImageAtPath:category.imagePath withImage:self.categoryCoverView.image];
	[self.delegate categoryEditorDidEndEditing:self]; // tell the grid view to refresh
}

- (IBAction)pickCoverButtonPressed:(id)sender {
	HAMCoverPickerViewController *coverPicker = [[HAMCoverPickerViewController alloc] initWithNibName:@"HAMCoverPickerViewController" bundle:nil];
	coverPicker.config = self.config;
	coverPicker.categoryID = self.categoryID;
	coverPicker.delegate = self;
	
	self.popover = [[UIPopoverController alloc] initWithContentViewController:coverPicker];
	[self.popover presentPopoverFromRect:self.pickCoverButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)coverPickerDidPickImage:(UIImage *)image {
	[self.popover dismissPopoverAnimated:YES];
	self.categoryCoverView.image = image;
}

@end
