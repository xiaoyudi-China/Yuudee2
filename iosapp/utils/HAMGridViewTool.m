//
//  HAMGridViewTool.m
//  iosapp
//
//  Created by daiyue on 13-7-24.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMGridViewTool.h"

@implementation HAMGridViewTool

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
    
    self.cardViewArray = [NSMutableArray array];
    
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

- (UIButton*)addCardViewOfCard:(HAMCard*)card atPosIndex:(int)index onPage:(int)pageIndex tag:(int)tag
{
    if (pageIndex > pageViews_.count) {
        return nil;
    }
    
    //add card view
    UIView* pageView = pageViews_[pageIndex];
    CGPoint cardPosition = [viewInfo cardPositionAtIndex:index];
    
    
    UIView* cardView = [[HAMCardView alloc] initAtPosition:cardPosition withViewInfo:viewInfo card:card];
    [pageView addSubview:cardView];
    if (tag!=-1)
        [HAMTools setObject:cardView toMutableArray:self.cardViewArray atIndex:tag];
    
    //add button area
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //a tested value. to hide the button.
    double offset=7;
    button.frame = CGRectMake(offset, offset, viewInfo.cardWidth - 2 * offset, viewInfo.cardHeight - 2 * offset);
//    button.backgroundColor = [UIColor redColor];
    button.tag = tag;
    SEL action;
	if (card.type == CARD_TYPE_CARD)
		action = @selector(leafClicked:);
	else // card.type == CARD_TYPE_CATEGORY
		action = @selector(groupClicked:);

    [button addTarget:viewController_ action:action forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:20.0];
    [buttonLayer setBorderWidth:0.0];
    //[downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];*/
    
    [cardView addSubview:button];
    
    return button;
}

-(void)addCardAtPosIndex:(int)pos onPage:(int)pageIndex cardID:(NSString*)cardID index:(int)index
{
    HAMCard* card=[config card:cardID];
    
    [self addCardViewOfCard:card atPosIndex:index onPage:pageIndex tag:index];
    
    [self addLabelAtPosIndex:index onPage:pageIndex text:[card name] color:[UIColor colorWithRed:100.0/255.0 green:60.0/255.0 blue:20.0/255.0 alpha:1] type:card.type tag:index];
}

-(void)addLabelAtPosIndex:(int)index onPage:(int)pageIndex text:(NSString*)text color:(UIColor*)color type:(int)cardType tag:(int)tag
{
    if (pageIndex > pageViews_.count) {
        return;
    }
    UIView* pageView = pageViews_[pageIndex];
    
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
    
    if (tag >=0 && [self.cardViewArray count] > tag)
        [self.cardViewArray[tag] addSubview:labelView];
    else
    {
        [pageView addSubview:labelView];
    }
}

@end
