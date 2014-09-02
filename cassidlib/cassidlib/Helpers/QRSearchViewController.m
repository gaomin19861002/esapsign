//
//  QRSearchViewController.m
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "QRSearchViewController.h"

@interface QRSearchViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    int num ;
    BOOL isDown;
}

@property (nonatomic, retain) AVCaptureDevice *device;
@property (nonatomic, retain) AVCaptureDeviceInput *input;
@property (nonatomic, retain) AVCaptureMetadataOutput *output;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;


@property (nonatomic, retain) UIImageView *line;

@property (nonatomic, retain) NSTimer *lineTimer;

@property (nonatomic, retain) UIBarButtonItem *leftBarButtonItem;


@property (nonatomic, retain) UIView *northView;
@property (nonatomic, retain) UIView *sourthView;
@property (nonatomic, retain) UIView *eastView;
@property (nonatomic, retain) UIView *westView;
@property (nonatomic, retain) UIImageView *centerView;

@property (nonatomic, retain) UILabel *messageLabel;


@end

@implementation QRSearchViewController

#pragma mark Life Cycle Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController) {
        self.title = @"二维码扫描";
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    }
    
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.rectOfInterest = CGRectMake(0.1, 0.1, 0.8, 0.8);
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //    CGRect rect = CGRectMake(0, 0, 1024, 1024);
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
    
    //增加view
    [self addSubViews];
    
    num = 0;
    isDown = YES;
    self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(lineAnimate) userInfo:nil repeats:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -private method
- (void) addSubViews{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.northView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 292)];
    self.northView.backgroundColor = [UIColor lightGrayColor];
    self.northView.alpha = 0.4;
    [self.view addSubview:self.northView];
    
    self.sourthView = [[UIView alloc] initWithFrame:CGRectMake(0, 732, 768, 732)];
    self.sourthView.backgroundColor = [UIColor lightGrayColor];
    self.sourthView.alpha = 0.4;
    [self.view addSubview:self.sourthView];
    
    self.eastView = [[UIView alloc] initWithFrame:CGRectMake(0, 292, 164, 440)];
    self.eastView.backgroundColor = [UIColor lightGrayColor];
    self.eastView.alpha = 0.4;
    [self.view addSubview:self.eastView];
    
    self.westView = [[UIView alloc] initWithFrame:CGRectMake(604, 292, 164, 440)];
    self.westView.backgroundColor = [UIColor lightGrayColor];
    self.westView.alpha = 0.4;
    [self.view addSubview:self.westView];
    
    UIImage *borderImage = [UIImage imageNamed:QRBorderImageName];
    UIImage *lineImage = [UIImage imageNamed:QRLineImageName];
    self.centerView = [[UIImageView alloc] initWithFrame:CGRectMake(164, 292, 440, 440)];
    self.centerView.contentMode = UIViewContentModeScaleAspectFit;
    self.centerView.image = borderImage;
//    self.centerView.alpha = 0;
    [self.view addSubview:self.centerView];
    
    self.line = [[UIImageView alloc] initWithFrame:CGRectMake(164, 292, 440, 2)];
    self.line.contentMode = UIViewContentModeScaleAspectFill;
    self.line.image = lineImage;
    [self.view addSubview:self.line];
    
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 440, 22)];
    self.messageLabel.text = QRMessageText;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageLabel.numberOfLines = 1;
    self.messageLabel.font = [UIFont systemFontOfSize:17.0];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.center = CGPointMake(384, 750);
    [self.view addSubview:self.messageLabel];
    
}

- (void) lineAnimate
{
    if (isDown) {
        num ++;
        CGRect rect = self.line.frame;
        rect.origin.y += 2;
        self.line.frame = rect;
        if (num >= 220) {
            isDown = NO;
        }
    }else {
        num --;
        CGRect rect = self.line.frame;
        rect.origin.y -= 2;
        self.line.frame = rect;
        if (num <= 0) {
            isDown = YES;
        }
    }
}

- (void) backButtonClicked
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(qrSearchViewControllerCanceled:)]) {
        [self.delegate qrSearchViewControllerCanceled:self];
    }
}

#pragma mark Setter and Getter Method
- (UIBarButtonItem *) leftBarButtonItem{
    if (!_leftBarButtonItem) {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backButtonClicked)];
    }
    return _leftBarButtonItem;
}

#pragma mark
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *strValue = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metaDataObject = [metadataObjects objectAtIndex:0];
        strValue = metaDataObject.stringValue;
    }
    
    if (self.session.isRunning) {
        [self.session stopRunning];
        [self.lineTimer invalidate];
        if ([self.delegate respondsToSelector:@selector(qrSearchViewController:didFinishedWithString:)]) {
            [self.delegate qrSearchViewController:self didFinishedWithString:strValue];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
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
