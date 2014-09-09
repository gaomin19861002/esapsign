//
//  CompleteManager.m
//  esapsign
//
//  Created by 苏智 on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "CompleteManager.h"
#import "Util.h"

@implementation CompleteManager

DefaultInstanceForClass(CompleteManager);

/*!
 追加登录头部信息
 @param action action 信息
 @return 包含登录信息的action
 */
- (NSDictionary *)appendLoginHead:(NSDictionary *)action
{
    NSDictionary *userInfo = [Util currentLoginUserInfo];
    return @{@"login": userInfo,
             @"actions": @[action]};
}

/**
 * @abstract 文件上传完成的请求包
 * @param fileID 文件id
 * @param completeType 完成的上传类型。0：文件上传 1：签名图上传
 * @return complete 包
 */
- (NSDictionary *)uploadCompleteCommand:(NSString *)fileID completeType:(NSString *)completeType
{
    NSString *extend = nil;
    if ([completeType isEqualToString:@"0"])
    {
        extend = @".pdf";
    }
    else
    {
        extend = @".png";
    }
    NSDictionary *complete = @{@"completeType": completeType,
                               @"completeId": fileID,
                               @"completeUrl": [NSString stringWithFormat:@"upload/%@%@", fileID, extend]};
    return [self appendLoginHead:complete];
}

/**
 *  uploadcomplete接口的数据包
 *  @param completeType 完成的上传类型. 0:文件上传、1:签名图上传
 *  @param completeId 完成的上传数据的id
 *  @param url 上传完成对应的url。
 *  @return 签名的数据包
 */
- (NSDictionary *) uploadCompleteCommand:(int) completeType completeId:(NSString *) completeId completeURL:(NSString *) url
{
    NSDictionary *complete = @{@"completeType" : [NSNumber numberWithInt:completeType],
                               @"completeId" : completeId,
                               @"completeUrl" : url};
    return [self appendLoginHead:complete];
}

@end
