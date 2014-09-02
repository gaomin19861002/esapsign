//
//  Client_file.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_user;
@class Client_sign_flow, Client_target;
@class Client_sign;

@interface Client_file : NSManagedObject

@property (nonatomic, retain) NSNumber * download_size;
@property (nonatomic, retain) NSString * file_id;
@property (nonatomic, retain) NSNumber * file_type;
@property (nonatomic, retain) NSNumber * local_version;
@property (nonatomic, retain) NSString * locker_account_id;
@property (nonatomic, retain) NSString * owner_account_id;
@property (nonatomic, retain) NSString * phsical_backup_filename;
@property (nonatomic, retain) NSString * phsical_filename;
@property (nonatomic, retain) NSNumber * record_references;
@property (nonatomic, retain) NSNumber * server_version;
@property (nonatomic, retain) NSString * sign_flow_id;
@property (nonatomic, retain) NSNumber * sign_status;
@property (nonatomic, retain) NSNumber * store_type;
@property (nonatomic, retain) NSNumber * total_size;
@property (nonatomic, retain) NSString * trans_filename;
@property (nonatomic, retain) NSNumber * upload_size;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSNumber * version_guid;
@property (nonatomic, retain) Client_target *clientTarget;
@property (nonatomic, retain) Client_sign_flow *currentSignflow;
@property (nonatomic, retain) NSSet *clientTargets;

/*!
 返回文件的所有签名人，按照签名流程的顺序返回
 */
- (NSArray *)sortedSignFlows;

/*!
 添加一个用户到签名流程
 */
- (Client_sign *)addUserToSignFlow:(NSString *)userName address:(NSString *)address;

/*!
 删除一个签名
 */
- (BOOL)removeClientSign:(Client_sign *)sign;

- (FileStatus)fileStatus;

@end

@interface Client_file (CoreDataGeneratedAccessors)

- (void)addClientTargetsObject:(Client_target *)value;
- (void)removeClientTargetsObject:(Client_target *)value;
- (void)addClientTargets:(NSSet *)values;
- (void)removeClientTargets:(NSSet *)values;

@end
