//
//  HAMUserManager.m
//  iosapp
//
//  Created by daiyue on 13-8-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCoursewareManager.h"

NSString *const HAMCourseware_New = @"HAMUser_NewUser";
NSString *const HAMCourseware_Update = @"HAMUser_UpdateUser";
NSString *const HAMCourseware_UpdateLayout = @"HAMUser_UpdateLayout";
NSString *const HAMCourseware_Delete = @"HAMUser_DeleteUser";

@implementation HAMCoursewareManager

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

-(void)newCourseware:(NSString*)name;
{
    HAMCourseware* newUser=[[HAMCourseware alloc] initWithName:name];
    [self.dbManager insertUser:newUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMCourseware_New object:newUser.UUID];
}

-(void)updateCurrentCoursewareName:(NSString*)newName
{
    [self.dbManager updateUser:currentCourseware.UUID name:newName];
    currentCourseware.name = newName;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMCourseware_Update object:currentCourseware.UUID];
}

-(void)updateCurrentCoursewareLayoutxnum:(int)xnum ynum:(int)ynum
{
	// update the database
	[self updateCourseware:currentCourseware withLayoutxnum:xnum ynum:ynum];
	
	// update the current setting
    currentCourseware.layoutx=xnum;
    currentCourseware.layouty=ynum;
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMCourseware_UpdateLayout object:currentCourseware.UUID];
}

- (void)updateCourseware:(HAMCourseware *)user withLayoutxnum:(int)x ynum:(int)y {
	[self.dbManager updateUserLayoutWithID:user.UUID xnum:x ynum:y];
}

- (void)updateCourseware:(HAMCourseware *)user withMuteState:(BOOL)mute {
	[self.dbManager updateUser:user.UUID withMuteState:mute];
}

-(void)deleteCourseware:(HAMCourseware*)user
{
    NSString *userUUID = [NSString stringWithString:user.UUID];
    [self.dbManager deleteUser:user.UUID];
    currentCourseware=nil;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:HAMCourseware_Delete object:userUUID];
}

#pragma mark -
#pragma mark Current User

-(HAMCourseware*)setCurrentCourseware:(HAMCourseware*)courseware
{
    if (!courseware)
        courseware = [self.dbManager user:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:courseware.UUID forKey:@"currentUserID"];
    [defaults setValue:courseware.name forKey:@"currentUserName"];
    currentCourseware = courseware;
    config.rootID = courseware.rootID;
    
    return courseware;
}

-(HAMCourseware*)currentCourseware
{
    if (currentCourseware!=nil)
        return currentCourseware;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* uuid=[defaults valueForKey:@"currentUserID"];
    if (!uuid)
    {
        return [self setCurrentCourseware:nil];
    }
    currentCourseware = [self.dbManager user:uuid];
    if (currentCourseware==nil)
        [self setCurrentCourseware:nil];
    return currentCourseware;
}

@end
