//
//  SignatureClipView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignatureClipView.h"
#import "CAAppDelegate.h"

/**
 *  SignatureViewStyle
 *
 *  @abstract 用来处理状态，包括：
 *      SignatureViewStyleNone: 默认状态，不允许删除和拖动
 *      SignatureViewStyleAllowDelete: 允许删除，不允许拖动
 *      SignatureViewStyleAllowPan: 允许拖动，不允许删除
 */
typedef NS_ENUM(NSInteger, SignatureViewStyle)
{
    SignatureViewStyleNone = 1,
    SignatureViewStyleAllowDelete,
    SignatureViewStyleAllowPan
};

@interface SignatureClipView () <UIGestureRecognizerDelegate>
{
    SignatureViewStyle defaultSignStyle;//用来标识其状态
}

@property (nonatomic, retain) UIView *marker;

@end

@implementation SignatureClipView

@synthesize btnConfirm;
@synthesize btnDelete;
@synthesize bInEdit;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.clipsToBounds = NO;
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SignViewImageWidth-4, frame.size.height)];
        [self addSubview:self.imgView];
        UIImage *signImage = [UIImage imageNamed:@"SignNew"];
        [self.imgView setImage:signImage];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.layer.masksToBounds = YES;
        self.imgView.layer.cornerRadius = 2.0f;
        
        btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDelete.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
        btnDelete.hidden = YES;
        [self addSubview:btnDelete];
        [btnDelete setImage:[UIImage imageNamed:@"MarkDelete"] forState:UIControlStateNormal];
        [btnDelete addTarget:self action:@selector(btnDeleteTapped) forControlEvents:UIControlEventTouchUpInside];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        btnConfirm.frame = CGRectMake(frame.size.width - 20.0f, 0.0f, 20.0f, 20.0f);
        btnConfirm.hidden = YES;
        [self addSubview:btnConfirm];
        [btnConfirm setImage:[UIImage imageNamed:@"MarkConfirm"] forState:UIControlStateNormal];
        [btnConfirm addTarget:self action:@selector(btnConfirmTapped) forControlEvents:UIControlEventTouchUpInside];
        
        defaultSignStyle = SignatureViewStyleNone;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Getter and Setter Method

- (UIView *)marker
{
    if (!_marker)
    {
        _marker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        _marker.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_marker addGestureRecognizer:tap];
    }
    return _marker;
}

/*
 * @param
 */
- (void)setBInEdit:(BOOL)bEdit
{
    if (bEdit)
    {
        btnDelete.hidden = NO;
        btnConfirm.hidden = YES; // 默认情况下始终不需要显示确认按钮
        
        //添加蒙版
        [[CAAppDelegate sharedDelegate].window.rootViewController.view addSubview:self.marker];
    }
    else
    {
        btnDelete.hidden = YES;
        btnConfirm.hidden = YES;
    }
    bInEdit = bEdit;
}

#pragma mark - Private Method

- (void)btnDeleteTapped
{
    if ([self.del respondsToSelector:@selector(SignatureClipViewDidRemove:)])
    {
        [self.del performSelector:@selector(SignatureClipViewDidRemove:) withObject:self];
    }
}

- (void)btnConfirmTapped
{
    if ([self.del respondsToSelector:@selector(SignatureClipViewDidConfirm:)])
    {
        [self.del performSelector:@selector(SignatureClipViewDidConfirm:) withObject:self];
    }
}

- (void)setDefaultSign:(Client_signfile *)defaultSignNew
{
    _defaultSign = defaultSignNew;
    UIImage *signImage = [UIImage imageWithContentsOfFile:defaultSignNew.signfile_path];
    [self.imgView setImage:signImage];
}

- (void)changeItemAlpha:(float)fAlpha withDelay:(float)timeDelay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationDelay:timeDelay];
    self.alpha = fAlpha;
    [UIView commitAnimations];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.panGesture && otherGestureRecognizer == self.longPressGesture)
    {
        return YES;
    }
    return NO;
}

#pragma mark - Gesture Handles

/**
 *  @abstract 允许进行拖拽
 *  @param  view：拖拽到得view
 */
- (void) allowPanWithRootView:(UIView *) view
{
    // 预处理
    if (defaultSignStyle != SignatureViewStyleAllowPan)
    {
        if (self.longPressGesture)
        {
            [self removeGestureRecognizer:self.longPressGesture];
        }
        if (self.panGesture)
        {
            [self removeGestureRecognizer:self.panGesture];
        }
    }
    
    defaultSignStyle = SignatureViewStyleAllowPan;
    
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
    [longPress setDelegate:self];
    self.longPressGesture = longPress;
    
    //添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSignPanGesture:)];
    pan.delaysTouchesEnded = NO;
    [self addGestureRecognizer:pan];
    [pan setDelegate:self];
    self.panGesture = pan;
}

/**
 *  @abstract 允许进行拖拽
 */
- (void) allowDelete
{
    //预处理
    if (defaultSignStyle != SignatureViewStyleAllowDelete)
    {
        if (self.longPressGesture) {
            [self removeGestureRecognizer:self.longPressGesture];
            self.longPressGesture = nil;
        }
        if (self.panGesture) {
            [self removeGestureRecognizer:self.panGesture];
            self.panGesture = nil;
        }
    }
    
    //添加长按手势
    defaultSignStyle = SignatureViewStyleAllowDelete;
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    longGesture.minimumPressDuration = 1;
    [self addGestureRecognizer:longGesture];
    self.longPressGesture = longGesture;
}

/**
 *  @abstract 处理拖动手势
 */
- (void) handleSignPanGesture:(UIPanGestureRecognizer *) pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self panBegin:pan];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self panMoved:pan];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self panEnded:pan];
        }
            break;
        default:
            break;
    }
}

/**
 *  @abstract 处理长按手势
 */
- (void) handleLongGesture:(UILongPressGestureRecognizer *) longGesture
{
    //允许删除模式下操作
    if (defaultSignStyle == SignatureViewStyleAllowDelete) {
        
        if (longGesture.state == UIGestureRecognizerStateBegan) {
            [self setBInEdit:YES];
        }
    }
    
    //允许拖动模式下操作
    if (defaultSignStyle == SignatureViewStyleAllowPan) {
        switch (longGesture.state) {
            case UIGestureRecognizerStateBegan:
            {
                if ([self.del respondsToSelector:@selector(SignatureClipViewDidStartDrag:)]) {
                    [self.del SignatureClipViewDidStartDrag:self];
                }
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                if ([self.del respondsToSelector:@selector(SignatureClipViewDidEndDrag:)]) {
                    [self.del SignatureClipViewDidEndDrag:self];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

/**
 *  @abstract 处理蒙版tap手势
 */
- (void) handleTapGesture:(UITapGestureRecognizer *) tap
{
    
    CGPoint point = [tap locationInView:self];
    if (CGRectContainsPoint(CGRectMake(-30.0f, -30.0f, 60.0f, 60.0f), point)) {
        [self btnDeleteTapped];
    }
    
    [self setBInEdit:NO];
   
    [self.marker removeFromSuperview];
}

/**
 *  @abstract 处理拖动手势开始
 */
- (void) panBegin:(UIPanGestureRecognizer *) pan
{
}

/**
 *  @abstract 处理拖动手势拖动中
 */
- (void) panMoved:(UIPanGestureRecognizer *) pan
{

    CGPoint translation = [pan translationInView:self.rootView];
    CGPoint toCenter = self.center;
    [pan setTranslation:CGPointZero inView:[self rootView]];

    UIInterfaceOrientation ori =  [UIApplication sharedApplication].keyWindow.rootViewController.interfaceOrientation;
    
    if (ori == UIInterfaceOrientationLandscapeRight) {
        toCenter.x += translation.y;
        toCenter.y -= translation.x;
    }
    if (ori == UIInterfaceOrientationLandscapeLeft) {
        toCenter.x -= translation.y;
        toCenter.y += translation.x;
    }
    if (ori == UIInterfaceOrientationPortrait) {
        toCenter.x += translation.x;
        toCenter.y += translation.y;
    }
    
    if (ori == UIInterfaceOrientationPortraitUpsideDown) {
        toCenter.x -= translation.x;
        toCenter.y -= translation.y;
    }
    
    self.center = toCenter;
}

/**
 *  @abstract 处理拖动手势拖动结束
 */
- (void) panEnded:(UIPanGestureRecognizer *) pan
{
}

@end
