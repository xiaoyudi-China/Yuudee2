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

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        
        //copy resources
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        
        NSArray* resourcesArray = [NSArray arrayWithObjects:@"cat1_p1.jpg",@"cat1_card1_p1.jpg",@"cat1_card1_p2.jpg",@"cat1_card1_p3.jpg",@"cat1_card1_s1.mp3",@"cat1_card2_p1.jpg",@"cat1_card2_p2.jpg",@"cat1_card2_p3.jpg",@"cat1_card2_s1.mp3",@"cat2_p1.jpg",@"cat2_card1_p1.jpg",@"cat2_card1_p2.jpg",@"cat2_card1_p3.jpg",@"cat2_card1_s1.mp3",@"cat2_card2_p1.jpg",@"cat2_card2_p2.jpg",@"cat2_card2_p3.jpg",@"cat2_card2_s1.mp3",@"cat2_card3_p1.jpg",@"cat2_card3_p2.jpg",@"cat2_card3_p3.jpg",@"cat2_card3_s1.mp3",@"cat2_card4_p1.jpg",@"cat2_card4_p2.jpg",@"cat2_card4_p3.jpg",@"cat2_card4_s1.mp3",@"cat2_card5_p1.jpg",@"cat2_card5_p2.jpg",@"cat2_card5_p3.jpg",@"cat2_card5_s1.mp3",@"cat2_card6_p1.jpg",@"cat2_card6_p2.jpg",@"cat2_card6_p3.jpg",@"cat2_card6_s1.mp3",@"cat2_card7_p1.jpg",@"cat2_card7_p2.jpg",@"cat2_card7_s1.mp3",@"cat2_card8_p1.jpg",@"cat2_card8_p2.jpg",@"cat2_card8_p3.jpg",@"cat2_card8_s1.mp3",@"cat2_card9_p1.jpg",@"cat2_card9_p2.jpg",@"cat2_card9_p3.jpg",@"cat2_card9_s1.mp3",nil];
        int i;
        for (i = 0; i < resourcesArray.count; i++) {
            NSString* resourceName = [resourcesArray objectAtIndex:i];
            NSString* srcPath = [resourcePath stringByAppendingPathComponent:resourceName];
            NSString* destPath = [documentsDirectory stringByAppendingPathComponent:resourceName];
            
            if (![fileManager copyItemAtPath:srcPath toPath:destPath error:&error]) {
                NSAssert(0, @"Failed to copy resource:[%@] with message '%@'",resourceName, [error localizedDescription]);
            }
        }
        
        //run SQL
        /*HAMDBManager* dbManager = [[HAMDBManager alloc] init];
        NSArray* createTabelSQLArray = DEFAULT_SQL_LIST;
        
        //create tables
        for (i = 0; i < createTabelSQLArray.count; i++) {
            NSString* SQL = [createTabelSQLArray objectAtIndex:i];
            [dbManager runSQL:SQL];
        }
        
        //insert resources
        for (i = 0; i < resourcesArray.count; i++) {
            NSString* resourceName = [resourcesArray objectAtIndex:i];
            NSString* SQL = [NSString stringWithFormat:@"insert into resources values('%@','%@')",resourceName, resourceName];
            [dbManager runSQL:SQL];
        }
        
        //insert users
        for (i = 1; i <= 3; i++) {
            NSString* SQL = [NSString stringWithFormat:@"insert into user values('u%d','阶段%d','user_cat%d',%d,%d)",i,i,i,i,i];
            [dbManager runSQL:SQL];
            SQL = [NSString stringWithFormat:@"insert into card values('user_cat%d','category','root_category',null,null,null,0)",i];
            [dbManager runSQL:SQL];
        }
        
        //insert cards
        NSString* SQL = [NSString stringWithFormat:@"insert into card values('cat1_card1','card','我吃饱了','cat1_card1_p1.jpg','cat1_card1_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat1_card2','card','我不吃了','cat1_card2_p1.jpg','cat1_card2_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card1','card','我看不清楚','cat2_card1_p1.jpg','cat2_card1_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card2','card','太黑了','cat2_card2_p1.jpg','cat2_card2_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card3','card','全身不舒服','cat2_card3_p1.jpg','cat2_card3_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card4','card','太饿了','cat2_card4_p1.jpg','cat2_card4_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card5','card','太渴了','cat2_card5_p1.jpg','cat2_card5_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card6','card','太累了','cat2_card6_p1.jpg','cat2_card6_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card7','card','太冷了','cat2_card7_p1.jpg','cat2_card7_s1.mp3',2,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card8','card','太热了','cat2_card8_p1.jpg','cat2_card8_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2_card9','card','太湿了','cat2_card9_p1.jpg','cat2_card9_s1.mp3',3,0)"];
        [dbManager runSQL:SQL];
        
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat1_card1','user_cat1', 0,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat1_card1','user_cat2', 0,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat1_card2','user_cat2', 1,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card1','user_cat3', 0,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card2','user_cat3', 1,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card3','user_cat3', 2,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card4','user_cat3', 3,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card5','user_cat3', 4,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card6','user_cat3', 5,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card7','user_cat3', 6,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card8','user_cat3', 7,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card9','user_cat3', 8,'scale')"];
        [dbManager runSQL:SQL];
        
        SQL = [NSString stringWithFormat:@"insert into card values('lib_root','category','lib_root',null,null,0,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat1','category','吃喝','cat1_p1.jpg',null,1,0)"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card values('cat2','category','感觉不舒服','cat2_p1.jpg',null,1,0)"];
        [dbManager runSQL:SQL];
        
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat1_card1','cat1', 0,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat1_card2','cat1', 1,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card1','cat2', 0,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card2','cat2', 1,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card3','cat2', 2,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card4','cat2', 3,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card5','cat2', 4,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card6','cat2', 5,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card7','cat2', 6,'scale')"];
        [dbManager runSQL:SQL];
        SQL = [NSString stringWithFormat:@"insert into card_tree values('cat2_card8','cat2', 7,'scale')"];
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card9','cat2', 8,'scale')";
        [dbManager runSQL:SQL];*/
        
        HAMDBManager* dbManager = [[HAMDBManager alloc] init];
        NSArray* createTabelSQLArray = DEFAULT_SQL_LIST;
        
        //create tables
        for (i = 0; i < createTabelSQLArray.count; i++) {
            NSString* SQL = [createTabelSQLArray objectAtIndex:i];
            [dbManager runSQL:SQL];
        }
        
        NSString* SQL;
        SQL = @"insert into resources values('cat1_p1.jpg','cat1_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card1_p1.jpg','cat1_card1_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card1_p2.jpg','cat1_card1_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card1_p3.jpg','cat1_card1_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card1_s1.mp3','cat1_card1_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card2_p1.jpg','cat1_card2_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card2_p2.jpg','cat1_card2_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card2_p3.jpg','cat1_card2_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat1_card2_s1.mp3','cat1_card2_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_p1.jpg','cat2_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card1_p1.jpg','cat2_card1_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card1_p2.jpg','cat2_card1_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card1_p3.jpg','cat2_card1_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card1_s1.mp3','cat2_card1_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card2_p1.jpg','cat2_card2_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card2_p2.jpg','cat2_card2_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card2_p3.jpg','cat2_card2_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card2_s1.mp3','cat2_card2_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card3_p1.jpg','cat2_card3_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card3_p2.jpg','cat2_card3_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card3_p3.jpg','cat2_card3_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card3_s1.mp3','cat2_card3_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card4_p1.jpg','cat2_card4_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card4_p2.jpg','cat2_card4_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card4_p3.jpg','cat2_card4_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card4_s1.mp3','cat2_card4_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card5_p1.jpg','cat2_card5_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card5_p2.jpg','cat2_card5_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card5_p3.jpg','cat2_card5_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card5_s1.mp3','cat2_card5_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card6_p1.jpg','cat2_card6_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card6_p2.jpg','cat2_card6_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card6_p3.jpg','cat2_card6_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card6_s1.mp3','cat2_card6_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card7_p1.jpg','cat2_card7_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card7_p2.jpg','cat2_card7_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card7_s1.mp3','cat2_card7_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card8_p1.jpg','cat2_card8_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card8_p2.jpg','cat2_card8_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card8_p3.jpg','cat2_card8_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card8_s1.mp3','cat2_card8_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card9_p1.jpg','cat2_card9_p1.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card9_p2.jpg','cat2_card9_p2.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card9_p3.jpg','cat2_card9_p3.jpg')";
        [dbManager runSQL:SQL];
        SQL = @"insert into resources values('cat2_card9_s1.mp3','cat2_card9_s1.mp3')";
        [dbManager runSQL:SQL];
        SQL = @"insert into user values('u1','阶段1','user_cat1',1,1)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('user_cat1','category','root_category',null,null,0,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into user values('u2','阶段2','user_cat2',2,2)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('user_cat2','category','root_category',null,null,0,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into user values('u3','阶段3','user_cat3',3,3)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('user_cat3','category','root_category',null,null,0,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('lib_root','category','lib_root',null,null,0,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat1','category','吃喝','cat1p1.jpg',null,1,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2','category','感觉不舒服','cat2p1.jpg',null,1,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat1_card1','card','我吃饱了','cat1_card1_p1.jpg','cat1_card1_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat1_card2','card','我不吃了','cat1_card2_p1.jpg','cat1_card2_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card1','card','我看不清楚','cat2_card1_p1.jpg','cat2_card1_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card2','card','太黑了','cat2_card2_p1.jpg','cat2_card2_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card3','card','全身不舒服','cat2_card3_p1.jpg','cat2_card3_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card4','card','太饿了','cat2_card4_p1.jpg','cat2_card4_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card5','card','太渴了','cat2_card5_p1.jpg','cat2_card5_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card6','card','太累了','cat2_card6_p1.jpg','cat2_card6_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card7','card','太冷了','cat2_card7_p1.jpg','cat2_card7_s1.mp3',2,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card8','card','太热了','cat2_card8_p1.jpg','cat2_card8_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card values('cat2_card9','card','太湿了','cat2_card9_p1.jpg','cat2_card9_s1.mp3',3,0)";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat1_card1','user_cat1',0,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat1_card1','user_cat2',0,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat1_card2','user_cat2',1,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card1','user_cat2',2,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card2','user_cat2',3,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card1','user_cat3',0,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card2','user_cat3',1,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card3','user_cat3',2,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card4','user_cat3',3,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card5','user_cat3',4,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card6','user_cat3',5,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card7','user_cat3',6,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card8','user_cat3',7,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card9','user_cat3',8,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat1_card1','cat1',0,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat1_card2','cat1',1,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card1','cat2',0,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card2','cat2',1,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card3','cat2',2,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card4','cat2',3,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card5','cat2',4,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card6','cat2',5,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card7','cat2',6,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card8','cat2',7,'scale')";
        [dbManager runSQL:SQL];
        SQL = @"insert into card_tree values('cat2_card9','cat2',8,'scale')";
        [dbManager runSQL:SQL];
}
    
	// use UMeng SDK to collect statistics
	[MobClick startWithAppkey:@"529d8c2556240b9e4d007957"];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self turnToChildView];

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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
