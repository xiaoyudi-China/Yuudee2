//
//  HAMFileTools.m
//  iosapp
//
//  Created by daiyue on 13-7-23.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMFileTools.h"

@implementation HAMFileTools

#pragma mark -
#pragma mark Path Methods

+(NSURL*)fileURL:(NSString*)fileName
{
    return [NSURL fileURLWithPath:[self filePath:fileName]];
}

+(NSString*)filePath:(NSString*)fileName
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+(NSString*)userFilePath:(NSString*)userName
{
    //return [self filePath:[[NSString alloc]initWithFormat:@"//users//%@",userName]];
    return [self filePath:[[NSString alloc]initWithFormat:@"//%@",userName]];
}

+(NSString*)activeUserFilePath
{
    return [self userFilePath:@"hamster"];
}

+(NSString*)activeUserFilePath:(NSString*)fileName
{
    return [self filePath:[[NSString alloc]initWithFormat:@"%@%@",@"hamster",fileName]];
}

#pragma mark -
#pragma mark Dictionary & Array Methods

+(NSDictionary*)dictionaryOfUser:(NSString*)userName
{
    NSString* filepath=[self userFilePath:userName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSDictionary *dictionary=[[NSDictionary alloc] initWithContentsOfFile:filepath];
        return dictionary;
    }
    return nil;
}

+(NSDictionary*)dictionaryOfActiveUser
{
    return [self dictionaryOfUser:@"hamster"];
}

#pragma mark -
#pragma mark Fetch Methods

+(NSMutableArray*)fetchNodes
{
    NSString* path=[self activeUserFilePath:@"Nodes"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSMutableData *data=[[NSMutableData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableArray *nodes=[unarchiver decodeObjectForKey:@"nodes"];
        [unarchiver finishDecoding];
        return nodes;
    }
    
    return nil;

}

+(NSDictionary*)fetchConfigFromJson
{
    /*FILE *configFile = fopen([[self filePath:@"config.txt"] UTF8String],"r");
    char line[300];
    NSString* rawString=@"";
    while(fgets(line,300,configFile)){
        rawString=[rawString stringByAppendingFormat:@"%@",[[NSString alloc] initWithUTF8String:line]];
    }
    
    fclose(configFile);
    
    rawString=[rawString stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    rawString=[rawString stringByReplacingOccurrencesOfString: @"\n" withString:@""];
    
    NSData* rawData=[rawString dataUsingEncoding: NSUTF8StringEncoding];*/
    return nil;
}



#pragma mark -
#pragma mark Write Methods

+(void) writeConfigToFile:(NSDictionary*)config
{
    [config writeToFile:[self activeUserFilePath] atomically:YES];
}

+(void) writeNodes:(NSMutableArray*)nodes
{
    NSMutableData *data=[[NSMutableData alloc] init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:nodes forKey:@"nodes"];
    [archiver finishEncoding];
    [data writeToFile:[self activeUserFilePath:@"Nodes"] atomically:YES];
}

@end
