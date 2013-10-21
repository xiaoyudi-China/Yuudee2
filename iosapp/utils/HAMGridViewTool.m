//
//  HAMGridViewTool.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewTool.h"

@implementation HAMGridViewTool

@synthesize layerArray;

-(id)initWithView:(UIView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config viewController:(id)_viewController edit:(Boolean)_edit{
    if (self=[super init])
    {
        view=_view;
        viewInfo=_viewInfo;
        config=_config;
        
        viewController=_viewController;
        
        edit=_edit;
    }
    return self;
}

-(void)refreshView:(NSString*)nodeUUID{
    NSArray *views = [[view subviews] copy];
    for(UIView* subview in views)
    {
        [subview removeFromSuperview];
    }
    NSArray* sublayers=[[[view layer] sublayers] copy];
    for (id sublayer in sublayers)
    {
        if (sublayer!=[NSNull null])
            [sublayer removeFromSuperlayer];
    }
    
    int i,j=0;
    
    HAMCard* card=[config card:nodeUUID];
    
    layerArray=[NSMutableArray array];
    
    //add home btn
    if (![card.UUID isEqualToString:config.rootID])
    {
        [self addButtonWithi:0 j:0 picName:@"back.png" action:@selector(groupClicked:) tag:-1 bgType:-1];
        [self addLabelWithi:0 j:0 text:@"返回" color:[UIColor blackColor] tag:-1];
        j=1;
    }
    
    //add else btn. fill blanks with add btn if edit
    int totalBtns=viewInfo.xnum*viewInfo.ynum;
    for(i=0;j<totalBtns;i++,j++)
    {
        NSString* childID=[config childOf:card.UUID at:i];
        
        if(!childID || (NSNull*)childID==[NSNull null])
        {
            if(edit)
                [self addAddNodeAtPos:j index:i];
            
            continue;
        }
        
        [self addCardAtPos:j cardID:childID index:i];
    }
}

- (void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum
{
    [viewInfo updateInfoWithxnum:_xnum ynum:_ynum];
}

- (void)addButtonWithi:(int)i j:(int)j picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType
{
    double a=viewInfo.a;
    double x=j*a+(j+1)*viewInfo.xSpace;
    double y=i*(a+viewInfo.h)+(i+1)*viewInfo.ySpace;
    
    CGRect frame = CGRectMake(x, y, a, a);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //a tested value. to hide the button.
    double offset=7;
    button.frame = CGRectMake(x+offset,y+offset,a-2*offset,a-2*offset);
    //button.frame=frame;
    
    //UIImage *buttonBg=[UIImage imageNamed:picName];
    //[button setBackgroundImage:buttonBg forState:UIControlStateNormal];
    
    //tag  home : -1 others : index
    button.tag = tag;
    [button addTarget:viewController action:action forControlEvents:UIControlEventTouchUpInside];
    
    if(edit && tag>=0)
    {
        UILongPressGestureRecognizer *longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:viewController
            action:@selector(longpressStateChanged:)];
        
        longpressRecognizer.delegate = viewController;
        longpressRecognizer.minimumPressDuration = 0.3; //最少按压响应时间
        [button addGestureRecognizer:longpressRecognizer];
    }   
    
    CALayer * downButtonLayer = [button layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:20.0];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
    
    [view addSubview:button];
    
    CALayer* bglayer=[[CALayer alloc] init];
    [bglayer setFrame:frame];
    [bglayer setPosition:CGPointMake(x+frame.size.width/2, y+frame.size.height/2)];
    
    //draw foreground
//    UIImage* fgImage=[UIImage imageNamed:picName];
    UIImage* fgImage=[[UIImage alloc]initWithContentsOfFile:[HAMFileTools filePath:picName]];
    UIImageView* fgView=[[UIImageView alloc] initWithImage:fgImage];
    CGRect picFrame=CGRectMake(viewInfo.picOffsetX, viewInfo.picOffsetY, viewInfo.picWidth, viewInfo.picHeight);
    [fgView setFrame:picFrame];
    [bglayer addSublayer:fgView.layer];
    //[view addSubview:fgView];
    
    //draw background
    UIImage* bgImage=nil;
    switch (bgType) {
        case 0:
            bgImage =[UIImage imageNamed:@"category.png"];
            break;
            
        case 1:
            bgImage =[UIImage imageNamed:@"card.png"];
            break;
            
        default:
            return;
            break;
    }
    UIImageView* bgView=[[UIImageView alloc] initWithImage:bgImage];
    //TODO:1.153 is a tested value
    [bgView setFrame:CGRectMake(0, -a*0.14/2, a, a*1.153)];
    //[view addSubview:bgView];
    [bglayer addSublayer:bgView.layer];
    
    [[view layer]addSublayer:bglayer];
    //[bglayer setAnchorPoint:CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2)];
    [HAMTools addObject:bglayer toMutableArray:layerArray atIndex:tag];
}

- (void)addAddNodeAtPos:(int)pos index:(int)index
{
    int xid=pos/viewInfo.xnum;
    int yid=pos%viewInfo.xnum;

    [self addButtonWithi:xid j:yid picName:@"add.png" action:@selector(addClicked:) tag:index bgType:-1];
    [self addLabelWithi:xid j:yid text:@"新增词条/分组" color:[UIColor blackColor] tag:index];
}

-(void)addCardAtPos:(int)pos cardID:(NSString*)cardID index:(int)index
{
    int xid=pos/viewInfo.xnum;
    int yid=pos%viewInfo.xnum;
    
    HAMCard* card=[config card:cardID];
    NSString* imagePath=[[card image] localPath];
    
    if ([card type]==1)
        [self addButtonWithi:xid j:yid picName:imagePath action:@selector(leafClicked:) tag:index bgType:1];
    else
        [self addButtonWithi:xid j:yid picName:imagePath action:@selector(groupClicked:) tag:index bgType:0];
    
    [self addLabelWithi:xid j:yid text:[card name] color:[UIColor whiteColor] tag:index];
}

-(void)addLabelWithi:(int)i j:(int)j text:(NSString*)text color:(UIColor*)color tag:(int)index
{
    double y=viewInfo.a-viewInfo.wordh;
    double xoff=j*viewInfo.a+(j+1)*viewInfo.xSpace;
    double yoff=i*(viewInfo.a+viewInfo.h)+(i+1)*viewInfo.ySpace;

    
    /*UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(x,y,viewInfo.a,viewInfo.wordh)];
    
    label.text= text;
    label.textColor=color;
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont fontWithName:label.font.fontName size:viewInfo.a*0.13];
    
    label.backgroundColor=[UIColor clearColor];
    
    //if (index>=0)
    //    [[layerArray objectAtIndex:index] addSublayer:label.layer];
    //else
    [view.layer addSublayer:label.layer];
        //[view addSubview:label];*/
    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [textLayer setString:text];
    [textLayer setFontSize:viewInfo.a*0.13];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    textLayer.foregroundColor=[color CGColor];
    //[textLayer setShadowColor:[UIColor blackColor].CGColor];
    //[textLayer setShadowOpacity:1.0];
    //[textLayer setShadowOffset:CGSizeMake(-4.0, -4.0)];
    [textLayer setFrame:CGRectMake(0,y,viewInfo.a,viewInfo.wordh)];
    [textLayer setPosition:CGPointMake(viewInfo.a/2.0, y+viewInfo.wordh/1.5)];
    //[textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    //[_imageLayer addSublayer:textLayer];
    if (index>=0 && [layerArray count]>index)
        [[layerArray objectAtIndex:index] addSublayer:textLayer];
    else
    {
        [textLayer setPosition:CGPointMake(xoff+viewInfo.a/2.0, yoff+y+viewInfo.wordh/1.5)];
        [view.layer addSublayer:textLayer];
    }
    //[view addSubview:label];*/
}

@end
