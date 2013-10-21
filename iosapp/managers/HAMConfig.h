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
#import "HAMUser.h"

#define FLAGNUM 5
#define NODENUM 66

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
    int dirtyFlag[5];
    
    NSMutableArray* allList;
    NSMutableArray* cardList;
    NSMutableArray* catList;
}

@property NSString* rootID;
@property HAMUserManager* userManager;

-(id)initFromDB;
-(void)clear;

-(HAMCard*)card:(NSString*)UUID;
-(NSString*)childOf:(NSString*)parentID at:(int)pos;

-(NSMutableArray*) allList;
-(NSMutableArray*) cardList;
-(NSMutableArray*) catList;

-(void)updateChildOfNode:(NSString*)nodeID with:(NSString*)childID atIndex:(int)index;
-(void)insertChild:(NSString*)childID toNode:(NSString*)parentID;
-(void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image;
-(void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image;

-(void)deleteCard:(NSString*)UUID;
@end
