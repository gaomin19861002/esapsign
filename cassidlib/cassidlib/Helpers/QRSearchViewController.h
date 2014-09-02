//
//  QRSearchViewController.h
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define QRBorderImageName @"qr_border"
#define QRLineImageName @"qr_line"
#define QRMessageText @"请将二维码/条形码放入框内,即可自动扫描"

@class QRSearchViewController;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 二维码扫描视图控制器代理
@protocol QRSearchDelegate <NSObject>

@optional
/*!
 *  @abstract 二维码扫描取消
 */
- (void) qrSearchViewControllerCanceled:(QRSearchViewController *) searchController;
/*!
 *  @abstract 二维码扫描完成
 */
- (void) qrSearchViewController:(QRSearchViewController *)searchController didFinishedWithString:(NSString *) string;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 二维码扫描视图控制器代理
@interface QRSearchViewController : UIViewController

@property (nonatomic, weak) id<QRSearchDelegate> delegate;


@end
