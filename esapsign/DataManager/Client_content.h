//
//  Client_content.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_user;

@class ClientContentInEdit;

@interface Client_content : NSManagedObject

@property (nonatomic, retain) NSString * content_id;
@property (nonatomic, retain) NSNumber * contentType;
@property (nonatomic, retain) NSString * contentValue;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * account_id;
@property (nonatomic, retain) Client_user *clientUser;

/*!
 条目类型名称
 此字段可用title字段替换
 */
@property(nonatomic, copy) NSString *contentTypeName;

@end
