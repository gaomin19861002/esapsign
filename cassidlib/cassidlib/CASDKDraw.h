//
//  CADrawViewController.h
//  cassidlib
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "datatypes.h"

@class CASDKDraw;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 绘图接口类的代理方法
@protocol CASDKDrawDelegate <NSObject>

@optional

/**
 * @abstract 该代理方法用于处理得到签名后的静态图像的处理
 */
- (void)CASDKDraw:(CASDKDraw *)controller getDrawImage:(UIImage *)image;

/**
 * @abstract 该代理方法用于完成操作后的处理
 */
- (void)CASDKDrawComplete:(CASDKDraw *)controller;

/**
 * @abstract 该代理方法用于完成二维码扫描操作后的处理
 */
- (void)CASDKDraw:(CASDKDraw *)controller getScanCode:(NSString*)resultString;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 绘图接口类
@interface CASDKDraw : NSObject

@property (assign, nonatomic) CGRect imageRect;

/**
 * @abstract 设置画笔颜色
 */
+ (void)setPaintColor:(UIColor*)color;

/**
 * @abstract 设置笔触效果
 */
+ (void)setPenStyle:(PenStyle)style lineWidth:(float)lineWidth widthRange:(float)widthRange;



#pragma mark - Object member

/**
 * @abstract 代理成员
 */
@property (assign, nonatomic) id<CASDKDrawDelegate> delegate;

/**
 * @abstract 初始化接口类，赋予其一个UIView对象用于展示
 */
- (id)initWithBundleView:(UIView*)view;

/**
 * @abstract 清除操作
 */
- (void)clearTool;

/**
 * @abstract 撤销操作
 */
- (void)undoTool;

/**
 * @abstract 完成操作
 */
- (void)completeTool;

/**
 * @abstract 二维码扫描操作
 */
- (void)scanTool;

/**
 * @abstract 添加预置图形操作
 */
- (void)addImageTool:(UIImage*)image inRect:(CGRect)frame;

/**
 * @abstract 判断画板是否为空
 */
- (bool)isEmptyCanvas;

@end
