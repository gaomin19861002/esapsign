//
//  SyncManager.m
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SyncManager.h"
#import "RequestManager.h"
#import "UIAlertView+Additions.h"
#import "Util.h"
#import "CAAppDelegate.h"
#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "DataManager+Targets.h"
#import "DataManager+SignPic.h"
#import "DownloadManager.h"
#import "NSObject+DelayBlocks.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"
#import "ActionManager.h"

//#define UseTestDataPacket   1

@interface SyncManager()<RequestManagerDelegate>

@property(nonatomic, retain) ASIFormDataRequest *updateRequest;

@end

@implementation SyncManager

DefaultInstanceForClass(SyncManager);

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAllSignDownloadFinished)
                                                     name:SignPicUpdateCompleteNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)startSync
{
    if ([CAAppDelegate sharedDelegate].offlineMode)
    {
        return;
    }
    
    [[RequestManager defaultInstance] registerDelegate:self];

    NSDictionary *userInfo = [Util currentLoginUserInfo];
    NSDictionary *para = @{@"login": userInfo, @"type": @"0"};
#ifdef UseTestDataPacket
    [self performSelector:@selector(asynRequestStarted:) withObject:nil];
    [self performSelector:@selector(asynRequestFinished:) withObject:nil afterDelay:1];
#else
    self.updateRequest = [[RequestManager defaultInstance] asyncPostData:UpdateRequestPath Parameter:para];
#endif
}

- (void)handleAllSignDownloadFinished
{
    [self.parentController hideProgress];
}

#pragma mark - Request Manager Delegate

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.updateRequest)
    {
        [self.parentController showProgressText:@"同步中..."];
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.updateRequest)
    {
        [[RequestManager defaultInstance] unRegisterDelegate:self];
        [self.parentController hideProgress];
        DebugLog(@"login failed=%@", self.updateRequest.error);
        [UIAlertView showAlertMessage:@"同步失败"];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (![NSThread isMainThread])
        NSLog(@"current thread is no main thread");
    
    if (request == self.updateRequest)
    {
        // 取消代理
        [[RequestManager defaultInstance] unRegisterDelegate:self];

        // 处理返回字符串
#ifdef UseTestDataPacket
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testResponse" ofType:@"txt"];
        NSString *responseString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
#else
        NSString *responseString = [self.updateRequest responseString];
#endif
        NSLog(@"res= %@", responseString);
        NSDictionary *responseDic = [responseString jsonValue];

        if (![self checkLoginResponseSuccess:responseDic])
            return;

        [self processContactData:responseDic];
        
        [self appendSignToContact:responseDic];
        
        [self processTargetData:responseDic];

        [self processSignPicData:responseDic];
        
        // 进入下载过程（仅下载签名图片）
        [[DownloadManager defaultInstance] resetDownloadFileList];
        [[DownloadManager defaultInstance] startDownload];
        [self performBlock:^{
            // 重刷文档界面
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncUpdateFinishedNotification object:nil];
            // 重刷通讯录页面
            [[NSNotificationCenter defaultCenter] postNotificationName:ContactImportSucceedNotification object:nil];
        } afterDelay:.5];
        // 下载完成后，再重刷签名图界面并切处理是否要跳转到签名
    }
}

#pragma mark - Update result process

// 处理登录信息
- (bool)checkLoginResponseSuccess:(NSDictionary*)responseDic
{
    NSDictionary *loginDict = [responseDic objectForKey:@"login"];
    
    if ([[loginDict objectForKey:@"result"] intValue] != 1)
    {
        // 跳转到登录界面
        CAAppDelegate *delegate = (CAAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate popLoginView];
        
        return NO;
    }
    
    reqireSignMark = NO;
    if ([[loginDict objectForKey:@"requireSign"] intValue] == 1)
    {
        // 需要跳转到签名页
        reqireSignMark = YES;
    }
    
    return YES;
}

// 处理联系人信息
- (void)processContactData:(NSDictionary*)responseDic
{
    DataManager* manager = [DataManager defaultInstance];
    
    // 删除本地所有联系人 - 这一步不太有效率，暂时这样
    [manager clearAllContacts];
    [manager clearAllContactItems];
    
    if ([[responseDic objectForKey:@"contact"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *contactDict = [responseDic objectForKey:@"contact"];
        NSArray *contacts = [contactDict objectForKey:@"contacts"];
        
        for (NSDictionary *contactDic in contacts)
        {
            NSArray *contactItems = [contactDic objectForKey:@"contactItems"];
            __unused Client_contact *user = [manager syncContact:contactDic andItems:contactItems];
        }
    }
}

// 将位于签名包中的联系人整合入通讯录
- (void)appendSignToContact:(NSDictionary*)responseDic
{
    DataManager *manager = [DataManager defaultInstance];
    NSDictionary *targetDict = [responseDic objectForKey:@"target"];
    NSArray *targetList = [targetDict objectForKey:@"targets"];
    for (NSDictionary *dict in targetList)
    {
        NSDictionary* fileDict = [dict objectForKey:@"file"];
        if ([[dict objectForKey:@"type"] integerValue] == TargetTypeFile && fileDict != nil)
        {
            NSDictionary* signFlowDict = [fileDict objectForKey:@"signFlow"];
            if (signFlowDict != nil)
            {
                NSArray* signListNew = [signFlowDict objectForKey:@"signs"];
                for (NSDictionary* signDict in signListNew)
                {
                    // 根据地址判断是否已经存在对应地址的用户
                    Client_contact *findUser = [manager findUserWithAddress:[signDict objectForKey:@"signerAddress"]];
                    if (findUser == nil)
                    {
                        NSString* aid = [signDict objectForKey:@"id"];
                        Client_contact* contact = [manager addContactByPersonName:[signDict objectForKey:@"signerName"] familyName:@""];
                        [manager addContactItem:contact
                                    itemAccount:aid
                                      itemTitle:@"签约"
                                       itemType:UserContentTypeEmail
                                      itemValue:[signDict objectForKey:@"signerAddress"]
                                        isMajor:[aid isEqualToString:@""]];
                        
                        NSDictionary *action = [[ActionManager defaultInstance] contactNewAction:contact];
                        [[ActionManager defaultInstance] addToQueue:action sendAtOnce:NO];
                    }
                }
            }
        }
    }
    [manager syncContactCache];
    
    // 设置一个合理的时机发送可能迟滞的Action
    [[ActionManager defaultInstance] sendQueueAtOnce];
}

// 处理文档目录信息
- (void)processTargetData:(NSDictionary*)responseDic
{
    DataManager* manager = [DataManager defaultInstance];
    
    // 注意：当本地数据库使用多用户时，可能不同的用户会引用到同一个文件，继而会有相同的signFlow数据包、Sign数据包等，因而不能都当作新的数据就插入
    //  数据库；更新文件时，Target处理也要检查是否数据库中已经有id，届时应当采用database update，而不是database insert
    //  现在都是insert
    
    // 下载管理器中的未完成数据都重置
    [[DownloadManager defaultInstance] clearDownload];
    
    // 清除已有的target对象，除了file
    [manager clearAllTargets];
    [manager clearAllSignFlow];
    [manager clearAllSign];
    
    NSDictionary *targetDict = [responseDic objectForKey:@"target"];
    NSArray *targetList = [targetDict objectForKey:@"targets"];
    for (NSDictionary *dict in targetList)
    {
        // 同步target数据
        Client_target *target = [manager syncTarget:dict];
        
        NSDictionary* fileDict = [dict objectForKey:@"file"];
        if ([target.type isEqualToNumber:@(TargetTypeFile)] && fileDict != nil)
        {
            // 同步file对象
            Client_file *file = [manager syncFile:fileDict];
            
            // 补充Target关联File的字段
            target.file_id = [fileDict objectForKey:@"id"];
            target.clientFile = file;
            
            NSDictionary* signFlowDict = [fileDict objectForKey:@"signFlow"];

            // 同步SignFlow对象 注意：即便SignFlow是空的也一样处理
            Client_sign_flow* signFlow = [manager syncSignFlow:signFlowDict];
            
            // 补充File关联SignFlow的字段
            file.sign_flow_id = [signFlowDict objectForKey:@"id"];
            file.currentSignflow = signFlow;
            
            NSArray* signList = [signFlowDict objectForKey:@"signs"];
            for (NSDictionary* signDict in signList)
            {
                // 获取Sign数据包
                Client_sign* sign = [manager syncSign:signDict];
                
                sign.sign_flow_id = signFlow.sign_flow_id;
                sign.sign_flow = signFlow;
                
                // 查找本地用户表中，对应的用户名
                Client_contact *user = [[DataManager defaultInstance] findUserWithAddress:sign.sign_address];
                if (user != nil)
                    sign.sign_displayname = user.user_name;
            }
            
            NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            file.phsical_filename = [NSString stringWithFormat:@"%@.pdf", [cacheFolder stringByAppendingPathComponent:file.file_id]]; // 以文件ID作为文件名进行缓存
        }
    }
}

// 处理签名图信息
- (void)processSignPicData:(NSDictionary*)responseDic
{
    DataManager* manager = [DataManager defaultInstance];
    [manager clearLocalSignPic];
    
    NSDictionary *penDict = [responseDic objectForKey:@"pen"];
    NSArray *penList = [penDict objectForKey:@"pens"];
    if ([penList isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dict in penList)
            [manager syncSignPicWithDict:dict];
    }
}


@end
