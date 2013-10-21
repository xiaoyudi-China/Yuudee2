//
//  HAMFileTools.h
//  iosapp
//
//  Created by daiyue on 13-7-23.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMFileTools : NSObject
{}

+(NSURL*)fileURL:(NSString*)fileName;
+(NSString*)filePath:(NSString*)fileName;

+(NSMutableArray*)fetchNodes;
+(NSDictionary*)fetchConfigFromJson;

+(void) writeNodes:(NSMutableArray*)nodes;

@end
