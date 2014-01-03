//
//  HAMSharedData.m
//  iosapp
//
//  Created by 张 磊 on 14-1-3.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMSharedData.h"

@implementation HAMSharedData

+ (id)sharedData {
	static HAMSharedData *theSharedData = nil;
	if (! theSharedData)
		theSharedData = [[self alloc] init];
	
	return theSharedData;
}

- (id)init {
	if (self = [super init]) {
		self.imageCache = [[NSCache alloc] init];
	}
	
	return self;
}

@end
