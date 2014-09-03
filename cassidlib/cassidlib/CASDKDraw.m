//
//  CADrawViewController.m
//  cassidlib
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "CASDKDraw.h"

#import "Util.h"
#import "UIImageCoverRect.h"
#import "CALibCanvas.h"
#import "CACanvasActiveStatus.h"

#import "QRSearchViewController.h"


#define SignViewTagBase 1100

@interface CASDKDraw () <QRSearchDelegate>
{
    CALibCanvas *_paletteView;
}

// 背景容器视图
@property (retain, nonatomic) UIView *boundleView;

@end

@implementation CASDKDraw

- (id)initWithBundleView:(UIView*)view
{
    self = [super init];
    if (self)
    {
        self.boundleView = view;
        float w = view.frame.size.width;
        float h = view.frame.size.height;
        _paletteView = [[CALibCanvas alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        [_paletteView setBackgroundColor:[UIColor clearColor]];
        [self.boundleView addSubview:_paletteView];
    }
    return self;
}

- (void)resizeDrawCanvas
{
    float w = self.boundleView.frame.size.width;
    float h = self.boundleView.frame.size.height;
    [_paletteView setFrame:CGRectMake(0, 0, w, h)];
}

+ (void)setPaintColor:(UIColor *)color
{
    [CACanvasActiveStatus sharedInstance].paintColor = color;
}

+ (void)setPenStyle:(PenStyle)style lineWidth:(float)lineWidth widthRange:(float)widthRange
{
    [CACanvasActiveStatus sharedInstance].penStyle = style;
    [CACanvasActiveStatus sharedInstance].lineWidth = lineWidth;
    [CACanvasActiveStatus sharedInstance].widthRange = widthRange;
}

- (void)clearTool
{
    [_paletteView clear];
}

- (void)undoTool
{
    [_paletteView undo];
}

- (void)scanTool
{
    if (![self.delegate isKindOfClass:[UIViewController class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"CASDKDraw的代理必须是UIViewController"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    // 调用二维码功能
    QRSearchViewController *qrSearchController = [[QRSearchViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:qrSearchController];
    UIViewController *controller = (UIViewController *) self.delegate;
    qrSearchController.delegate = self;
    [controller presentViewController:nav animated:YES completion:nil];
}

- (void)completeTool
{
    self.imageRect = [self.boundleView convertRect:_paletteView.signFrame fromView:_paletteView];
    if (self.imageRect.size.width >= 64 || self.imageRect.size.height >= 64)
    {
        UIImage *imageSaved = [_paletteView saveWithoutCompress];
        [self.delegate CASDKDraw:self getDrawImage:imageSaved];
    }
    
    [_paletteView clear];
    [self.delegate CASDKDrawComplete:self];
}

- (void)addImageTool:(UIImage*)image inRect:(CGRect)frame
{
    [_paletteView setSignImage:image inRect:frame];
}

- (bool)isEmptyCanvas
{
    return [_paletteView isEmpty];
}

#pragma mark - QRSearchDelegate methods

- (void) qrSearchViewControllerCanceled:(QRSearchViewController *)searchController
{
    NSLog(@"the QRCode Search finished");
}

- (void) qrSearchViewController:(QRSearchViewController *)searchController didFinishedWithString:(NSString *)string
{
    NSLog(@"the QRCode Search finished with String: %@", string);
    [self.delegate CASDKDraw:self getScanCode:string];
}

@end

