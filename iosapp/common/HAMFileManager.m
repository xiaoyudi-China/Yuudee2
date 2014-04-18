//
//  HAMFileManager.m
//  小雨滴
//
//  Created by 张 磊 on 14-4-17.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import "HAMFileManager.h"

@interface HAMFileManager ()
@property (nonatomic) NSFileManager *fileManager; // TODO: a better name?
@end

@implementation HAMFileManager

+ (HAMFileManager *)defaultManager {
	HAMFileManager *fileManager = [[HAMFileManager alloc] init];
	fileManager.fileManager = [NSFileManager defaultManager];
	return  fileManager;
}

+ (NSString *)documentPath {
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)temporaryPath {
	return NSTemporaryDirectory();
}

- (NSArray*)contentsOfDirectoryAtPath:(NSString *)path {
	NSError *error;
	NSArray *result = [self.fileManager contentsOfDirectoryAtPath:path error:&error];
	if (! result)
		NSLog(@"%@", error.localizedDescription);
	
	return result;
}

- (void)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
	NSError *error;
	BOOL success = [self.fileManager copyItemAtPath:srcPath toPath:dstPath error:&error];
	if (! success)
		NSLog(@"%@", error.localizedDescription);
}

- (void)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes {
	NSError *error;
	BOOL success = [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:&error];
	if (! success)
		NSLog(@"%@", error.localizedDescription);
}

- (BOOL)fileExistsAtPath:(NSString *)path {
	return [self.fileManager fileExistsAtPath:path];
}

- (void)removeItemAtPath:(NSString *)path {
	NSError *error;
	BOOL success = [self.fileManager removeItemAtPath:path error:&error];
	if (! success)
		NSLog(@"%@", error.localizedDescription);
}

- (void)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
	NSError *error;
	BOOL success = [self.fileManager moveItemAtPath:srcPath toPath:dstPath error:&error];
	if (! success)
		NSLog(@"%@", error.localizedDescription);
}

@end
