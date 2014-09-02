//
//  ClientContentInEdit.m
//  PdfEditor
//
//  Created by Yi Minwen on 14-6-22.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "ClientContentInEdit.h"
#import "Client_content.h"

@implementation ClientContentInEdit
@synthesize content_id = _content_id;
@synthesize contentType = _contentType;
@synthesize contentValue = _contentValue;
@synthesize major = _major;
@synthesize title = _title;
@synthesize user_id = _user_id;
@synthesize account_id = _account_id;
@synthesize contentTypeName = _contentTypeName;

- (id)initWithClientContent:(Client_content *)item {
    if (self = [super init]) {
        self.content_id = item.content_id;
        self.contentType = item.contentType.integerValue;
        self.contentValue = item.contentValue;
        self.major = item.major.boolValue;
        self.title = item.title;
        self.user_id = item.user_id;
        self.account_id = item.account_id;
    }
    
    return self;
}

- (id)initWithContentTitle:(NSString *)title
               contentType:(UserContentType)contentType
              contentValue:(NSString *)contentVlaue
                     major:(BOOL)major {
    if (self = [super init]) {
        self.contentType = contentType;
        self.contentValue = contentVlaue;
        self.major = major;
        self.title = title;
    }
    
    return self;
}

+ (NSMutableArray *)contentsInEditFromArray:(NSArray *)arrContents {
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:1];
    for (Client_content *item in arrContents) {
        ClientContentInEdit *newItem = [[ClientContentInEdit alloc] initWithClientContent:item];
        [results addObject:newItem];
    }
    
    return results;
}

@end
