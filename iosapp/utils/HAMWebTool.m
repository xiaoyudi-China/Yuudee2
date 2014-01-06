//
//  HAMWebTool.m
//  iosapp
//
//  Created by daiyue on 13-8-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMWebTool.h"

@implementation HAMWebTool

-(id)init
{
    if (self=[super init])
    {
        receivedData=[NSMutableData data];
    }
    return self;
}

-(void)dataFromUrl:(NSString*)urlString sel:(SEL)finishFuction handle:(id)callbackHandle
{
    url=urlString;
    callback=finishFuction;
    handle=callbackHandle;
    
    [self performSelectorOnMainThread:@selector(startConnection) withObject:nil waitUntilDone:NO];
}

-(void)startConnection
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:50];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [handle performSelector:callback withObject:nil withObject:error];
	#pragma clang diagnostic pop
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    if ([handle respondsToSelector:callback])
		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[handle performSelector:callback withObject:receivedData withObject:nil];
		#pragma clang diagnostic pop
	else
        NSLog(@"error callback!");
}

@end
