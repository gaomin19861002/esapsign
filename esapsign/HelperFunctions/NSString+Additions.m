//
//  NSString+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-13.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString(Additions)

/*!
 计算单行显示时，字符串的显示宽度
 */
- (CGSize)singleLineSizeWithFont:(UIFont *)font
{
    CGSize size = CGSizeZero;
    if (IsIOS7OrLater()) {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName: font} context:nil];
        size = rect.size;
    } else {
        CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName: font} context:nil];
        size = rect.size;
        //size = [self sizeWithFont:font];
    }
    
    return size;
}

/*!
 处理通讯录标签 _$!<Mobile>!$_ 处理成Mobile
 */
- (NSString *)contactLabel {
    if ([self length] < 8) {
        return nil;
    }
    int len = [self length];
    return [self substringWithRange:NSMakeRange(4, len - 8)];
}

/*!
 返回路径中的文件名称
 */
- (NSString *)fileNameInPath {
    if (![self length]) {
        return nil;
    }
    
    NSArray *components = [self componentsSeparatedByString:@"/"];
    if (![components count]) {
        return nil;
    }
    
    return [components lastObject];
}

- (BOOL)isNumberString {
    NSString *regex = @"\\d+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([predicate evaluateWithObject:self]) {
        
        return YES;
    }
    
    return NO;
}

@end
