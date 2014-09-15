//
//  DataManager+Contacts.h
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (Contacts)

// 删除所有联系人(By gaomin)
- (void)clearAllContacts;

// 删除所有联系人条目
- (void)clearAllContactItems;

// 从服务器同步一个联系人对象
- (Client_contact* )syncContact:(NSDictionary*)contactDic andItems:(NSArray*)items;


// 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
//  @param  contentType:条目类型（0：email，1：电话号码，2：文字信息）
//  @return Client_user对象，如果没找到，则返回nil。
- (Client_contact *)syncContact:(NSString *)contentType andValue:(NSString *) contentValue;


// 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
- (Client_contact *)syncSignContact:(NSString *)address displayName:(NSString *)displayName;

// 将一组签名包数据内容合并到当前通讯录
- (Client_contact *)mergeSignContactByAddress:(NSString *)address displayName:(NSString *)displayName userid:(NSString *) userid;


// 根据id找对应的联系人
- (Client_contact *)findContactWithId:(NSString *) contact_id;

// 根据Address找对应的用户
- (Client_contact *)findUserWithAddress:(NSString *) address;

// 获取5个常用联系人
- (NSArray *)lastestConstacts;

// 创建一个联系人基本信息字典
- (NSDictionary* )createDefaultContactValue;

// 创建一个默认的联系人条目信息
- (NSDictionary*)createDefaultContactItemValue;

// 将一个Client_contact_item对象打包回字典
- (NSDictionary*)createContactItemValueByItem:(Client_contact_item*) item;

// 通过添加姓名开始创建一个通讯录用户
- (Client_contact *)addContactByPersonName:(NSString *)personName familyName:(NSString *)familyName;

// 直接添加一条通讯录用户条目
- (void)addContactItem:(Client_contact *)contact
           itemAccount:(NSString *)accountId
             itemTitle:(NSString *)title
              itemType:(UserContentType)contentType
             itemValue:(NSString *)contentVlaue
               isMajor:(BOOL)major;

// 删除联系人(By Yi Minwen)
- (void)deleteClientUser:(Client_contact *)user;

@end