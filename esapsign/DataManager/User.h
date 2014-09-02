//
//  User.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

/**
 * @abstract 用户名
 */
@property(nonatomic, copy) NSString *name;

/**
 * @abstract 密码
 */
@property(nonatomic, copy) NSString *password;

/**
 * @abstract 用户的系统标识
 */
@property(nonatomic, copy) NSString *accountId;

@end
