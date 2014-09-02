//
//  NSString+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-13.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Additions)

/*!
 计算单行显示时，字符串的显示宽度
 */
- (CGSize)singleLineSizeWithFont:(UIFont *)font;

/*!
 处理通讯录标签
 */
- (NSString *)contactLabel;

/*!
 返回路径中的文件名称
 */
- (NSString *)fileNameInPath;

- (BOOL)isNumberString;

@end
