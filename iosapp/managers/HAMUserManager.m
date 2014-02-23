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
        dbManager=[HAMDBManager new];
    }
    return self;
}

#pragma mark -
#pragma mark User

-(NSMutableArray*)userList
{
    return [dbManager allUsers];
}

-(void)newUser:(NSString*)username;
{
    HAMUser* newUser=[[HAMUser alloc] initWithName:username];
    [dbManager insertUser:newUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_NewUser object:newUser.UUID];
}

-(void)updateCurrentUserName:(NSString*)newName
{
    [dbManager updateUser:currentUser.UUID name:newName];
    currentUser.name = newName;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_UpdateUser object:currentUser.UUID];
}

-(void)updateCurrentUserLayoutxnum:(int)xnum ynum:(int)ynum
{
    currentUser.layoutx=xnum;
    currentUser.layouty=ynum;
    [dbManager updateUserLayoutWithID:currentUser.UUID xnum:xnum ynum:ynum];
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_UpdateLayout object:currentUser.UUID];
}

-(void)deleteUser:(HAMUser*)user
{
    /*NSMutableArray* cards=[dbManager cardsOfUser:user.UUID mode:0];
    int i;
    for (i=0; i<[cards count]; i++) {
        [config deleteCard:cards[i]];
    }*/
    NSString *userUUID = [NSString stringWithString:user.UUID];
    [dbManager deleteUser:user.UUID];
    currentUser=nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMUser_DeleteUser object:userUUID];
}

#pragma mark -
#pragma mark Current User

-(HAMUser*)setCurrentUser:(HAMUser*)user
{
    if (!user)
        user=[dbManager user:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:user.UUID forKey:@"currentUserID"];
    [defaults setValue:user.name forKey:@"currentUserName"];
    currentUser=user;
    config.rootID=user.rootID;
    
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
    currentUser=[dbManager user:uuid];
    if (currentUser==nil)
        [self setCurrentUser:nil];
    return currentUser;
}

@end
