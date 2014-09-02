//
//  UIAlertView+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertView(Additions)

+ (void)showAlertMessage:(NSString *)message;

+ (void)showAlertTitle:(NSString *)title message:(NSString *)message;

@end
