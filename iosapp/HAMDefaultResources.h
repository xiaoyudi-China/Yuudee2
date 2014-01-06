//
//  HAMDefaultResources.h
//  iosapp
//
//  Created by Dai Yue on 13-12-12.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#ifndef iosapp_HAMDefaultResources_h
#define iosapp_HAMDefaultResources_h

#define DEFAULT_RESOURCES_LIST 

#define DEFAULT_SQL_LIST [NSArray arrayWithObjects:@"create table resources(id varchar(36) primary key,filename varchar(32))",@"create table card(id varchar(36) primary key,type varchar(8),name varchar(64),image varchar(36), audio varchar(36),imagenum int,removable int)",@"create table card_tree(child varchar(36), parent varchar(36), position int,animation varchar(10))",@"create table user(id varchar(36), name varchar(64), root_category varchar(36),layoutx int,layouty int)",nil]


#endif