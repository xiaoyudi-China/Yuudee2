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

#define HAMUser_NewUser         @"HAMUser_NewUser"
#define HAMUser_UpdateUser      @"HAMUser_UpdateUser"
#define HAMUser_UpdateLayout    @"HAMUser_UpdateLayout"
#define HAMUser_DeleteUser      @"HAMUser_DeleteUser"

@class HAMConfig;

@interface HAMUserManager : NSObject
{
    HAMUser* currentUser;
}

@property (weak, nonatomic) HAMConfig* config;
@property (strong, nonatomic) HAMDBManager *dbManager;

//user
-(NSMutableArray*)userList;

-(void)newUser:(NSString*)username;
-(void)updateCurrentUserName:(NSString*)newName;
-(void)updateCurrentUserLayoutxnum:(int)x ynum:(int)y;
-(void)updateCurrentUserMuteState:(BOOL)mute;
-(void)deleteUser:(HAMUser*)user;

- (void)updateUser:(HAMUser*)user withLayoutxnum:(int)xnum ynum:(int)ynum;
- (void)updateUser:(HAMUser*)user withMuteState:(BOOL)mute;

//current user
-(HAMUser*)setCurrentUser:(HAMUser*)user;
-(HAMUser*)currentUser;

@end
