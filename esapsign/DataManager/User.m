//
//  User.m
///  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithCoder: (NSCoder *)coder
{
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.password = [coder decodeObjectForKey:@"password"];
        self.accountId = [coder decodeObjectForKey:@"accountId"];
    }
    
    return self;
}

- (void)encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.accountId forKey:@"accountId"];
}

@end
