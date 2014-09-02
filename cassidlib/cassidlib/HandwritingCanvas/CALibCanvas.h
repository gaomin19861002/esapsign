//
//  CALibCanvas.h
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CALibPath.h"

@interface CALibCanvas : UIView

/*
 * 签名在当前视图frame
 */
@property (nonatomic, readonly, assign) CGRect signFrame;

/**
 *  更新页面(手势移动过程中实时刷新)
 *
 *  @param path 当前笔画
 */
- (void)paintPath:(CALibPath*)path;

/**
 *  当前笔画
 *
 *  @return
 */
- (CALibPath*)lastPath;

/**
 *  完成一笔画
 */
- (void)closePath;

/**
 *  撤销
 */
- (void)undo;

/**
 *  清除
 */
- (void)clear;

/**
 *  恢复(未开放)
 */
//-(void)redo;

/**
 *  保存签名
 *
 *  @return 返回签名图片
 */
- (UIImage*)save;

- (UIImage*)saveWithoutCompress;

/*!
 *  @abstract 重新设置signFrame
 */
- (void)resetSignFrame:(CGRect ) rect;

/*!
 *  @abstract 判断是否有笔画
 */
- (BOOL)isEmpty;

/*!
 *  @abstract 判断是否有笔画
 *  @param image 添加的签名图
 *  @param rect image所在的rect
 */
- (void)setSignImage:(UIImage *) image inRect:(CGRect) rect;

/*!
 *  @abstract 判断是否还有图像，如果含有，表明是图像模式
 */
- (BOOL)hasImage;

/*!
 *  @abstract 清除image
 */
- (void)clearImage;

@end
