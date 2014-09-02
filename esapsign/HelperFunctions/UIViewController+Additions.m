//
//  UIViewController+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-5-17.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UIViewController+Additions.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

#define ProgressHUDKey  @"progressHUD"

@implementation UIViewController(Additions)

/*!
 显示锁屏界面
 */
- (void)showProgressText:(NSString *)text {
    MBProgressHUD *progressHUD = objc_getAssociatedObject(self, ProgressHUDKey);
    if (progressHUD) {
        [progressHUD setHidden:YES];
        objc_removeAssociatedObjects(progressHUD);
    }
    
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    progressHUD.removeFromSuperViewOnHide = YES;
    if (![text length]) {
        progressHUD.labelText = @"加载中...";
    } else {
        progressHUD.labelText = text;
    }
    [progressHUD show:YES];
    
    objc_setAssociatedObject(self, ProgressHUDKey, progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*!
 隐藏锁屏界面
 */
- (void)hideProgress {
    MBProgressHUD *progressHUD = objc_getAssociatedObject(self, ProgressHUDKey);
    if (progressHUD) {
        [progressHUD setHidden:YES];
        objc_removeAssociatedObjects(progressHUD);
    }
}

@end
