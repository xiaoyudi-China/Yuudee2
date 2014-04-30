//
//  HAMUserManager.h
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAMDBManager.h"
#import "HAMConfig.h"

extern NSString *const HAMCourseware_New;
extern NSString *const HAMCourseware_Update;
extern NSString *const HAMCourseware_UpdateLayout;
extern NSString *const HAMCourseware_Delete;

@class HAMConfig;

@interface HAMCoursewareManager : NSObject
{
    HAMCourseware* currentCourseware; //TODO: make this a normal property
}

@property (weak, nonatomic) HAMConfig* config;
@property (strong, nonatomic) HAMDBManager *dbManager;

//user
-(NSMutableArray*)userList;

-(void)newCourseware:(NSString*)name;
-(void)updateCurrentCoursewareName:(NSString*)newName;
-(void)updateCurrentCoursewareLayoutxnum:(int)x ynum:(int)y;
-(void)deleteCourseware:(HAMCourseware*)user;

- (void)updateCourseware:(HAMCourseware*)user withLayoutxnum:(int)xnum ynum:(int)ynum;
- (void)updateCourseware:(HAMCourseware*)user withMuteState:(BOOL)mute;

//current user
-(HAMCourseware*)setCurrentCourseware:(HAMCourseware*)courseware;
-(HAMCourseware*)currentCourseware;

@end
