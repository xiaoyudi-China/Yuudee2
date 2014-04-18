//
//  HAMUUIDManager.m
//  小雨滴
//
//  Created by 张 磊 on 14-4-18.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import "HAMUUIDManager.h"

@implementation HAMUUIDManager

+ (NSString*)createUUID {
	CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuid = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault, uuidRef));
	CFRelease(uuidRef);
	return uuid;
}

@end
