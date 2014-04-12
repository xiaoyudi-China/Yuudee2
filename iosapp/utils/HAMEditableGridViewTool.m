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
    NSLog(@"refreshView - Enter refreshView: %f",[NSDate timeIntervalSinceReferenceDate]);
    [self prepareRefreshView:nodeUUID scrollToFirstPage:showFirstPage];
    NSLog(@"refreshView - After prepareRefreshView:%f",[NSDate timeIntervalSinceReferenceDate]);
//    cardViewArray_ = [NSMutableArray array];
    editButtonArray_ = [NSMutableArray array];
    
    int childIndex=0,posIndex,pageIndex;
    HAMCard* card = [config card:nodeUUID];
    //Boolean isRoot = [card.UUID isEqualToString:config.rootID];
    int btnsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    
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
            NSString* childID=[config childCardIDOfCat:card.cardID atIndex:childIndex];
            
            if(!childID || (NSNull*)childID==[NSNull null])
            {
                isBlankAtTag_[childIndex] = YES;
                //isBlankAtIndex_[posIndex + pageIndex * btnsPerPage] = YES;
                [self addBlankButtonAtPos:posIndex onPage:pageIndex index:childIndex];
                continue;
            }
            
//            isBlankAtIndex_[posIndex + pageIndex * btnsPerPage] = NO;
            isBlankAtTag_[childIndex] = NO;
            [self addCardAtPosIndex:posIndex onPage:pageIndex cardID:childID index:childIndex];
            [self addEditButtonAtPos:posIndex onPage:pageIndex tag:childIndex];
        }
    }
    
    NSLog(@"refreshView - After drawing buttons:%f",[NSDate timeIntervalSinceReferenceDate]);
    
    onEdgeCounter_ = 0;
}

- (UIButton*)addCardViewOfCard:(HAMCard *)card atPosIndex:(int)index onPage:(int)pageIndex tag:(int)tag
{
//    int btnsPerPage = viewInfo.xnum * viewInfo.ynum;
//    int index = i * j + btnsPerPage * pageIndex;
    
    UIButton* button = [super addCardViewOfCard:card atPosIndex:index onPage:pageIndex tag:tag];
    if (tag == -1)
        return button;
    
//    [HAMTools setObject:button toMutableArray:cardViewArray_ atIndex:tag];
    
    UIView* cardView = self.cardViewArray[tag];
    positionArray_[tag] = cardView.center;
    tagOfIndex_[tag] = tag;
    
    if (isBlankAtTag_[tag]) {
        return button;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [button addGestureRecognizer:panGestureRecognizer];
    return nil;
}

- (void)addBlankButtonAtPos:(int)pos onPage:(int)pageIndex index:(int)index
{
    //add card view
    UIView* pageView = pageViews_[pageIndex];
    CGPoint cardPosition = [viewInfo cardPositionAtIndex:index];
//    CGPoint blankBtnOffset = viewInfo.blankBtnOffset;
//    CGRect frame = CGRectMake(cardPosition.x + blankBtnOffset.x, cardPosition.y + blankBtnOffset.y, viewInfo.blankBtnWidth, viewInfo.blankBtnHeight);
    CGRect frame = CGRectMake(cardPosition.x, cardPosition.y, viewInfo.cardWidth, viewInfo.cardHeight);
    
    UIButton* blankButton = [[UIButton alloc] initWithFrame:frame];
    UIImage* bgImage = [UIImage imageNamed:@"parent_main_blankcard.png"];
    [blankButton setImage:bgImage forState:UIControlStateNormal];
    
    blankButton.tag = index;
    [blankButton addTarget:viewController_ action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [pageView addSubview:blankButton];
    [HAMTools setObject:blankButton toMutableArray:self.cardViewArray atIndex:index];
    
    tagOfIndex_[index] = index;
    positionArray_[index] = blankButton.center;
}

- (void)addEditButtonAtPos:(int)pos onPage:(int)pageIndex tag:(int)tag
{
    CGPoint position = [viewInfo cardPositionAtIndex:pos];
    CGPoint editBtnOffset = viewInfo.editBtnOffset;
    
    position.x += editBtnOffset.x;
    position.y += editBtnOffset.y;
    
    CGRect frame = CGRectMake(position.x, position.y, viewInfo.editBtnWidth, viewInfo.editBtnHeight);
    UIButton* editButton = [[UIButton alloc] initWithFrame:frame];
    
    UIImage *bgImageNom = [UIImage imageNamed:@"parent_main_editbtn.png"];
    UIImage *bgImageHighlight = [UIImage imageNamed:@"parent_main_editbtn_down.png"];
    [editButton setImage:bgImageNom forState:UIControlStateNormal];//正常状态
    [editButton setImage:bgImageHighlight forState:UIControlStateHighlighted];//点击高亮状态
    
    editButton.tag = tag;
    [editButton addTarget:viewController_ action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    /*
    CALayer * downButtonLayer = [editButton layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:20.0];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];*/
    
    UIView* pageView = pageViews_[pageIndex];
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

-(void)moveCardView:(UIView*)targetView toIndex:(NSInteger)index animated:(Boolean)animated{
    int cardsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    NSInteger onPagenum = index / cardsPerPage;
    UIView* superView = pageViews_[onPagenum];
    
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
    UIView* pageView = pageViews_[pagenum];
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
    UIView* pageView = pageViews_[currentPage_];
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
    double minDist = MAXFLOAT;
    int nearestIndex = 0, i;
    int cardsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    
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
            [editButtonArray_[i] removeFromSuperview];
        }
        editButtonArray_ = nil;
    }
    
    UIView* buttonView = recognizer.view;
    NSInteger tag = buttonView.tag;
    
    UIView* cardView = self.cardViewArray[tag];
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
    NSInteger currentIndex = 0;
    NSInteger i, cardnum = self.cardViewArray.count;
    
    for (i = 0; i < cardnum; i++) {
        if (tagOfIndex_[i] == tag){
            currentIndex = i;
            break;
        }
    }
    
    //find nearest
    int cardsPerPage = viewInfo.xnum_ * viewInfo.ynum_;
    int nearestIndex = [self findNearestIndexOfPosition:newPosition] + cardsPerPage * currentPage_;
    
    //move other cards
    NSInteger newTagOfIndex[EDITVIEW_MAX_CARD_NUM];
    for (i=0; i<cardnum; i++){
        newTagOfIndex[i] = tagOfIndex_[i];
    }
    newTagOfIndex[nearestIndex] = tag;
    
    
    //sequential move solution:
    int inc = currentIndex > nearestIndex ? 1 : -1;
    for (i = nearestIndex; i != currentIndex; i += inc) {
        NSInteger targetTag = tagOfIndex_[i];
        UIView* targetView = self.cardViewArray[targetTag];
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
    if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
        NSLog(@"handlePan - Recongnized finger up:%f",[NSDate timeIntervalSinceReferenceDate]);
//        [self moveCardView:cardView toPosition:positionArray_[nearestIndex] animated:YES];
        [self moveCardView:cardView toIndex:nearestIndex animated:YES];
        NSLog(@"handlePan - Moved card view:%f",[NSDate timeIntervalSinceReferenceDate]);
        NSMutableArray* children = [[config childrenOfCat:currentUUID_] copy];
        NSLog(@"handlePan - Got old children:%f",[NSDate timeIntervalSinceReferenceDate]);
        for (i=0; i<cardnum; i++) {
            NSInteger targetTag = tagOfIndex_[i];
            if (tagOfIndex_[i] == i)
                continue;
            NSObject* child;
            if (targetTag < [children count])
            {
                child = children[targetTag];
                if (child == [NSNull null]) {
                    child = nil;
                }
            }
            else{
                child = nil;
            }
            [config updateRoomOfCat:currentUUID_ with:(HAMRoom*)child atIndex:i];
        }
        NSLog(@"handlePan - Saved changes to database:%f",[NSDate timeIntervalSinceReferenceDate]);
        
        //swap is quicker, but refresh is safer
        [self refreshView:currentUUID_ scrollToFirstPage:NO];
        NSLog(@"handlePan - Refreshed view:%f",[NSDate timeIntervalSinceReferenceDate]);
        /*for (i=0; i<cardnum; i++) {
            tagOfIndex_[i] = i;
            isBlankAtTag_[i] = newIsBlankAtTag[i];
        }*/
        
    }
}

@end
