//
//  UIViewController+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-5-17.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController(Additions)

/*!
 显示锁屏界面
 */
- (void)showProgressText:(NSString *)text;

/*!
 隐藏锁屏界面
 */
- (void)hideProgress;

@end
