//
//  HAMSharedData.m
//  iosapp
//
//  Created by 张 磊 on 14-1-3.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMSharedData.h"

@implementation HAMSharedData

static BOOL MultiResolution = NO; // temporarily used for debugging

+ (id)sharedData {
	static HAMSharedData *theSharedData = nil;
	if (! theSharedData)
		theSharedData = [[self alloc] init];
	
	return theSharedData;
}

+ (UIImage*)imageNamed:(NSString *)imageName {
	NSArray *tokens = [imageName componentsSeparatedByString:@"."];
	if (tokens.count != 2) // the image name is invalid
		return nil;
	NSString *fileName = imageName;
	if (MultiResolution && [UIScreen mainScreen].scale > 1.0) // using retina display
		fileName = [@[tokens[0], @"@2x.", tokens[1]] componentsJoinedByString:@""];
	
	NSString *path = [HAMFileTools filePath:fileName];
	NSCache *imageCache = ((HAMSharedData*)[self sharedData]).imageCache;
	if (! [imageCache objectForKey:path]) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		if (! image) // the specified image might not exist
			return nil;
		
		[imageCache setObject:image forKey:path];
	}
	return [imageCache objectForKey:path];
}

+ (void)updateImageNamed:(NSString*)imageName withImage:(UIImage*)image {
	NSArray *tokens = [imageName componentsSeparatedByString:@"."];
	if (tokens.count != 2) // the image name is invalid
		return;
	NSString *fileName = imageName;
	if (MultiResolution && [UIScreen mainScreen].scale > 1.0) // using retina display
		fileName = [@[tokens[0], @"@2x.", tokens[1]] componentsJoinedByString:@""];
	
	NSString *path = [HAMFileTools filePath:fileName];
	NSCache *imageCache = ((HAMSharedData*)[self sharedData]).imageCache;
	[imageCache setObject:image forKey:path];
}

- (id)init {
	if (self = [super init]) {
		self.imageCache = [[NSCache alloc] init];
	}
	
	return self;
}

@end
