//
//  Client_file.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_contact;
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

@property (nonatomic, retain) Client_sign_flow *fileFlow;
@property (nonatomic, retain) NSSet *targets;

- (void)removeClientSign:(Client_sign *)sign;

- (FileDownloadStatus)fileDownloadStatus;

@end

@interface Client_file (CoreDataGeneratedAccessors)

- (void)addTargetsObject:(Client_target *)value;
- (void)removeTargetsObject:(Client_target *)value;
- (void)addTargets:(NSSet *)values;
- (void)removeTargets:(NSSet *)values;

@end
