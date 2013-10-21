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

@implementation HAMAppDelegate

@synthesize viewController;
@synthesize navController;
@synthesize structureEditViewController;
@synthesize urlFlag;

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
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //background
    //UIImage* draw = [UIImage imageNamed:@"bg.png"];
    UIView* myView=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    //UIColor *backgroundColor = [UIColor colorWithPatternImage:draw];
    
    [myView setBackgroundColor:[UIColor whiteColor]];
    //[draw drawAsPatternInRect:myView.frame];
    [self.window addSubview:myView];
    
    NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url) {
        if ([[url scheme] isEqualToString:@"iosapp"]) {
            urlFlag=YES;
            self.window.rootViewController = self.navController;
            [self.window makeKeyAndVisible];
            return YES;
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[HAMViewController alloc] initWithNibName:@"HAMViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[HAMViewController alloc] initWithNibName:@"HAMViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    urlFlag=NO;
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
    if (urlFlag==YES)
    {
        urlFlag=NO;
        return;
    }
    
    if (!viewController)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController = [[HAMViewController alloc] initWithNibName:@"HAMViewController_iPhone" bundle:nil];
        } else {
            viewController = [[HAMViewController alloc] initWithNibName:@"HAMViewController_iPad" bundle:nil];
        }
    }
    
    if (self.structureEditViewController!=nil)
        [structureEditViewController.view removeFromSuperview];
    if (self.navController!=nil)
        [navController.view removeFromSuperview];
    
    [self.window addSubview:viewController.view];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
