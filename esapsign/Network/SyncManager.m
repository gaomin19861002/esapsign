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
#import "DownloadManager.h"
#import "NSObject+DelayBlocks.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"

//#define UseTestDataPacket   1

@interface SyncManager()<RequestManagerDelegate>

@property(nonatomic, retain) ASIFormDataRequest *updateRequest;

- (void)handleAllSignDownloadFinished;

@end

@implementation SyncManager

DefaultInstanceForClass(SyncManager);
//ReleaseInstanceForClass;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAllSignDownloadFinished)
                                                     name:DownloadAllSignFinishedNotitication
                                                   object:nil];
    }
    
    return self;
}

- (void)startSync {
    [[RequestManager defaultInstance] registerDelegate:self];

    NSDictionary *userInfo = [Util currentLoginUserInfo];
    NSDictionary *para = @{@"login": userInfo,
                           @"type": @"0"};
#ifdef UseTestDataPacket
    [self performSelector:@selector(asynRequestStarted:) withObject:nil];
    [self performSelector:@selector(asynRequestFinished:) withObject:nil afterDelay:1];
#else
    self.updateRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, UpdateRequestPath] Parameter:para];
#endif
}

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.updateRequest) {
        [self.parentController showProgressText:@"同步中..."];
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.updateRequest) {
        [[RequestManager defaultInstance] unRegisterDelegate:self];
        [self.parentController hideProgress];
        DebugLog(@"login failed=%@", self.updateRequest.error);
        [UIAlertView showAlertMessage:@"同步失败"];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    DataManager* manager = [DataManager defaultInstance];
    if (![NSThread isMainThread]) {
        DebugLog(@"current thread is no main thread");
    }
    if (request == self.updateRequest)
    {
        [[RequestManager defaultInstance] unRegisterDelegate:self];
        //[self.parentController hideProgress];
#ifdef UseTestDataPacket
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testResponse" ofType:@"txt"];
        NSString *resString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
#else
        NSString *resString = [self.updateRequest responseString];
#endif
        DebugLog(@"res= %@", resString);
        NSDictionary *resDict = [resString jsonValue];
        NSDictionary *loginDict = [resDict objectForKey:@"login"];
        if ([[loginDict objectForKey:@"result"] intValue] != 1)
        {
            // 跳转到登录界面
            CAAppDelegate *delegate = (CAAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate popLoginView];
            
            return;
        }
        
        // 删除本地所有联系人
        [[DataManager defaultInstance] deleteAllClientUsers];
        
        //处理联系人信息
        
        if ([[resDict objectForKey:@"contact"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *contactDict = [resDict objectForKey:@"contact"];
            NSArray *contacts = [contactDict objectForKey:@"contacts"];
            
            for (NSDictionary *contact in contacts) {
                
                Client_user *user = nil;
                
                //只根据邮箱和手机号进行匹配。

                //得到联系人信息列表
                NSArray *contactItems = [contact objectForKey:@"contactItems"];
//                int limit = 10;
//                int start = 0;
                for (NSDictionary *item in contactItems) {
//                    if (start++ >= 10) break;
                    NSString *content = [item objectForKey:@"content"];
                    NSString *type = [item objectForKey:@"type"];
                    
                    user = [[DataManager defaultInstance] syncUser:content andValue:type];
                    if (user) {
                        //找到用户,更新displayname
                        user.family_name = [contact objectForKey:@"familyName"];
                        user.person_name = [contact objectForKey:@"personName"];
                        
                    }
                }
                //没有找到用户的处理
                if (!user) {
                    
                    //新建联系人并且加入条目
                    user = [[DataManager defaultInstance] createUserWithDictionary:contact];
                    for (NSDictionary *item  in [contact objectForKey:@"contactItems"]) {
                        [[DataManager defaultInstance] addContentWithUser:user content:item];
                    }
                }
            }
        }
        
        // 处理通讯录信息
        // By Yi Minwen 2014-6-22
        NSDictionary *targetDict = [resDict objectForKey:@"target"];
        NSArray *targetList = [targetDict objectForKey:@"targets"];
        for (NSDictionary *dict in targetList)
        {
            NSDictionary* fileDict = [dict objectForKey:@"file"];
            if ([[dict objectForKey:@"type"] integerValue] == 2 && fileDict != nil)
            {
                NSDictionary* signFlowDict = [fileDict objectForKey:@"signFlow"];
                if (signFlowDict != nil)
                {
                    //                     添加签名人到ClientUser表
                    NSArray* signListNew = [signFlowDict objectForKey:@"signs"];
                    for (NSDictionary* signDict in signListNew)
                    {
                        //根据id判断是否已经存在对应id的用户
                        //Client_user *findUser = [[DataManager defaultInstance] findUserWithId:[signDict objectForKey:@"id"]];
                        Client_user *findUser = [[DataManager defaultInstance] findUserWithAddress:[signDict objectForKey:@"signerAddress"]];
                        if (!findUser) {
                            [[DataManager defaultInstance] syncSignUser:[signDict objectForKey:@"signerAddress"] displayName:[signDict objectForKey:@"signerName"] userid:[signDict objectForKey:@"id"]];
                        }else{
                            //我得联系人中已经存在对应的联系人，不作修改
                            
                        }
                    }
                }
            }
        }
        
        // 处理文档对象信息
        // 注意：当本地数据库使用多用户时，可能不同的用户会引用到同一个文件，继而会有相同的signFlow数据包、Sign数据包等，因而不能都当作新的数据就插入
        //  数据库；更新文件时，Target处理也要检查是否数据库中已经有id，届时应当采用database update，而不是database insert
        //  现在都是insert
        
        // 清除已有的target对象
        [[DownloadManager defaultInstance] clearDownload];

        [[DataManager defaultInstance] clearAllTargets];
        [[DataManager defaultInstance] clearAllSignFlow];
        [[DataManager defaultInstance] clearAllSign];
        
        for (NSDictionary *dict in targetList)
        {
            // 同步target数据
            Client_target *target = [manager syncTarget:dict];
            
#warning test
            //if (! [@"" isEqualToString:[dict objectForKey:@"parentId"]]
             //   && ! [@"311BAE9-7449-45BD-855A-F33E1E534A70" isEqualToString:[dict objectForKey:@"parentId"]])
             //   continue;
            
            NSDictionary* fileDict = [dict objectForKey:@"file"];
            if ([target.type isEqualToNumber:@(2)] && fileDict != nil)
            {
                // 同步file对象
                Client_file *file = [manager syncFile:fileDict];
                
                // 补充文件Target字段
                target.file_id = [fileDict objectForKey:@"id"];
                target.clientFile = file;
                //file.clientTarget = target;

                NSDictionary* signFlowDict = [fileDict objectForKey:@"signFlow"];
                if (signFlowDict != nil)
                {
                    // 补充文件的SignFlow字段
                    file.sign_flow_id = [signFlowDict objectForKey:@"id"];
                    
                    // 填写signFlow对象
                    Client_sign_flow* signFlow = (Client_sign_flow *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignFlow
                                                                                                   inManagedObjectContext:[DataManager defaultInstance].objectContext];
                    signFlow.sign_flow_id = [signFlowDict objectForKey:@"id"];
                    signFlow.file_id = file.file_id;
                    // signFlow.starterAccount = [signFlowDict objectForKey:@"starterAccount"]; 需要增加 starterAccount字段
                    signFlow.current_sequence = @([[signFlowDict objectForKey:@"currentSequence"] integerValue]);
                    signFlow.current_sign_id = [signFlowDict objectForKey:@"currentSignId"];
                    signFlow.current_sign_status = @([[signFlowDict objectForKey:@"currentSignStatus"] integerValue]);
                    // signFlow.status = ; 通过事后的综合判断，随后填写
                    [[DataManager defaultInstance].objectContext insertObject:signFlow];
                    
                    file.sign_flow_id = file.sign_flow_id;
                    file.sign_status = file.sign_status;
                    file.currentSignflow = signFlow;
                    
                    NSArray* signList = [signFlowDict objectForKey:@"signs"];
                    for (NSDictionary* signDict in signList)
                    {
                        // 获取Sign数据包
                        Client_sign *sign = (Client_sign *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSign
                                                                                         inManagedObjectContext:[DataManager defaultInstance].objectContext];
                        sign.sign_flow_id = signFlow.sign_flow_id;
                        sign.sign_id = [signDict objectForKey:@"id"];
                        sign.sequence = @([[signDict objectForKey:@"sequence"] integerValue]);
                        //sign.sign_date = [[signDict objectForKey:@"signDate"] date];
                        //sign.refuse_date = [[signDict objectForKey:@"refuseDate"] date];
                        sign.sign_account_id = [signDict objectForKey:@"signerAccountID"];
                        sign.sign_displayname = [signDict objectForKey:@"signerName"];
                        sign.sign_address = [signDict objectForKey:@"signerAddress"];
                        sign.sign_flow = signFlow;
                        
                        // 查找本地用户表中，对应的用户名
                        Client_user *user = [[DataManager defaultInstance] clientUserWithAddress:sign.sign_address];
                        sign.sign_displayname = user.user_name;
                        
                        [[DataManager defaultInstance].objectContext insertObject:sign];
                    }
                }

                NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                file.phsical_filename = [NSString stringWithFormat:@"%@.pdf", [cacheFolder stringByAppendingPathComponent:file.file_id]]; // 以文件ID作为文件名进行缓存
            }
        }

        // 处理签名图片信息
        
        [[DataManager defaultInstance] clearLocalSignFile];

        NSDictionary *penDict = [resDict objectForKey:@"pen"];
        NSArray *penList = [penDict objectForKey:@"pens"];
        if ([penList isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *dict in penList)
            {
                // Client_signfile* signFile = [manager syncSignFileInfo:[dict objectForKey:@"id"] serverPath:[dict objectForKey:@"picUrl"]];
                Client_signfile *signFile = [manager syncSignFileWithDict:dict];
            }
        }

        reqireSignMark = NO;
        if ([[loginDict objectForKey:@"requireSign"] intValue] == 1)
        {
            // 需要跳转到签名页
            reqireSignMark = YES;
        }
        
        [[DownloadManager defaultInstance] resetDownloadFileList];
        [[DownloadManager defaultInstance] startDownload];
        [self performBlock:^{
            // 重刷文档界面
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncUpdateFinishedNotification object:nil];
            // 重刷通讯录页面
            [[NSNotificationCenter defaultCenter] postNotificationName:ContactImportSucceedNotification object:nil];
            // 重刷签名图界面
            

        } afterDelay:.5];
    }
}

- (void)asynDownloadFileStarted
{
    
}

- (void)handleAllSignDownloadFinished {
    [self.parentController hideProgress];
}

@end
