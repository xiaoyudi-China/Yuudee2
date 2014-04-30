//
//  HAMNodeInfoTool.m
//  iosapp
//
//  Created by daiyue on 13-7-25.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMConfig.h"

@implementation HAMConfig
@synthesize rootID;
@synthesize userManager;

#pragma mark -
#pragma mark Update Config & Nodes

-(id)initFromDB
{
    if(!(self = [super init]))
        return nil;
    
    dbManager=[HAMDBManager new];
    if (![dbManager isDatabaseExist])
        return nil;
    
    userManager=[HAMCoursewareManager new];
    userManager.config=self;
    rootID=[userManager currentCourseware].rootID;
    
    cards=[NSMutableDictionary dictionary];
    cardTree=[NSMutableDictionary dictionary];
    
    //[self setAllDirty];
    
    return self;
}

#pragma mark -
#pragma mark DirtyFlag Methods

-(void)clear
{
    rootID=[userManager setCurrentCourseware:nil].rootID;
    //[self setAllDirty];
    cardTree=[NSMutableDictionary dictionary];
    cards=[NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark Card

-(HAMCard*)card:(NSString*)UUID
{
	if (! UUID)
		return nil;
	
    HAMCard* card = cards[UUID];
    if (card)
        return card;
    
    card = [dbManager card:UUID];
    cards[UUID] = card;
    return card;
}

-(void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image
{
	// the equivalence check should be done by the caller, not here
    //if (![name isEqualToString:card.name])
    //TODO: update name every time. should fix this.
    {
        card.name=name;
        [dbManager updateCard:card.ID name:name];
    }
    
    if (audio)
    {
        card.audioPath = audio;
        [dbManager updateCard:card.ID audio:card.audioPath];
    }
    
    if (image)
    {
        card.imagePath = image;
        [dbManager updateCard:card.ID image:card.imagePath];
    }
    
    [cards removeObjectForKey:card.ID];
}

-(void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image
{
    HAMCard* card = [[HAMCard alloc] init];
    card.ID = UUID;
    card.name = name;
    card.type = type;
    card.numImages = 1;
    card.removable = YES;
    
    if (audio)
    {
        card.audioPath = audio;
    }
    
    if (image)
    {
        card.imagePath = image;
    }
    
    [dbManager insertCard:card];
    
    cards[card.ID] = card;
}

-(void)deleteCard:(NSString*)ID
{
    HAMCard* card = [self card:ID];
    
    [dbManager deleteCardFromTree:card.ID];
    [dbManager deleteCardWithID:card.ID];
    
    cardTree = [NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark CardTree

-(NSString*)childCardIDOfCat:(NSString*)parentID atIndex:(NSInteger)index
{
    HAMRoom* room = [self roomOfCat:parentID atIndex:index];
    
    if (!room)
        return nil;
    return room.cardID;
}

- (HAMAnimationType)animationOfCat:(NSString*)parentID atIndex:(NSInteger)index
{
    HAMRoom* room = [self roomOfCat:parentID atIndex:index];
    
    if (!room)
        return -1;
    return room.animation;
}

- (BOOL)muteStateOfCat:(NSString *)parentID atIndex:(NSInteger)index {
	HAMRoom *room = [self roomOfCat:parentID atIndex:index];
	return room.mute;
}

-(HAMRoom*)roomOfCat:(NSString*)parentID atIndex:(NSInteger)index{
    NSMutableArray* children = [self childrenOfCat:parentID];
    
    if ([children count] <= index)
        return nil;
    
    NSObject* room = children[index];
    if (room == [NSNull null])
        return nil;
    
    return (HAMRoom*)room;
}

//returns the children room array of parentID
-(NSMutableArray*)childrenOfCat:(NSString*)parentID
{
    NSMutableArray* children = cardTree[parentID];
    if (!children)
    {
        children = [dbManager childrenOf:parentID];
        cardTree[parentID] = children;
    }
    return children;
}

-(NSMutableArray*)childrenCardIDOfCat:(NSString*)parentID
{
    NSArray* children = [self childrenOfCat:parentID];
    
    NSMutableArray* cardIDArray = [NSMutableArray arrayWithCapacity: children.count];
    for (int i = 0; i < children.count; i++) {
        NSObject* room = children[i];
        if (room != [NSNull null]) {
            [HAMTools setObject:((HAMRoom*)room).cardID toMutableArray:cardIDArray atIndex:i];
        }
    }
    
    return cardIDArray;
}

-(void)updateRoomOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(NSInteger)index
{
    if ((NSObject*)newRoom == [NSNull null])
        newRoom = nil;
    
    HAMRoom* oldRoom = [self roomOfCat:parentID atIndex:index];
    
    if ((oldRoom == nil && newRoom == nil) || [oldRoom isEqualToRoom:newRoom])
        return;
    
    NSMutableArray* children=[self childrenOfCat:parentID];
    if (!newRoom || !newRoom.cardID)
    {
        [HAMTools setObject:[NSNull null] toMutableArray:children atIndex:index];
        [dbManager deleteChildOfCat:parentID atIndex:index];
    }
    else
    {
        [HAMTools setObject:newRoom toMutableArray:children atIndex:index];
        [dbManager updateChildOfCat:parentID with:newRoom atIndex:index];
    }
}

- (void)updateAnimationOfCat:(NSString *)parentID with:(HAMAnimationType)animation atIndex:(NSInteger)index
{
    NSMutableArray* children = [self childrenOfCat:parentID];
    if (children.count <= index)
        return;
    
    HAMRoom* room = children[index];
    room.animation = animation;
    [dbManager updateAnimationOfCat:parentID toAnimation:animation atIndex:index];
}

- (void)updateMuteStateOfCat:(NSString *)parentID with:(BOOL)muteState atIndex:(NSInteger)index {
	NSArray *children = [self childrenOfCat:parentID];
	if (children.count <= index)
		return;
	
	HAMRoom *room = children[index];
	room.mute = muteState;
	[dbManager updateMuteStateOfCat:parentID toMuteState:muteState atIndex:index];
}

-(void)insertChildren:(NSArray*)newChildren intoCat:(NSString*)parentID atIndex:(NSInteger)beginIndex
{
    NSMutableArray* children = [[self childrenOfCat:parentID] mutableCopy];
    
    //i - index of children; j - index of newChildren
    NSInteger i,j;
    Boolean conflictFlag = NO;
    for (i = beginIndex, j = 0; i < children.count && j < newChildren.count; i++, j++) {
        HAMRoom* newRoom = newChildren[j];
        if (children[i] == [NSNull null])
            [children setObject:newRoom atIndexedSubscript:i];
        else
        {
            conflictFlag = YES;
            [children insertObject:newRoom atIndex:i];
        }
    }
    for (; j < newChildren.count; i++, j++) {
        HAMRoom* newRoom = newChildren[j];
        [HAMTools setObject:newRoom toMutableArray:children atIndex:i];
    }
    
    NSInteger endIndex = conflictFlag ? children.count - 1 : beginIndex + newChildren.count - 1;
    for (i = beginIndex; i <= endIndex; i++)
    {
        [self updateRoomOfCat:parentID with:children[i] atIndex:i];
    }
}

//delete card from lib. will not move following cards forward
-(void)deleteCardInLib:(NSString*)cardID
{
    HAMCard* card = [self card:cardID];
    
    if (card.type == HAMCardTypeCategory) {
        NSArray* children = [self childrenCardIDOfCat:cardID];
        int i;
        for (i = 0; i < children.count; i++) {
            NSObject* childID = children[i];
            if (childID != [NSNull null]) {
                [self deleteCardInLib:cardID];
            }
        }
    }

    [self deleteCard:cardID];
}

//delete card from lib. will move following cards forward
-(void)deleteChildOfCatInLib:(NSString*)parentID atIndex:(NSInteger)index
{
    if (!parentID) {
        return;
    }
    
    NSMutableArray* children = [self childrenCardIDOfCat:parentID];
    NSInteger childrenCount = children.count;
    if (index >= childrenCount) {
        return;
    }
    
    NSString* childID = children[index];
    [self deleteCardInLib:childID];
    
    //move following cards forward
    NSInteger i;
    for (i = index + 1; i < childrenCount; i++) {
        HAMRoom* room = [self roomOfCat:parentID atIndex:i];
        [self updateRoomOfCat:parentID with:room atIndex:i - 1];
    }
    
    //if not last, delete last
    if (index + 1 < childrenCount)
        [self updateRoomOfCat:parentID with:nil atIndex:childrenCount - 1];
}

- (void)addChild:(NSString *)childID toParent:(NSString *)parentID {
	NSInteger numChildren = [self childrenOfCat:parentID].count;
	HAMRoom *room = [[HAMRoom alloc] initWithCardID:childID animation:HAMAnimationTypeScale muteState:NO];
	[self updateRoomOfCat:parentID with:room atIndex:numChildren];
}

- (void)removeChild:(NSString *)childID fromParent:(NSString *)parentID {
	NSInteger oldIndex = [[self childrenCardIDOfCat:parentID] indexOfObject:childID];
	NSInteger numOldCards = [self childrenOfCat:parentID].count;
	for (NSInteger index = oldIndex; index < numOldCards; index++) {
		HAMRoom *nextRoom = [self roomOfCat:parentID atIndex:index + 1]; // supposed to be nil when exceeding boundary
		[self updateRoomOfCat:parentID with:nextRoom atIndex:index];
	}
}

- (void)moveChild:(NSString *)childID fromParent:(NSString *)srcParentID toParent:(NSString *)dstParentID {
	[self removeChild:childID fromParent:srcParentID];
	[self addChild:childID toParent:dstParentID];
}

@end