//
//  HAMInitViewController.m
//  iosapp
//
//  Created by Dai Yue on 14-1-15.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMInitViewController.h"
#import "HAMAppDelegate.h"
#import "HAMFileManager.h"
#import "HAMConstants.h"
#import "HAMUUIDManager.h"
#import <sqlite3.h>

static NSString *const CARDS_DIRECTORY_NAME = @"cards";
static NSString *const CATEGORY_COVER_NAME = @"cover.jpg";

@implementation HAMInitViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [self performSelectorInBackground:@selector(initResources) withObject:nil];
}

- (void)viewUpdate{
    [self.progressView setProgress:(self.copiedResourcesCount + 0.0f) / self.totalResourcesCount];
	self.copiedCountLabel.text = @(self.copiedResourcesCount).stringValue;
	self.totalCountLabel.text = @(self.totalResourcesCount).stringValue;
}

// TODO:
//  1. do not override existing files when upgrading
//  2. retain cards previously created by user
- (void)initResources
{
	//copy cards
	HAMFileManager* fileManager = [HAMFileManager defaultManager];
	 
	NSString* documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	
	NSString *sqlCreateCard = @"CREATE TABLE Card(id VARCHAR(36) PRIMARY KEY, type VARCHAR(8), name VARCHAR(64), image VARCHAR(36), audio VARCHAR(36), num_images INT, removable INT)";
	NSString *sqlInsertCard = @"INSERT INTO Card VALUES('%@', '%@', '%@', '%@', '%@', %d, %d)";
	NSString *sqlCreateUser = @"CREATE TABLE User(id VARCHAR(36), name VARCHAR(64), root_category VARCHAR(36), layoutx INT, layouty INT, mute INT)";
	NSString *sqlInsertUser = @"INSERT INTO User VALUES('%@', '%@', '%@', %d, %d, %d)";
	NSString *sqlCreateTree = @"CREATE TABLE CardTree(child VARCHAR(36), parent VARCHAR(36), position INT, animation INT)";
	NSString *sqlInsertTree = @"INSERT INTO CardTree VALUES('%@', '%@', %d, %d)";
	
	// initialize the database
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
	NSString *databasePath = [libraryPath stringByAppendingPathComponent:DATABASE_NAME];
	sqlite3 *database = NULL;
	NSString *sql;
	
	if (SQLITE_OK != sqlite3_open(databasePath.UTF8String, &database))
		NSLog(@"%s", sqlite3_errmsg(database));
	
	sql = sqlCreateCard;
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));
		
	sql = sqlCreateUser;
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));

	sql = sqlCreateTree;
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));
	
	// count the total number of cards(categories' covers are also counted)
	NSInteger numCards = 0;
	NSString *cardResourcePath = [resourcePath stringByAppendingPathComponent:CARDS_DIRECTORY_NAME];
	NSArray *categories = [fileManager contentsOfDirectoryAtPath:cardResourcePath];
	for (NSString *category in categories) {
		NSString *categoryPath = [cardResourcePath stringByAppendingPathComponent:category];
		NSArray *cards = [fileManager contentsOfDirectoryAtPath:categoryPath];
		numCards += cards.count;
	}

	// copy card resources from the app bundle into the sandboxed document directory
	self.totalResourcesCount = numCards;
	NSInteger counter = 1;
	for (NSString *category in categories) {
		NSString *srcCategoryPath = [cardResourcePath stringByAppendingPathComponent:category];
		
		NSArray *components = [category componentsSeparatedByString:@"-"];
		NSInteger categoryNum = ((NSString*)components[0]).integerValue;
		NSString *categoryName = components[1];
		NSString *categoryID = [HAMUUIDManager createUUID]; // allocate a unique ID
		NSString *srcCoverPath = [srcCategoryPath stringByAppendingPathComponent:CATEGORY_COVER_NAME];
		NSString *dstCoverPath = [documentPath stringByAppendingPathComponent:[categoryID stringByAppendingPathExtension:@"jpg"]];
		if ([fileManager fileExistsAtPath:srcCoverPath]) {
			[fileManager copyItemAtPath:srcCoverPath toPath:dstCoverPath];
			self.copiedResourcesCount = counter++;
		}
		
		sql = [NSString stringWithFormat:sqlInsertCard, categoryID, @"category", categoryName, dstCoverPath, nil, 1, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSInteger categoryPos = categoryNum; // the 'uncategorized' has position 0
		sql = [NSString stringWithFormat:sqlInsertTree, categoryID, LIB_ROOT_ID, (int)categoryPos, (int)HAMAnimationTypeNone];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSString *userID = [@"u" stringByAppendingString:@(categoryNum).stringValue];
		NSString *userRoot = [@"user_cat" stringByAppendingString:@(categoryNum).stringValue];
		sql = [NSString stringWithFormat:sqlInsertUser, userID, categoryName, userRoot, 3, 3, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:sqlInsertCard, userRoot, @"category", @"root_category", nil, nil, 1, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSArray *cards = [fileManager contentsOfDirectoryAtPath:srcCategoryPath];
		for (NSString *card in cards) {
			if ([card isEqualToString:CATEGORY_COVER_NAME]) // it's the category's cover
				continue;
			
			NSString *cardID = [HAMUUIDManager createUUID];
			NSString *srcCardPath = [srcCategoryPath stringByAppendingPathComponent:card];
			NSString *dstCardPath = [documentPath stringByAppendingPathComponent:[cardID stringByAppendingPathExtension:CARD_FILE_EXTENSION]];
			[fileManager copyItemAtPath:srcCardPath toPath:dstCardPath];
			
			components = [[card stringByDeletingPathExtension] componentsSeparatedByString:@"-"];
			NSInteger cardNum = ((NSString*)components[0]).integerValue;
			NSString *cardName = components[1];
			NSArray *images = [fileManager contentsOfDirectoryAtPath:[dstCardPath stringByAppendingPathComponent:CARD_IMAGE_SUBDIR]];
			NSArray *audios = [fileManager contentsOfDirectoryAtPath:[dstCardPath stringByAppendingPathComponent:CARD_AUDIO_SUBDIR]];
			
			// FIXME: last object or first object?
			NSString *imagePath = [dstCardPath stringByAppendingPathComponent:[CARD_IMAGE_SUBDIR stringByAppendingPathComponent:images.lastObject]];
			NSString *audioPath = [dstCardPath stringByAppendingPathComponent:[CARD_AUDIO_SUBDIR stringByAppendingPathComponent:audios.lastObject]];
			NSInteger numImages = images.count;
			
			// FIXME
			sql = [NSString stringWithFormat:sqlInsertCard, cardID, @"card", cardName, imagePath, audioPath, (int)numImages, NO];
			if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
				NSLog(@"%s", sqlite3_errmsg(database));
			
			NSInteger cardPos = cardNum - 1; // cardNum starts from 1, while cardPos starts from 0
			sql = [NSString stringWithFormat:sqlInsertTree, cardID, categoryID, (int)cardPos, HAMAnimationTypeScale];
			if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
				NSLog(@"%s", sqlite3_errmsg(database));
			
			sql = [NSString stringWithFormat:sqlInsertTree, cardID, userRoot, (int)cardPos, HAMAnimationTypeScale];
			if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
				NSLog(@"%s", sqlite3_errmsg(database));
			
			self.copiedResourcesCount = counter++;
			[self performSelectorOnMainThread:@selector(viewUpdate) withObject:nil waitUntilDone:YES];
		}
	}
	
	sqlite3_close(database); // close the database connection
	
    HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    [delegate turnToChildView];
}

@end
