//
//  Client_user.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_content;

@interface Client_user : NSManagedObject

@property (nonatomic, retain) NSString * family_name;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSDate * last_timestamp;
@property (nonatomic, retain) NSString * person_name;
@property (nonatomic, retain) NSDate * selectedDate;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSSet *clientContents;

/*!
 用户名
 */
@property(nonatomic, copy) NSString *user_name;

/*!
 返回指定类型的条目值
 */
- (NSString *)contentWithType:(UserContentType)type useLarge:(bool)useLarge;

/*!
 返回文字类条目
 */
- (NSArray *)showContexts;

/*!
 返回用户的主要标识地址
 */
- (NSString *)majorAddress;

@end

@interface Client_user (CoreDataGeneratedAccessors)

- (void)addClientContentsObject:(Client_content *)value;
- (void)removeClientContentsObject:(Client_content *)value;
- (void)addClientContents:(NSSet *)values;
- (void)removeClientContents:(NSSet *)values;

@end
