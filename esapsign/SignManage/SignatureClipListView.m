//
//  SignatureClipListView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignatureClipListView.h"
#import "SignatureClipView.h"
#import "CAAppDelegate.h"

#import "FileManagement.h"
#import "DataManager.h"
#import "RequestManager.h"
#import "ActionManager.h"
#import "CompleteManager.h"

#import "SignatureClipCollectionViewLayout.h"
#import "SignatureClipCollectionCell.h"

#import "Util.h"
#import "UIColor+Additions.h"
#import "UIViewController+Additions.h"

#define SignCollectionCellIdentifier @"SignCollectionCellIdentifier"

@interface SignatureClipListView () <ActionManagerDelegate, RequestManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) NSString* currentImageID;
@property (nonatomic, copy) NSString *currentImagePath;

@property (nonatomic, retain) ASIFormDataRequest *upSignRequest;
@property (nonatomic, retain) ASIFormDataRequest *uploadImageRequest;
@property (nonatomic, retain) ASIFormDataRequest *uploadCompleteRequest;
@property (nonatomic, retain) ASIFormDataRequest *delSignRequest;

@end

@implementation SignatureClipListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [[RequestManager defaultInstance] registerDelegate:self];
        [[ActionManager defaultInstance] registerDelegate:self];
        
        CGFloat xpos = self.frame.size.width;// - (self.frame.size.width - totalLength) / 2;
        xpos -= SignViewImageWidth - 40;// / 2;
        
        UICollectionViewLayout *flowLayout = [[SignatureClipCollectionViewLayout alloc] init];
        
        // Init the CollectionView
        CGRect collectionRect = CGRectMake(0, 2, xpos, 52);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionRect collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        //collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.allowsSelection = NO;
        // collectionView.clipsToBounds = NO;
        collectionView.dataSource = self;
        // collectionView.delegate = self;
        collectionView.showsHorizontalScrollIndicator = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        
        //Regist SignCollectionCell for the CollectionView
        [collectionView registerClass:[SignatureClipCollectionCell class] forCellWithReuseIdentifier:SignCollectionCellIdentifier];
        [self addSubview:collectionView];
        self.signCollectionView = collectionView;
        
        // 尾部移动“添加”按钮
        self.btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnAdd setImage:[UIImage imageNamed:@"SignNew"] forState:UIControlStateNormal];
        self.btnAdd.frame = CGRectMake(xpos, -40, 96, 96);
    
        UIView *markView = [[UIView alloc] init];
        // markView.backgroundColor = [UIColor colorWithRed:35.0 green:45.0 blue:59.0 alpha:1.0];
        markView.backgroundColor = [UIColor colorWithR:35 G:45 B:59 A:255];
        markView.frame = CGRectMake(xpos, 0, 100, 56);
        [self addSubview:markView];

        [self.btnAdd addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnAdd];
    }
    return self;
}

- (void)dealloc
{
    [[ActionManager defaultInstance] unRegisterDelegate:self];
    [[RequestManager defaultInstance] unRegisterDelegate:self];
}

#pragma mark - Setter Method

- (void)setArrDefaultSigns:(NSMutableArray *)arrNewDefaultSigns
{
    _arrDefaultSigns = arrNewDefaultSigns;
    [self.signCollectionView reloadData];
}

#pragma mark - Override Method

/**
 *  重写view的这个方法是为了让点击按钮能够正常的响应点击事件。（因为添加按钮超出了本view的边界）
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.btnAdd.frame, point))
    {
        return self.btnAdd;
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - Private Method

/**
 *  @abstract 添加按钮点击处理
 */
- (void)addBtnClicked:(UIButton *)btn
{
    if ([self.signsListDelegate respondsToSelector:@selector(SignatureClipListViewDidClickedNewSignBtn:)])
    {
        [self.signsListDelegate SignatureClipListViewDidClickedNewSignBtn:self];
    }
}

/**
 *  @abstract 新增签名，供完成后回调
 */
- (void)insertNewSign:(UIImage *)signImage
{
    self.currentImageID = [Util generalUUID];
    
    NSData *dataImage = UIImagePNGRepresentation(signImage);
    NSString *signCachedFolder = [FileManagement signsImageCachedFolder];
    NSString *desFile = [signCachedFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.currentImageID]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:desFile isDirectory:NO]) {
        [manager removeItemAtPath:desFile error:nil];
    }
    self.currentImagePath = desFile;
    
    BOOL bResult = [dataImage writeToFile:desFile atomically:YES];
    if (bResult)
    {
        // 上传签名图的请求
        NSDictionary* action = [[ActionManager defaultInstance] signpenNewAction:self.currentImageID];
        [[ActionManager defaultInstance] addToQueue:action];
        self.upSignRequest = [ActionManager defaultInstance].actionRequest;
       
#warning 更为合理的做法应该是提交Action的异步操作成功以后再清理本地数据
        // 在本地添加数据
        [[DataManager defaultInstance] addSignWithPath:desFile withID:self.currentImageID];
        self.arrDefaultSigns = [DataManager defaultInstance].allSignFiles;
    }
}

#pragma mark - SignatureClipViewDelegate

- (void)SignatureClipViewDidRemove:(SignatureClipView *)signView
{
    Client_signfile *signfile = signView.defaultSign;
    NSString* delSignID = [NSString stringWithFormat:@"%@", signView.defaultSign.signfile_id];
    
    // 发送删除Action
    NSDictionary* action = [[ActionManager defaultInstance] signpenDelAction:delSignID];
    [[ActionManager defaultInstance] addToQueue:action];
    self.delSignRequest = [ActionManager defaultInstance].actionRequest;
    
#warning 更为合理的做法应该是发送删除Action的异步操作成功以后再清理本地数据
    // 从本地清除数据
    [self.arrDefaultSigns removeObject:signfile];
    [self.signCollectionView reloadData];
    [[DataManager defaultInstance] deleteSignFile:signView.defaultSign];
}

/**
 *  @abstract 拖动开始处理
 */
- (void)SignatureClipViewDidStartDrag:(SignatureClipView *)signView
{
    // 进行放大
    self.signCollectionView.clipsToBounds = NO;
    [UIView animateWithDuration:0.2 animations:^{
        signView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    }];
}

/**
 *  @abstract 拖动结束处理
 */
- (void)SignatureClipViewDidEndDrag:(SignatureClipView *)signView
{
    // 缩放到原有大小
    self.signCollectionView.clipsToBounds = YES;
    [UIView animateWithDuration:0.2 animations:^{
        signView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
    [self.signCollectionView reloadData];
    
    if ([self.signsListDelegate respondsToSelector:@selector(SignatureClipListView:DidDragSign:ToPoint:)])
    {
        [self.signsListDelegate SignatureClipListView:self DidDragSign:signView ToPoint:signView.center];
    }
}

#pragma mark - Request Manager Delegate

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        // 该请求可以通过Action Manager响应
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        // 该请求可以通过Action Manager响应
    }
    
    if (request == self.uploadImageRequest) {
        DebugLog(@"upload image file failed");
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
    }
    
    if (request == self.uploadCompleteRequest) {
        DebugLog(@"upload complete failed");
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        // 该请求可以通过Action Manager响应
    }
    
    if (request == self.uploadImageRequest)
    {
        NSLog(@"upload image file succeed");
        // 发送完成动作
        NSDictionary* complete = [[CompleteManager defaultInstance] uploadCompleteCommand:self.currentImageID completeType:@"1"];
        self.uploadCompleteRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, UploadCompleteRequestPath]
                                                                           Parameter:complete];
    }
    if (request == self.uploadCompleteRequest)
    {
        __unused NSString *resString = [self.uploadCompleteRequest responseString];
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        NSLog(@"upload complete succeed %@", resString);
    }
}

#pragma mark - Action Manager Delegate

// 异步请求开始通知外部程序
- (void)actionRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController showProgressText:@"上传中..."];
    }
    else if (request == self.delSignRequest)
    {
        
    }
}

// 异步请求失败通知外部程序
- (void)actionRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        NSLog(@"Upload Request Action Failed!");
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.upSignRequest = nil;
    }
    else if (request == self.delSignRequest)
    {
        self.delSignRequest = nil;
    }
}

// 异步请求结束通知外部程序
- (void)actionRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        NSLog(@"Upload Request Action Succeed!");

        // 请求成功后开始上传图片文件本体
        self.uploadImageRequest = [[RequestManager defaultInstance] asyncPostData:APIBaseUpload file:self.currentImagePath isPDF:NO];
        self.upSignRequest = nil;
    }
    else if (request == self.delSignRequest)
    {
        self.delSignRequest = nil;
    }
}

#pragma mark - UICollectionViewDataSource Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrDefaultSigns count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SignatureClipCollectionCell *cell = (SignatureClipCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:SignCollectionCellIdentifier
                                                                                               forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    // cell.contentView.frame = cell.frame;
    cell.contentView.contentMode = UIViewContentModeCenter;
    
    //init the cell
    // int index = arrDefaultSigns.count - indexPath.row - 1;
    Client_signfile *item = [self.arrDefaultSigns objectAtIndex:indexPath.row];
    CGRect viewRect =  CGRectMake(2, 3, SignViewItemWidth-4, SignViewItemHeight-10);
    SignatureClipView *defaultSignView = [[SignatureClipView alloc] initWithFrame:viewRect];
    defaultSignView.defaultSign = item;
    defaultSignView.del = self; //设置delete的delegate.
    // defaultSignView.alpha = 0.0f;
    
    cell.userInteractionEnabled = YES;
    cell.contentView.userInteractionEnabled = YES;
    
    //如果允许拖拽
    if (self.allowDragSign)
    {
        Assert(self.panTargetView, @"SignatureClipListView's pan shouldn't be nil");
        [defaultSignView allowPanWithRootView:self.panTargetView];
        [defaultSignView.panGesture requireGestureRecognizerToFail:[collectionView panGestureRecognizer]];
    }
    else
    {
        //不允许拖拽
        [defaultSignView allowDelete];
    }
    
    [cell.contentView addSubview:defaultSignView];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
