//
//  UIDevice+Addiotions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UIDevice+Addiotions.h"

@implementation UIDevice(Addiotions)

- (NSUInteger)deviceSystemMajorVersion {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion =
        [[[[[UIDevice currentDevice] systemVersion]
           componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

@end
