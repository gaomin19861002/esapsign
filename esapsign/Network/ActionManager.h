//
//  ActionManager.h
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Client_sign_flow.h"
#import "Client_target.h"
#import "Client_contact_item.h"
#import "ASIFormDataRequest.h"

@class ActionManager;

// 定义协议，主要应用于异步请求，通知外部程序当前的请求状态
@protocol ActionManagerDelegate<NSObject>

// 异步请求开始通知外部程序
- (void)actionRequestStarted:(ASIHTTPRequest *)request;

// 异步请求失败通知外部程序
- (void)actionRequestFailed:(ASIHTTPRequest *)request;

// 异步请求结束通知外部程序
- (void)actionRequestFinished:(ASIHTTPRequest *)request;

@end

/*!
 动作请求管理类
 */
@interface ActionManager : NSObject

DefaultInstanceForClassHeader(ActionManager);

/**
 * @abstract Action Manager 也是通过 Request Manager 来实现所有的通讯请求，保有自己的一个请求对象标识
 */
@property (nonatomic, retain) ASIFormDataRequest *actionRequest;

// Action管理器的代理
@property (nonatomic, assign) id<ActionManagerDelegate> actionDelegate;

- (void)registerDelegate:(id<ActionManagerDelegate>) delgate;

- (void)unRegisterDelegate:(id<ActionManagerDelegate>) delgate;

/**
 * 将要发送的Action请求放到队列里面
 */
- (ASIFormDataRequest*) addToQueue:(NSDictionary *) param sendAtOnce:(bool)sendAtOnce;

- (ASIFormDataRequest*) sendQueueAtOnce;

#pragma mark - Actions Package

#pragma mark - Target actions

- (NSDictionary*)createAction;

- (NSDictionary*)deleteAction;

- (NSDictionary*)renameAction;

- (NSDictionary*)moveAction;

- (NSDictionary*)updateRequestAction;

#pragma mark - SignPen actions

/*!
 生成新建签名的action包
 @param fileID 签名文件id
 @return action 包
 */
- (NSDictionary*)signpenNewAction:(NSString *)fileID;

/*!
 删除签名的action包
 @param delSignID 要删除的签名图文件id
 @return action 包
 */
- (NSDictionary*)signpenDelAction:(NSString*)delSignID;

#pragma mark - Contact actions

/*!
 Contact的数据包
 @param user 新建的联系人对象（客户端为user，服务端为contact）
 @return 新建联系人的Contact数据包
 */
- (NSDictionary *)contactNewAction:(Client_contact *) user;

/*!
 contactupdate的数据包
 @param user 更新的对象
 @return 联系人的数据包
 */
- (NSDictionary *)contactUpdateAction:(Client_contact *) user;

/*!
 contactdel的数据包
 @param user 要删除的对象
 @return 联系人的数据包
 */
- (NSDictionary *)contactDelAction:(Client_contact *) user;

#pragma mark - Signature actions

/*!
 文件加锁流程的数据包
 @param target 对应的文件target对象
 @return 文件签名流程数据包
 */
- (NSDictionary *)lockAction:(Client_target *) target;

/*!
 文件签名流程的数据包
 @param fileID 对应的文件id
 @return 文件签名流程数据包
 */
- (NSDictionary *)signsetAction:(Client_file *)file;

/**
 * @abstract sign request的数据包
 * @param sign 要签名的对象
 * @param target 签名的文件
 * @return 签名的数据包
 */
- (NSDictionary *) signRequestAction:(Client_sign *) sign andTarget:(Client_target *) target;

@end

