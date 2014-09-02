//
//  QRCodeViewController.h
//  PdfEditor
//
//  Created by Caland on 14-7-28.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class QRCodeViewController;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  二维码扫描协议
@protocol QRCodeViewControllerDelegate <NSObject>
@optional

- (void) qrCodeVideControllerCanceledSearch:(QRCodeViewController *) qrCodeViewController;

- (void) qrCodeVideController:(QRCodeViewController *) qrCodeViewController didFinishedWithString:(NSString *) str;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  二维码扫描视图控制器
@interface QRCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL isDown;
}
@property (nonatomic, retain) AVCaptureDevice *device;
@property (nonatomic, retain) AVCaptureDeviceInput *input;
@property (nonatomic, retain) AVCaptureMetadataOutput *output;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, retain) id<QRCodeViewControllerDelegate> delegate;


@property (nonatomic, retain) IBOutlet UIImageView *line;

@end
