//
//  FileDetailCell.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "FileDetailCell.h"
#import "NSString+Additions.h"
#import "Client_file.h"
#import "Client_sign_flow.h"
#import "Client_contact.h"
#import "Client_sign.h"
#import "UIImage+Additions.h"
#import "DownloadInfo.h"
#import "CAAppDelegate.h"
#import "SignerFlowOutsideView.h"

#define TagSignButtonStart      1000
#define TagSignNameLabelStart   2000
#define TagDeleteButtonStart    3000

@interface FileDetailCell() <SignInfoViewDelegate>
{
    int currentFlowCount;
}

@property(nonatomic, assign) BOOL signEditing;
@property(nonatomic, strong) NSArray *currentSignFlows;
@property(nonatomic, strong) UIView *overlayView;
@property(nonatomic, strong) SignerFlowOutsideView *dragImageView;
@property(nonatomic, assign) CGPoint dragBeginPos;
@property(nonatomic, assign) CGPoint dragViewOriCenter;
@property(nonatomic, retain) NSMutableArray *allCenters;

@property (strong, nonatomic) IBOutlet UIView *standardRect;
@property (strong, nonatomic) IBOutlet UIView *expandRect;

// 右侧状态按钮响应方法
- (IBAction)rightButtonClicked:(id)sender;

// 修改文件名按钮响应方法
- (IBAction)modifyButtonClicked:(id)sender;

// 下载按钮响应方法
- (IBAction)downLoadButtonClicked:(id)sender;

// 添加签名人按钮响应方法
- (IBAction)addSignButtonClicked:(id)sender;

// 提交签名流程响应方法
- (IBAction)submitSignButtonClicked:(id)sender;

// 操作下载方法
- (void)handleDownloadProgressNotification:(NSNotification *)notification;
- (void)handleDownloadStatusChangedNotification:(NSNotification *)notification;

// 操作编辑签名流程方法
- (void)handleLongPress:(UIGestureRecognizer *)recognizer;
- (void)handleTapInOverlayView:(UIGestureRecognizer *)recognizer;
- (void)deleteButtonClicked:(id)sender;
- (void)handlePanGesture:(UIGestureRecognizer *)recognizer;

@end

@implementation FileDetailCell

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadProgressNotification:) name:DownloadProgressUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadStatusChangedNotification:) name:DownloadStatusChangedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 更新签名流程
- (void)updateSignFlow:(Client_sign_flow *)signFlow
{
    if (signFlow != nil)
    {
        self.currentSignFlows = [signFlow sortedSignFlows];
        currentFlowCount = (int)[self.currentSignFlows count];
    }
    else
    {
        self.currentSignFlows = [NSMutableArray arrayWithCapacity:6];
        currentFlowCount = 0;
    }
    
    // 清空已显示的签名流程信息
    for (int i = 0; i < MaxSignMembers; i++)
    {
        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
        [signerHead clear];
    }
    
    self.allCenters = [NSMutableArray array];
    
    // 添加签名人信息
    for (NSInteger i = 0; i < currentFlowCount; i++)
    {
        Client_sign *sign = [self.currentSignFlows objectAtIndex:i];
        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
        // 首先判断是否是当前要签名的状态，然后再去依据签名包内部的状态来设置签署状态
        [signerHead setBeCurrent:[signFlow isActiveSign:sign]];
        [signerHead setSign:sign];
        [signerHead setDelegate:self];
        
        [self.allCenters addObject:[NSValue valueWithCGPoint:signerHead.center]];
        
        // 添加长按事件
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        signerHead.userInteractionEnabled = YES;
        [signerHead addGestureRecognizer:pressGesture];
    }
}

// 更新下载状态
- (void)setStatus:(FileDownloadStatus)status
{
    _status = status;
    self.progressView.hidden = _status != FileStatusDownloading;
    self.statusButton.hidden = _status == FileStatusFinished;
    self.statusLabel.hidden = _status == FileStatusFinished;
    CGFloat alpha = _status == FileStatusFinished ? 1.0f : 0.3f;
    
    self.standardRect.alpha = alpha;
    self.expandRect.alpha = alpha;
    
    if (_status != FileStatusDownloading)
        self.progressView.progress = .0f;
    
    switch (_status)
    {
        case FileStatusFinished:
            self.statusLabel.text = @"完成";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudFinish"] forState:UIControlStateNormal];
            break;
        case FileStatusNotStarted:
            self.statusLabel.text = @"下载";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudRunDown"] forState:UIControlStateNormal];
            break;
        case FileStatusWaitingDownload:
            self.statusLabel.text = @"取消";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudRunDown"] forState:UIControlStateNormal];
            break;
        case FileStatusDownloading:
            self.statusLabel.text = @"暂停";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudPause"] forState:UIControlStateNormal];
            break;
        case FileStatusPauseDownload:
            self.statusLabel.text = @"下载";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudRunDown"] forState:UIControlStateNormal];
            break;
        case FileStatusWaitingUpload:
            self.statusLabel.text = @"等待中";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudRunUp"] forState:UIControlStateNormal];
            break;
        case FileStatusUploading:
            self.statusLabel.text = @"暂停";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudPause"] forState:UIControlStateNormal];
            break;
        case FileStatusPauseUpload:
            self.statusLabel.text = @"上传";
            [self.statusButton setBackgroundImage:[UIImage imageNamed:@"CloudRunUp"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

// 设置文档所有者
- (void)setIsOwner:(BOOL)isOwner
{
    _isOwner = isOwner;
    
    if (self.signManageAvaliable)
    {
        self.addSignButton.hidden = !_isOwner;
        self.submitSignFlowButton.hidden = !_isOwner;
    }
}

#pragma mark - Private Methods

- (IBAction)rightButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(statusButtonClicked:)])
        [self.delegate statusButtonClicked:self];
}

- (IBAction)modifyButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(modifyButtonClicked:)])
        [self.delegate modifyButtonClicked:self];
}

- (IBAction)downLoadButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(downLoadButtonClicked:)])
        [self.delegate downLoadButtonClicked:self];
}

- (IBAction)addSignButtonClicked:(id)sender
{
    if (currentFlowCount >= 6)
        return;

    UIButton *addButton = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(addSignButtonClicked:sender:)])
        [self.delegate addSignButtonClicked:self sender:addButton];
}

- (IBAction)submitSignButtonClicked:(id)sender
{
}

// 设置是否正在编辑签名流程
- (void)setSignEditing:(BOOL)signEditing
{
    _signEditing = signEditing;
    currentFlowCount = (int)[self.currentSignFlows count];
    for (NSInteger i = 0; i < currentFlowCount; i++)
    {
        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
        [signerHead setEditing:_signEditing];
    }
}

// 叠加层
- (UIView *)overlayView
{
    if (!_overlayView)
    {
        CGRect frame = CGRectMake(0.0f, 0.0f, 1024.0f, 1024.0f);
        _overlayView = [[UIView alloc] initWithFrame:frame];
        _overlayView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapInOverlayView:)];
        [_overlayView addGestureRecognizer:tap];
        
        // 添加拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_overlayView addGestureRecognizer:pan];
    }
    
    return _overlayView;
}

// 设置是否可以编辑签名流程
- (void)setSignManageAvaliable:(BOOL)avaliable
{
    _signManageAvaliable = avaliable;
    self.signEditing = NO;
    
    if (avaliable)
    {
        self.addSignButton.hidden = NO;
        self.addSignButton.enabled = YES;
        self.submitSignFlowButton.hidden = NO;
        self.submitSignFlowButton.enabled = YES;
    }
    else
    {
        self.addSignButton.hidden = YES;
        self.addSignButton.enabled = NO;
        self.submitSignFlowButton.hidden = YES;
        self.submitSignFlowButton.enabled = NO;
    }
}

#pragma mark - 下载控制按钮

- (void)handleDownloadProgressNotification:(NSNotification *)notification
{
    DownloadInfo *info = (DownloadInfo *)[notification.userInfo objectForKey:DownloadInfoKey];
    if ([info.fileID isEqualToString:self.targetInfo.clientFile.file_id])
    {
        if (self.status != FileStatusDownloading)
            [self.progressView setProgress:0 animated:NO];
        if (self.status != FileStatusFinished)
        {
            self.status = FileStatusDownloading;
            [self.progressView setProgress:info.downloadProgress animated:YES];
        }
    }
}

- (void)handleDownloadStatusChangedNotification:(NSNotification *)notification
{
    DownloadInfo *info = (DownloadInfo *)[notification.userInfo objectForKey:DownloadInfoKey];
    if ([info.fileID isEqualToString:self.targetInfo.clientFile.file_id]) {
        switch (info.status)
        {
            case DownloadStatusFinished:
                self.status = FileStatusFinished;
                break;
            case DownloadStatusNoStarted:
                self.status = FileStatusNotStarted;
                break;
            case DownLoadStatusWaitingDownload:
                self.status = FileStatusWaitingDownload;
                break;
            case DownloadStatusDownloading:
                self.status = FileStatusDownloading;
                break;
            case DownloadStatusPaused:
                self.status = FileStatusPauseDownload;
                break;
            case DownloadStatusFailed:
                self.status = FileStatusWaitingDownload;
                break;
            default:
                break;
        }
    }
}

#pragma mark - 编辑签名流程

- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    if (self.signEditing || !self.signManageAvaliable)
        return;
    
    self.signEditing = YES;
    [self.overlayView removeFromSuperview];
    [[CAAppDelegate sharedDelegate].window.rootViewController.view addSubview:self.overlayView];
}

- (void)handleTapInOverlayView:(UIGestureRecognizer *)recognizer
{
    // 判断点击区域是否在签名图标内
    BOOL tapInSignHead = NO;
    currentFlowCount = (int)[self.currentSignFlows count];

    for (int i = 0; i < currentFlowCount; i++)
    {
        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
        if (signerHead)
        {
            CGPoint point = [recognizer locationInView:signerHead];
            DebugLog(@"%@", NSStringFromCGPoint(point));
            if (CGRectContainsPoint(CGRectMake(0, 0, 60.0f, 60.0f), point))
            {
                tapInSignHead = YES;
                [signerHead deleteButtonClicked:nil];
                break;
            }
        }
    }
    if (!tapInSignHead)
    {
        self.signEditing = NO;
        [self.overlayView removeFromSuperview];
    }
}

- (void)deleteButtonClicked:(id)sender
{
    
}

- (void)handlePanGesture:(UIGestureRecognizer *)recognizer
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            // 判断点击区域是否在签名图标内
            currentFlowCount = (int)[self.currentSignFlows count];
            
            for (int i = 0; i < currentFlowCount; i++)
            {
                SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                if (signerHead)
                {
                    CGPoint point = [recognizer locationInView:signerHead];
                    DebugLog(@"%@", NSStringFromCGPoint(point));
                    if (CGRectContainsPoint(signerHead.bounds, point))
                    {
                        self.dragImageView = signerHead;
                        self.dragBeginPos = [pan locationInView:pan.view];
                        break;
                    }
                }
            }
            
            if (self.dragImageView)
            {
                self.dragViewOriCenter = self.dragImageView.center;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.15];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
                CGAffineTransform transform = CGAffineTransformMakeScale(1.3, 1.3);
                self.dragImageView.transform = transform;
                [UIView commitAnimations];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [pan locationInView:pan.view];
            DebugLog(@"pan change %@", NSStringFromCGPoint(point));
            CGFloat xoffset = point.x - self.dragBeginPos.x;
            CGFloat targetX = self.dragViewOriCenter.x + xoffset;
            CGFloat targetY = self.dragViewOriCenter.y;
            if (self.dragImageView)
                self.dragImageView.center = CGPointMake(targetX, targetY);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGPoint point = [pan locationInView:self.contentView];
            DebugLog(@"pan end %@", NSStringFromCGPoint(point));

            // 计算目标位置的索引
            int nIndex = -1;
            for (int i = 0; i < [self.allCenters count]; i++)
            {
                CGPoint signPos = [[self.allCenters objectAtIndex:i] CGPointValue];
                if (point.x <= signPos.x)
                {
                    nIndex = i;
                    break;
                }
            }
            
            // 判断是否是最后边
            CGPoint lastPos = [[self.allCenters lastObject] CGPointValue];
            if (point.x >= lastPos.x)
                nIndex = (int)[self.allCenters count] - 1;
            
            int oriIndex = (int)self.dragImageView.tag - TagSignButtonStart;
            if (nIndex > -1)
            {
                // 如果位置没有变化
                if (oriIndex == nIndex)
                {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.3];
                    self.dragImageView.center = [[self.allCenters objectAtIndex:oriIndex] CGPointValue];
                    [UIView commitAnimations];

                }
                else if (nIndex < oriIndex)
                {
                    // 向前调整
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.3];
                    self.dragImageView.center = [[self.allCenters objectAtIndex:nIndex] CGPointValue];
                    
                    for (int i = nIndex; i < oriIndex; i++)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        signerHead.center = [[self.allCenters objectAtIndex:i + 1] CGPointValue];
                    }
                    
                    [UIView commitAnimations];
                    
                    // 修改图标的tag值
                    for (int i = oriIndex - 1; i >= nIndex; i--)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        CGRect frame = signerHead.frame;
                        [signerHead removeFromSuperview];
                        signerHead.tag = TagSignButtonStart + i + 1;
                        [self.contentView addSubview:signerHead];
                        signerHead.frame = frame;
                    }
                    [self.dragImageView removeFromSuperview];
                    self.dragImageView.tag = TagSignButtonStart + nIndex;
                    [self.contentView addSubview:self.dragImageView];
                    
                    // 调整签名顺序
                    NSNumber *sequence = self.dragImageView.sign.sequence;
                    for (int i = nIndex; i < oriIndex - 1; i++)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        SignerFlowOutsideView *nextSign = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i + 1];
                        signerHead.sign.sequence = nextSign.sign.sequence;
                    }
                    
                    SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + oriIndex];
                    signerHead.sign.sequence = sequence;

                }
                else if (nIndex > oriIndex)
                {
                    // 向后调整
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.3];
                    self.dragImageView.center = [[self.allCenters objectAtIndex:nIndex] CGPointValue];
                    
                    for (int i = oriIndex + 1; i <= nIndex; i++)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        signerHead.center = [[self.allCenters objectAtIndex:i - 1] CGPointValue];
                    }
                    
                    [UIView commitAnimations];
                    
                    // 修改图标的tag值
                    for (int i = oriIndex + 1; i <= nIndex; i++)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        [signerHead removeFromSuperview];
                        signerHead.tag = TagSignButtonStart + i - 1;
                        [self.contentView addSubview:signerHead];
                    }
                    
                    [self.dragImageView removeFromSuperview];
                    self.dragImageView.tag = TagSignButtonStart + nIndex;
                    [self.contentView addSubview:self.dragImageView];
                    
                    // 调整签名顺序
                    NSNumber *sequence = self.dragImageView.sign.sequence;
                    for (int i = nIndex; i > oriIndex; i--)
                    {
                        SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i];
                        SignerFlowOutsideView *prevSign = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + i - 1];
                        signerHead.sign.sequence = prevSign.sign.sequence;
                    }
                    
                    SignerFlowOutsideView *signerHead = (SignerFlowOutsideView *)[self viewWithTag:TagSignButtonStart + oriIndex];
                    signerHead.sign.sequence = sequence;
                }
            }
            
            self.dragImageView = nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	self.dragImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
	[UIView commitAnimations];
}

#pragma mark - SignInfoViewDeleage

- (void)willRemoveSign:(SignerFlowOutsideView *)infoView
{
    
}

@end
