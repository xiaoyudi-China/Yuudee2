//
//  HAMNodeInfoTool.h
//  iosapp
//
//  Created by daiyue on 13-7-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMFileTools.h"
#import "HAMDBManager.h"
#import "HAMUserManager.h"
#import "HAMCard.h"
#import "HAMRoom.h"
#import "HAMUser.h"

#define FLAGNUM 5
#define NODENUM 66

#define LIB_ROOT @"POETRYIS-WHAT-GETS-LOST-INTRANSLATE."

@class HAMUserManager;

@interface HAMConfig : NSObject
{
    HAMDBManager* dbManager;
    HAMUserManager* userManager;
    
    //nodes is always clean
    NSMutableDictionary* cards;
    NSMutableDictionary* cardTree;
    
    //0 - clean 1 - dirty
    //0 - allList 1 - cardList 2 - catList
    //int dirtyFlag[5];
    
    NSMutableArray* allList;
    NSMutableArray* cardList;
    NSMutableArray* catList;
}

@property NSString* rootID;
@property HAMUserManager* userManager;

-(id)initFromDB;
-(void)clear;

-(HAMCard*)card:(NSString*)UUID;
-(NSString*)childCardIDOfCat:(NSString*)parentID atIndex:(int)index;
-(int)animationOfCat:(NSString*)parentID atIndex:(int)index;
-(HAMRoom*)roomOfCat:(NSString*)parentID atIndex:(int)index;
-(NSMutableArray*)childrenCardIDOfCat:(NSString*)parentID;

-(void)updateRoomOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(int)index;
-(void)updateAnimationOfCat:(NSString*)parentID with:(int)animation atIndex:(int)index;
-(void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image;
-(void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image;

-(void)deleteCard:(NSString*)UUID;
@end
