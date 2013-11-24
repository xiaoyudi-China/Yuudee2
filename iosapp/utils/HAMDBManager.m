//
//  HAMDBManager.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMDBManager.h"

@implementation HAMDBManager

#pragma mark
#pragma mark DB METHODS

-(Boolean)openDatabase
{
    if (dbIsOpen)
    {
        NSLog(@"is already open!");
        return true;
    }
    
    if (sqlite3_open([[HAMFileTools filePath:DBNAME] UTF8String], &database)
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
    int rc=sqlite3_open_v2([[HAMFileTools filePath:DBNAME] UTF8String], &database, SQLITE_OPEN_READWRITE, NULL);
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
        return [NSString stringWithUTF8String:text];
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
    
    NSString* query=[[NSString alloc]initWithFormat:@"SELECT * FROM CARD WHERE ID='%@'",UUID];
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to select!");
        [self closeDatabase];
        return nil;
    }
    
    sqlite3_step(statement);
    HAMCard* card=[HAMCard alloc];

    card.UUID=[self stringAt:0];
    
    NSString* type=[self stringAt:1];
    if ([type isEqualToString:@"card"])
        card.type=1;
    else
        card.type=0;
    
    card.name=[self stringAt:2];
    
    NSString* imageID,* audioID;
    imageID=[self stringAt:3];
    audioID=[self stringAt:4];
    int isRemovable = sqlite3_column_int(statement, 6);
    
    [self closeDatabase];
    
    if (imageID)
        card.image=[self resource:imageID];
    if (audioID)
        card.audio=[self resource:audioID];
    
    card.isRemovable_ = isRemovable;
    
    return card;
}

/*-(NSMutableArray*)allCards:(int)mode user:(NSString*)userID
{
    [self openDatabase];
    
    NSMutableArray* cards=[NSMutableArray arrayWithCapacity:100];
    
    NSString* query;
    switch (mode) {
        case 0:
            query=[[NSString alloc] initWithFormat: @"SELECT ID,NAME FROM CARD WHERE TYPE='card' OR USER='%@'",userID];
            break;
        
        case 1:
            query=@"SELECT ID,NAME FROM CARD WHERE TYPE='card'";
            break;
            
        case 2:
            query=[[NSString alloc] initWithFormat:@"SELECT ID,NAME FROM CARD WHERE TYPE='category' AND USER='%@'",userID];
            break;
            
        default:
            query=nil;
            break;
    }
    
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to select!");
        [self closeDatabase];
        return nil;
    }
    
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        HAMCard* card=[HAMCard alloc];
        card.UUID=[self stringAt:0];
        card.name=[self stringAt:1];
        [cards addObject:card];
    }
    
    [self closeDatabase];
    return cards;
}*/

-(NSMutableArray*)cardsOfUser:(NSString*)userID mode:(int)mode
{
    NSString* whereClause;
    switch (mode) {
        case 0:
            whereClause=[[NSString alloc] initWithFormat: @"USER = '%@'",userID];
            break;
            
        case 1:
            whereClause=[[NSString alloc] initWithFormat: @"USER = '%@' AND TYPE='card'",userID];
            break;
            
        case 2:
            whereClause=[[NSString alloc] initWithFormat: @"USER = '%@' AND TYPE='category'",userID];
            break;
            
        default:
            whereClause=nil;
            break;
    }
    [self prepareSelect:@"ID,NAME" from:@"CARD" where:whereClause];
    
    NSMutableArray* cards=[[NSMutableArray alloc] initWithCapacity:20];
    while (sqlite3_step(statement)==SQLITE_ROW) {
        HAMCard* card=[HAMCard alloc];
        card.UUID=[self stringAt:0];
        card.name=[self stringAt:1];
        [cards addObject:card];
    }
    
    [self closeDatabase];
    return cards;
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

-(void)insertCard:(HAMCard*)card user:(NSString *)user
{
    [self openDatabase];
    
    char* update="INSERT INTO CARD (ID, TYPE, NAME, IMAGE, AUDIO, USER, REMOVABLE) VALUES (?, ?, ?, ?, ?, ?, 0);";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [card.UUID UTF8String], -1, NULL);
        
        char* type;
        switch (card.type) {
            case 0:
                type="category";
                break;
                
            case 1:
                type="card";
                break;
                
            default:
                type="error_type";
                break;
        }
        sqlite3_bind_text(stmt, 2, type, -1, NULL);
        
        sqlite3_bind_text(stmt, 3, [card.name UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [card.image.UUID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [card.audio.UUID UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [user UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 7, card.isRemovable_);
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
#pragma mark From CARD_TREE

-(NSMutableArray*)childrenOf:(NSString*)parentID
{
    [self openDatabase];
    
    NSString* query=[[NSString alloc]initWithFormat:@"SELECT CHILD,POSITION,ANIMATION FROM CARD_TREE WHERE PARENT='%@';",parentID];
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to select from card_tree!");
        [self closeDatabase];
        return nil;
    }
    
    NSMutableArray* children = [NSMutableArray arrayWithCapacity:100];
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSString* childID = [self stringAt:0];
        int pos=sqlite3_column_int(statement, 1);
        NSString* animation = [self stringAt:2];
        
        int animationType;
        if ([animation isEqualToString:@"SHAKE"] || [animation isEqualToString:@"shake"]) {
            animationType = ROOM_ANIMATION_SHAKE;
        }
        else if ([animation isEqualToString:@"SCALE"] || [animation isEqualToString:@"scale"]){
            animationType = ROOM_ANIMATION_SCALE;
        }
        else{
            animationType = ROOM_ANIMATION_NONE;
        }
        
        HAMRoom* room = [[HAMRoom alloc] initWithCardID:childID animation:animationType];
        [HAMTools setObject:room toMutableArray:children atIndex:pos];
    }
    
    [self closeDatabase];
    return children;
}

/*
-(Boolean)ifCat:(NSString*)parentID hasChildAt:(int)pos{
    [self prepareSelect:@"*" from:@"CARD_TREE" where:[[NSString alloc] initWithFormat:@"PARENT = '%@' and POSITION = %d",parentID,pos]];
    
    Boolean exist=sqlite3_step(statement)==SQLITE_ROW;
    
    [self closeDatabase];
    return exist;

}*/

-(void)deleteChildOfCat:(NSString *)parentID atIndex:(int)index
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM CARD_TREE WHERE PARENT='%@' AND POSITION=%d",parentID,index];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from card_tree!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)deleteCardFromTree:(NSString*)UUID
{
    [self openDatabase];
    
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM CARD_TREE WHERE PARENT='%@' OR CHILD='%@';",UUID,UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from card_tree!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
}

-(void)updateChildOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(int)index
{
    [self openDatabase];
    
    /*NSString* query=[[NSString alloc] initWithFormat:@"CREATE INDEX PARENT_POSITION ON CARD_TREE (PARENT, POSITION)"];
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to create index!");
        [self closeDatabase];
        return;
    }*/
    
    //TODO: I don't know if this insert or replace works!! Must add index creating to SQL on server!
    
    char* update="INSERT OR REPLACE INTO CARD_TREE (CHILD, PARENT, POSITION, ANIMATION) VALUES (?, ?, ?, ?);";
    
    if (sqlite3_prepare_v2(database, update, -1, &statement, nil)==SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [newRoom.cardID_ UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [parentID UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 3, index);
        
        NSString* animation;
        switch (newRoom.animation_) {
            case ROOM_ANIMATION_NONE:
                animation = @"NONE";
                break;
                
            case ROOM_ANIMATION_SCALE:
                animation = @"SCALE";
                break;
                
            case ROOM_ANIMATION_SHAKE:
                animation = @"SHAKE";
                break;
                
            default:
                break;
        }
        sqlite3_bind_text(statement, 4, [animation UTF8String], -1, NULL);
    }
    if (sqlite3_step(statement)!=SQLITE_DONE)
    {
        NSAssert(0, @"Error updating");
    }
    
    /*NSString* query=[[NSString alloc]initWithFormat:@"SELECT * FROM CARD_TREE WHERE PARENT='%@' AND POSITION=%d",parentID,index];
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to select from card_tree!");
        [self closeDatabase];
        return;
    }
    
    if(sqlite3_step(statement)==SQLITE_ROW)
    {
        //record exists. we need to update
        
    }
    else
    {
        //record doesn't exist. we need to insert
    }*/
    
    [self closeDatabase];
}

/*-(void)updateChild:(NSString*)childID ofCat:(NSString*)parentID toIndex:(int)newIndex
{
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE CARD_TREE SET POSITION = %d WHERE CHILD = '%@' AND PARENT = '%@'",newIndex, childID, parentID]];
}*/

-(void)updateAnimationOfCat:(NSString*)parentID toAnimation:(int)animation atIndex:(int)index
{
    NSString* animationString;
    switch (animation) {
        case ROOM_ANIMATION_NONE:
            animationString = @"NONE";
            break;
        
        case ROOM_ANIMATION_SCALE:
            animationString = @"SCALE";
            break;
            
        case ROOM_ANIMATION_SHAKE:
            animationString = @"SHAKE";
            break;
            
        default:
            animationString = @"?";
            break;
    }
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE CARD_TREE SET ANIMATION = '%@' WHERE PARENT = '%@' AND POSITION = %d", animationString, parentID, index]];
}

#pragma mark -
#pragma mark From RESOURCES

-(HAMResource*)resource:(NSString*)UUID
{
    [self openDatabase];
    
    NSString* query=[[NSString alloc]initWithFormat:@"SELECT * FROM RESOURCES WHERE ID='%@'",UUID];
    int result=sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (result!=SQLITE_OK)
    {
        NSAssert(0,@"Fail to select from resource!");
        [self closeDatabase];
        return nil;
    }
    
    sqlite3_step(statement);
    HAMResource* resource=[HAMResource alloc];
    
    resource.UUID=[self stringAt:0];
    resource.localPath=[self stringAt:1];
    
    [self closeDatabase];
    return resource;
}

-(void)deleteResourceWithID:(NSString*)UUID
{
    [self openDatabase];
    char *errorMsg;
    
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM RESOURCES WHERE ID='%@';",UUID];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        NSLog( @"Fail to delete from RESOURCE!");
        [self ErrorReport: sql];
    }
    
    [self closeDatabase];
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

-(HAMUser*)user:(NSString*)userID
{
    NSString* whereClause;
    if (userID!=nil)
        whereClause=[[NSString alloc]initWithFormat: @"ID = '%@'",userID];
    if(![self prepareSelect:@"*" from:@"USER" where:whereClause])
        return nil;
    
    HAMUser* user;
    if(sqlite3_step(statement)==SQLITE_ROW)
    {
        user=[HAMUser alloc];
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
        HAMUser* user=[HAMUser alloc];
        user.UUID=[self stringAt:0];
        user.name=[self stringAt:1];
        user.rootID=[self stringAt:2];
        
        [users addObject:user];
    }
    
    [self closeDatabase];
    return users;
}

-(void)insertUser:(HAMUser*)user
{
    //TODO: default layoutx,layouty
    [self runSQL:[[NSString alloc] initWithFormat: @"INSERT INTO USER VALUES(\"%@\",\"%@\",\"%@\",3,4);",user.UUID,user.name,user.rootID]];
    [self runSQL:[[NSString alloc] initWithFormat: @"INSERT INTO CARD VALUES(\"%@\",\"category\",\"root_category\",null,null,\"%@\");",user.rootID,user.name]];
}

-(void)updateUser:(NSString*)userID name:(NSString*)newName
{
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE USER SET NAME = '%@' WHERE ID = '%@'",newName,userID]];
}

-(void)updateUserLayoutWithID:(NSString*)userID xnum:(int)xnum ynum:(int)ynum
{
    [self runSQL:[[NSString alloc] initWithFormat:@"UPDATE USER SET LAYOUTX = %d, LAYOUTY = %d WHERE ID = '%@'",xnum,ynum,userID]];
}

-(void)deleteUser:(NSString*)userID
{
    [self runSQL:[[NSString alloc] initWithFormat:@"DELETE FROM USER WHERE ID = '%@'",userID]];
}

@end