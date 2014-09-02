//
//  UIImage+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Additions)

@property (nonatomic, retain) NSString  *imgURL;      // 添加图片链接属性

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius;

+ (UIImage *)imageWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor size:(CGSize)size radius:(CGFloat)radius;

+ (UIImage *)imageWithFile:(NSString *)filePath;

@end
