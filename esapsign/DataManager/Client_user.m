//
//  Client_user.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_user.h"
#import "Client_content.h"


@implementation Client_user

@dynamic family_name;
@dynamic gender;
@dynamic last_timestamp;
@dynamic person_name;
@dynamic selectedDate;
@dynamic user_id;
@dynamic clientContents;
@synthesize user_name = _user_name;


- (NSString *)user_name
{
    // 在用户姓名发生变更时，此处无法及时更新，因此每次都用最新的
//    if (!_user_name) {
        NSString *personName = self.person_name == nil ? @"" : self.person_name;
        NSString *familyName = self.family_name == nil ? @"" : self.family_name;
        _user_name = [[NSString stringWithFormat:@"%@%@", familyName, personName] copy];
//    }
    
    return _user_name;
}

/*!
 返回指定类型的条目值
 */
- (NSString *)contentWithType:(UserContentType)type useLarge:(bool)useLarge
{
    for (Client_content *context in self.clientContents) {
        if ([context.contentType intValue] == type) {
            return context.contentValue;
        }
    }
    
    NSString *filePath = nil;
    if (type == UserContentTypePhoto) {
        // 返回默认图片
        filePath = useLarge ? @"IconHeadBig" : @"IconHead";
    }
    
    return filePath;
}

/*!
 返回文字类条目
 */
- (NSArray *)showContexts
{
    NSMutableArray *showContext = [[NSMutableArray alloc] init];
    
    for (Client_content *context in self.clientContents)
    {
        if ([context.contentType intValue] != UserContentTypePhoto)
        {
            [showContext addObject:context];
        }
    }
    [showContext sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
        Client_content *content1 = (Client_content *)obj1;
        Client_content *content2 = (Client_content *)obj2;
        
        if ([content1.contentType intValue] < [content2.contentType intValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    return showContext;
}

/*!
 返回用户的主要标识地址
 */
- (NSString *)majorAddress {
    for (Client_content *content in self.clientContents) {
        if ([content.account_id length]) {
            return content.contentValue;
        }
    }
    
    for (Client_content *content in self.clientContents) {
        if ([content.major boolValue]) {
            return content.contentValue;
        }
    }
    
    for (Client_content *content in self.clientContents) {
        if ([content.contentType intValue] == UserContentTypePhone) {
            return content.contentValue;
        }
    }
    
    for (Client_content *content in self.clientContents) {
        if ([content.contentType intValue] == UserContentTypeEmail) {
            return content.contentValue;
        }
    }
    
    return nil;
}

@end
