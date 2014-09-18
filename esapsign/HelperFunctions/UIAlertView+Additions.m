//
//  UIAlertView+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UIAlertView+Additions.h"

@implementation UIAlertView(Additions)

+ (void)showAlertMessage:(NSString *)message {
    [self showAlertTitle:message message:nil];
}

+ (void)showAlertTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

@end
