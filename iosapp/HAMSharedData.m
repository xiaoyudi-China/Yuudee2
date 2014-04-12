//
//  HAMSharedData.m
//  iosapp
//
//  Created by 张 磊 on 14-1-3.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMSharedData.h"
#import <malloc/malloc.h>

@implementation HAMSharedData

+ (id)sharedData {
	static HAMSharedData *theSharedData = nil;
	if (! theSharedData)
		theSharedData = [[self alloc] init];
	
	return theSharedData;
}

// TODO: support for retina display
+ (UIImage*)imageAtPath:(NSString *)path {
	NSCache *imageCache = ((HAMSharedData*)[self sharedData]).imageCache;
	if (! [imageCache objectForKey:path]) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		if (! image) // the specified image might not exist
			return nil;
		
		[imageCache setObject:image forKey:path];
	}
	return [imageCache objectForKey:path];
}

+ (void)updateImageAtPath:(NSString *)path withImage:(UIImage *)image {
	NSCache *imageCache = ((HAMSharedData*)[self sharedData]).imageCache;
	[imageCache setObject:image forKey:path];
}

- (id)init {
	if (self = [super init]) {
		self.imageCache = [[NSCache alloc] init];
		self.imageCache.countLimit = 50; // TODO: this value could be further tuned
	}
	
	return self;
}

@end
