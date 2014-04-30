//
//  HAMCard.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCard.h"
#import "HAMUUIDManager.h"
#import "HAMConstants.h"
#import "HAMFileManager.h"

@implementation HAMCard

- (id)init {
	if (self = [super init]) {
		self.ID = [HAMUUIDManager createUUID];
		self.removable = YES; // user-created cards are removable by default
		self.numImages = 1; // user-created cards each have only one image
	}
	return self;
}

- (id)initCard {
    if (self = [self init]) {
		self.type = HAMCardTypeCard;
		
		NSString *filename = [self.ID stringByAppendingPathExtension:CARD_FILE_EXTENSION];
		NSString *filePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:filename];
		self.imagePath = [[filePath stringByAppendingPathComponent:CARD_IMAGE_SUBDIR] stringByAppendingPathComponent:@"1.jpg"];
		self.audioPath = [[filePath stringByAppendingPathComponent:CARD_AUDIO_SUBDIR] stringByAppendingPathComponent:@"1.caf"]; // user-created audio
		
		HAMFileManager *fileManager = [HAMFileManager defaultManager];
		// create sub-directories
		[fileManager createDirectoryAtPath:[filePath stringByAppendingPathComponent:CARD_IMAGE_SUBDIR] withIntermediateDirectories:YES attributes:nil];
		[fileManager createDirectoryAtPath:[filePath stringByAppendingPathComponent:CARD_AUDIO_SUBDIR] withIntermediateDirectories:YES attributes:nil];
    }
    return self;
}

- (id)initCategory {
	if (self = [self init]) {
		self.type = HAMCardTypeCategory;
		
		NSString *imageName = [self.ID stringByAppendingPathExtension:@"jpg"];
		self.imagePath = [[HAMFileManager documentPath] stringByAppendingPathComponent:imageName];
	}
	return self;
}

@end
