//
//  Client_contact_item.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_contact_item.h"
#import "Client_contact.h"

@implementation Client_contact_item

@dynamic item_id;
@dynamic contentType;
@dynamic contentValue;
@dynamic major;
@dynamic title;
@dynamic contact_id;
@dynamic account_id;

@dynamic ownerContact;

@synthesize contentTypeName = _contentTypeName;

- (NSString *)contentTypeName
{
    if (!_contentTypeName)
    {
        NSString *name = nil;
        switch ([self.contentType intValue])
        {
            case UserContentTypePhone:
                name = @"电话";
                break;
            case UserContentTypeEmail:
                name = @"邮箱";
                break;
            case UserContentTypeAddress:
                name = @"地址";
                break;
            default:
                break;
        }
        _contentTypeName = [name copy];
    }
    
    return _contentTypeName;
}

@end
