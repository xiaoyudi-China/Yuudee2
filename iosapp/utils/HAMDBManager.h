//
//  HAMDBManager.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "HAMCard.h"
#import "HAMTools.h"
#import "HAMCourseware.h"
#import "HAMRoom.h"


@interface HAMDBManager : NSObject
{
    sqlite3* database;
    sqlite3_stmt* statement;
    
    Boolean dbIsOpen;
}

-(Boolean)isDatabaseExist;
-(Boolean)runSQL:(NSString*)sql;

//table CARD
-(HAMCard*)card:(NSString*)UUID;
-(void)updateCard:(NSString*)UUID name:(NSString*)name;
-(void)updateCard:(NSString*)UUID audio:(NSString*)audio;
-(void)updateCard:(NSString*)UUID image:(NSString*)image;
-(void)insertCard:(HAMCard*)card;
-(void)deleteCardWithID:(NSString*)UUID;

//table CardTree
-(NSMutableArray*)childrenOf:(NSString*)parentID;
-(void)deleteChildOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(void)deleteCardFromTree:(NSString*)UUID;
-(void)updateChildOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index;
-(void)updateAnimationOfCat:(NSString*)parentID toAnimation:(HAMAnimationType)animation atIndex:(NSInteger)index;
- (void)updateMuteStateOfCat:(NSString *)parentID toMuteState:(BOOL)mute atIndex:(NSInteger)index;

//table USER
-(HAMCourseware*)user:(NSString*)userID;
-(NSMutableArray*)allUsers;
-(void)insertUser:(HAMCourseware*)user;
-(void)updateUser:(NSString*)userID name:(NSString*)newName;
-(void)updateUserLayoutWithID:(NSString*)userID xnum:(int)xnum ynum:(int)ynum;
- (void)updateUser:(NSString*)userID withMuteState:(BOOL)mute;
-(void)deleteUser:(NSString*)userID;

@end
