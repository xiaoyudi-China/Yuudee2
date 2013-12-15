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
    if(!(self=[super init]))
        return nil;
    
    dbManager=[HAMDBManager new];
    if (![dbManager isDatabaseExist])
        return nil;
    
    userManager=[HAMUserManager new];
    userManager.config=self;
    rootID=[userManager currentUser].rootID;
    
    cards=[NSMutableDictionary dictionary];
    cardTree=[NSMutableDictionary dictionary];
    
    //[self setAllDirty];
    
    return self;
}

#pragma mark -
#pragma mark DirtyFlag Methods

-(void)clear
{
    rootID=[userManager setCurrentUser:nil].rootID;
    //[self setAllDirty];
    cardTree=[NSMutableDictionary dictionary];
    cards=[NSMutableDictionary dictionary];
}

/*-(void) setAllDirty
{
    for(int i=0;i<FLAGNUM;i++)
        dirtyFlag[i]=1;
}

-(void)setDirtyWithType:(int)type
{
    dirtyFlag[0]=1;
    if (type==0)
        dirtyFlag[2]=1;
    else
        dirtyFlag[1]=1;
}*/

#pragma mark -
#pragma mark Card

-(HAMCard*)card:(NSString*)UUID
{
    HAMCard* card=[cards objectForKey:UUID];
    if (card)
        return card;
    
    card=[dbManager card:UUID];
    [cards setObject:card forKey:UUID];
    return card;
}

-(void)updateCard:(HAMCard*)card name:(NSString*)name audio:(NSString*)audio image:(NSString*)image
{
	// the equivalence check should be done by the caller, not here
    //if (![name isEqualToString:card.name])
    {
        card.name=name;
        [dbManager updateCard:card.UUID name:name];
        //[self setDirtyWithType:card.type];
    }
    
    if (audio)
    {
        card.audio=[[HAMResource alloc] initWithPath:audio];
        [dbManager insertResourceWithID:card.audio.UUID path:card.audio.localPath];
        [dbManager updateCard:card.UUID audio:card.audio.UUID];
    }
    
    if (image)
    {
        card.image=[[HAMResource alloc] initWithPath:image];
        [dbManager insertResourceWithID:card.image.UUID path:card.image.localPath];
        [dbManager updateCard:card.UUID image:card.image.UUID];
    }
    
    [cards removeObjectForKey:card.UUID];
}

-(void)newCardWithID:(NSString*)UUID name:(NSString*)name type:(int)type audio:(NSString*)audio image:(NSString*)image
{
    HAMCard* card = [HAMCard alloc];
    card.UUID = UUID;
    card.name = name;
    card.type = type;
    card.isRemovable_ = YES;
    
    if (audio)
    {
        [dbManager deleteResourceWithID:card.audio.UUID];
        card.audio = [[HAMResource alloc] initWithPath:audio];
        [dbManager insertResourceWithID:card.audio.UUID path:card.audio.localPath];
    }
    
    if (image)
    {
        [dbManager deleteResourceWithID:card.image.UUID];
        card.image = [[HAMResource alloc] initWithPath:image];
        [dbManager insertResourceWithID:card.image.UUID path:card.image.localPath];
    }
    
    [dbManager insertCard:card user:[userManager currentUser].UUID];
    
    [cards setObject:card forKey:card.UUID];
}

-(void)deleteCard:(NSString*)UUID
{
    HAMCard* card=[self card:UUID];
    
    [dbManager deleteResourceWithID:card.audio.UUID];
    [dbManager deleteResourceWithID:card.image.UUID];
    [dbManager deleteCardFromTree:card.UUID];
    [dbManager deleteCardWithID:card.UUID];
    
    cardTree=[NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark Card_tree

-(NSString*)childCardIDOfCat:(NSString*)parentID atIndex:(int)index
{
    HAMRoom* room = [self roomOfCat:parentID atIndex:index];
    
    if (!room)
        return nil;
    return room.cardID_;
}

-(int)animationOfCat:(NSString*)parentID atIndex:(int)index
{
    HAMRoom* room = [self roomOfCat:parentID atIndex:index];
    
    if (!room)
        return -1;
    return room.animation_;
}

-(HAMRoom*)roomOfCat:(NSString*)parentID atIndex:(int)index{
    NSMutableArray* children = [self childrenOfCat:parentID];
    
    if ([children count] <= index)
        return nil;
    
    NSObject* room = [children objectAtIndex:index];
    if (room == [NSNull null])
        return nil;
    
    return (HAMRoom*)room;
}

//returns the children room array of parentID
-(NSMutableArray*)childrenOfCat:(NSString*)parentID
{
    NSMutableArray* children = [cardTree objectForKey:parentID];
    if (!children)
    {
        children = [dbManager childrenOf:parentID];
        [cardTree setObject:children forKey:parentID];
    }
    return children;
}

-(NSMutableArray*)childrenCardIDOfCat:(NSString*)parentID
{
    NSArray* children = [self childrenOfCat:parentID];
    
    NSMutableArray* cardIDArray = [NSMutableArray arrayWithCapacity: children.count];
    for (int i = 0; i < children.count; i++) {
        NSObject* room = [children objectAtIndex:i];
        if (room != [NSNull null]) {
            [HAMTools setObject:((HAMRoom*)room).cardID_ toMutableArray:cardIDArray atIndex:i];
        }
    }
    
    return cardIDArray;
}

/*-(void) parseJSONDictionary:(NSDictionary*)dictionary
{
    NSDictionary* nodeInfo;
    NSString* type;
    id node;
    nodes=[NSMutableArray arrayWithCapacity:100];
    
    int i;
    for(i=0;(nodeInfo=[dictionary objectForKey:[[NSString alloc]initWithFormat:@"n%d",i]]);i++)
    {
        
        
        if (!nodeInfo)
        {
            [nodes addObject:[NSNull null]];
            continue;
        }
        
        type=[nodeInfo objectForKey:@"type"];
        if ([type isEqualToString:@"group"])
        {
            node=[HAMGroup new];
            [node setChildren:[nodeInfo objectForKey:@"children"]];
        }
        else
        {
            
            node=[HAMLeaf new];
            [node setSoundName:[nodeInfo objectForKey:@"soundname"]];
        }
        [node setNodeID:i];
        [node setShowText:[nodeInfo objectForKey:@"text"]];
        [node setPicName:[nodeInfo objectForKey:@"picname"]];
        
        [nodes addObject:node];
    }
}*/

-(void)updateRoomOfCat:(NSString*)parentID with:(HAMRoom*)newRoom atIndex:(int)index
{
    if ((NSObject*)newRoom == [NSNull null])
        newRoom = nil;
    
    HAMRoom* oldRoom = [self roomOfCat:parentID atIndex:index];
    
    if ((oldRoom == nil && newRoom == nil) || [oldRoom isEqualToRoom:newRoom])
        return;
    
    NSMutableArray* children=[self childrenOfCat:parentID];
    if (!newRoom || !newRoom.cardID_)
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

-(void)updateAnimationOfCat:(NSString*)parentID with:(int)animation atIndex:(int)index
{
    NSMutableArray* children = [self childrenOfCat:parentID];
    if (children.count <= index)
        return;
    
    HAMRoom* room = [children objectAtIndex:index];
    room.animation_ = animation;
    [dbManager updateAnimationOfCat:parentID toAnimation:animation atIndex:index];
}

-(void)insertChildren:(NSArray*)newChildren intoCat:(NSString*)parentID atIndex:(int)beginIndex
{
    NSMutableArray* children = [[self childrenOfCat:parentID] mutableCopy];
    
    //i - index of children; j - index of newChildren
    int i,j;
    Boolean conflictFlag = NO;
    for (i = beginIndex, j = 0; i < children.count && j < newChildren.count; i++, j++) {
        HAMRoom* newRoom = [newChildren objectAtIndex:j];
        if ([children objectAtIndex:i] == [NSNull null])
            [children setObject:newRoom atIndexedSubscript:i];
        else
        {
            conflictFlag = YES;
            [children insertObject:newRoom atIndex:i];
        }
    }
    for (; j < newChildren.count; i++, j++) {
        HAMRoom* newRoom = [newChildren objectAtIndex:j];
        [HAMTools setObject:newRoom toMutableArray:children atIndex:i];
    }
    
    int endIndex = conflictFlag ? children.count - 1 : beginIndex + newChildren.count - 1;
    for (i = beginIndex; i <= endIndex; i++)
    {
        [self updateRoomOfCat:parentID with:[children objectAtIndex:i] atIndex:i];
    }
}

/*-(void)moveChildOfCat:(NSString*)parentID fromIndex:(int)oldIndex toIndex:(int)newIndex
{
    NSMutableArray* children = [self childrenOf:parentID];
    if (oldIndex >= [children count])
        return;

    NSString* childID = [children objectAtIndex:oldIndex];
    [dbManager updateChild:childID ofCat:parentID toIndex:newIndex];
    [HAMTools setObject:[NSNull null] toMutableArray:children atIndex:oldIndex];
    [HAMTools setObject:childID toMutableArray:children atIndex:newIndex];
}*/

/*-(void)insertChild:(NSString*)childID toNode:(NSString*)parentID
{
    NSMutableArray* children=[self childrenCardIDOf:parentID];
    int pos;
    //get pos to insert
    //for (pos=0;[dbManager ifCat:parentID hasChildAt:pos];pos++);
    for (pos=0;pos<[children count]&&[children objectAtIndex:pos]!=[NSNull null];pos++);
    [dbManager updateChildOfCat:parentID with:childID atIndex:pos];
    [HAMTools setObject:childID toMutableArray:children atIndex:pos];
}*/


//delete card from lib. will not move following cards forward
-(void)deleteCardInLib:(NSString*)cardID
{
    HAMCard* card = [self card:cardID];
    
    if (card.type == CARD_TYPE_CATEGORY) {
        NSArray* children = [self childrenCardIDOfCat:cardID];
        int i;
        for (i = 0; i < children.count; i++) {
            NSObject* childID = [children objectAtIndex:i];
            if (childID != [NSNull null]) {
                [self deleteCardInLib:cardID];
            }
        }
    }

    [self deleteCard:cardID];
}

//delete card from lib. will move following cards forward
-(void)deleteChildOfCatInLib:(NSString*)parentID atIndex:(int)index
{
    if (!parentID) {
        return;
    }
    
    NSMutableArray* children = [self childrenCardIDOfCat:parentID];
    int childrenCount = children.count;
    if (index >= childrenCount) {
        return;
    }
    
    NSString* childID = [children objectAtIndex:index];
    [self deleteCardInLib:childID];
    
    //move following cards forward
    int i;
    for (i = index + 1; i < childrenCount; i++) {
        HAMRoom* room = [self roomOfCat:parentID atIndex:i];
        [self updateRoomOfCat:parentID with:room atIndex:i - 1];
    }
    
    //if not last, delete last
    if (index + 1 < childrenCount)
        [self updateRoomOfCat:parentID with:nil atIndex:childrenCount - 1];
}

@end