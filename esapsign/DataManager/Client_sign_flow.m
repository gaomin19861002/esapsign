//
//  Client_sign_flow.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_sign_flow.h"
#import "Client_file.h"
#import "Client_sign.h"
#import "DataManager.h"

@implementation Client_sign_flow

@dynamic sign_flow_id;
@dynamic current_sequence;
@dynamic current_sign_id;
@dynamic current_sign_status;
@dynamic status;

@dynamic clientSigns;

/*!
 返回文件的所有签名人，按照签名流程的顺序返回
 */
- (NSArray *)sortedSignFlows
{
    NSMutableArray *signFlows = [NSMutableArray array];
    for (Client_sign * sign in self.clientSigns)
    {
        [signFlows addObject:sign];
    }
    
    [signFlows sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Client_sign *sign1 = (Client_sign *)obj1;
        Client_sign *sign2 = (Client_sign *)obj2;
        if ([sign1.sequence intValue] < [sign2.sequence intValue]) {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    return signFlows;
}

/*!
 判断一个sign是否是当前要执行的sign
 */
- (bool)isActiveSign:(Client_sign*)sign
{
    if (sign == nil || sign.sign_flow_id != self.sign_flow_id)
        return NO;
    
    // 如果当前签名ID匹配
    if ([self.current_sign_id isEqualToString:sign.sign_id]
        // 或者是在当前签名ID未设置的状态下，当前签名的顺序号匹配
        || ((self.current_sign_id == nil || [self.current_sign_id isEqualToString:@""]) && (self.current_sequence == sign.sequence)))
        return YES;
    
    return NO;
}

- (Client_sign *)addUserToSignFlow:(NSString *)userName address:(NSString *)address
{
    return [[DataManager defaultInstance] addFileSignFlow:self displayName:userName address:address];
}

@end
