//
//  HandSignViewController.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "HandSignViewController.h"
#import "UIImage+Rotate.h"
#import "UIAlertView+Additions.h"
#import "cassidlib.h"
#import "QRCodeViewController.h"
#import "CAAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "AllNaviViewController.h"

#define HandSignCameraTag 3001
#define HandSignPhotoLibTag 3002

@interface HandSignViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, QRCodeViewControllerDelegate>

/**
 * @abstract 使用开发库中的CASDKDraw类来实现手写功能模块
 */
@property (nonatomic, strong) CASDKDraw* drawSDK;

/*
 * Colors picker
 */
@property (retain, nonatomic) IBOutlet UIButton *blackPicker;
@property (retain, nonatomic) IBOutlet UIButton *bluePicker;
@property (retain, nonatomic) IBOutlet UIButton *redPicker;
@property (retain, nonatomic) IBOutlet UIButton *whitePicker;

/*
 * Pens picker
 */
@property (retain, nonatomic) IBOutlet UIButton *writePen;
@property (retain, nonatomic) IBOutlet UIButton *writeBrush;
@property (retain, nonatomic) IBOutlet UIButton *writeSlim;

/*!
 定义导航栏左侧按钮
 */
@property(nonatomic, retain) UIBarButtonItem *leftBarItem;

/*!
 *  用来弹出相册选择
 */
@property (nonatomic, retain) UIPopoverController *popOverController;

/*!
 *  从相册或者拍照倒出来的image
 */
@property (nonatomic, retain) UIImageView *photoImageView;

/*!
 *  PhotoLibButton 的frame
 */
@property (nonatomic, assign) CGRect popRect;

@end

@implementation HandSignViewController
{
    BOOL isQrCode;
}

- (UIBarButtonItem *)leftBarItem
{
    if (!_leftBarItem)
    {
        _leftBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                     target:self
                                                                     action:@selector(backButtonClicked:)];
    }
    return _leftBarItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.navigationController)
    {
        self.title = @"新增签名";
        self.navigationItem.leftBarButtonItem = self.leftBarItem;
        _blackPicker.layer.cornerRadius = 51.0;
    }
    
    [self.backgroundView setImage:[UIImage imageNamed:@"AllBackground"]];
    
    // 初始化SDK时，指定绘图的目标视图，这里用的是drawTarget这个UIView
    self.drawSDK = [[CASDKDraw alloc] initWithBundleView:self.drawCanvas];
    [self.drawSDK setDelegate:self];
    [CASDKDraw setPaintColor:[UIColor blackColor]];
    [CASDKDraw setPenStyle:FastThinSlowThick lineWidth:10.0f widthRange:5.0f];

    // 设置画笔的初始状态
    [self.writePen setSelected:YES];
    [self.writeSlim setSelected:NO];
    [self.writeBrush setSelected:NO];

    isQrCode = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.drawSDK resizeDrawCanvas];
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Functions for UI elements

- (IBAction)colorSelected:(id)sender
{
    UIButton *btnColorPicker = (UIButton *)sender;
    UIColor *colorPicked = [UIColor blackColor];
    NSString* selectColorRingName = @"ColorRingBlack";
    switch (btnColorPicker.tag % 5000) {
        case 0:
            colorPicked = [UIColor blackColor];
            selectColorRingName = @"ColorRingBlack";
            break;
        case 1:
            colorPicked = [UIColor blueColor];
            selectColorRingName = @"ColorRingBlue";
            break;
        case 2:
            colorPicked = [UIColor redColor];
            selectColorRingName = @"ColorRingRed";
            break;
        case 3:
            colorPicked = [UIColor whiteColor];
            selectColorRingName = @"ColorRingWhite";
            break;
        default:
            colorPicked = [UIColor blackColor];
            break;
    }
    [self.writePen setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateNormal];
    [self.writeSlim setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateNormal];
    [self.writeBrush setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateNormal];
    [self.writePen setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateSelected];
    [self.writeSlim setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateSelected];
    [self.writeBrush setBackgroundImage:[UIImage imageNamed:selectColorRingName] forState:UIControlStateSelected];
    
    ////////////////////////////////////////////////////////////////////////////////////
    // 调用颜色设置接口函数
    [CASDKDraw setPaintColor:colorPicked];
    ////////////////////////////////////////////////////////////////////////////////////
}

- (IBAction)penSelected:(id)sender
{
    [self.writePen setSelected:NO];
    [self.writeSlim setSelected:NO];
    [self.writeBrush setSelected:NO];
    
    UIButton *btnPenPicker = (UIButton *)sender;
    [btnPenPicker setSelected:YES];
    
    PenStyle penStyle = FixWidth;
    float lineWidth = 3.0f;
    float widthRange = 5.0f;
    
    if (btnPenPicker == self.writeSlim)
    {
        penStyle = FixWidth;
        lineWidth = 3.0f;
    }
    else if (btnPenPicker == self.writeBrush)
    {
        penStyle = FixWidth;
        lineWidth = 20.0f;
    }
    else if (btnPenPicker == self.writePen)
    {
        penStyle = FastThinSlowThick;
        lineWidth = 10.0f;
        widthRange = 5.0f;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 调用笔触设置接口函数
    [CASDKDraw setPenStyle:penStyle lineWidth:lineWidth widthRange:widthRange];
    /////////////////////////////////////////////////////////////////////////////////////////////////////
}

- (IBAction)toolClear:(id)sender
{
    [self.drawSDK clearTool];
}

- (IBAction)toolUndo:(id)sender
{
    [self.drawSDK undoTool];
}

- (IBAction)toolSubmit:(id)sender
{
    [self.drawSDK completeTool];
}

- (IBAction)toolScan:(id)sender
{
    [self.drawSDK scanTool];
}

#pragma mark - CASDKDraw Delegate

/**
 * @abstract 该代理方法用于处理得到签名后的静态图像的处理
 */
- (void)CASDKDraw:(CASDKDraw *)controller getDrawImage:(UIImage *)image
{
    self.imageRect = self.drawSDK.imageRect;
    
    if (isQrCode) {
        [self.delegate HandSignViewController:self qrFinishSignWithImage:image];
    }else {
        [self.delegate HandSignViewController:self DidFinishSignWithImage: image];
    }
}

/**
 * @abstract 该代理方法用于完成操作后的处理
 */
- (void)CASDKDrawComplete:(CASDKDraw *)controller
{
    // [self.view removeFromSuperview];
}

/**
 * @abstract 该代理方法用于完成二维码扫描操作后的处理
 */
- (void)CASDKDraw:(CASDKDraw *)controller getScanCode:(NSString *)resultString
{
    // 显示字符串内容
    //self.qrCodeLabel.text = resultString;
}

/*!
 *  @abstract get image from camera
 */
- (IBAction)CameraBtnClicked:(id)sender
{
    //判断是否有摄像头
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [UIAlertView showAlertMessage:@"没有发现摄像头!"];
        return ;
    }
    
    if ([self.drawSDK isEmptyCanvas])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"导入图片会使当前笔画作废" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = HandSignCameraTag;
        [alertView show];
    }
    else
    {
        [self.drawSDK clearTool];
        [self openCamera];
    }
}

/*!
 *  @abstract get image from photo lib
 */
- (IBAction)PhotoLibBtnClicked:(id)sender
{
    self.popRect = ((UIButton *)sender).frame;
    
    if ([self.drawSDK isEmptyCanvas])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"导入图片会使当前笔画作废" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = HandSignPhotoLibTag;
        [alertView show];
    }
    else
    {
        [self.drawSDK clearTool];
        [self openPhotoLib];
    }
}

/**
 *  @abstract 二维码扫描按钮点击处理事件，发生在手写签名后，应用于上传签名图到网络端
 */
- (IBAction) qrcodeSearch:(id)sender
{
    //检查是否存在笔画
    //isEmptyTool方法
    if ([self.drawSDK isEmptyCanvas]) {
        
        [UIAlertView showAlertMessage:@"请先签名!"];
        
        return ;
    }
    
    //判断是否有摄像头
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [UIAlertView showAlertMessage:@"No avaliable camera found!"];
        return ;
    }
    
    CAAppDelegate *appDelegate = [CAAppDelegate sharedDelegate];
    UIPopoverController *pop = appDelegate.detailViewManager.navigationPopoverController;
    if (pop) {
        [pop dismissPopoverAnimated:YES];
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Toolkits_iPad" bundle:nil];
    QRCodeViewController *qrcoder = (QRCodeViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"QRCodeSearchController"];
    UINavigationController *nav = [[AllNaviViewController alloc] initWithRootViewController:qrcoder];
    qrcoder.delegate = self;
    
    [self presentViewController:nav animated:YES completion:nil];
    //    [appDelegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

/*!
 *  @abstract 打开摄像头
 */
- (void)openCamera
{
    //添加到window上
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [self presentViewController:picker animated:YES completion:nil];
}

/*!
 *  @abstract 打开照片库
 */
- (void)openPhotoLib
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//设置为从相册中取图片
    
    [self.popOverController presentPopoverFromRect:self.popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

/*!
 *  @abstract 控制画笔工具的显隐性
 *  @param isShow 是否显示  YES：显示工具  NO:隐藏空间
 */
- (void) toogleTools:(BOOL) isShow
{
    self.whitePicker.hidden = isShow;
    self.redPicker.hidden = isShow;
    self.blackPicker.hidden = isShow;
    self.bluePicker.hidden = isShow;
    
    self.writeBrush.hidden = isShow;
    self.writePen.hidden = isShow;
    self.writeSlim.hidden = isShow;
}

#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //处理图片旋转,摄像头拍摄的
        if (picker != self.popOverController.contentViewController)
        {
            image = [UIImage fixRotateImage:image];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(100, 100, 400, 300);
        imageView.center = self.drawCanvas.center;
        [self.drawSDK addImageTool:image inRect:imageView.frame];
    }
    [self toogleTools:YES];
    if (picker == self.popOverController.contentViewController)
    {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker == self.popOverController.contentViewController)
    {
        [self.popOverController dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    // [picker.view removeFromSuperview];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.drawSDK clearTool];
    
    if (alertView.tag == HandSignCameraTag)
    {
        [self openCamera];
    }
    if (alertView.tag == HandSignPhotoLibTag)
    {
        [self openPhotoLib];
    }
}

#pragma mark - UIViewController Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.drawCanvas setNeedsDisplay];
    [self.drawCanvas setNeedsLayout];
}

#pragma makr - QRCodeViewControllerDelegate Methods
- (void) qrCodeVideControllerCanceledSearch:(QRCodeViewController *) qrCodeViewController
{
    //什么都不做即可
    [UIAlertView showAlertMessage:@"二维码扫描已取消..."];
}

- (void) qrCodeVideController:(QRCodeViewController *) qrCodeViewController didFinishedWithString:(NSString *) str
{
    //进行请求，这个是二维码的请求。
    
    [UIAlertView showAlertMessage:[NSString stringWithFormat:@"二维码扫描结果:%@", str]];
    isQrCode = YES;
    [self.drawSDK completeTool];
}

@end
