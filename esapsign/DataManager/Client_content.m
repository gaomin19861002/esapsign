//
//  Client_content.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_content.h"
#import "Client_user.h"
#import "ClientContentInEdit.h"


@implementation Client_content

@dynamic content_id;
@dynamic contentType;
@dynamic contentValue;
@dynamic major;
@dynamic title;
@dynamic user_id;
@dynamic account_id;
@dynamic clientUser;
@synthesize contentTypeName = _contentTypeName;

- (NSString *)contentTypeName
{
    if (!_contentTypeName)
    {
        NSString *name = nil;
        switch ([self.contentType intValue])
        {
            case UserContentTypeName:
                name = @"姓名";
                break;
            case UserContentTypePhone:
                name = @"电话";
                break;
            case UserContentTypeEmail:
                name = @"邮箱";
                break;
            case UserContentTypeAddress:
                name = @"地址";
                break;
            case UserContentTypePhoto:
                name = @"照片";
                break;
                
            default:
                break;
        }
        _contentTypeName = [name copy];
    }
    
    return _contentTypeName;
}
@end
