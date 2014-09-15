//
//  Client_user.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_contact.h"
#import "Client_contact_item.h"
#import "DataManager+Contacts.h"

@implementation Client_contact

@dynamic family_name;
@dynamic gender;
@dynamic last_used;
@dynamic last_timestamp;
@dynamic person_name;
@dynamic contact_id;
@dynamic clientItems;
@dynamic image_filepath;
@synthesize user_name = _user_name;

- (NSString *)user_name
{
    NSString *personName = self.person_name == nil ? @"" : self.person_name;
    NSString *familyName = self.family_name == nil ? @"" : self.family_name;
    _user_name = [NSString stringWithFormat:@"%@%@", familyName, personName];
    return _user_name;
}

/*!
 返回头像
 */
- (NSString *)headIconUseLarge:(bool)useLarge
{
    if (self.image_filepath != nil)
        return self.image_filepath;
    NSString *filePath = useLarge ? @"IconHeadBig" : @"IconHead";
    return filePath;
}

/*!
 返回条目
 */
- (NSArray *)showContents
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (Client_contact_item *item in self.clientItems)
    {
        NSDictionary* itemDic = [[DataManager defaultInstance] createContactItemValueByItem:item];
        [items addObject:itemDic];
    }

    [items sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSDictionary *content1 = (NSDictionary *)obj1;
        NSDictionary *content2 = (NSDictionary *)obj2;
        if ([[content1 objectForKey:@"content"] intValue] < [[content2 objectForKey:@"content"] intValue])
            return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    return items;
}

/*!
 返回用户的主要标识地址
 */
- (NSString *)majorAddress
{
    // 优先返回指定的主要地址
    for (Client_contact_item *content in self.clientItems)
    {
        if ([content.major boolValue])
            return content.contentValue;
    }

    // 没有指定的优先地址时，返回有账号关联的地址
    for (Client_contact_item *content in self.clientItems)
    {
        if ([content.account_id length] > 0
            && [content.contentType intValue] != UserContentTypeAddress)
        {
            return content.contentValue;
        }
    }
    
    return nil;
}

@end

@implementation Client_contact (compare)

- (NSComparisonResult)compare:(Client_contact*)otherUser
{
    Client_contact *curUser = (Client_contact *)self;
    NSComparisonResult result = [curUser.user_name compare:otherUser.user_name];
    return result == NSOrderedDescending;
}

@end