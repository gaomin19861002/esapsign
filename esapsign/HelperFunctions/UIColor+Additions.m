//
//  UIColor+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-2.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor(Additions)

+ (UIColor *)colorWithR:(int)red G:(int)green B:(int)blue A:(int)alpha {
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha / 255.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#"
                                                     withString: @""];
    
    if ([hexString length] < 6) {
        return nil;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-fA-F|0-9]" options:0 error:NULL];
    NSUInteger match = [regex numberOfMatchesInString:hexString options:NSMatchingReportCompletion range:NSMakeRange(0, [hexString length])];
    if (match != 0) {
        return nil;
    }
    
    NSRange range = NSMakeRange(0, 2);
    unsigned * pval = nil;
    NSString *component = [hexString substringWithRange:range];
    [[NSScanner scannerWithString:component] scanHexInt:pval];
    float rRetVal = (*pval) / 255.f;
    
    range.location += 2;
    component = [hexString substringWithRange:range];
    [[NSScanner scannerWithString:component] scanHexInt:pval];
    float gRetVal = (*pval) / 255.f;
    
    range.location += 2;
    component = [hexString substringWithRange:range];
    [[NSScanner scannerWithString:component] scanHexInt:pval];
    float bRetVal = (*pval) / 255.f;
    
    return [UIColor colorWithRed:rRetVal green:gRetVal blue:bRetVal alpha:1.0f];
}

@end
