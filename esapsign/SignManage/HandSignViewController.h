//
//  HandSignViewController.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "cassidlib.h"

@class HandSignViewController;

@protocol HandSignViewControllerDelegate <NSObject>

@optional

- (void)HandSignViewController:(HandSignViewController *)controller DidFinishSignWithImage:(UIImage *)image;

- (void)HandSignViewController:(HandSignViewController *)controller qrFinishSignWithImage:(UIImage *)image;

@end

/**
 * 手写签名页(包括新增签名和直接签名)
 */
@interface HandSignViewController : UIViewController <CASDKDrawDelegate>

@property (strong, nonatomic) IBOutlet UIView *drawCanvas;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundView;

@property (assign, nonatomic) id<HandSignViewControllerDelegate> delegate;

@property (nonatomic, assign) CGRect imageRect;

/**
 * @abstract Operating buttons' actions
 */
- (IBAction)colorSelected:(id)sender;
- (IBAction)penSelected:(id)sender;

/**
 * Command buttons' actions
 */
- (IBAction)toolClear:(id)sender;
- (IBAction)toolUndo:(id)sender;
- (IBAction)toolSubmit:(id)sender;

- (IBAction)CameraBtnClicked:(id)sender;
- (IBAction)PhotoLibBtnClicked:(id)sender;

/**
 *  @abstract 二维码扫描按钮点击处理事件，发生在手写签名后，应用于上传签名图到网络端
 */
- (IBAction) qrcodeSearch:(id)sender;

@end
