//
//  HAMSQLiteWrapper.m
//  小雨滴
//
//  Created by 张 磊 on 14-4-24.
//  Copyright (c) 2014年 应用汇. All rights reserved.
//

#import "HAMSQLiteWrapper.h"

@interface HAMSQLiteWrapper () {
	sqlite3 *_database;
}
@end

@implementation HAMSQLiteWrapper

- (id)initWithDatabasePath:(NSString *)path {
	if (self = [super init]) {
		int result = sqlite3_open(path.UTF8String, &_database);
		if (result != SQLITE_OK)
			NSLog(@"%s", sqlite3_errmsg(_database));
	}
	return self;
}

- (sqlite3 *)sqliteDatabase {
	return _database;
}

- (void)executeSQL:(NSString *)sql {
	int result = sqlite3_exec(_database, sql.UTF8String, NULL, NULL, NULL);
	if (result != SQLITE_OK)
		NSLog(@"%s", sqlite3_errmsg(_database));
}

- (void)dealloc {
	sqlite3_close(_database);
}

@end
