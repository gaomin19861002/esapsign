//
//  Client_target.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataManager;
@class Client_file;

@interface Client_target : NSManagedObject

@property (nonatomic, retain) NSString * account_id;
@property (nonatomic, retain) NSString * client_id;
@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * display_name;
@property (nonatomic, retain) NSString * file_id;
@property (nonatomic, retain) NSDate * last_time_stamp;
@property (nonatomic, retain) NSString * parent_id;
@property (nonatomic, retain) NSNumber * record_status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * update_time;
@property (nonatomic, retain) Client_file *clientFile;

/*!
 定义数据管理对象
 */
@property(nonatomic, assign) DataManager *manager;

/*!
 定义下一级目录
 */
@property(nonatomic, retain) NSArray *subFolders;

/*!
 定义下一级文件
 */
@property(nonatomic, retain) NSArray *subFiles;

@end
