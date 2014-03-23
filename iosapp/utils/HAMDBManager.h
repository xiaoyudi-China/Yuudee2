//
//  HAMDBManager.h
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "HAMFileTools.h"
#import "HAMCard.h"
#import "HAMTools.h"
#import "HAMUser.h"
#import "HAMRoom.h"

#define DBNAME @"app_data.db"

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
//-(NSMutableArray*)allCards:(int)mode user:(NSString*)userID;
//-(NSMutableArray*)cardsOfUser:(NSString*)userID mode:(int)mode;
-(void)updateCard:(NSString*)UUID name:(NSString*)name;
-(void)updateCard:(NSString*)UUID audio:(NSString*)audio;
-(void)updateCard:(NSString*)UUID image:(NSString*)image;
-(void)insertCard:(HAMCard*)card;
-(void)deleteCardWithID:(NSString*)UUID;

//table CARD_TREE
-(NSMutableArray*)childrenOf:(NSString*)parentID;
-(void)deleteChildOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(void)deleteCardFromTree:(NSString*)UUID;
-(void)updateChildOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index;
-(void)updateAnimationOfCat:(NSString*)parentID toAnimation:(int)animation atIndex:(NSInteger)index;
//-(void)updateChild:(NSString*)childID ofCat:(NSString*)parentID toIndex:(int)newIndex;
//-(Boolean)ifCat:(NSString*)parentID hasChildAt:(int)pos;

//table RESOURCE
-(void)insertResourceWithID:(NSString*)UUID path:(NSString*)path;
-(void)deleteResourceWithID:(NSString*)UUID;

//table USER
-(HAMUser*)user:(NSString*)userID;
-(NSMutableArray*)allUsers;
-(void)insertUser:(HAMUser*)user;
-(void)updateUser:(NSString*)userID name:(NSString*)newName;
-(void)updateUserLayoutWithID:(NSString*)userID xnum:(int)xnum ynum:(int)ynum;
- (void)updateUser:(NSString*)userID withMuteState:(BOOL)mute;
-(void)deleteUser:(NSString*)userID;

@end
