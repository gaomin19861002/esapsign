//
//  ActionManager.m
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ActionManager.h"
#import "RequestManager.h"
#import "NSObject+Json.h"
#import "NSString+Additions.h"
#import "UIAlertView+Additions.h"
#import "Util.h"
#import "CAAppDelegate.h"
#import "DataManager.h"
#import "DownloadManager.h"
#import "NSDate+Additions.h"
#import "SyncManager.h"
#import "CAAppDelegate.h"
#import "ClientContentInEdit.h"


@interface ActionManager()<RequestManagerDelegate>
{
    bool inRequest;
}


/*!
 *  action缓存队列
 */
@property (nonatomic, strong) NSMutableArray *actionQueue;

@property(nonatomic, retain) NSMutableArray *allDelegates;

/*!
 对action追加登录头部信息
 @param action action 信息
 @return 包含登录信息的action
 */
- (NSDictionary *)appendLoginHead:(NSDictionary *)action;

- (NSDictionary *)signPacket:(Client_sign *)sign;

@end

@implementation ActionManager

DefaultInstanceForClass(ActionManager);

- (NSMutableArray *)allDelegates
{
    if (!_allDelegates) {
        _allDelegates = [[NSMutableArray alloc] init];
    }
    
    return _allDelegates;
}

- (void)registerDelegate:(id<RequestManagerDelegate>) delgate
{
    if (delgate) {
        [self.allDelegates addObject:delgate];
    }
}

- (void)unRegisterDelegate:(id<RequestManagerDelegate>) delgate
{
    if (delgate) {
        [self.allDelegates removeObject:delgate];
    }
}

- (id)init
{
    id result = [super init];
    if (result)
    {
        [[RequestManager defaultInstance] registerDelegate:self];
        inRequest = NO;
    }
    return result;
}

- (void)dealloc
{
    [[RequestManager defaultInstance] unRegisterDelegate:self];
}

- (NSMutableArray *) actionQueue
{
    if (!_actionQueue)
    {
        _actionQueue = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _actionQueue;
}

/*!
 对action追加登录头部信息
 @param action action 信息
 @return 包含登录信息的action
 */
- (NSDictionary *)appendLoginHead:(NSDictionary *)action
{
    NSDictionary *userInfo = [Util currentLoginUserInfo];
    return @{@"login": userInfo,
             @"actions": @[action]};
}

#pragma mark - Action Package factory

#pragma mark - Target actions

- (NSDictionary*)createAction
{
#warning TODO
    NSDictionary* newData = @{@"id": @""};
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"create",
                             @"orgData": @"",
                             @"newData": newData,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

- (NSDictionary*)deleteAction
{
#warning TODO
    NSDictionary* newData = @{@"id": @""};
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"delete",
                             @"orgData": @"",
                             @"newData": newData,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

- (NSDictionary*)renameAction
{
#warning TODO
    NSDictionary* newData = @{@"id": @""};
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"rename",
                             @"orgData": @"",
                             @"newData": newData,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

- (NSDictionary*)moveAction
{
#warning TODO
    NSDictionary* newData = @{@"id": @""};
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"move",
                             @"orgData": @"",
                             @"newData": newData,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

- (NSDictionary*)updateRequestAction
{
#warning TODO
    NSDictionary* newData = @{@"id": @""};
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"update",
                             @"orgData": @"",
                             @"newData": newData,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

#pragma mark - SignPen actions

/**
 * @abstract 生成新建签名的action包
 * @param fileID 签名文件id
 * @return action 包
 */
- (NSDictionary *)signpenNewAction:(NSString *)fileID
{
    NSDictionary* pen = @{@"id": fileID,
                          @"cert": @"",
                          @"rule": @"0",
                          @"picUrl": @""
                          };
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"signpennew",
                             @"orgData": @"",
                             @"newData": pen,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

/**
 * @abstract 删除签名的action包
 * @param delSignID 要删除的签名图文件id
 * @return action 包
 */
- (NSDictionary*)signpenDelAction:(NSString*)delSignID
{
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"signpendel",
                             @"orgData": delSignID,
                             @"newData": @"",
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}


#pragma mark - Contact actions

/**
 * @abstract ContentItem的数据包
 * @param content 新建的联系人的content对象
 * @return 新建联系人的ContentItem数据包
 */
- (NSDictionary *)contentItemAction:(Client_content *) content isNew:(bool)isNew
{
    
    NSDictionary *item = @{@"id": isNew ? [Util generalUUID] : content.content_id,
                           @"accountId": content.account_id ? content.account_id: @"",
                           @"type": content.contentType ? content.contentType : @"",
                           @"title": content.title ? content.title : @"",
                           @"content": content.contentValue ? content.contentValue : @"",
                           @"major": content.major ? : @""};
    return item;
}

/**
 * @abstract ContactNew的数据包
 * @param user 新建的联系人对象（客户端为user，服务端为contact）
 * @return 新建联系人的Contact数据包
 */
- (NSDictionary *)contactNewAction:(Client_user *) user
{
    //组装newData，contactItems
    NSMutableArray *contactItems = [NSMutableArray array];
    for (Client_content *content in user.clientContents) {
        [contactItems addObject:[self contentItemAction:content isNew:YES]];
    }
    
    // json解析不支持NSDate格式 gaomin@20140818
    NSString *lastTimeStamp = [user.last_timestamp fullDateString];
    
    //然后拼装newData
    NSDictionary *newData = @{@"id" : [Util generalUUID],
                              @"contactAccount" : @"",//用户在ESAP平台上的id，这里缺乏对应关系
                              @"majorEmail" : [user majorAddress] ?[user majorAddress] : @"",
                              @"familyName" : user.family_name ? user.family_name : @"",
                              @"personName" : user.person_name ? user.person_name : @"",
                              @"gender" : user.gender ? user.gender : @"",
                              @"lastTimeStamp" : user.last_timestamp ? lastTimeStamp : @"",
                              @"contactItems" : contactItems? contactItems : @""};
    //拼装action
    NSDictionary *action = @{@"id": [Util generalUUID],
                             @"timestamp" : [NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version" : @"",
                             @"category" : @"contactnew",
                             @"orgData" : @"",
                             @"newData" : newData,
                             @"actionResult" : @""};
    
    return [self appendLoginHead:action];
}

/**
 * @abstract contactupdate的数据包
 * @param user 更新的对象
 * @return 联系人的数据包
 */
- (NSDictionary *)contactUpdateAction:(Client_user *) user
{
    //组装newData，contactItems
    NSMutableArray *contactItems = [NSMutableArray array];
    for (Client_content *content in user.clientContents) {
        [contactItems addObject:[self contentItemAction:content isNew:NO]];
    }
    
    //然后拼装newData
    // JSON解析不支持NSDate格式 gaomin@20140818
    NSString *lastTimeStamp = [user.last_timestamp fullDateString];
    NSDictionary *newData = @{@"id" : user.user_id,
                              @"contactAccount" : user.user_id ? user.user_id : @"",//用户在ESAP平台上的id
                              @"majorEmail" : [user majorAddress] ? [user majorAddress] : @"",
                              @"familyName" : user.family_name ? user.family_name : @"",
                              @"personName" : user.person_name ? user.person_name : @"",
                              @"gender" : user.gender ? user.gender : @"",
                              @"lastTimeStamp" : user.last_timestamp ? lastTimeStamp : @"",
                              @"contactItems" : contactItems.count  ? contactItems : @""};
    //拼装action
    NSDictionary *action = @{@"id": [Util generalUUID],
                             @"timestamp" : [NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version" : @"",
                             @"category" : @"contactupdate",
                             @"orgData" : user.user_id,
                             @"newData" : newData,
                             @"actionResult" : @""};
    
    return [self appendLoginHead:action];
}

/**
 * @abstract contactdel的数据包
 * @param user 要删除的对象
 * @return 联系人的数据包
 */
- (NSDictionary *)contactDelAction:(Client_user *) user
{
    //拼装action
    NSDictionary *action = @{@"id": [Util generalUUID],
                             @"timestamp" : [NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version" : @"",
                             @"category" : @"contactdel",
                             @"orgData" : user.user_id,
                             @"newData" : @"",
                             @"actionResult" : @""};
    
    return [self appendLoginHead:action];
}

#pragma mark - Signature actions

/**
 * @abstract sign的数据包
 * @param sign 要签名的对象
 * @param target 签名的文件
 * @return 签名的数据包
 */
- (NSDictionary *)signRequestAction:(Client_sign *) sign andTarget:(Client_target *) target
{
    NSDictionary *newData = @{@"id" : sign.sign_id,
                              @"sequence" : sign.sequence,
                              @"signDate" : [NSString stringWithFormat:@"%@", sign.sign_date],
                              @"refuseDate" : @"",
                              @"signerAccountID" : sign.sign_account_id,
                              @"signerName" : sign.displayName,
                              @"signerAddress" : sign.sign_address};
    //拼装action
    NSDictionary *action = @{@"id": [Util generalUUID],
                             @"timestamp" : [NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version" : @"",
                             @"category" : @"sign",
                             @"orgData" : target.file_id ? target.file_id : @"",//target的id
                             @"newData" : newData,//sign数据包
                             @"actionResult" : @""};
    return [self appendLoginHead:action];
}

/**
 * @abstract 文件签名流程的数据包
 * @param fileID 对应的文件id
 * @return 文件签名流程数据包
 */
- (NSDictionary *)signsetAction:(Client_file *)file
{
    Client_sign_flow *signflow = file.currentSignflow;
    NSMutableDictionary *signflowDict = [NSMutableDictionary dictionary];
    [signflowDict setObject:signflow.sign_flow_id forKey:@"id"];
    [signflowDict setObject:[NSString stringWithFormat:@"%@", signflow.current_sequence] forKey:@"currentSequence"];
    [signflowDict setObject:signflow.current_sign_id forKey:@"currentSignId"];
    [signflowDict setObject:[NSString stringWithFormat:@"%@", signflow.current_sign_status] forKey:@"currentSignStatus"];
    
    NSMutableArray *signs = [NSMutableArray array];
    for (Client_sign *sign in file.sortedSignFlows)
    {
        [signs addObject:[self signPacket:sign]];
    }
    [signflowDict setObject:signs forKey:@"signs"];
    
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"signset",
                             @"orgData": file.file_id,
                             @"newData": signflowDict,
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}

/**
 * @abstract 文件签名操作的数据包
 * @param fileID 对应的文件id
 * @return 文件签名流程数据包
 */
- (NSDictionary *)signPacket:(Client_sign *)sign
{
    NSMutableDictionary *signDict = [NSMutableDictionary dictionary];
    [signDict setObject:sign.sign_id forKey:@"id"];
    [signDict setObject:[NSString stringWithFormat:@"%@", sign.sequence] forKey:@"sequence"];
    if (sign.sign_date) {
        [signDict setObject:[sign.sign_date fullDateString] forKey:@"signDate"];
    } else {
        [signDict setObject:@"" forKey:@"signDate"];
    }
    
    if (sign.refuse_date) {
        [signDict setObject:[sign.refuse_date fullDateString] forKey:@"refuseDate"];
    } else {
        [signDict setObject:@"" forKey:@"refuseDate"];
    }
    
    if (sign.sign_account_id) {
        [signDict setObject:sign.sign_account_id forKey:@"signerAccountID"];
    } else {
        [signDict setObject:@"" forKey:@"signerAccountID"];
    }
    
    [signDict setObject:sign.sign_displayname forKey:@"signerName"];
    [signDict setObject:sign.sign_address forKey:@"signerAddress"];
    
    return signDict;
}

/**
 * @abstract 文件加锁流程的数据包
 * @param target 对应的文件target对象
 * @return 文件签名流程数据包
 */
- (NSDictionary *)lockAction:(Client_target *) target
{
    NSDictionary* action = @{@"id": [Util generalUUID],
                             @"timestamp":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"version": @"",
                             @"category": @"lock",
                             @"orgData": target.client_id,
                             @"newData": @"",
                             @"actionResult": @""};
    return [self appendLoginHead:action];
}


#pragma mark - Queue method

/**
 * @abstract 将要发送的Action请求放到队列里面
 * @param param Action请求的参数内容
 * @return
 */
- (void) addToQueue:(NSDictionary *) param
{
    [self.actionQueue addObject:param];
    
    // 如果已经在发送一个action请求，暂时不处理，直接返回。这样保证单例模式ActionManager只有一个actionRequest对象
    if (inRequest)
        return;
    
    [self postAction];
}

/**
 * @abstract 清空队列请求
 */
- (void)clearQueue
{
    [self.actionQueue removeAllObjects];
}

- (void)postAction
{
    if ([self.actionQueue count] > 0)
    {
        NSDictionary *queuePackage = @{@"actions": self.actionQueue};
        NSDictionary *requestPackage = [self appendLoginHead:queuePackage];
        self.actionRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, ActionRequestPath] Parameter:requestPackage];
        [self clearQueue];
    }
}

#pragma mark - Request Method

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.actionRequest)
    {
        inRequest = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ActionManagerDelegate> delegate in self.allDelegates) {
                if ([delegate respondsToSelector:@selector(actionRequestStarted:)]) {
                    [delegate actionRequestStarted:request];
                }
            }
        });
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.actionRequest)
    {
        inRequest = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView showAlertMessage:@"动作请求已创建，但因为网络问题，未能提交。"];
        
            for (id<ActionManagerDelegate> delegate in self.allDelegates) {
                if ([delegate respondsToSelector:@selector(actionRequestFailed:)]) {
                    [delegate actionRequestFailed:request];
                }
            }
#warning 这种情况下，之前清除的Action Queue数据应当恢复
        });
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.actionRequest)
    {
        inRequest = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ActionManagerDelegate> delegate in self.allDelegates) {
                if ([delegate respondsToSelector:@selector(actionRequestFinished:)]) {
                    [delegate actionRequestFinished:request];
                }
            }

            // 继续尝试发送剩下的Action
            [self postAction];

# warning 检查所有的Action Result，如果有失败的结果，需要调用同步
            // NSDictionary *resDict = [[request responseString] jsonValue];
        });
    }
}

@end
