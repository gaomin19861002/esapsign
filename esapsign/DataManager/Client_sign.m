//
//  Client_sign.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_sign.h"
#import "Client_sign_flow.h"
#import "DataManager.h"
#import "DataManager+Contacts.h"

@implementation Client_sign

@dynamic refuse_date;
@dynamic sequence;
@dynamic sign_account_id;
@dynamic sign_date;
@dynamic sign_flow_id;
@dynamic sign_id;
@dynamic sign_displayname;
@dynamic sign_address;

@dynamic sign_flow;

/*!
 返回sign对应的User对象
 */
- (Client_contact *)clientContact
{
    return [[DataManager defaultInstance] findUserWithAddress:self.sign_address];
}

/*!
 返回签名人的显示名称
 @return 显示名称
 */
- (NSString *)displayName
{
    if ([self.clientContact.user_name length])
    {
        self.sign_displayname = self.clientContact.user_name;
    }
    return self.sign_displayname;
}

@end
