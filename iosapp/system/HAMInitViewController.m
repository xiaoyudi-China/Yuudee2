//
//  HAMInitViewController.m
//  iosapp
//
//  Created by Dai Yue on 14-1-15.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMInitViewController.h"
#import "HAMDBManager.h"
#import "HAMAppDelegate.h"
#import "HAMConfig.h"
#import <sqlite3.h>

@interface HAMInitViewController ()
{}

@end

@implementation HAMInitViewController

@synthesize copiedCountLabel;
@synthesize totalCountLabel;
@synthesize progressView;

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
    [progressView setProgress:(self.copiedResourcesCount + 0.0f) / self.totalResourcesCount];
	copiedCountLabel.text = @(self.copiedResourcesCount).stringValue;
	totalCountLabel.text = @(self.totalResourcesCount).stringValue;
}

// TODO:
//  1. do not override existing files when upgrading
//  2. retain cards previously created by user
- (void)initResources
{
	//copy resources
	NSError* error;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	 
	NSString* documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
		
	NSInteger numCards = 0;
	NSString *cardResourcePath = [resourcePath stringByAppendingPathComponent:@"cards"];
	NSArray *categories = [fileManager contentsOfDirectoryAtPath:cardResourcePath error:&error];
	if (! categories)
		NSLog(@"%@", error.localizedDescription);
	for (NSString *category in categories) {
		NSString *categoryPath = [cardResourcePath stringByAppendingPathComponent:category];
		NSArray *cards = [fileManager contentsOfDirectoryAtPath:categoryPath error:&error];
		if (! cards)
			NSLog(@"%@", error.localizedDescription);
		numCards += cards.count;
	}
	
	// initialize the database
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
	NSString *databasePath = [libraryPath stringByAppendingPathComponent:DATABASE_NAME];
	sqlite3 *database = NULL;
	NSString *sql;
	if (SQLITE_OK != sqlite3_open(databasePath.UTF8String, &database))
		NSLog(@"%s", sqlite3_errmsg(database));
	
	sql = @"CREATE TABLE Card(id VARCHAR(36) PRIMARY KEY, type VARCHAR(8), name VARCHAR(64), image VARCHAR(36), audio VARCHAR(36), num_images INT, removable INT)";
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));
		
	sql = @"CREATE TABLE User(id VARCHAR(36), name VARCHAR(64), root_category VARCHAR(36), layoutx INT, layouty INT, mute INT)";
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));

	sql = @"CREATE TABLE Card_Tree(child VARCHAR(36), parent VARCHAR(36), position INT, animation INT)";
	if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
		NSLog(@"%s", sqlite3_errmsg(database));
	
	// copy card resources from the app bundle into the sandboxed document directory
	self.totalResourcesCount = numCards;
	NSInteger counter = 1;
	for (NSString *category in categories) {
		NSString *srcCategoryPath = [cardResourcePath stringByAppendingPathComponent:category];
		NSString *dstCategoryPath = [documentPath stringByAppendingPathComponent:category];
		if (! [fileManager createDirectoryAtPath:dstCategoryPath withIntermediateDirectories:NO attributes:nil error:&error])
			NSLog(@"%@", error.localizedDescription);
		
		NSArray *components = [category componentsSeparatedByString:@"-"];
		NSInteger categoryNum = ((NSString*)components[0]).integerValue;
		NSString *categoryName = components[1];
		NSString *categoryID = [@"cat" stringByAppendingString:@(categoryNum).stringValue];
		NSString *srcCoverPath = [srcCategoryPath stringByAppendingPathComponent:COVER_NAME];
		NSString *dstCoverPath = [dstCategoryPath stringByAppendingPathComponent:COVER_NAME];
		NSString *coverPath;
		if ([fileManager fileExistsAtPath:srcCoverPath]) { // the category's cover may not exist
			if (! [fileManager copyItemAtPath:srcCoverPath toPath:dstCoverPath error:&error])
				NSLog(@"%@", error.localizedDescription);
			
			self.copiedResourcesCount = counter++;
			coverPath = [dstCategoryPath stringByAppendingPathComponent:COVER_NAME];
		}
		else {
			coverPath = nil;
		}
		
		sql = [NSString stringWithFormat:@"INSERT INTO Card VALUES('%@', '%@', '%@', '%@', '%@', %d, %d)", categoryID, @"category", categoryName, coverPath, nil, 1, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSInteger categoryPos = categoryNum;
		sql = [NSString stringWithFormat:@"INSERT INTO Card_Tree VALUES('%@', '%@', %d, %d)", categoryID, LIB_ROOT_ID, categoryPos, (int)HAMAnimationTypeNone];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSString *userID = [@"u" stringByAppendingString:@(categoryNum).stringValue];
		NSString *userRoot = [@"user_cat" stringByAppendingString:@(categoryNum).stringValue];
		sql = [NSString stringWithFormat:@"INSERT INTO User VALUES('%@', '%@', '%@', %d, %d, %d)", userID, categoryName, userRoot, 3, 3, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		sql = [NSString stringWithFormat:@"INSERT INTO Card VALUES('%@', '%@', '%@', '%@', '%@', %d, %d)", userRoot, @"category", @"root_category", nil, nil, 1, NO];
		if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
			NSLog(@"%s", sqlite3_errmsg(database));
		
		NSArray *cards = [fileManager contentsOfDirectoryAtPath:srcCategoryPath error:&error];
		if (! cards)
			NSLog(@"%@", error.localizedDescription);
		for (NSString *card in cards) {
			if ([card isEqualToString:COVER_NAME]) // it's the category's cover
				continue;
			
			NSString *srcCardPath = [srcCategoryPath stringByAppendingPathComponent:card];
			NSString *dstCardPath = [dstCategoryPath stringByAppendingPathComponent:card];
			if (! [fileManager copyItemAtPath:srcCardPath toPath:dstCardPath error:&error])
				NSLog(@"%@", error.localizedDescription);
			
			components = [[card stringByDeletingPathExtension] componentsSeparatedByString:@"-"];
			NSInteger cardNum = ((NSString*)components[0]).integerValue;
			NSString *cardName = components[1];
			NSString *cardID = [categoryID stringByAppendingString:[@"_card" stringByAppendingString:@(cardNum).stringValue]];
			NSArray *images = [fileManager contentsOfDirectoryAtPath:[dstCardPath stringByAppendingPathComponent:@"images"] error:&error];
			if (! images)
				NSLog(@"%@", error.localizedDescription);
			NSArray *audios = [fileManager contentsOfDirectoryAtPath:[dstCardPath stringByAppendingPathComponent:@"audios"] error:&error];
			if (! audios)
				NSLog(@"%@", error.localizedDescription);
			
			// FIXME: last object or first object?
			NSString *imagePath = [dstCardPath stringByAppendingPathComponent:[@"images" stringByAppendingPathComponent:images.lastObject]];
			NSString *audioPath = [dstCardPath stringByAppendingPathComponent:[@"audios" stringByAppendingPathComponent:audios.lastObject]];
			NSInteger numImages = images.count;
			
			// FIXME
			sql = [NSString stringWithFormat:@"INSERT INTO Card VALUES('%@', '%@', '%@', '%@', '%@', %d, %d)",
				   cardID, @"card", cardName, imagePath, audioPath, (int)numImages, NO];
			if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
				NSLog(@"%s", sqlite3_errmsg(database));
			
			NSInteger cardPos = cardNum - 1; // cardNum starts from 1, while cardPos starts from 0
			sql = [NSString stringWithFormat:@"INSERT INTO Card_Tree VALUES('%@', '%@', %d, %d)", cardID, categoryID, cardPos, HAMAnimationTypeScale];
			if (SQLITE_OK != sqlite3_exec(database, sql.UTF8String, NULL, NULL, NULL))
				NSLog(@"%s", sqlite3_errmsg(database));
			
			sql = [NSString stringWithFormat:@"INSERT INTO Card_Tree VALUES('%@', '%@', %d, %d)", cardID, userRoot, cardPos, HAMAnimationTypeScale];
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
