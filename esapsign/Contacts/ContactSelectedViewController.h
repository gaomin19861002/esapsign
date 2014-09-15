//
//  ContactSelectedViewController.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-17.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Client_contact;
@class ContactSelectedViewController;
@protocol ContactSelectedViewControllerDelegate<NSObject>

/*!
 点击确定按钮，通知外部程序，外部需要调用dismiss退出当前页
 */
- (void)confirmSelectUser:(ContactSelectedViewController *)controller
                 userName:(NSString *)userName
                  address:(NSString *)address;

@end

@interface ContactSelectedViewController : UIViewController

@property(nonatomic, assign) id<ContactSelectedViewControllerDelegate> delegate;

@end
