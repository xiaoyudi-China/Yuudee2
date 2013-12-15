//
//  HAMDefaultResources.h
//  iosapp
//
//  Created by Dai Yue on 13-12-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#ifndef iosapp_HAMDefaultResources_h
#define iosapp_HAMDefaultResources_h

#define DEFAULT_RESOURCES_LIST [NSArray arrayWithObjects:@"cat1_p1.jpg",@"cat1_card1_p1.jpg",@"cat1_card1_s1.mp3",@"cat1_card2_p1.jpg",@"cat1_card2_s1.mp3",@"cat2_p1.jpg",@"cat2_card1_p1.jpg",@"cat2_card1_s1.mp3",@"cat2_card2_p1.jpg",@"cat2_card2_s1.mp3",@"cat2_card3_p1.jpg",@"cat2_card3_s1.mp3",@"cat2_card4_p1.jpg",@"cat2_card4_s1.mp3",@"cat2_card5_p1.jpg",@"cat2_card5_s1.mp3",@"cat2_card6_p1.jpg",@"cat2_card6_s1.mp3",@"cat2_card7_p1.jpg",@"cat2_card7_s1.mp3",@"cat2_card8_p1.jpg",@"cat2_card8_s1.mp3",@"cat2_card9_p1.jpg",@"cat2_card9_s1.mp3",nil]

#define DEFAULT_SQL_LIST [NSArray arrayWithObjects:@"create table resources(id varchar(36) primary key, filename varchar(32))",@"create table card(id varchar(36) primary key,type varchar(8),name varchar(64),image var(36),audio varchar(36),user varchar(36),removable int)",@"create table card_tree(child varchar(36), parent varchar(36), position int,animation varchar(10))",@"create table user(id varchar(36), name varchar(64), root_category varchar(36),layoutx int,layouty int)",nil]


#endif
