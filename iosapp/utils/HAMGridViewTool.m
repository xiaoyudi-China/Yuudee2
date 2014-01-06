//
//  HAMGridViewTool.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewTool.h"

@implementation HAMGridViewTool

@synthesize cardViewArray_;

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
        currentPage_ = 0;
    }
    return self;
}

//prepare data and scrollview
-(void)prepareRefreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage{
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
    
    cardViewArray_=[NSMutableArray array];
    
    NSArray* children = [config childrenCardIDOfCat:nodeUUID];
    int btnsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    
    totalPageNum_ = ceil( (children.count + 0.0f) / btnsPerPage);
    if (totalPageNum_ == 0)
        totalPageNum_ = 1;
//    currentPage_ = MIN(currentPage_, totalPageNum_ - 1);
    
    pageViews_ = [NSMutableArray arrayWithCapacity:totalPageNum_];
    CGRect scrollFrame = scrollView_.frame;
    CGSize contentSize = CGSizeMake(CGRectGetWidth(scrollFrame) * totalPageNum_, CGRectGetHeight(scrollFrame));
    scrollView_.contentSize = contentSize;
    
    if (showFirstPage)
        currentPage_ = 0;
    else
        currentPage_ = MIN(currentPage_, totalPageNum_ - 1);
    
    CGSize frameSize = scrollFrame.size;
    scrollView_.contentOffset = CGPointMake(frameSize.width * currentPage_, 0.0f);
    
    for (int i = 0; i < totalPageNum_; i++) {
        CGRect frame = CGRectMake(i*frameSize.width, 0, frameSize.width, frameSize.height);
        UIView* pageView = [[UIView alloc] initWithFrame:frame];
        [scrollView_ addSubview:pageView];
        [pageViews_ addObject:pageView];
    }
}

//add things to scroll view
-(void)refreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage
{
    [self prepareRefreshView:nodeUUID scrollToFirstPage:showFirstPage];
    
    int childIndex=0,posIndex,pageIndex;
    HAMCard* card = [config card:nodeUUID];
    //Boolean isRoot = [card.UUID isEqualToString:config.rootID];
    int btnsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    
    for (pageIndex = 0; pageIndex < totalPageNum_; pageIndex++) {
        posIndex = 0;
        //add home btn
        /*if (!isRoot)
        {
            [self addButtonAtPosIndex:posIndex onPage:pageIndex picName:@"back.png" action:@selector(groupClicked:) tag:-1 bgType:-1];
            [self addLabelAtPosIndex:posIndex onPage:pageIndex text:@"返回" color:[UIColor blackColor] tag:-1];
            posIndex=1;
        }*/
        //add else btn
        
        for(; posIndex < btnsPerPage; childIndex++,posIndex++)
        {
            NSString* childID=[config childCardIDOfCat:card.UUID atIndex:childIndex];
        
            if(!childID || (NSNull*)childID==[NSNull null])
                continue;
        
            [self addCardAtPosIndex:posIndex onPage:pageIndex cardID:childID index:childIndex];
        }
    }
}

- (void)setLayoutWithxnum:(int)_xnum ynum:(int)_ynum
{
    viewInfo = [[HAMViewInfo alloc] initWithXnum:_xnum ynum:_ynum];
}

- (UIButton*)addButtonAtPosIndex:(int)index onPage:(int)pageIndex picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType
{
    if (pageIndex > pageViews_.count) {
        return nil;
    }
    
    //add card view
    UIView* pageView = [pageViews_ objectAtIndex:pageIndex];
    CGPoint cardPosition = [viewInfo cardPositionAtIndex:index];
    
    CGRect frame = CGRectMake(cardPosition.x, cardPosition.y, viewInfo.cardWidth, viewInfo.cardHeight);
    UIView* cardView = [[UIView alloc] initWithFrame:frame];
    [pageView addSubview:cardView];
    if (tag!=-1)
        [HAMTools setObject:cardView toMutableArray:cardViewArray_ atIndex:tag];
    
    //add button area
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //a tested value. to hide the button.
    double offset=7;
    button.frame = CGRectMake(offset, offset, viewInfo.cardWidth - 2 * offset, viewInfo.cardHeight - 2 * offset);
//    button.backgroundColor = [UIColor redColor];
    button.tag = tag;
    [button addTarget:viewController_ action:action forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:20.0];
    [buttonLayer setBorderWidth:0.0];
    //[downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];*/
    
    [cardView addSubview:button];
    
    
    //draw cardwhite
    CGRect localFrame = CGRectMake(0, 0, viewInfo.cardWidth, viewInfo.cardHeight);
    UIImageView* cardWhiteBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_white.png"]];
    [cardWhiteBg setFrame:localFrame];
    [cardView addSubview:cardWhiteBg];
    
    //draw cardpic
	UIImage* fgImage = nil;
	if (picName) { // NOTE: picName may be 'nil'
		NSCache *imageCache = ((HAMSharedData*)[HAMSharedData sharedData]).imageCache;
		NSString *path = [HAMFileTools filePath:picName];
		if (! [imageCache objectForKey:path])
			[imageCache setObject:[UIImage imageWithContentsOfFile:path] forKey:path];
		fgImage = [imageCache objectForKey:path];
	}

	UIImageView* fgView=[[UIImageView alloc] initWithImage:fgImage];
    CGRect picFrame=CGRectMake(viewInfo.picOffsetX, viewInfo.picOffsetY, viewInfo.picWidth, viewInfo.picHeight);
    [fgView setFrame:picFrame];
    [cardView addSubview:fgView];
    
    //draw cardbg
    UIImage* bgImage=nil;
    switch (bgType) {
        case CARD_TYPE_CATEGORY:
            bgImage =[UIImage imageNamed:@"common_cat_bg.png"];
            break;
            
        case CARD_TYPE_CARD:
            bgImage =[UIImage imageNamed:@"common_card_bg.png"];
            break;
            
        default:
            break;
    }
    UIImageView* bgView=[[UIImageView alloc] initWithImage:bgImage];
    [bgView setFrame:CGRectMake(0, 0, viewInfo.cardWidth, viewInfo.cardHeight)];
    [cardView addSubview:bgView];
    
    //draw cardwood
    UIImageView* cardWoodBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_wood.png"]];
    [cardWoodBg setFrame:localFrame];
    [cardView addSubview:cardWoodBg];
    
    return button;
}

-(void)addCardAtPosIndex:(int)pos onPage:(int)pageIndex cardID:(NSString*)cardID index:(int)index
{
    HAMCard* card=[config card:cardID];
    NSString* imagePath=[[card image] localPath];
    
    if ([card type]==1)
        [self addButtonAtPosIndex:index onPage:pageIndex picName:imagePath action:@selector(leafClicked:) tag:index bgType:1];
    else
        [self addButtonAtPosIndex:index onPage:pageIndex picName:imagePath action:@selector(groupClicked:) tag:index bgType:0];
    
    [self addLabelAtPosIndex:index onPage:pageIndex text:[card name] color:[UIColor colorWithRed:100.0/255.0 green:60.0/255.0 blue:20.0/255.0 alpha:1] type:card.type tag:index];
}

-(void)addLabelAtPosIndex:(int)index onPage:(int)pageIndex text:(NSString*)text color:(UIColor*)color type:(int)cardType tag:(int)tag
{
    if (pageIndex > pageViews_.count) {
        return;
    }
    UIView* pageView = [pageViews_ objectAtIndex:pageIndex];
    
    double posY;
    switch (cardType) {
        case CARD_TYPE_CARD:
            posY = viewInfo.cardLableY;
            break;
            
        case CARD_TYPE_CATEGORY:
            posY = viewInfo.catLableY;
            break;
            
        default:
            posY = 0;
            break;
    }
  
    UILabel* labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, posY, viewInfo.cardWidth, viewInfo.fontSize)];
    labelView.text = text;
    labelView.textColor = color;
    labelView.font = [UIFont boldSystemFontOfSize:viewInfo.fontSize];
    labelView.textAlignment = NSTextAlignmentCenter;
    labelView.userInteractionEnabled = NO;
    
    if (tag >=0 && [cardViewArray_ count] > tag)
        [[cardViewArray_ objectAtIndex:tag] addSubview:labelView];
    else
    {
        [pageView addSubview:labelView];
    }
}

@end
