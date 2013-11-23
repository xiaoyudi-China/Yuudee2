//
//  HAMDragableViewTool.m
//  iosapp
//
//  Created by Dai Yue on 13-10-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMEditableGridViewTool.h"

@implementation HAMEditableGridViewTool
{
    int onEdgeCounter_;
    int onEdgeSide_;
    NSTimer* onEdgeTimer_;
    UIView* onEdgeView_;
}

#pragma mark -
#pragma mark View

-(void)prepareRefreshView:(NSString *)nodeUUID scrollToFirstPage:(Boolean)showFirstPage
{
    [super prepareRefreshView:nodeUUID scrollToFirstPage:showFirstPage];
    
    //add extra page
    totalPageNum_++;
    CGSize scrollFrameSize = scrollView_.frame.size;
    CGSize contentSize = CGSizeMake(scrollFrameSize.width * totalPageNum_, scrollFrameSize.height);
    scrollView_.contentSize = contentSize;
    
    
    CGRect newPageFrame = CGRectMake((totalPageNum_ - 1) * scrollFrameSize.width, 0, scrollFrameSize.width, scrollFrameSize.height);
    UIView* pageView = [[UIView alloc] initWithFrame:newPageFrame];
    [scrollView_ addSubview:pageView];
    [pageViews_ addObject:pageView];
}

-(void)refreshView:(NSString*)nodeUUID scrollToFirstPage:(Boolean)showFirstPage{
    [self prepareRefreshView:nodeUUID scrollToFirstPage:showFirstPage];
    
//    cardViewArray_ = [NSMutableArray array];
    editButtonArray_ = [NSMutableArray array];
    
    int childIndex=0,posIndex,pageIndex;
    HAMCard* card = [config card:nodeUUID];
    //Boolean isRoot = [card.UUID isEqualToString:config.rootID];
    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
    
    for (pageIndex = 0; pageIndex < totalPageNum_; pageIndex++) {
        posIndex = 0;
        //add home btn
        /*if (!isRoot)
        {
            [self addButtonWithi:0 j:0 onPage:pageIndex picName:@"back.png" action:@selector(groupClicked:) tag:-1 bgType:-1];
            [self addLabelWithi:0 j:0 onPage:pageIndex text:@"返回" color:[UIColor blackColor] tag:-1];
            posIndex=1;
        }*/
        //add else btn
        
        for(; posIndex < btnsPerPage; childIndex++,posIndex++)
        {
            NSString* childID=[config childCardIDOfCat:card.UUID atIndex:childIndex];
            
            if(!childID || (NSNull*)childID==[NSNull null])
            {
                isBlankAtTag_[childIndex] = YES;
                //isBlankAtIndex_[posIndex + pageIndex * btnsPerPage] = YES;
                [self addAddNodeAtPos:posIndex onPage:pageIndex index:childIndex];
                continue;
            }
            
//            isBlankAtIndex_[posIndex + pageIndex * btnsPerPage] = NO;
            isBlankAtTag_[childIndex] = NO;
            [self addCardAtPos:posIndex onPage:pageIndex cardID:childID index:childIndex];
            [self addEditButtonAtPos:posIndex onPage:pageIndex tag:childIndex];
        }
    }
    
    onEdgeCounter_ = 0;
}

- (UIButton*)addButtonWithi:(int)i j:(int)j onPage:(int)pageIndex picName:(NSString*)picName action:(SEL)action tag:(int)tag bgType:(int)bgType
{
//    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
//    int index = i * j + btnsPerPage * pageIndex;
    
    UIButton* button = [super addButtonWithi:i j:j onPage:pageIndex picName:picName action:action tag:tag bgType:bgType];
    //don't add return button
    if (tag == -1)
        return button;
    
//    [HAMTools setObject:button toMutableArray:cardViewArray_ atIndex:tag];
    
    UIView* cardView = [cardViewArray_ objectAtIndex:tag];
    positionArray_[tag] = cardView.center;
    tagOfIndex_[tag] = tag;
//    indexOfTag_[tag] = index;
    
    if (isBlankAtTag_[tag]) {
        return button;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [button addGestureRecognizer:panGestureRecognizer];
    return nil;
}

- (void)addAddNodeAtPos:(int)pos onPage:(int)pageIndex index:(int)index
{
    int xid=pos/viewInfo.xnum;
    int yid=pos%viewInfo.xnum;
    
    [self addButtonWithi:xid j:yid onPage:pageIndex picName:@"add.png" action:@selector(addClicked:) tag:index bgType:-1];
    [self addLabelWithi:xid j:yid onPage:pageIndex text:@"新增词条/分组" color:[UIColor blackColor] tag:index];
}

- (void)addEditButtonAtPos:(int)pos onPage:(int)pageIndex tag:(int)tag
{
    UIView* pageView = [pageViews_ objectAtIndex:pageIndex];
    
    UIButton* editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGPoint position = [viewInfo positionAtPosIndex:pos];
    double length = viewInfo.a * 0.25;
    position.x += viewInfo.a - length;
    editButton.frame = CGRectMake(position.x, position.y, length, length);
    editButton.backgroundColor = [UIColor whiteColor];
    editButton.tag = tag;
    [editButton addTarget:viewController_ action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer * downButtonLayer = [editButton layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:20.0];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
    
    [pageView addSubview:editButton];
    [editButtonArray_ addObject:editButton];
}

#pragma mark -
#pragma mark Page Actions

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(scrollView_.frame);
    currentPage_ = floor((scrollView_.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}


-(void)moveCardView:(UIView*)targetView toPosition:(CGPoint)position animated:(Boolean)animated{
    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    }
    
    targetView.center = position;
    
    if (!animated) {
        [CATransaction commit];
    }
}

-(void)moveCardView:(UIView*)targetView toIndex:(int)index animated:(Boolean)animated{
    int cardsPerPage = viewInfo.xnum * viewInfo.ynum;
    int onPagenum = index / cardsPerPage;
    UIView* superView = [pageViews_ objectAtIndex:onPagenum];
    
    if (targetView.superview != superView) {
        [targetView removeFromSuperview];
        [superView addSubview:targetView];
    }
    
    [self moveCardView:targetView toPosition:positionArray_[index] animated:animated];
}

- (void)moveCardView:(UIView*)cardView toPage:(int)pagenum
{
    CGRect cardFrame = cardView.frame;
    //[cardView removeFromSuperview];
    UIView* pageView = [pageViews_ objectAtIndex:pagenum];
    [pageView addSubview:cardView];
    cardView.frame = cardFrame;
}

- (void)gotoPage:(int)pagenum{
    if (pagenum < 0 || pagenum >= totalPageNum_) {
        return;
    }
    
    currentPage_ = pagenum;
    
    CGRect bounds = scrollView_.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * currentPage_;
    bounds.origin.y = 0;
    [scrollView_ scrollRectToVisible:bounds animated:YES];
}

-(int)judgeOutsidePageAtView:(UIView*)cardView{
    CGRect cardFrame = cardView.frame;
    UIView* pageView = [pageViews_ objectAtIndex:currentPage_];
    CGRect pageFrame = pageView.frame;
    
    if(cardFrame.origin.x < 0)
        return -1;
    if (cardFrame.origin.x > pageFrame.size.width - cardFrame.size.width)
        return 1;
    return 0;
}

-(void)onEdge
{
    onEdgeCounter_++;
    NSLog(@"%d",onEdgeCounter_);
    int side = [self judgeOutsidePageAtView:onEdgeView_];
    if (side == 0 || onEdgeSide_ != side) {
        onEdgeCounter_ = 0;
        onEdgeSide_ = 0;
        [onEdgeTimer_ invalidate];
    }
    
    if (onEdgeCounter_ > 10) {
        [self gotoPage:currentPage_ + onEdgeSide_];
        [self moveCardView:onEdgeView_ toPage:currentPage_];
        onEdgeCounter_ = 0;
    }
}

-(int)findNearestIndexOfPosition:(CGPoint)newPosition
{
    /*double minDist = MAXFLOAT;
    int nearestIndex, i;
    int cardsPerPage = viewInfo.xnum * viewInfo.ynum;
    int endIndex = MIN([cardViewArray_ count], cardsPerPage*(pagenum+1));
    
    for (i = pagenum * cardsPerPage; i < endIndex ; i++) {
        CGPoint position = positionArray_[i];
        double dist = (newPosition.x - position.x) * (newPosition.x - position.x) + (newPosition.y - position.y) * (newPosition.y - position.y);
        if (minDist > dist){
            minDist = dist;
            nearestIndex = i;
        }
    }
    return nearestIndex;*/
    
    double minDist = MAXFLOAT;
    int nearestIndex, i;
    int cardsPerPage = viewInfo.xnum * viewInfo.ynum;
    
    //search only in the 1st page for every page has the same layout
    for (i = 0; i < cardsPerPage ; i++) {
        CGPoint position = positionArray_[i];
        double dist = (newPosition.x - position.x) * (newPosition.x - position.x) + (newPosition.y - position.y) * (newPosition.y - position.y);
        if (minDist > dist){
            minDist = dist;
            nearestIndex = i;
        }
    }
    return nearestIndex;
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    if (editButtonArray_){
        for (int i = 0; i<[editButtonArray_ count]; i++) {
            [[editButtonArray_ objectAtIndex:i] removeFromSuperview];
        }
        editButtonArray_ = nil;
    }
    
    UIView* buttonView = recognizer.view;
    int tag = buttonView.tag;
    
    UIView* cardView = [cardViewArray_ objectAtIndex:tag];
    [cardView.superview bringSubviewToFront:cardView];
    
    //judge if outside
    if (onEdgeSide_ == 0) {
        int side;
        if ((side = [self judgeOutsidePageAtView:cardView]) != 0) {
            onEdgeSide_ = side;
            onEdgeView_ = cardView;
            onEdgeTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onEdge) userInfo:nil repeats:YES];
            [onEdgeTimer_ fire];
        }
    }
    
    //move card
    CGPoint newPosition = cardView.center;
    CGPoint translation = [recognizer translationInView:viewController_.view];
    [recognizer setTranslation:CGPointZero inView:viewController_.view];
    newPosition.x += translation.x;
    newPosition.y += translation.y;
    //TODO: don't repeat this for efficiency
    /*CALayer* superLayer = [cardLayer superlayer];
    [cardLayer removeFromSuperlayer];
    [superLayer addSublayer:cardLayer];*/
    
    [self moveCardView:cardView toPosition:newPosition animated:NO];
        
    //get current index
    int currentIndex = 0;
    int i, cardnum = [cardViewArray_ count];
    
    for (i = 0; i < cardnum; i++) {
        if (tagOfIndex_[i] == tag){
            currentIndex = i;
            break;
        }
    }
    
    //find nearest
    int cardsPerPage = viewInfo.xnum * viewInfo.ynum;
    int nearestIndex = [self findNearestIndexOfPosition:newPosition] + cardsPerPage * currentPage_;
    
    //move other cards
    int newTagOfIndex[EDITVIEW_MAX_CARD_NUM];
    for (i=0; i<cardnum; i++){
        newTagOfIndex[i] = tagOfIndex_[i];
    }
    newTagOfIndex[nearestIndex] = tag;
    
    
    //sequential move solution:
    int inc = currentIndex > nearestIndex ? 1 : -1;
    for (i = nearestIndex; i != currentIndex; i += inc) {
        int targetTag = tagOfIndex_[i];
        UIView* targetView = [cardViewArray_ objectAtIndex:targetTag];
        if (isBlankAtTag_[targetTag]){
            //[self moveCardView:targetView toPosition:positionArray_[currentIndex] animated:NO];
            [self moveCardView:targetView toIndex:currentIndex animated:NO];
            newTagOfIndex[currentIndex] = targetTag;
            break;
        }
        else{
            //[self moveCardView:targetView toPosition:positionArray_[i+inc] animated:YES];
            [self moveCardView:targetView toIndex:i+inc animated:YES];
            newTagOfIndex[i+inc] = targetTag;
        }
    }
    //swap solution:
    
    /*if (nearestIndex != currentIndex)
    {
        int targetTag = tagOfIndex_[nearestIndex];
        UIView* targetView = [cardViewArray_ objectAtIndex:targetTag];
        CALayer* targetLayer = [layerArray objectAtIndex:targetTag];
        [self moveView:targetView andLayer:targetLayer toPosition:positionArray_[currentIndex] animated:YES];
        newTagOfIndex[currentIndex] = targetTag;
    }*/
    
    for (i=0; i<cardnum; i++) {
        tagOfIndex_[i] = newTagOfIndex[i];
    }
    
    //finger up
    //TODO: may need to move this part to the begining of this function. depend on the circumstances of last calling of handlePan
    if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
//        [self moveCardView:cardView toPosition:positionArray_[nearestIndex] animated:YES];
        [self moveCardView:cardView toIndex:nearestIndex animated:YES];
        NSMutableArray* children = [[config childrenOfCat:currentUUID_] copy];
        for (i=0; i<cardnum; i++) {
            int targetTag = tagOfIndex_[i];
            if (tagOfIndex_[i] == i)
                continue;
            NSObject* child;
            if (targetTag < [children count])
            {
                child = [children objectAtIndex:targetTag];
                if (child == [NSNull null]) {
                    child = nil;
                }
            }
            else{
                child = nil;
            }
            [config updateRoomOfCat:currentUUID_ with:(HAMRoom*)child atIndex:i];
        }
        
        //swap is quicker, but refresh is safer
        [self refreshView:currentUUID_ scrollToFirstPage:NO];
        /*for (i=0; i<cardnum; i++) {
            tagOfIndex_[i] = i;
            isBlankAtTag_[i] = newIsBlankAtTag[i];
        }*/
        
    }
}

@end
