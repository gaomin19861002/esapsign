//
//  CompleteManager.h
//  esapsign
//
//  Created by 苏智 on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompleteManager : NSObject

DefaultInstanceForClassHeader(CompleteManager);

/*!
 文件上传完成的请求包
 @param fileID 文件id
 @param completeType 完成的上传类型。0：文件上传 1：签名图上传
 @return complete 包
 */
- (NSDictionary *)uploadCompleteCommand:(NSString *)fileID completeType:(NSString *)completeType;

/*!
 *  uploadcomplete接口的数据包
 *  @param completeType 完成的上传类型. 0:文件上传、1:签名图上传
 *  @param completeId 完成的上传数据的id
 *  @param url 上传完成对应的url。
 *  @return 签名的数据包
 */
- (NSDictionary *)uploadCompleteCommand:(int) completeType completeId:(NSString *) completeId completeURL:(NSString *) url;

@end
