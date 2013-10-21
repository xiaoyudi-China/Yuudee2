//
//  HAMWebTool.h
//  iosapp
//
//  Created by daiyue on 13-8-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAMWebTool : NSObject <NSURLConnectionDelegate>
{
    NSString* url;
    NSMutableData* receivedData;
    id handle;
    SEL callback;
}

-(void)dataFromUrl:(NSString*)urlString sel:(SEL)callback handle:(id)callbackHandle;


@end
