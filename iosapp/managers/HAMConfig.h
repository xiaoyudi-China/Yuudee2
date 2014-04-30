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
#import "HAMCoursewareManager.h"
#import "HAMCard.h"
#import "HAMRoom.h"
#import "HAMCourseware.h"
#import "HAMConstants.h"

@class HAMCoursewareManager;

@interface HAMConfig : NSObject
{
    HAMDBManager* dbManager;
    HAMCoursewareManager* userManager;
    
    //nodes is always clean
    NSMutableDictionary* cards;
    NSMutableDictionary* cardTree;
}

@property NSString* rootID;
@property HAMCoursewareManager* userManager;

-(id)initFromDB;
-(void)clear;

-(HAMCard*)card:(NSString*)UUID;

-(NSMutableArray*)childrenOfCat:(NSString*)parentID;
-(NSMutableArray*)childrenCardIDOfCat:(NSString*)parentID;
-(HAMRoom*)roomOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(NSString*)childCardIDOfCat:(NSString*)parentID atIndex:(NSInteger)index;
-(HAMAnimationType)animationOfCat:(NSString*)parentID atIndex:(NSInteger)index;
- (BOOL)muteStateOfCat:(NSString *)parentID atIndex:(NSInteger)index;

- (void)updateRoomOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index;
- (void)updateAnimationOfCat:(NSString *)parentID with:(HAMAnimationType)animation atIndex:(NSInteger)index;
- (void)updateMuteStateOfCat:(NSString *)parentID with:(BOOL)muteState atIndex:(NSInteger)index;
- (void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image;
- (void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image;
- (void)addChild:(NSString *)childID toParent:(NSString *)parentID;
- (void)removeChild:(NSString *)childID fromParent:(NSString *)parentID;
- (void)moveChild:(NSString *)childID fromParent:(NSString *)srcParentID toParent:(NSString *)dstParentID;

-(void)insertChildren:(NSArray*)newChildren intoCat:(NSString*)parentID atIndex:(NSInteger)beginIndex;
-(void)deleteCard:(NSString*)ID;

// FIXME: this method seems to be useless
-(void)deleteChildOfCatInLib:(NSString*)parentID atIndex:(NSInteger)index;
@end
