//
//  HAMInitViewController.m
//  iosapp
//
//  Created by Dai Yue on 14-1-15.
//  Copyright (c) 2014年 Droplings. All rights reserved.
//

#import "HAMInitViewController.h"
#import "HAMDBManager.h"
#import "HAMAppDelegate.h"

@interface HAMInitViewController ()
{
}

@end

@implementation HAMInitViewController

@synthesize copiedCountLabel;
@synthesize totalCountLabel;
@synthesize progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [self performSelectorInBackground:@selector(copyResources) withObject:nil];
}

- (void)viewUpdate{
    [progressView setProgress:(self.copiedResourcesCount + 0.0f) / self.totalResourcesCount];
	copiedCountLabel.text = @(self.copiedResourcesCount).stringValue;
	totalCountLabel.text = @(self.totalResourcesCount).stringValue;
}

// TODO:
//  1. do not override existing files when upgrading
//  2. retain cards previously created by user
- (void)copyResources
{
	//copy resources
	NSError* error;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = paths[0];
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	
	NSMutableArray *resourcesArray = [[NSMutableArray alloc] init];
	NSString *filePath = [resourcePath stringByAppendingPathComponent:@"resources.txt"];
	NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for (NSString *line in lines) {
		NSString *resource = line;
		[resourcesArray addObject:resource];
	}
	
	self.totalResourcesCount = resourcesArray.count;
	NSInteger count = 1;
	for (NSString *resourceName in resourcesArray) {
		self.copiedResourcesCount = count++;
		[self performSelectorOnMainThread:@selector(viewUpdate) withObject:nil waitUntilDone:YES];
		
		NSString* srcPath = [resourcePath stringByAppendingPathComponent:resourceName];
		NSString* destPath = [documentsDirectory stringByAppendingPathComponent:resourceName];
		
		// delete the resource file if it already exists
		if ([fileManager fileExistsAtPath:destPath])
			if (! [fileManager removeItemAtPath:destPath error:&error])
				NSLog(@"%@", error.localizedDescription);
		
		if (![fileManager copyItemAtPath:srcPath toPath:destPath error:&error])
			NSLog(@"%@", error.localizedDescription);
	}
    	
    HAMAppDelegate* delegate = [UIApplication sharedApplication].delegate;
    [delegate turnToChildView];
}

@end
