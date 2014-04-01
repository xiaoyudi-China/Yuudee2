//
//  HAMCategoryEditorViewController.m
//  iosapp
//
//  Created by 张 磊 on 13-11-15.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCategoryEditorViewController.h"
#import "HAMSharedData.h"

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
		self.categoryNameField.text = [self.config card:self.categoryID].name;
		self.tempCategoryName = self.categoryNameField.text;
		NSString *imageName = [NSString stringWithFormat:@"%@.jpg", self.categoryID];
		self.categoryCoverView.image = [HAMSharedData imageNamed:imageName];
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
	self.categoryNameLabel.text = self.tempCategoryName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.finishButton.enabled = self.tempCategoryName.length ? YES : NO;
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
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSData *imageData = UIImageJPEGRepresentation(self.categoryCoverView.image, 1.0);
	
	if (self.categoryID) { // editing category
		HAMCard *category = [self.config card:self.categoryID];
		
		NSString *imageName = [NSString stringWithFormat:@"%@.jpg", category.UUID];
		NSString *filePath = [HAMFileTools filePath:imageName];
		NSError *error;
		if (! [fileManager removeItemAtPath:filePath error:&error]) // remove the old image
			NSLog(@"%@", error.localizedDescription);
		if (! [imageData writeToFile:filePath atomically:YES]) // save the new image
			NSLog(@"failed to save image file");
		
		// update the image cache
		[HAMSharedData updateImageNamed:imageName withImage:self.categoryCoverView.image];
		
		[self.config updateCard:category name:self.tempCategoryName audio:nil image:imageName];
	}
	else { // creating category
		HAMCard *category = [[HAMCard alloc] initNewCard];
		NSString *categoryName = self.tempCategoryName;
		
		NSString *imageName = [NSString stringWithFormat:@"%@.jpg", category.UUID];
		NSString *filePath = [HAMFileTools filePath:imageName];
		BOOL success = [imageData writeToFile:filePath atomically:YES];
		if (! success) {
			// TODO: error handling
		}
		// update the image cache
		[HAMSharedData updateImageNamed:imageName withImage:self.categoryCoverView.image];
		
		// type 0 indicates a category
		[self.config newCardWithID:category.UUID name:categoryName type:0 audio:nil image:imageName];
		category.isRemovable = YES; // ???: what's this for?
		
		NSInteger numChildren = [self.config childrenCardIDOfCat:LIB_ROOT_ID].count;
		HAMRoom *room = [[HAMRoom alloc] initWithCardID:category.UUID animation:ROOM_ANIMATION_NONE];
		[self.config updateRoomOfCat:LIB_ROOT_ID with:room atIndex:numChildren];

		// collect user statistics
		NSDictionary *attrs = @{@"分类名称": categoryName};
		[MobClick event:@"create_category" attributes:attrs]; // trace event
	}
	
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
