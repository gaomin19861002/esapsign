//
//  UIImageAdditions.m
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "UIImageAdditions.h"
#import <objc/runtime.h>

static NSString *keyURL = @"URL";

@implementation UIImage(Additions)

- (NSString *)imgURL {
    return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(keyURL));
}

- (void)setImgURL:(NSString *)imgURL {
    objc_setAssociatedObject(self, (__bridge const void *)(keyURL), imgURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    return [UIImage imageWithColor:color strokeColor:nil size:size radius:0.f];
}

+ (UIImage *)imageWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor size:(CGSize)size {
    return [UIImage imageWithColor:color strokeColor:strokeColor size:size radius:0.f];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    return [UIImage imageWithColor:color strokeColor:nil size:size radius:radius];
}

+ (UIImage *)imageWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor size:(CGSize)size radius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [path addClip];
    
    [color setFill];
    [path fill];
    
    if (strokeColor) {
        path.lineWidth = 1.;
        [strokeColor setStroke];
        [path stroke];
    }
    
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

+ (UIImage *)imageWithFile:(NSString *)filePath {
    if (![filePath length]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    return [UIImage imageWithData:data];
}

@end
