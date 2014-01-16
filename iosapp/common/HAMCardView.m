//
//  HAMCardView.m
//  iosapp
//
//  Created by Dai Yue on 13-12-26.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMCardView.h"

@implementation HAMCardView
{
    UIImageView* cardImageView_;
    HAMCard* card_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initAtPosition:(CGPoint)position withViewInfo:(HAMViewInfo*)viewInfo card:(HAMCard*)card{
    card_ = card;
    
    CGRect frame = CGRectMake(position.x, position.y, viewInfo.cardWidth, viewInfo.cardHeight);
    self = [self initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    /*
    //draw cardwhite
    CGRect localFrame = CGRectMake(0, 0, viewInfo.cardWidth, viewInfo.cardHeight);
    UIImageView* cardWhiteBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_white.png"]];
    [cardWhiteBg setFrame:localFrame];
    [self addSubview:cardWhiteBg];
    
    //draw cardpic
    UIImage* fgImage=[[UIImage alloc]initWithContentsOfFile:[HAMFileTools filePath:card.image.localPath]];
    cardImageView_ = [[UIImageView alloc] initWithImage:fgImage];
    CGRect picFrame = CGRectMake(viewInfo.picOffsetX, viewInfo.picOffsetY, viewInfo.picWidth, viewInfo.picHeight);
    [cardImageView_ setFrame:picFrame];
    [self addSubview:cardImageView_];
    
    //draw cardbg
    UIImage* bgImage=nil;
    switch (card.type) {
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
    [self addSubview:bgView];
    
    //draw cardwood
    UIImageView* cardWoodBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_wood.png"]];
    [cardWoodBg setFrame:localFrame];
    [self addSubview:cardWoodBg];*/
    
    //draw cardwhite
    CGRect localFrame = CGRectMake(0, 0, viewInfo.cardWidth, viewInfo.cardHeight);
    UIImageView* cardWhiteBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_white.png"]];
    [cardWhiteBg setFrame:localFrame];
    [self addSubview:cardWhiteBg];
    
    //draw cardpic
	UIImage* fgImage = nil;
    NSString* picName = card_.image.UUID;
	if (picName) { // NOTE: picName may be 'nil'
		NSCache *imageCache = ((HAMSharedData*)[HAMSharedData sharedData]).imageCache;
		NSString *path = [HAMFileTools filePath:picName];
        UIImage* value = [UIImage imageWithContentsOfFile:path];
		if (! [imageCache objectForKey:path] && value != nil)
			[imageCache setObject:value forKey:path];
		fgImage = [imageCache objectForKey:path];
	}
    
	cardImageView_ = [[UIImageView alloc] initWithImage:fgImage];
    CGRect picFrame=CGRectMake(viewInfo.picOffsetX, viewInfo.picOffsetY, viewInfo.picWidth, viewInfo.picHeight);
    [cardImageView_ setFrame:picFrame];
    [self addSubview:cardImageView_];
    
    //draw cardbg
    UIImage* bgImage=nil;
    switch (card.type) {
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
    [self addSubview:bgView];
    
    //draw cardwood
    UIImageView* cardWoodBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_card_wood.png"]];
    [cardWoodBg setFrame:localFrame];
    [self addSubview:cardWoodBg];
    
    return self;
}

- (void)changeCardImagePathToPath:(NSString*)newImagePath{
    UIImage* cardImage=[[UIImage alloc]initWithContentsOfFile:[HAMFileTools filePath:newImagePath]];
    [cardImageView_ setImage:cardImage];
}

#pragma mark -
#pragma mark Gif Delegate

- (void)changeGifImageToPicNum:(int)picNum{
    NSString* picName = card_.image.UUID;
    NSString* targetPic = [picName substringToIndex:[picName rangeOfString:@"p"].location];
    targetPic = [NSString stringWithFormat:@"%@p%d.jpg",targetPic,picNum];
    [self changeCardImagePathToPath:targetPic];
}

- (void)endGif{
    [self changeGifImageToPicNum:1];
}

@end
