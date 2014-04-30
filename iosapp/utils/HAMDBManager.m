//
//  HAMDBManager.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMDBManager.h"
#import "HAMConstants.h"


@interface HAMDBManager ()
@property (nonatomic) NSString *databasePath;
@end

@implementation HAMDBManager

#pragma mark
#pragma mark DB METHODS

// TODO: make this more intuitive
- (NSString*)databasePath {
	if (! _databasePath) {
		NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
		_databasePath = [libraryPath stringByAppendingPathComponent:DATABASE_NAME];
	}
	return _databasePath;
}

-(Boolean)openDatabase
{
    if (dbIsOpen)
    {
        NSLog(@"is already open!");
        return true;
    }
    
    if (sqlite3_open([self databasePath].UTF8String, &database)
        != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0,@"Fail to open database!");
        return false;
    }
    
    dbIsOpen=YES;
    return true;
}

-(Boolean)isDatabaseExist
{
    int rc=sqlite3_open_v2([self databasePath].UTF8String, &database, SQLITE_OPEN_READWRITE, NULL);
    if (rc==0)
        sqlite3_close(database);
    return rc==0;
}

-(void)closeDatabase
{
    if (!dbIsOpen)
        return;
    
    if (statement)
    {
        sqlite3_finalize(statement);
        statement=nil;
    }
    sqlite3_close(database);
    dbIsOpen=NO;
}

-(Boolean)prepareSelect:(NSString*)selectClause from:(NSString*)table where:(NSString*)whereClause
{
    [self openDatabase];
    
    NSString *sql;
    if (whereClause)
    {
        sql= [[NSString alloc] initWithFormat:@"SELECT %@ FROM %@ WHERE %@;",selectClause,table,whereClause];
    }
    else
    {
        sql=[[NSString alloc] initWithFormat:@"SELECT %@ FROM %@;",selectClause,table];
    }
    
    int result=sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSLog( @"Fail to %@",sql);
        [self closeDatabase];
        return false;
    }
    return true;
}

-(Boolean)runSQL:(NSString*)sql
{
    char *errorMsg;
    
    [self openDatabase];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to %@:%s",sql,errorMsg);
        [self closeDatabase];
        return false;
    }
    [self closeDatabase];
    return true;
}

#pragma mark -
#pragma mark Tools

-(NSString*)stringAt:(int)column
{
    char* text=(char*)sqlite3_column_text(statement, column);
    if (text)
        return @(text);
    else
        return nil;
}

//error
- (void)ErrorReport: (NSString *)item
{
    char *errorMsg;
    
    if (sqlite3_exec(database, [item UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK)
    {
        NSLog(@"%@ ok.",item);
    }
    else
    {
        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
    }
}

#pragma mark -
#pragma mark From CARD

-(HAMCard*)card:(NSString*)UUID
{
    [self openDatabase];
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT * FROM Card WHERE id='%@'",UUID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        NSAssert(0,@"Fail to select!");
        [self closeDatabase];
        return nil;
    }
    
    sqlite3_step(statement);
    HAMCard* card = [[HAMCard alloc] init];

    card.ID = [self stringAt:0];
	card.type = (HAMCardType)sqlite3_column_int(statement, 1);
    card.name=[self stringAt:2];
    card.imagePath = [self stringAt:3];
    card.audioPath = [self stringAt:4];
    card.numImages = sqlite3_column_int(statement, 5);
    card.removable = sqlite3_column_int(statement, 6);
    
    [self closeDatabase];
    
    return card;
}

-(void)updateCard:(NSString*)UUID name:(NSString*)name
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE CARD SET NAME='%@' WHERE ID='%@'",name,UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to update name!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)updateCard:(NSString*)UUID audio:(NSString*)audio
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE CARD SET AUDIO='%@' WHERE ID='%@';",audio,UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to update audio!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)updateCard:(NSString*)UUID image:(NSString*)image
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE CARD SET IMAGE='%@' WHERE ID='%@';",image,UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to update image!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)insertCard:(HAMCard*)card
{
    [self openDatabase];
    
    char* update="INSERT INTO Card (id, type, name, image, audio, num_images, removable) VALUES (?, ?, ?, ?, ?, ?, ?);";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [card.ID UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, (int)card.type);
        sqlite3_bind_text(stmt, 3, [card.name UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [card.imagePath UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [card.audioPath UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 6, card.numImages);
        sqlite3_bind_int(stmt, 7, card.removable);
    }
    if (sqlite3_step(stmt)!= SQLITE_DONE)
        NSAssert(0, @"Error inserting into card");
    
    [self closeDatabase];
}

-(void)deleteCardWithID:(NSString*)UUID
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM CARD WHERE ID='%@';",UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from RESOURCE!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

#pragma mark -
#pragma mark From CardTree

-(NSMutableArray*)childrenOf:(NSString*)parentID
{
    [self openDatabase];
    
    NSString* query = [[NSString alloc]initWithFormat:@"SELECT child, position, animation, mute FROM CardTree WHERE parent='%@';",parentID];
    int result = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result != SQLITE_OK)
    {
        NSAssert(0,@"Fail to select from CardTree!");
        [self closeDatabase];
        return nil;
    }
    
    NSMutableArray* children = [NSMutableArray arrayWithCapacity:100];
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSString* childID = [self stringAt:0];
        NSInteger pos = sqlite3_column_int(statement, 1);
        HAMAnimationType animation = sqlite3_column_int(statement, 2);
		BOOL mute = sqlite3_column_int(statement, 3);
        
        HAMRoom* room = [[HAMRoom alloc] initWithCardID:childID animation:animation muteState:mute];
        [HAMTools setObject:room toMutableArray:children atIndex:pos];
    }
    
    [self closeDatabase];
    return children;
}

-(void)deleteChildOfCat:(NSString *)parentID atIndex:(NSInteger)index
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM CardTree WHERE PARENT='%@' AND POSITION=%ld",parentID,(long)index];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from CardTree!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)deleteCardFromTree:(NSString*)UUID
{
    [self openDatabase];
    
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM CardTree WHERE PARENT='%@' OR CHILD='%@';",UUID,UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from CardTree!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)updateChildOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index
{
    [self openDatabase];
    
    //TODO: I don't know if this insert or replace works!! Must add index creating to SQL on server!
    
    char* update="INSERT OR REPLACE INTO CardTree (CHILD, PARENT, POSITION, ANIMATION, mute) VALUES (?, ?, ?, ?, ?);";
    
    if (sqlite3_prepare_v2(database, update, -1, &statement, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [newRoom.cardID UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [parentID UTF8String], -1, NULL);
		sqlite3_bind_int(statement, 3, (int)index);
		sqlite3_bind_int(statement, 4, newRoom.animation);
		sqlite3_bind_int(statement, 5, newRoom.mute);
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert(0, @"Error updating");
    }
    
    [self closeDatabase];
}

-(void)updateAnimationOfCat:(NSString*)parentID toAnimation:(HAMAnimationType)animation atIndex:(NSInteger)index
{
	[self runSQL:[[NSString alloc] initWithFormat:@"UPDATE CardTree SET animation = %d WHERE parent = '%@' AND position = %d", animation, parentID, (int)index]];
}

- (void)updateMuteStateOfCat:(NSString *)parentID toMuteState:(BOOL)mute atIndex:(NSInteger)index {
	[self runSQL:[NSString stringWithFormat:@"UPDATE CardTree SET mute = %d WHERE parent = '%@' AND position = %d", mute, parentID, (int)index]];
}

-(void)insertResourceWithID:(NSString*)UUID path:(NSString*)path
{
    [self openDatabase];
    
    char* update="INSERT INTO RESOURCES (ID, FILENAME) VALUES (?, ?);";
    
    if (sqlite3_prepare_v2(database, update, -1, &statement, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [UUID UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [path UTF8String], -1, NULL);
    }
    if (sqlite3_step(statement)!=SQLITE_DONE)
    {
        NSAssert(0, @"Error insert into RESOURCES");
    }
    
    [self closeDatabase];
}

#pragma mark
#pragma mark From USER

-(HAMCourseware*)user:(NSString*)userID
{
    NSString* whereClause;
    if (userID!=nil)
        whereClause=[[NSString alloc]initWithFormat: @"ID = '%@'",userID];
    if(![self prepareSelect:@"*" from:@"USER" where:whereClause])
        return nil;
    
    HAMCourseware* user;
    if(sqlite3_step(statement)==SQLITE_ROW)
    {
        user = [[HAMCourseware alloc] init];
        user.UUID=[self stringAt:0];
        user.name=[self stringAt:1];
        user.rootID=[self stringAt:2];
        user.layoutx=sqlite3_column_int(statement, 3);
        user.layouty=sqlite3_column_int(statement, 4);
    }
    
    [self closeDatabase];
    return user;
}

-(NSMutableArray*)allUsers
{
    /*NSString *sql = [[NSString alloc] initWithFormat:@"create table USER(ID varchar(36), NAME varchar(64), ROOT_CATEGORY varchar(36));"];
    [self runSQL:sql];
    
    sql = [[NSString alloc] initWithFormat:@"INSERT INTO USER VALUES(\"cb6c9999-bc3b-42f3-90d9-4f54222c7ec7\",\"默认用户\",\"af35431e-cdea-4d66-b32f-57bf683a25ce\");"];
    [self runSQL:sql];*/
    
    [self prepareSelect:@"*" from:@"USER" where:nil];
    
    NSMutableArray* users=[[NSMutableArray alloc] initWithCapacity:20];
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        HAMCourseware* user = [[HAMCourseware alloc] init];
        user.UUID = [self stringAt:0];
        user.name = [self stringAt:1];
        user.rootID = [self stringAt:2];
        user.layoutx = sqlite3_column_int(statement, 3);
        user.layouty = sqlite3_column_int(statement, 4);
        
        [users addObject:user];
    }
    
    [self closeDatabase];
    return users;
}

-(void)insertUser:(HAMCourseware*)user
{
    //TODO: default layoutx,layouty
    [self runSQL:[[NSString alloc] initWithFormat: @"INSERT INTO USER VALUES('%@', '%@', '%@', %d, %d);",user.UUID,user.name,user.rootID, user.layoutx, user.layouty]];
    [self runSQL:[[NSString alloc] initWithFormat: @"INSERT INTO CARD VALUES(\"%@\",\"category\",\"root_category\",null,null,\"%@\",1);",user.rootID,user.name]];
}

-(void)updateUser:(NSString*)userID name:(NSString*)newName
{
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE USER SET NAME = '%@' WHERE ID = '%@'",newName,userID]];
}

-(void)updateUserLayoutWithID:(NSString*)userID xnum:(int)xnum ynum:(int)ynum
{
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE USER SET LAYOUTX = %d, LAYOUTY = %d WHERE ID = '%@'",xnum,ynum,userID]];
}

- (void)updateUser:(NSString*)userID withMuteState:(BOOL)mute {
	[self runSQL:[NSString stringWithFormat:@"UPDATE USER SET mute = %d WHERE id = '%@'", mute, userID]];
}

-(void)deleteUser:(NSString*)userID
{
    [self runSQL:[[NSString alloc] initWithFormat:@"DELETE FROM USER WHERE ID = '%@'",userID]];
}

@end