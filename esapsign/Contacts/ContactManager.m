//
//  ContactManager.m
//  PdfEditor
//
//  Created by MinwenYi on 14-3-31.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "ContactManager.h"
#import <AddressBook/AddressBook.h>

#import "Client_contact.h"
#import "Client_contact_item.h"
#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "Util.h"
#import "NSString+Additions.h"
#import "User.h"
#import "ActionManager.h"


@implementation ContactManager

DefaultInstanceForClass(ContactManager);

// 从系统通讯录中导入用户信息
- (void)importAddressBook
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (!accessGranted)
    {
        return ;
    }
    
    //如果没有授权则退出
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
        return ;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        for (int i = 0; i < CFArrayGetCount(results); i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(results, i);
            NSString* ContactName = @"";
            
            // 读取firstname
            NSString *personName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            if (personName != nil)
                ContactName = [ContactName stringByAppendingFormat:@"%@ ",personName];
            
            // 读取middlename
            NSString *familyName = @"";
            NSString *middlename = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
            if(middlename != nil)
                familyName = [familyName stringByAppendingFormat:@"%@ ",middlename];
            
            //读取lastname
            NSString *lastname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
            if(lastname != nil)
                familyName = [familyName stringByAppendingFormat:@"%@ ",lastname];
            if ([ContactName hasSuffix:@" "])
                ContactName = [ContactName substringToIndex:ContactName.length - 1];
            if ([familyName hasSuffix:@" "])
                familyName = [familyName substringToIndex:familyName.length - 1];
            
            Client_contact *user = nil;
            // 读取邮件地址，判定是否之前已导入过
            ABMultiValueRef emailsToRead = ABRecordCopyValue(person, kABPersonEmailProperty);
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(emailsToRead) + ABMultiValueGetCount(phone) == 0)
            {
                // 抛弃没有电话号码跟邮箱的数据
                continue;
            }
            
            for (int k = 0; k < ABMultiValueGetCount(emailsToRead); k++)
            {
                NSString *email = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emailsToRead, k));
                if ([email length])
                {
                    user = [[DataManager defaultInstance] findUserWithAddress:email];
                    //如果存在用户，就跳出循环
                    if (user)
                        break;
                }
            }
            //根据手机号之判断是否存在用户
            if (!user)
            {
                //读取电话多值
                for (int k = 0; k < ABMultiValueGetCount(phone); k++)
                {
                    NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
                    if ([personPhone length])
                    {
                        user = [[DataManager defaultInstance] findUserWithAddress:personPhone];
                        if (user)
                            break;
                    }
                }
            }
            if (!user)
            {
                // 都没有，重新生成
                user = [[DataManager defaultInstance] addContactByPersonName:ContactName familyName:familyName];
            }
            else
            {
                // 已经导入过的用户则只更新昵称
                user.family_name = familyName;
                user.person_name = ContactName;
                continue;
            }
            
            NSLog(@"%s,%@,%@, %@", __FUNCTION__, personName, middlename, lastname);
            //这里是添加用户
            for (int k = 0; k < ABMultiValueGetCount(phone); k++)
            {
                NSString * label = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phone, k));
                NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
                
                if ([personPhone length])
                {
                    [[DataManager defaultInstance] addContactItem:user
                                                      itemAccount:@""
                                                        itemTitle:[label contactLabel]
                                                         itemType:UserContentTypePhone
                                                        itemValue:personPhone
                                                          isMajor:NO];
                }
            }
            
            // 读取邮件地址，选取第一个邮件地址为major
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (int k = 0; k < ABMultiValueGetCount(emails); k++)
            {
                NSString *email = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, k));
                NSString * label = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(emails, k));
                if ([email length])
                {
                    BOOL isMajor = k > 0 ? NO : YES;
                    [[DataManager defaultInstance] addContactItem:user
                                                      itemAccount:@""
                                                        itemTitle:[label contactLabel]
                                                         itemType:UserContentTypeEmail
                                                        itemValue:email
                                                          isMajor:isMajor];
                }
            }
            
            // 读取通讯地址
            ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
            for (int k = 0; k < ABMultiValueGetCount(addresses); k++)
            {
                NSString * label = (NSString *)CFBridgingRelease(ABMultiValueCopyLabelAtIndex(addresses, k));
                NSMutableString *address = [NSMutableString string];
                NSDictionary *addressDict = (NSDictionary *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(addresses, k));
                NSString *country = [addressDict objectForKey:(NSString *)kABPersonAddressCountryKey];
                if ([country length]) {
                    [address appendString:country];
                }
                
                NSString *province = [addressDict objectForKey:(NSString *)kABPersonAddressStreetKey];
                if ([province length]) {
                    [address appendString:province];
                }
                
                NSString *city = [addressDict objectForKey:(NSString *)kABPersonAddressCityKey];
                if ([city length]) {
                    [address appendString:city];
                }
                
                NSString *street = [addressDict objectForKey:(NSString *)kABPersonAddressZIPKey];
                if ([street length]) {
                    [address appendString:street];
                }
                
                if ([address length]) {
                    [[DataManager defaultInstance] addContactItem:user
                                                      itemAccount:@""
                                                        itemTitle:[label contactLabel]
                                                         itemType:UserContentTypeAddress
                                                        itemValue:address
                                                          isMajor:NO];
                }
            }
            
            // 读取图像信息
            if ((BOOL)ABPersonHasImageData(person))
            {
                NSData *imageData = (NSData *)CFBridgingRelease(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize));
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", [DataManager defaultInstance].userPath, user.contact_id];
                [imageData writeToFile:filePath atomically:YES];
                user.image_filepath = filePath;
            }
            
            // 生成action
            NSDictionary *action = [[ActionManager defaultInstance] contactNewAction:user];
            [[ActionManager defaultInstance] addToQueue:action sendAtOnce:NO];//添加到队列中但不立即提交
        }
        
        // 设置一个合理的时机发送可能迟滞的Action
        [[ActionManager defaultInstance] sendQueueAtOnce];
        
        CFRelease(results);
        CFRelease(addressBook);
        // 增加导入过标记
        NSData *userData = [Util valueForKey:LoginUser];
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        // 标记已经导入过通讯录
        [Util setValue:@"1" forKey:user.name];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DataManager defaultInstance] syncContactCache];
            [[NSNotificationCenter defaultCenter] postNotificationName:ContactImportSucceedNotification object:nil];
        });
    });
}


@end
