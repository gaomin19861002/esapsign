//
//  QRCodeViewController.m
//  PdfEditor
//
//  Created by Caland on 14-7-28.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "QRCodeViewController.h"
#import "UIColor+Additions.h"


@interface QRCodeViewController ()

@property (nonatomic, retain) NSTimer *timer;

/*!
 定义导航栏左侧按钮
 */
@property(nonatomic, retain) UIBarButtonItem *leftBarItem;

@end

@implementation QRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //退回按钮
    if (self.navigationController) {
        self.title = @"二维码扫描";
        self.navigationItem.leftBarButtonItem = self.leftBarItem;
//        _blackPicker.layer.cornerRadius = 51.0;
    }
    
    //修改view的contentInset
    self.view.contentMode = UIViewContentModeTop;
    
    num = 0;
    isDown = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(lineAnimanate) userInfo:nil repeats:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];

    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.rectOfInterest = CGRectMake(0.1, 0.1, 0.8, 0.8);//设置取值的范围，就是扫描的范围。
    
    self.session = [[AVCaptureSession alloc] init];
    //    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    _preview.frame = self.view.frame;
    CGRect rect = CGRectMake(0, 0, 1024, 1024);
    _preview.frame = rect;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        _preview.frame = CGRectMake(0, 0, 768, 960);
    }else {
        _preview.frame = CGRectMake(0, 0, 1024, 768);
    }
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.session startRunning];

    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    [self.timer invalidate];
}

- (void) lineAnimanate
{
    //NSLog(@"%s\n%d -- %@\n", __FUNCTION__, num, NSStringFromCGRect(self.line.frame));
    if (isDown) {
        num ++;
        CGRect frame = self.line.frame;
        frame.origin.y += 2;
        self.line.frame = frame;
        if (num >= 220) {
            isDown = NO;
        }
    }else {
        num --;
        CGRect frame = self.line.frame;
        frame.origin.y -= 2;
        self.line.frame = frame;
        if (! num > 0) {
            isDown = YES;
        }
    }
        
}

#pragma mark
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *strValue = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metaDataObject = [metadataObjects objectAtIndex:0];
        strValue = metaDataObject.stringValue;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(qrCodeVideController:didFinishedWithString:)]) {
            [self.delegate qrCodeVideController:self didFinishedWithString:strValue];
        }
    }];
}

#pragma mark - Property Methods

- (UIBarButtonItem *)leftBarItem {
    if (!_leftBarItem) {
        _leftBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                     target:self
                                                                     action:@selector(backButtonClicked:)];
    }
    
    return _leftBarItem;
}

-(void)backButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(qrCodeVideControllerCanceledSearch:)]) {
        [self.delegate qrCodeVideControllerCanceledSearch:self];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//设置摄像头的orientation
- (void) setOrigation:(UIInterfaceOrientation) orientation for:(AVCaptureConnection *) conn
{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [conn setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        }
        case UIInterfaceOrientationLandscapeRight:
        {
            [conn setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        }
        case UIInterfaceOrientationPortrait:
        {
            [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            [conn setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        }
        default:
            break;
    }
}

#pragma mark
#pragma mark - UIInterfaceOrigation

- (BOOL) shouldAutorotate{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setOrigation:toInterfaceOrientation for:_preview.connection];
    //竖屏状态下
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _preview.frame = CGRectMake(0, 0, 768, 960);
    }else {
        _preview.frame = CGRectMake(0, 0, 1024, 768);
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}    

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
