//
//  HAMCard.m
//  iosapp
//
//  Created by daiyue on 13-7-29.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCard.h"

@implementation HAMCard

-(id)initNewCard
{
    if (self = [super  init])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        self.cardID = CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
		CFRelease(uuidRef);
    }
    return self;
}

- (id)initNewCardAtPath:(NSString*)path {
	if (self = [self initNewCard]) {
		self.imagePath = [[path stringByAppendingPathComponent:@"images"] stringByAppendingPathComponent:@"1.jpg"];
		self.audioPath = [[path stringByAppendingPathComponent:@"audios"] stringByAppendingPathComponent:@"1.caf"]; // user-created audio
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		// create sub-directories
		if (! [fileManager createDirectoryAtPath:[path stringByAppendingPathComponent:@"images"] withIntermediateDirectories:YES attributes:nil error:&error])
			NSLog(@"%@", error.localizedDescription);
		if (! [fileManager createDirectoryAtPath:[path stringByAppendingPathComponent:@"audios"] withIntermediateDirectories:YES attributes:nil error:&error])
			NSLog(@"%@", error.localizedDescription);
	}
	return self;
}

@end
