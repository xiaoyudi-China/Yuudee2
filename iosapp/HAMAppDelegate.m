//
//  HAMAppDelegate.m
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMAppDelegate.h"
#import "HAMViewController.h"
#import "HAMSettingsViewController.h"
#import "HAMStructureEditViewController.h"
#import "HAMInitViewController.h"

@implementation HAMAppDelegate

@synthesize viewController;
@synthesize navController;
@synthesize structureEditViewController;
//@synthesize urlFlag;
/*
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url)
        return NO;
    
    if ([[url scheme] isEqualToString:@"iosapp"])
    {
        urlFlag=YES;
        if (self.viewController!=nil)
        {
            [[self viewController].view removeFromSuperview];
        }
        
        if (!structureEditViewController)
            structureEditViewController=[[HAMStructureEditViewController alloc] initWithNibName:@"HAMStructureEditView" bundle:nil];
        if (!navController)
            navController=[[UINavigationController alloc] initWithRootViewController:structureEditViewController];
        [self.window addSubview:navController.view];
    }
    return YES;
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
	// use UMeng SDK to collect statistics
	[MobClick startWithAppkey:@"529d8c2556240b9e4d007957"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self turnToChildView];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [self turnToInitView];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*if (urlFlag==YES)
    {
        urlFlag=NO;
        return;
    }*/
    
    
}

-(void)turnToChildView
{
	if (! self.viewController) { // the first time to be shown
		self.viewController = [[HAMViewController alloc] initWithNibName:@"HAMViewController_iPad" bundle:nil];
		self.window.rootViewController = self.viewController;
		[self.window makeKeyAndVisible];
	}
    else
		[self.viewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)turnToParentView
{
	HAMStructureEditViewController *parentViewController = [[HAMStructureEditViewController alloc] initWithNibName:@"HAMStructureEditView" bundle:nil];
	UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:parentViewController];
	navigator.navigationBarHidden = YES;
	
	parentViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self.viewController presentViewController:navigator animated:YES completion:NULL];
}

- (void)turnToInitView
{
    HAMInitViewController *initViewController = [[HAMInitViewController alloc] initWithNibName:@"HAMInitViewController" bundle:nil];
	UINavigationController *navigator = [[UINavigationController alloc] initWithRootViewController:initViewController];
	navigator.navigationBarHidden = YES;
	
	initViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self.viewController presentViewController:navigator animated:YES completion:NULL];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
