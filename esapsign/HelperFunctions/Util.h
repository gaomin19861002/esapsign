//
//  Util.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-23.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

/*!
 通用方法类
 */

@interface Util : NSObject

/*!
 生成一个UUID
 */
+ (NSString *)generalUUID;

/**
 *  @abstract 得到udid
 */
+ (NSString *) getUDID;

/*!
 本地读取指定key的缓存值
 */
+ (id)valueForKey:(NSString *)key;

/*!
 存储一个值到本地
 */
+ (void)setValue:(id)value forKey:(NSString *)key;

/*!
 当前登录用户信息包
 */
+ (NSDictionary *)currentLoginUserInfo;

+ (User *)currentLoginUser;

+ (NSString*)currentLoginUserId;

@end
