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

-(id)initWithView:(UIScrollView*)_view viewInfo:(HAMViewInfo*)_viewInfo config:(HAMConfig*)_config delegate:(id)_viewController edit:(Boolean)_edit{
    if (self=[super init])
    {
        scrollView_=_view;
        viewInfo=_viewInfo;
        config=_config;
        
        viewController_=_viewController;
        
        scrollView_.pagingEnabled = YES;
        scrollView_.showsHorizontalScrollIndicator = NO;
        scrollView_.showsVerticalScrollIndicator = NO;
        scrollView_.scrollsToTop = NO;
        scrollView_.delegate = self;
    }
    return self;
}

-(void)prepareRefreshView:(NSString*)nodeUUID{
    currentUUID_ = nodeUUID;
    
    NSArray *views = [[scrollView_ subviews] copy];
    for(UIView* subview in views)
    {
        [subview removeFromSuperview];
    }
    NSArray* sublayers=[[[scrollView_ layer] sublayers] copy];
    for (id sublayer in sublayers)
    {
        if (sublayer!=[NSNull null])
            [sublayer removeFromSuperlayer];
    }
    
    layerArray=[NSMutableArray array];
    
    NSArray* children = [config childrenOf:nodeUUID];
    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
    
    totalPageNum = ceil( (children.count + 0.0f) / btnsPerPage);
    if (totalPageNum == 0)
        totalPageNum = 1;
    
    pageViews = [NSMutableArray arrayWithCapacity:totalPageNum];
    CGRect scrollFrame = scrollView_.frame;
    CGSize contentSize = CGSizeMake(CGRectGetWidth(scrollFrame) * totalPageNum, CGRectGetHeight(scrollFrame));
    scrollView_.contentSize = contentSize;
    scrollView_.contentOffset = CGPointMake(0.0f, 0.0f);
    
    CGSize frameSize = scrollFrame.size;
    for (int i = 0; i < totalPageNum; i++) {
        CGRect frame = CGRectMake(i*frameSize.width, 0, frameSize.width, frameSize.height);
        UIView* pageView = [[UIView alloc] initWithFrame:frame];
        [scrollView_ addSubview:pageView];
        [pageViews addObject:pageView];
    }
}

-(void)refreshView:(NSString*)nodeUUID{
    [self prepareRefreshView:nodeUUID];
    
    int childIndex=0,posIndex,pageIndex;
    HAMCard* card = [config card:nodeUUID];
    Boolean isRoot = [card.UUID isEqualToString:config.rootID];
    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
    
    for (pageIndex = 0; pageIndex < totalPageNum; pageIndex++) {
        posIndex = 0;
        //add home btn
        if (!isRoot)
        {
            [self addButtonWithi:0 j:0 onPage:pageIndex picName:@"back.png" action:@selector(groupClicked:) tag:-1 bgType:-1];
            [self addLabelWithi:0 j:0 onPage:pageIndex text:@"返回" color:[UIColor blackColor] tag:-1];
            posIndex=1;
        }
        //add else btn
        
        for(; posIndex < btnsPerPage; childIndex++,posIndex++)
        {
            NSString* childID=[config childOf:card.UUID at:childIndex];
        
            if(!childID || (NSNull*)childID==[NSNull null])
                continue;
        
            [self addCardAtPos:posIndex onPage:pageIndex cardID:childID index:childIndex];
        }
    }
}

- (void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum
{
    [viewInfo updateInfoWithxnum:_xnum ynum:_ynum];
}

- (UIButton*)addButtonWithi:(int)i j:(int)j onPage:(int)pageIndex picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType
{
    if (pageIndex > pageViews.count) {
        return nil;
    }
    
    UIView* pageView = [pageViews objectAtIndex:pageIndex];
    
    double a=viewInfo.a;
    double x=j*a+(j+1)*viewInfo.xSpace;
    double y=i*(a+viewInfo.h)+(i+1)*viewInfo.ySpace;
    
    CGRect frame = CGRectMake(x, y, a, a);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //a tested value. to hide the button.
    double offset=7;
    button.frame = CGRectMake(x+offset,y+offset,a-2*offset,a-2*offset);
    //button.backgroundColor = [UIColor redColor];
    button.tag = tag;
    [button addTarget:viewController_ action:action forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:20.0];
    [buttonLayer setBorderWidth:0.0];
    //[downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];*/
    
    [pageView addSubview:button];
    
    CALayer* cardLayer=[[CALayer alloc] init];
    [cardLayer setFrame:frame];
    [cardLayer setPosition:CGPointMake(x+frame.size.width/2, y+frame.size.height/2)];
    [[pageView layer]addSublayer:cardLayer];
    if (tag!=-1)
        [HAMTools setObject:cardLayer toMutableArray:layerArray atIndex:tag];
    
    //draw foreground
    UIImage* fgImage=[[UIImage alloc]initWithContentsOfFile:[HAMFileTools filePath:picName]];
    UIImageView* fgView=[[UIImageView alloc] initWithImage:fgImage];
    CGRect picFrame=CGRectMake(viewInfo.picOffsetX, viewInfo.picOffsetY, viewInfo.picWidth, viewInfo.picHeight);
    [fgView setFrame:picFrame];
    [cardLayer addSublayer:fgView.layer];
    
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
            return button;
            break;
    }
    UIImageView* bgView=[[UIImageView alloc] initWithImage:bgImage];
    //TODO:1.153 is a tested value
    [bgView setFrame:CGRectMake(0, -a*0.14/2, a, a*1.153)];
    [pageView addSubview:bgView];
    [cardLayer addSublayer:bgView.layer];
    
    return button;
}

-(void)addCardAtPos:(int)pos onPage:(int)pageIndex cardID:(NSString*)cardID index:(int)index
{
    int xid=pos/viewInfo.xnum;
    int yid=pos%viewInfo.xnum;
    
    HAMCard* card=[config card:cardID];
    NSString* imagePath=[[card image] localPath];
    
    if ([card type]==1)
        [self addButtonWithi:xid j:yid onPage:pageIndex picName:imagePath action:@selector(leafClicked:) tag:index bgType:1];
    else
        [self addButtonWithi:xid j:yid onPage:pageIndex picName:imagePath action:@selector(groupClicked:) tag:index bgType:0];
    
    [self addLabelWithi:xid j:yid onPage:pageIndex text:[card name] color:[UIColor whiteColor] tag:index];
}

-(void)addLabelWithi:(int)i j:(int)j onPage:(int)pageIndex text:(NSString*)text color:(UIColor*)color tag:(int)index
{
    if (pageIndex > pageViews.count) {
        return;
    }
    UIView* pageView = [pageViews objectAtIndex:pageIndex];
    
    double y=viewInfo.a-viewInfo.wordh;
    double xoff=j*viewInfo.a+(j+1)*viewInfo.xSpace;
    double yoff=i*(viewInfo.a+viewInfo.h)+(i+1)*viewInfo.ySpace;

    CATextLayer *textLayer = [CATextLayer layer];
    [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [textLayer setString:text];
    [textLayer setFontSize:viewInfo.a*0.13];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    textLayer.foregroundColor=[color CGColor];
    [textLayer setFrame:CGRectMake(0,y,viewInfo.a,viewInfo.wordh)];
    [textLayer setPosition:CGPointMake(viewInfo.a/2.0, y+viewInfo.wordh/1.5)];
    
    if (index>=0 && [layerArray count]>index)
        [[layerArray objectAtIndex:index] addSublayer:textLayer];
    else
    {
        [textLayer setPosition:CGPointMake(xoff+viewInfo.a/2.0, yoff+y+viewInfo.wordh/1.5)];
        [pageView.layer addSublayer:textLayer];
    }
    //[view addSubview:label];*/
}

@end
