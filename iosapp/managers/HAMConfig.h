//
//  HAMNodeInfoTool.h
//  iosapp
//
//  Created by daiyue on 13-7-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMAppDelegate.h"
#import "HAMDBManager.h"
#import "HAMUserManager.h"
#import "HAMCard.h"
#import "HAMRoom.h"
#import "HAMUser.h"
#import "HAMConstants.h"

@class HAMUserManager;

@interface HAMConfig : NSObject
{
    HAMDBManager* dbManager;
    HAMUserManager* userManager;
    
    //nodes is always clean
    NSMutableDictionary* cards;
    NSMutableDictionary* cardTree;
}

@property NSString* rootID;
@property HAMUserManager* userManager;

-(id)initFromDB;
-(void)clear;

-(HAMCard*)card:(NSString*)UUID;

-(NSMutableArray*)childrenOfCat:(NSString*)parentID;
-(NSMutableArray*)childrenCardIDOfCat:(NSString*)parentID;
-(HAMRoom*)roomOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(NSString*)childCardIDOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(int)animationOfCat:(NSString*)parentID atIndex:(NSInteger)index;

-(void)updateRoomOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index;
-(void)updateAnimationOfCat:(NSString*)parentID with:(int)animation atIndex:(NSInteger)index;
-(void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image;
-(void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image;

-(void)insertChildren:(NSArray*)newChildren intoCat:(NSString*)parentID atIndex:(NSInteger)beginIndex;
-(void)deleteCard:(NSString*)UUID;

-(void)deleteChildOfCatInLib:(NSString*)parentID atIndex:(NSInteger)index;
@end
