//
//  HAMFileManager.h
//  小雨滴
//
//  Created by 张 磊 on 14-4-17.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import <Foundation/Foundation.h>

// a wrapper of NSFileManager, handling errors internally
@interface HAMFileManager : NSObject

+ (HAMFileManager *)defaultManager;
+ (NSString *)documentPath;
+ (NSString *)temporaryPath;

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path;
- (void)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;
- (void)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (void)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;
- (void)removeItemAtPath:(NSString *)path;

@end
