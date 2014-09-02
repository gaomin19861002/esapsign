//
//  Util.h
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 通用方法类
 */

@interface Util : NSObject

/*!
 生成一个UUID
 */
+ (NSString *)generalUUID;

/*!
 本地读取指定key的缓存值
 */
+ (id)valueForKey:(NSString *)key;

/*!
 存储一个值到本地
 */
+ (void)setValue:(id)value forKey:(NSString *)key;

@end
