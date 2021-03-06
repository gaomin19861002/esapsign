//
//  Util.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-23.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "Util.h"
#import "User.h"
//#import "OpenUDID.h"

@implementation Util

/*!
 生成一个UUID
 */
+ (NSString *)generalUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidRef = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    NSString *uuidString = (NSString *)CFBridgingRelease(uuidRef);
    return uuidString ;
}

/**
 *  @abstract 得到udid
 */
+ (NSString *) getUDID
{
    UIDevice *device=[UIDevice currentDevice];
    return [NSString stringWithFormat:@"%@_%@", device.name, device.identifierForVendor.UUIDString];
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
/*!
 存储一个值到本地
 */
+ (void)setValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    [nd setObject:value forKey:key];
    [nd synchronize];
}

/*!
 当前登录用户信息包
 */
+ (NSDictionary *)currentLoginUserInfo {
    NSData *userData = [self valueForKey:LoginUser];
    if (userData) {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        NSDictionary *dict = @{@"alias" : user.name,
                               @"password":user.password,
                               @"id" : [Util generalUUID],
                               @"type": @"0",
                               @"requireCert": @"0",
                               @"deviceId" : [Util getUDID],
                               @"deviceType": @"2" };
        return dict;
    }
    
    return nil;
}

+ (User *)currentLoginUser {
    NSData *userData = [self valueForKey:LoginUser];
    if (userData) {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        return user;
    }
    
    return nil;
}

+ (NSString*)currentLoginUserId
{
    NSData *userData = [self valueForKey:LoginUser];
    if (userData) {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        return user.accountId;
    }
    
    return 0;
}

@end
