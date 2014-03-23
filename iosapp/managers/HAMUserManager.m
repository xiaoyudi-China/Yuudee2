//
//  HAMUserManager.m
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMUserManager.h"

@implementation HAMUserManager

@synthesize config;

-(id)init
{
    if (self=[super init])
    {
        self.dbManager = [HAMDBManager new];
    }
    return self;
}

#pragma mark -
#pragma mark User

-(NSMutableArray*)userList
{
    return [self.dbManager allUsers];
}

-(void)newUser:(NSString*)username;
{
    HAMUser* newUser=[[HAMUser alloc] initWithName:username];
    [self.dbManager insertUser:newUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_NewUser object:newUser.UUID];
}

-(void)updateCurrentUserName:(NSString*)newName
{
    [self.dbManager updateUser:currentUser.UUID name:newName];
    currentUser.name = newName;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_UpdateUser object:currentUser.UUID];
}

-(void)updateCurrentUserLayoutxnum:(int)xnum ynum:(int)ynum
{
	// update the database
	[self updateUser:currentUser withLayoutxnum:xnum ynum:ynum];
	
	// update the current setting
    currentUser.layoutx=xnum;
    currentUser.layouty=ynum;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_UpdateLayout object:currentUser.UUID];
}

- (void)updateUser:(HAMUser *)user withLayoutxnum:(int)x ynum:(int)y {
	[self.dbManager updateUserLayoutWithID:user.UUID xnum:x ynum:y];
}

- (void)updateCurrentUserMuteState:(BOOL)mute {
	// update the database
	[self updateUser:currentUser withMuteState:mute];
	
	// update the current setting
	currentUser.mute = mute;
	[[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_UpdateUser object:currentUser.UUID];
}

- (void)updateUser:(HAMUser *)user withMuteState:(BOOL)mute {
	[self.dbManager updateUser:user.UUID withMuteState:mute];
}

-(void)deleteUser:(HAMUser*)user
{
    NSString *userUUID = [NSString stringWithString:user.UUID];
    [self.dbManager deleteUser:user.UUID];
    currentUser=nil;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_DeleteUser object:userUUID];
}

#pragma mark -
#pragma mark Current User

-(HAMUser*)setCurrentUser:(HAMUser*)user
{
    if (!user)
        user = [self.dbManager user:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:user.UUID forKey:@"currentUserID"];
    [defaults setValue:user.name forKey:@"currentUserName"];
    currentUser = user;
    config.rootID = user.rootID;
    
    return user;
}

-(HAMUser*)currentUser
{
    if (currentUser!=nil)
        return currentUser;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* uuid=[defaults valueForKey:@"currentUserID"];
    if (!uuid)
    {
        return [self setCurrentUser:nil];
    }
    currentUser = [self.dbManager user:uuid];
    if (currentUser==nil)
        [self setCurrentUser:nil];
    return currentUser;
}

@end
