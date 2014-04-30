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
#import "HAMSQLiteWrapper.h"

static NSString *const CARDS_DIRECTORY_NAME = @"cards";
static NSString *const CATEGORY_COVER_NAME = @"cover.jpg";

static NSString *const SQLCreateCard = @"CREATE TABLE Card(id VARCHAR(36) PRIMARY KEY, type INT, name VARCHAR(64), image VARCHAR(36), audio VARCHAR(36), num_images INT, removable INT)";
static NSString *const SQLInsertCard = @"INSERT INTO Card VALUES('%@', %d, '%@', '%@', '%@', %d, %d)";
static NSString *const SQLCreateUser = @"CREATE TABLE User(id VARCHAR(36), name VARCHAR(64), root_category VARCHAR(36), layoutx INT, layouty INT)";
static NSString *const SQLInsertUser = @"INSERT INTO User VALUES('%@', '%@', '%@', %d, %d)";
static NSString *const SQLCreateTree = @"CREATE TABLE CardTree(child VARCHAR(36), parent VARCHAR(36), position INT, animation INT, mute INT)";
static NSString *const SQLInsertTree = @"INSERT INTO CardTree VALUES('%@', '%@', %d, %d, %d)";

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

// NOT FINISHED!!!
- (void)importOldResources {
}

// TODO:
//  1. do not override existing files when upgrading
//  2. delete unneeded cards from last version
//  3. show an indicator when import old resources
- (void)initResources
{
	//copy cards
	HAMFileManager* fileManager = [HAMFileManager defaultManager];
	 
	NSString* documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	
	// initialize the database
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
	NSString *databasePath = [libraryPath stringByAppendingPathComponent:DATABASE_NAME];
	HAMSQLiteWrapper *database = [[HAMSQLiteWrapper alloc] initWithDatabasePath:databasePath];
	NSString *sql;
		
	[database executeSQL:SQLCreateCard];
	[database executeSQL:SQLCreateUser];
	[database executeSQL:SQLCreateTree];
	
	// count the total number of cards(categories' covers are also counted)
	NSInteger numCards = 0;
	NSString *cardResourcePath = [resourcePath stringByAppendingPathComponent:CARDS_DIRECTORY_NAME];
	NSArray *categories = [fileManager contentsOfDirectoryAtPath:cardResourcePath];
	for (NSString *category in categories) {
		NSString *categoryPath = [cardResourcePath stringByAppendingPathComponent:category];
		NSArray *cards = [fileManager contentsOfDirectoryAtPath:categoryPath];
		numCards += cards.count;
	}
	
	// add the 'uncategorized' to database
	sql = [NSString stringWithFormat:SQLInsertCard, UNCATEGORIZED_ID, HAMCardTypeCategory, @"未分类", nil, nil, 1, NO];
	[database executeSQL:sql];
	sql = [NSString stringWithFormat:SQLInsertTree, UNCATEGORIZED_ID, LIB_ROOT_ID, 0, HAMAnimationTypeScale, NO];
	[database executeSQL:sql];
	
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
		
		sql = [NSString stringWithFormat:SQLInsertCard, categoryID, (int)HAMCardTypeCategory, categoryName, dstCoverPath, nil, 1, NO];
		[database executeSQL:sql];
		
		NSInteger categoryPos = categoryNum; // position 0 is reserved for the 'uncategorized'
		sql = [NSString stringWithFormat:SQLInsertTree, categoryID, LIB_ROOT_ID, (int)categoryPos, (int)HAMAnimationTypeScale, NO];
		[database executeSQL:sql];
		
		NSString *userID = [@"u" stringByAppendingString:@(categoryNum).stringValue];
		NSString *userRoot = [@"user_cat" stringByAppendingString:@(categoryNum).stringValue];
		sql = [NSString stringWithFormat:SQLInsertUser, userID, categoryName, userRoot, 3, 3];
		[database executeSQL:sql];
		
		sql = [NSString stringWithFormat:SQLInsertCard, userRoot, (int)HAMCardTypeCategory, @"root_category", nil, nil, 1, NO];
		[database executeSQL:sql];
		
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
			
			sql = [NSString stringWithFormat:SQLInsertCard, cardID, (int)HAMCardTypeCard, cardName, imagePath, audioPath, (int)numImages, NO];
			[database executeSQL:sql];
			
			NSInteger cardPos = cardNum - 1; // cardNum starts from 1, while cardPos starts from 0
			sql = [NSString stringWithFormat:SQLInsertTree, cardID, categoryID, (int)cardPos, HAMAnimationTypeScale, NO];
			[database executeSQL:sql];
			
			sql = [NSString stringWithFormat:SQLInsertTree, cardID, userRoot, (int)cardPos, HAMAnimationTypeScale, NO];
			[database executeSQL:sql];
			
			self.copiedResourcesCount = counter++;
			[self performSelectorOnMainThread:@selector(viewUpdate) withObject:nil waitUntilDone:YES];
		}
	}
	
	/********* import cards previously created by user **********/
	
	NSString *oldDatabasePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:@"app_data.db"];
	HAMSQLiteWrapper *oldDatabase = [[HAMSQLiteWrapper alloc] initWithDatabasePath:oldDatabasePath];
	sqlite3_stmt *statement;
	
	sql = @"SELECT * FROM Resources";
	if (SQLITE_OK != sqlite3_prepare_v2(oldDatabase.sqliteDatabase, sql.UTF8String, -1, &statement, NULL))
		NSLog(@"%s", sqlite3_errmsg(oldDatabase.sqliteDatabase));
	
	NSMutableDictionary *resources = [NSMutableDictionary dictionary];
	while (SQLITE_ROW == sqlite3_step(statement)) {
		const char *resourceID = (const char*)sqlite3_column_text(statement, 0);
		const char *resourcePath = (const char*)sqlite3_column_text(statement, 1);
		resources[@(resourceID)] = @(resourcePath);
	}
	sqlite3_finalize(statement);
	
	
	sql = @"SELECT * FROM Card";
	if (SQLITE_OK != sqlite3_prepare_v2(oldDatabase.sqliteDatabase, sql.UTF8String, -1, &statement, NULL))
		NSLog(@"%s", sqlite3_errmsg(oldDatabase.sqliteDatabase));
	
	NSMutableArray *userCreatedCards = [NSMutableArray array];
	while (SQLITE_ROW == sqlite3_step(statement)) {
		BOOL removable = sqlite3_column_int(statement, 6);
		const char *type = (const char*)sqlite3_column_text(statement, 1);
		if (removable && strcmp(type, "card") == 0) { // user-created card
			const char *name = (const char*)sqlite3_column_text(statement, 2);
			const char *imageID = (const char*)sqlite3_column_text(statement, 3);
			const char *audioID = (const char*)sqlite3_column_text(statement, 4);
			
			HAMCard *card = [[HAMCard alloc] initCard];
			card.name = @(name);
			
			// copy image and audio to new position
			if (imageID) {
				NSString *imageLocalPath = resources[@(imageID)];
				NSString *oldImagePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:imageLocalPath];
				[fileManager moveItemAtPath:oldImagePath toPath:card.imagePath];
			}
			if (audioID) { // audio may not exist
				NSString *audioLocalPath = resources[@(audioID)];
				NSString *oldAudioPath = [[HAMFileManager documentPath] stringByAppendingPathComponent:audioLocalPath];
				[fileManager moveItemAtPath:oldAudioPath toPath:card.audioPath];
			}
			
			[userCreatedCards addObject:card];
		}
	}
	sqlite3_finalize(statement);
	
	// old cards are put in the 'uncategorized' category
	int position = 0;
	for (HAMCard *card in userCreatedCards) {
		sql = [NSString stringWithFormat:SQLInsertCard, card.ID, HAMCardTypeCard, card.name, card.imagePath, card.audioPath, 1, YES];
		[database executeSQL:sql];
		
		sql = [NSString stringWithFormat:SQLInsertTree, card.ID, UNCATEGORIZED_ID, position++, HAMAnimationTypeScale, NO];
		[database executeSQL:sql];
	}
	
	HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    [delegate turnToChildView];
}

@end
