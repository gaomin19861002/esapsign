//
//  Client_sign.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_sign_flow;
@class Client_contact;

@interface Client_sign : NSManagedObject

@property (nonatomic, retain) NSDate * refuse_date;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSString * sign_account_id;
@property (nonatomic, retain) NSDate * sign_date;
@property (nonatomic, retain) NSString * sign_flow_id;
@property (nonatomic, retain) NSString * sign_id;
@property (nonatomic, retain) NSString * sign_displayname;
@property (nonatomic, retain) NSString * sign_address;

@property (nonatomic, retain) Client_sign_flow *ownerFlow;

/*!
 返回sign对应的User对象
 */
- (Client_contact *)clientContact;

/*!
 返回签名人的显示名称
 @return 显示名称
 */
- (NSString *)displayName;

@end
