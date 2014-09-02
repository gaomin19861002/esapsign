//
//  UIColor+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-2.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor(Additions)

/*!
 生成颜色的快速方法。参数取数范围为0~255而不是系统方法的0~1。
 @param red 红色，取数范围为0~255
 @param green 绿色，取数范围为0~255
 @param blue 蓝色，取数范围为0~255
 @param alpha 透明程度，取数范围为0~255
 */
+ (UIColor *)colorWithR:(int)red G:(int)green B:(int)blue A:(int)alpha;

/*!
 生成颜色的快速方法。。
 @param hexString  "0xffffff"
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
