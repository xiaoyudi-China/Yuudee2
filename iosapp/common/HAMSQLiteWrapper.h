//
//  HAMSQLiteWrapper.h
//  小雨滴
//
//  Created by 张 磊 on 14-4-24.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface HAMSQLiteWrapper : NSObject

- (id)initWithDatabasePath:(NSString *)path;
- (void)executeSQL:(NSString *)sql;

- (sqlite3 *)sqliteDatabase;

@end
