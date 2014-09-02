//
//  Util.m
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Util.h"

@implementation Util

/*!
 生成一个UUID
 */
+ (NSString *)generalUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidRef = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    NSString *uuidString = (__bridge NSString *)uuidRef;
    return uuidString;
}

/*!
 本地读取指定key的缓存值
 */
+ (id)valueForKey:(NSString *)key {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    return [nd valueForKey:key];
}

/*!
 存储一个值到本地
 */
+ (void)setValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    [nd setObject:value forKey:key];
    [nd synchronize];
}

@end
