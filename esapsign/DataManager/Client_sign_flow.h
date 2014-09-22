//
//  Client_sign_flow.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_file, Client_sign;

@interface Client_sign_flow : NSManagedObject

@property (nonatomic, retain) NSNumber * current_sequence;
@property (nonatomic, retain) NSString * current_sign_id;
@property (nonatomic, retain) NSNumber * current_sign_status;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * sign_flow_id;

@property (nonatomic, retain) Client_file* flowFile;
@property (nonatomic, retain) NSSet *signs;

/*!
 返回文件的所有签名人，按照签名流程的顺序返回
 */
- (NSArray *)sortedSignFlows;

/*!
 判断一个sign是否是当前要执行的sign
 */
- (bool)isActiveSign:(Client_sign*)sign;

/*!
 添加一个用户到签名流程
 */
- (Client_sign *)addUserToSignFlow:(NSString *)userName address:(NSString *)address;

/*!
 删除一个签名流程
 */
- (void)removeUserFromSignFlow:(Client_sign*)sign;

@end
