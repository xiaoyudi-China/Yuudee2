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
#import "HAMInitViewController.h"

@implementation HAMAppDelegate

@synthesize viewController;
@synthesize navController;
@synthesize structureEditViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
	[MobClick startWithAppkey:@"529d8c2556240b9e4d007957"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self turnToChildView];
   	
	NSString* currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastVersion"];
	
	// the app is fresh installed, or has been upgraded
    if (!lastVersion || ![lastVersion isEqual:currentVersion])
		[self turnToInitView];
	
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"LastVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
}

-(void)turnToChildView{
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
	HAMSettingsViewController *parentViewController = [[HAMSettingsViewController alloc] initWithNibName:@"HAMSettingsViewController" bundle:nil];
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

@end
