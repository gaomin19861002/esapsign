//
//  Client_contact.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_contact_item;

@interface Client_contact : NSManagedObject

@property (nonatomic, retain) NSString * contact_id;
@property (nonatomic, retain) NSString * image_filepath;
@property (nonatomic, retain) NSString * family_name;
@property (nonatomic, retain) NSString * person_name;
@property (nonatomic, retain) NSNumber * gender;

@property (nonatomic, retain) NSDate * last_timestamp;
@property (nonatomic, retain) NSDate * last_used;

@property (nonatomic, retain) NSSet *clientItems;

// 用户名
@property (nonatomic, copy) NSString *user_name;

// 用户头像
- (NSString *)headIconUseLarge:(bool)useLarge;

// 通讯条目
- (NSArray *)showContents;

// 返回用户的主要标识地址
- (NSString *)majorAddress;

@end

@interface Client_contact (CoreDataGeneratedAccessors)

- (void)addClientItemsObject:(Client_contact_item *)value;
- (void)removeClientItemsObject:(Client_contact_item *)value;
- (void)addClientItems:(NSSet *)values;
- (void)removeClientItems:(NSSet *)values;

@end

@interface Client_contact (compare)

- (NSComparisonResult)compare:(Client_contact *)otherUser;

@end
