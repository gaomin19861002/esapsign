//
//  DataManager.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Client_account.h"
#import "Client_target.h"
#import "Client_file.h"
#import "Client_sign_flow.h"
#import "Client_sign.h"
#import "Client_signpic.h"
#import "Client_contact.h"
#import "Client_contact_item.h"
#import "User.h"
#import "Util.h"

#define DBFileName  @"clientInfo.data"

/*!
 定义EntityName
 */
#define EntityClientTarget      @"Client_target"
#define EntityClientFile        @"Client_file"
#define EntityClientSignFlow    @"Client_sign_flow"
#define EntityClientSign        @"Client_sign"
#define EntityClientSignPic     @"Client_signpic"
#define EntityClientContact     @"Client_contact"
#define EntityClientContactItem @"Client_contact_item"
#define EntityClientAccount     @"Client_account"

/*!
 数据库管理类
 */
@interface DataManager : NSObject

DefaultInstanceForClassHeader(DataManager);

// 通用的对象存储管理
@property(nonatomic, retain) NSManagedObjectContext *objectContext;
@property(nonatomic, retain) NSManagedObjectModel *objectModel;
@property(nonatomic, retain) NSPersistentStoreCoordinator *storeCoordinator;

// 四大类基础类型对象。注意使用时，添加、修改对象都必须走objectContext，这里只能只读调用
@property(nonatomic, retain, readonly) NSMutableArray *allTargets;
@property(nonatomic, retain, readonly) NSMutableArray *allFiles;
@property(nonatomic, retain, readonly) NSMutableArray *allContacts;
@property(nonatomic, retain, readonly) NSMutableArray *allSignPics;
@property(nonatomic, retain, readonly) NSMutableArray *allSignFlows;

// 该联系人缓冲队列用于在合并数据库时，避免高频度反复从数据库中获取数据
@property (nonatomic, strong) NSMutableArray* contactCache;
- (void)syncContactCache;

/*!
 用户目录路径
 */
@property(nonatomic, copy) NSString *userPath;

// 保存数据
- (void)saveContext;

// 从数据库中取得数据
- (NSArray *)arrayFromCoreData:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                         limit:(NSUInteger)limit
                        offset:(NSUInteger)offset
                       orderBy:(NSSortDescriptor *)sortDescriptor;

#pragma mark - 签名流程及其操作

// 添加一个签名包到指定文件的签名流程中
- (Client_sign *)addFileSignFlow:(Client_sign_flow *)flow
                     displayName:(NSString *)displayName
                         address:(NSString *)address;

// 从一个文件的签名流程中删除一个签名包
- (BOOL)removeClientSign:(Client_sign *)sign
          fromClientFile:(Client_file *)file;



/**
 *  获取与联系人所有相关签名文档(By Yi Minwen)
 *  @param user 相关联系人
 */
- (NSMutableArray *)allTargetsWithClientUser:(Client_contact *)contact;

/**
 *  判定是否有对应签名流程(By Yi Minwen)
 *  @param file 当前文件
 */
- (BOOL)hasSignFlowWithClientFile:(Client_file *)file;

/*!
 提交签名并检查是否整个签名流程已经完成
 @param signFlow 当前signflow
 @param sign 签名
 */
- (bool)finishSignFlow:(Client_sign_flow *)signFlow withSign:(Client_sign*)sign;

/*!
 是否签名流程已走完
 @param file 签名文件
 @return
 */
- (BOOL)isClientFileFinishedSign:(Client_file *)file;

/*!
 是否当前target具备编辑条件
 目前只有收件箱下的可编辑，其他都不可编辑
 @param target 当前target
 @return 返回可编辑状态
 */
- (BOOL)isClientTargetEditable:(Client_target *)target;

#pragma mark - Client_account Methods

/**
 *  @abstract 根据用户名（登陆账号）匹配用户
 *  @param accountId  NSString 用户登陆的账号。
 */
- (Client_account *)queryAccountByAccountId:(NSString *) accountId;

/**
 *  @abstract 创建一个新的用户信息
 *  @param user User
 */
- (Client_account *)createAccountWithUser:(User *) user;

@end
