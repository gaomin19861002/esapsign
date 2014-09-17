//
//  DataManager+Contacts.m
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager+Contacts.h"
#import "NSDate+Additions.h"

@implementation DataManager (Contacts)

// 删除所有联系人接口 gaomin@20140815
- (void)clearAllContacts
{
    NSMutableArray* contacts = self.allContacts;
    for (Client_contact *item in contacts)
    {
        [self.objectContext deleteObject:item];
    }
}

// 删除所有联系人条目
- (void)clearAllContactItems
{
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContactItem
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    for (Client_contact_item *item in fetchObjects)
    {
        [self.objectContext deleteObject:item];
    }
}

// 从服务器同步一个联系人对象
- (Client_contact* )syncContact:(NSDictionary*)contactDic andItems:(NSArray*)items
{
    Client_contact* contact = [self fetchContact:[contactDic objectForKey:@"id"]];
    if (contact == nil)
    {
        contact = (Client_contact *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientContact
                                                                  inManagedObjectContext:self.objectContext];
        contact.contact_id = [contactDic objectForKey:@"id"];
        [self.objectContext insertObject:contact];
    }
    
    contact.family_name = [contactDic objectForKey:@"familyName"];
    contact.person_name = [contactDic objectForKey:@"personName"];
    //contact.image_filepath
    //contact.gender
    NSDate *date = nil;

    if ([[contactDic objectForKey:@"lastTimeStamp"] isEqualToString:@""])
    {
        NSLog(@"Warning: It should not to be an empty value in contact last timestamp!");
        date = [NSDate convertDateToLocalTime:[NSDate date]];
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [dateFormatter dateFromString:[contactDic objectForKey:@"lastTimeStamp"]];
    }
    contact.last_timestamp = date;
    
    [self clearAllItemsInContact:contact];
    
    // Items
    for (NSDictionary *itemDic in items)
    {
        Client_contact_item* item = [self syncContactItem:itemDic];
        item.contact_id = contact.contact_id;
        item.clientContact = contact;
    }
    
    return contact;
}

// 从服务器同步一个联系人条目对象
- (Client_contact_item* )syncContactItem:(NSDictionary*)contactItemDic
{
    Client_contact_item* contactItem = [self fetchContactItem:[contactItemDic objectForKey:@"id"]];
    if (contactItem == nil)
    {
        contactItem = (Client_contact_item *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientContactItem
                                                                           inManagedObjectContext:self.objectContext];
        contactItem.item_id = [contactItemDic objectForKey:@"id"];
        [self.objectContext insertObject:contactItem];
    }
    
    contactItem.account_id = [contactItemDic objectForKey:@"accountId"];
    contactItem.title = [contactItemDic objectForKey:@"title"];
    contactItem.contentType = [NSNumber numberWithInt:[[contactItemDic objectForKey:@"type"] intValue]];
    contactItem.contentValue = [contactItemDic objectForKey:@"content"];
    contactItem.major = [NSNumber numberWithInt:[[contactItemDic objectForKey:@"major"] intValue]];

    return contactItem;
}

#pragma mark - Contact Search

// 根据id找对应的联系人
- (Client_contact *) findContactWithId:(NSString *) contact_id
{
    return [self fetchContact:contact_id];
}

// 根据Address找对应的用户
- (Client_contact *) findUserWithAddress:(NSString *) address
{
    for (Client_contact *contact in self.allContacts)
    {
        for (Client_contact_item *item in contact.clientItems)
        {
            if ([item.contentValue isEqualToString:address])
                return contact;
        }
    }
    return nil;
}

// 获取5个常用联系人
- (NSArray *)lastestConstacts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_used != NULL"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"last_used" ascending:NO];
    return [self arrayFromCoreData:EntityClientContact
                         predicate:predicate
                             limit:5
                            offset:0
                           orderBy:sort];
}


#pragma mark - Contact operations

// 创建一个联系人基本信息字典
- (NSMutableDictionary *)createDefaultContactValue
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date = [[NSDate convertDateToLocalTime:[NSDate date]] fullDateString];
    
    NSMutableDictionary* contactDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [Util generalUUID], @"id",
                                [[NSNumber numberWithInt:0] stringValue], @"gender",
                                @"", @"familyName",
                                @"", @"personName",
                                date, @"lastTimeStamp", nil];
    return contactDic;
}

// 创建一个默认的联系人条目信息
- (NSMutableDictionary*)createDefaultContactItemValue
{
    NSMutableDictionary* itemDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [Util generalUUID], @"id",
                             [NSString stringWithFormat:@"%d", UserContentTypeEmail], @"type",
                             @"邮箱", @"title",
                             @"", @"content",
                             @"0", @"major", nil];
    return itemDic;
}

// 将一个Client_contact_item对象打包回字典
- (NSMutableDictionary*)createContactItemValueByItem:(Client_contact_item*) item
{
    NSMutableDictionary* itemDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             item.item_id, @"id",
                             [item.contentType stringValue], @"type",
                             item.title, @"title",
                             item.contentValue, @"content",
                             [item.major stringValue], @"major", nil];
    return itemDic;
}

// 直接添加一个通讯录用户
- (Client_contact *)addContactByPersonName:(NSString *)firstName familyName:(NSString *)lastName
{
    Client_contact *user = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContact
                                                         inManagedObjectContext:self.objectContext];
    user.contact_id = [Util generalUUID];
    user.person_name = firstName;
    user.family_name = lastName;

    [self.objectContext insertObject:user];
    
    return user;
}

// 直接添加一条通讯录用户条目
- (void)addContactItem:(Client_contact *)contact
           itemAccount:(NSString *)accountId
             itemTitle:(NSString *)title
              itemType:(UserContentType)contentType
             itemValue:(NSString *)contentVlaue
               isMajor:(BOOL)major
{
    Client_contact_item *item = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContactItem
                                                                 inManagedObjectContext:self.objectContext];
    item.contact_id = contact.contact_id;
    item.item_id = [Util generalUUID];
    item.contentType = @(contentType);
    item.contentValue = contentVlaue;
    item.clientContact = contact;
    item.major = @(major);
    item.title = title;
    [self.objectContext insertObject:item];
}

// 删除联系人(By Yi Minwen)
- (void)deleteClientUser:(Client_contact *)client
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contact_id==%@", client.contact_id];
    NSArray *contacts = [self arrayFromCoreData:EntityClientContact
                                     predicate:predicate
                                         limit:NSUIntegerMax
                                        offset:0
                                       orderBy:nil];
    

    for (Client_contact *contact in contacts)
    {
        [self clearAllItemsInContact:contact];
        [self.objectContext deleteObject:contact];
    }
}

#pragma mark - Private functions

- (Client_contact*)fetchContact:(NSString*) contactID
{
    Client_contact *contact = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contact_id==%@", contactID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContact
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        contact = [fetchObjects firstObject];
    return contact;
}

- (Client_contact_item*)fetchContactItem:(NSString*) contactItemID
{
    Client_contact_item *contactItem = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item_id==%@", contactItemID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContactItem
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        contactItem = [fetchObjects firstObject];
    return contactItem;
}

// 清除指定Client_user的所有联系方式
- (void) clearAllItemsInContact:(Client_contact *)contact
{
    for (Client_contact_item *content in contact.clientItems)
    {
        //[self.objectContext refreshObject:content mergeChanges:YES];
        [self.objectContext deleteObject:content];
    }
}


@end
