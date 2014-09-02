//
//  DocDetailViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DocDetailViewController.h"
#import "PDFDocument.h"
#import "DataManager.h"
#import "FileManagement.h"
#import "ActionManager.h"
#import "CompleteManager.h"
#import "ContactSelectedViewController.h"
#import "ResizableSignatureClipView.h"

#import "Util.h"
#import "HTBKVObservation.h"
#import "MBProgressHUD.h"

#import "NSObject+Json.h"
#import "NSObject+DelayBlocks.h"
#import "UIImage+CoverRect.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"
#import "UIAlertView+Additions.h"
#import "UIViewController+Additions.h"

// 该Tag值。。。。
#define SignViewTagBase     1100

static int signViewTag = SignViewTagBase;

// 展示pdf时两端空白宽度
#define WebViewWidthSpace 24.0f

// 页间隔
#define WebViewHeightSpace 3.5f

#define MaxSignFlowXOffset 130.0

@interface DocDetailViewController () <ActionManagerDelegate, RequestManagerDelegate, UIActionSheetDelegate, ContactSelectedViewControllerDelegate>
{
    // PDF文档控制对象，用于写入操作
    PDFDocument *m_pdfdoc;

    // 记录文档偏移位置
    float contentOffsetY;
    
    // 操作过程图标
    MBProgressHUD *hud;
    
    bool bDirtyFlag;
}

/**
 * @abstract 使用开发库中的CASDKDraw类来实现手写功能模块
 */
@property (nonatomic, strong) CASDKDraw* drawSDK;

@property (strong, nonatomic) IBOutlet UIView *drawCanvas;

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


@property (nonatomic, copy) NSString *fileTempPath;
@property (nonatomic, retain) NSMutableArray *arrSigns;
@property (nonatomic, retain) NSMutableArray *arrPageHeight;

@property (nonatomic, retain) ASIFormDataRequest *upSignRequest;
@property (nonatomic, retain) ASIHTTPRequest *lockSignRequest;
@property (nonatomic, retain) ASIHTTPRequest *signRequest;
@property (nonatomic, retain) ASIHTTPRequest *upCompleteRequest;

@property (nonatomic, assign) NSUInteger pageIndexBeforeRotate;
@property (nonatomic, retain) HTBKVObservation *contextOffsetObserver;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIPopoverController* addSignerPopoverController;

@end

// 文档视图主体实现
@implementation DocDetailViewController

#pragma mark - Overide member functions

- (void)dealloc
{
	[m_pdfdoc releasePDFSDK];

    //移除监听
    [[RequestManager defaultInstance] unRegisterDelegate:self];
    [[ActionManager defaultInstance] unRegisterDelegate:self];
    
    // 删除临时文件
    [FileManagement removeFile:self.fileTempPath];
}

- (void)initDrawSDK
{
    // 初始化SDK时，指定绘图的目标视图，这里用的是drawTarget这个UIView
    self.drawSDK = [[CASDKDraw alloc] initWithBundleView:self.drawCanvas];
    [self.drawSDK setDelegate:self];
    [CASDKDraw setPaintColor:[UIColor blackColor]];
    [CASDKDraw setPenStyle:FastThinSlowThick lineWidth:10.0f widthRange:5.0f];
    [self.directSignView setHidden:YES];
    
    // 设置画笔的初始状态
    [self.writePen setSelected:YES];
    [self.writeSlim setSelected:NO];
    [self.writeBrush setSelected:NO];
}

- (void)initSignListView
{
    // 设置签名列表视图
    signsListView = [[SignatureClipListView alloc] initWithFrame:CGRectMake(0, 0, 1024, 56)];
    [self.operationBgView addSubview:signsListView];
    signsListView.arrDefaultSigns = [[DataManager defaultInstance] allDefaultSignFiles];
    signsListView.signsListDelegate = self;
    signsListView.allowDragSign = YES;
    signsListView.panTargetView = self.backgroundView;
    [signsListView.btnAdd setImage:[UIImage imageNamed:@"SignDirect"] forState:UIControlStateNormal];
    [signsListView.btnAdd setHidden:NO];
}

- (void)initSignFlowInside
{
    // 设置签名流拖动手势
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.signFlowView addGestureRecognizer:gesture];
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.signFlowView addGestureRecognizer:tapRecognizer];
    NSArray *signs = [clientTarget.clientFile sortedSignFlows];
    [self updateSignflowWithSigns:signs];
    
    // 增加滑动检测，滑动时收起签名流
    self.contextOffsetObserver =
    [HTBKVObservation observe:self.documentDisplayView.scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld callback:^(HTBKVObservation *observation, NSDictionary *changeDictionary) {
        [self showSignFlow:NO];
    }];
}

/**
 * @abstract 视图内容加载后时调用
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (clientTarget == nil) return;
    bDirtyFlag = NO;

    // 调整显示UI界面
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = clientTarget.display_name;
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RightBackground"]];
    self.operationBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomAllTall"]];
    [self.submitButton.titleLabel setFont:[UIFont fontWithName:@"Libian SC" size:36]];

    // 设定为上传管理器代理
    [[RequestManager defaultInstance] registerDelegate:self];
    [[ActionManager defaultInstance] registerDelegate:self];
    
    [self initDrawSDK];
    
    [self initSignFlowInside];
    
    [self initSignListView];
    
    // 设置好临时文件的路径
    NSString *documentPath = clientTarget.clientFile.phsical_filename;
    NSString *fileName = [NSString stringWithFormat:@"temp_%@", [documentPath lastPathComponent]];
    self.fileTempPath = [documentPath stringByDeletingLastPathComponent];
    self.fileTempPath = [self.fileTempPath stringByAppendingPathComponent:fileName];
    NSLog(@"%s,self.fileDesPath=%@", __FUNCTION__, self.fileTempPath);
    
    // 加载文档并加以显示
    [self.documentDisplayView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:documentPath]]];
    [self.documentDisplayView setDelegate:self];
    // documentDisplayView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    // documentDisplayView.scrollView.pagingEnabled = YES;
    
    // 使用PDF控件加载对应文档
    m_pdfdoc = [[PDFDocument alloc] init];
    [m_pdfdoc initPDFSDK];
    [m_pdfdoc setDesFilePath:self.fileTempPath];
    if (![m_pdfdoc openPDFDocument:[documentPath UTF8String]])
        return;
    [self arrPageHeight]; // 显式调用属性Get方法以完成页面高低初始化操作
}

/**
 * @abstract 视图内容将要显示
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //判断是否需要加锁,根据是否是收件箱下文件进行判断。
    if ([[DataManager defaultInstance] isClientTargetEditable:clientTarget])
    {
        //请求加锁操作
        NSDictionary* action = [[ActionManager defaultInstance] lockAction:clientTarget];
        [[ActionManager defaultInstance] addToQueue:action];
        self.lockSignRequest = [ActionManager defaultInstance].actionRequest;
        self.operationBgView.hidden = NO;
        _operationBgConstraint.constant = 0.0f;
    }
    else
    {
        //下边的operationBgView不显示
        self.operationBgView.hidden = YES;
        self.operationBgConstraint.constant = 0.0f;
        
        //为webView设置更大的显示空间
        CGRect frame = self.documentDisplayView.frame;
        frame.size.height += 56;
        self.documentDisplayView.frame = frame;
        NSLog(@"---%f, ---%f", frame.size.width, frame.size.height);
    }
    
    // 此处纠正位置是因为，在初始生成的时候，还无法判定旋转屏状态，第一次进入页面重新刷下
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) || UIDeviceOrientationIsPortrait(self.interfaceOrientation) )
    {
        signsListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth), 0);
        // signsListView.signCollectionView.frame.origin.x += 400;
        
        CGRect frame = signsListView.signCollectionView.frame;
        // frame.origin.x = 260;
        // frame.size.width = 664;
        frame.origin.x = 291;
        frame.size.width = 604;
        signsListView.signCollectionView.frame = frame;
        signsListView.signCollectionView.contentOffset = CGPointMake(0, 0);
        
    }
    else
    {
        CGRect frame = signsListView.signCollectionView.frame;
        frame.origin.x = 12;
        frame.size.width = 900;
        signsListView.signCollectionView.frame = frame;
        signsListView.signCollectionView.contentOffset = CGPointMake(0, 0);
    }
}

/**
 * @abstract 视图内容将要消失
 */
- (void)viewWillDisappear:(BOOL)animate
{
    [super viewWillDisappear:animate];
    signsListView.transform = CGAffineTransformIdentity;
}

/**
 * @abstract 使用Webview调用显示文档
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%s,%f, %lu,%@",__FUNCTION__,
          self.documentDisplayView.pageLength,
          (unsigned long)self.documentDisplayView.pageCount,
          NSStringFromCGSize(webView.scrollView.contentSize));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.documentDisplayView.scrollView setContentOffset:CGPointMake(0.0f, contentOffsetY) animated:NO];
    });
}

/**
 * @abstract 内存警告时调用。注意，由于文件大小的不可估量，必须处理该方法以完善应用
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @abstract 旋转屏幕时的参数调整
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%s,%f", __FUNCTION__, self.documentDisplayView.scrollView.zoomScale);
    // 由于旋转过后，zoomScale会发生变化，导致坐标计算出错，重刷页面
    // 求取当前滚动页位置
    CGPoint contentOffset = self.documentDisplayView.scrollView.contentOffset;
    float fTotleHeight = 0.0f;
    float scale = self.documentDisplayView.scrollView.zoomScale;
    self.pageIndexBeforeRotate = 0;
    while (self.pageIndexBeforeRotate < self.arrPageHeight.count)
    {
        // 页面被放大，每页高度也发生变化
        CGFloat pageSizeAfterScaled = [[self.arrPageHeight objectAtIndex:self.pageIndexBeforeRotate] floatValue] * scale;
        fTotleHeight += pageSizeAfterScaled;
        if (fTotleHeight <= contentOffset.y)
            self.pageIndexBeforeRotate++;
        else
            break;
    }
}

/**
 * @abstract 旋转屏幕时的参数调整
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"%s,%f", __FUNCTION__, self.documentDisplayView.scrollView.zoomScale);
    
    CGFloat zoomScale = self.documentDisplayView.scrollView.zoomScale;
    
    // 重新计算页高
    self.arrPageHeight = nil;
    [self arrPageHeight];
    // 根据页面计算偏移位置
    contentOffsetY = 0.0;
    while (self.pageIndexBeforeRotate > 0)
    {
        contentOffsetY += [[self.arrPageHeight objectAtIndex:self.pageIndexBeforeRotate] floatValue];
        self.pageIndexBeforeRotate--;
    }
    [self.documentDisplayView.scrollView setZoomScale:1.0];
    [self.documentDisplayView reload];
    
    // 修复签名页坐标
    [UIView animateWithDuration:0.2 animations:^{
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            signsListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth), 0);
            CGRect frame = signsListView.signCollectionView.frame;
            frame.origin.x = 291;
            frame.size.width = 604;
            signsListView.signCollectionView.frame = frame;
            
            [self updateResizableSign:zoomScale];
        }else {
            signsListView.transform = CGAffineTransformIdentity;
            CGRect frame = signsListView.signCollectionView.frame;
            frame.origin.x = 12;
            frame.size.width = 900;
            signsListView.signCollectionView.frame = frame;
            
            [self updateResizableSign:zoomScale];
        }
    }];
}

#pragma mark - Properties functions

/**
 * @abstract Set value to property of clientTarget
 */
- (void)setClientTarget:(Client_target *)newClientTarget
{
    clientTarget = newClientTarget;

    // 判定编辑状态
    self.editable = ![[DataManager defaultInstance] isClientFileFinishedSign:clientTarget.clientFile];
    self.editable = self.editable & [[DataManager defaultInstance] isClientTargetEditable:newClientTarget];
}

/**
 * @abstract Set value to property of editable
 */
- (void)setEditable:(BOOL)isEditable
{
    _editable = isEditable;
    
    // 更改界面状态
    self.operationBgView.userInteractionEnabled = _editable;
}

/**
 * @abstract Get value to property of arrSigns
 */
- (NSMutableArray *)arrSigns
{
    if (!_arrSigns)
        _arrSigns = [[NSMutableArray alloc] initWithCapacity:4];
    return _arrSigns;
}

/**
 * @abstract Get value to property of arrPageHeight
 */
- (NSMutableArray *)arrPageHeight
{
    if (!_arrPageHeight)
    {
        _arrPageHeight = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < [m_pdfdoc pageCount]; i++)
        {
            float fWidth = 0.0f;
            float fHeight = 0.0f;
            FSPDF_Page_GetSize([m_pdfdoc getPDFPage:i], &fWidth, &fHeight);
            float realHeight = fHeight / fWidth * (self.documentDisplayView.frame.size.width - WebViewWidthSpace);
            realHeight += WebViewHeightSpace;
            [_arrPageHeight addObject:[NSNumber numberWithFloat:realHeight]];
        }
    }
    return _arrPageHeight;
}

#pragma mark - Interactions of UI

/**
 * @abstract 导航取消返回（包括即时签名取消）
 */
- (IBAction)cancelButtonClicked:(id)sender
{
    if (bCreateNewSign)
    {
        bCreateNewSign = NO;
        [self.directSignView setHidden:YES];
        
        // 重新打开签名相关操作
        [self.operationBgView setHidden:NO];
        [self.submitButton setHidden:!bDirtyFlag];
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 * @abstract 确认操作
 */
- (IBAction)submitButtonClicked:(id)sender
{
    if (clientTarget)
    {
        // 进行sign请求
        Client_sign_flow *currentSignFlow = clientTarget.clientFile.currentSignflow;
        currentSign = [[DataManager defaultInstance] finishSignFlow:currentSignFlow withStatus:@(2)];

        NSDictionary *actions = [[ActionManager defaultInstance] signRequestAction:currentSign andTarget:clientTarget];
        self.signRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, ActionRequestPath] Parameter:actions];
     }
}

/**
 * @abstract 获得页面上一点的逻辑位置，如果页面有放大，自动转换到原始比例下坐标
 */
- (CGPoint)getPagePoint:(CGPoint)point inScrollView:(UIScrollView *)scrollView
{
    CGPoint contentOffset = self.documentDisplayView.scrollView.contentOffset;
    float scale = self.documentDisplayView.scrollView.zoomScale;
    int nIndex = 0;
    float fHeight = 0.0f;
    float fY = contentOffset.y;
    for (; nIndex < self.arrPageHeight.count; nIndex++)
    {
        // 页面被放大，每页高度也发生变化
        CGFloat pageSizeAfterScaled = [[self.arrPageHeight objectAtIndex:nIndex] floatValue] * scale;
        if (fHeight + pageSizeAfterScaled > fY + point.y)
        {
            break;
        }
        fHeight += pageSizeAfterScaled;
    }
    // 放大坐标系中点位置
    point.x = point.x + contentOffset.x;
    point.y = point.y + fY - fHeight;
    
    // 还原到初始比例坐标系
    // x坐标变换
    point.x = point.x / scale;
    point.y = point.y / scale;
    
    return point;
}

/**
 * @abstract 向文档显示的地方添加一张图片
 */
- (void)addSignViewToDoc:(SignatureClipView*)signatureView withMaxWidth:(float)maxWidth andMinWidth:(float)minWidth
{
    ResizableSignatureClipView *signView = [[ResizableSignatureClipView alloc] initWithFrame:signatureView.frame];
    signView.maxWidth = maxWidth;
    signView.minWidth = minWidth;
    signView.del = self;
    signView.bInEdit = YES;
    signView.tag = signViewTag++;
    signView.imgView.image = signatureView.imgView.image;
    signView.imgView.backgroundColor = [UIColor clearColor];
    signView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = signView.frame;
    // frame.size.width *= 1.8;
    // frame.size.height *= 1.8;
    signView.frame = frame;
    
    [self.view addSubview:signView];
    [self.arrSigns addObject:signView];

    // 添加手势识别
    UIPanGestureRecognizer *gestPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [signView addGestureRecognizer:gestPan];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    signView.alpha = 1.0f;
    [UIView commitAnimations];
}

#pragma mark - ContactSelectedViewControllerDelegate

- (void)confirmSelectUser:(ContactSelectedViewController *)controller
                 userName:(NSString *)userName
                  address:(NSString *)address
{
    Client_target *fileTarget = clientTarget;
    [fileTarget.clientFile addUserToSignFlow:userName address:address];
    [_addSignerPopoverController dismissPopoverAnimated:YES];
    NSArray *signs = [clientTarget.clientFile sortedSignFlows];
    [self updateSignflowWithSigns:signs];
    
    // NSDictionary *signsetAction = [[ActionManager defaultInstance] signsetAction:fileTarget.clientFile];
    // self.signflowRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, ActionRequestPath] Parameter:signsetAction];
}

/*!
 初始化签名列表
 */
- (void)updateSignflowWithSigns:(NSArray *)signs
{
    BOOL isOwner = !![[Util currentLoginUser].accountId isEqualToString:clientTarget.clientFile.owner_account_id];
    NSUInteger signsCount = signs.count;
    if (isOwner) {
        // 增加一个添加签名按钮
        signsCount++;
    }
    [self.signFlowView updateSignflowConstraintsWithSignCount:signsCount];

    // 清除老的ClientSigns
    [self.signFlowView clearAllClientSigns];
    
    // 添加签名人信息
    for (NSInteger i = 0; i < signs.count; i++) {
        Client_sign *flow = [signs objectAtIndex:i];
        [self.signFlowView addClientSign:flow];
    }
    isOwner &= ![[DataManager defaultInstance] isClientFileFinishedSign:clientTarget.clientFile];
    isOwner &= self.editable;
    [self.signFlowView addNewClientSignButton:isOwner];
    self.signFlowView.supportLongPressAction = isOwner;
    BlockWeakObject(self, wself);
    self.signFlowView.newClientSignClickedBlock = ^{
        BlockStrongObject(wself, self);
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
        ContactSelectedViewController *selectedController = [story instantiateViewControllerWithIdentifier:@"ContactSelectedViewController"];
        self.addSignerPopoverController = [[UIPopoverController alloc] initWithContentViewController:selectedController];
        CGRect source = self.signFlowView.frame;
        
        selectedController.delegate = self;
        [self.addSignerPopoverController presentPopoverFromRect:source inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    };
    self.signFlowView.shouldDeleteClientSignBlock = ^(Client_sign *clienSign)
    {
        BlockStrongObject(wself, self);
        [clientTarget.clientFile removeClientSign:clienSign];
        return YES;
    };
}

/*!
 显示/隐藏signflow
 @param show 是否显示signflow
 */
- (void)showSignFlow:(BOOL)show
{
    CGPoint centerPoint = self.signFlowView.center;
    if (show)
    {
        centerPoint.x = self.view.frame.size.width - self.signFlowView.frame.size.width / 2.0;
    }
    else
    {
        centerPoint.x = self.view.frame.size.width - self.signFlowView.frame.size.width / 2.0 + MaxSignFlowXOffset;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.signFlowView.center = centerPoint;
    }];
}

/**
 * @abstract 手势操作签名图
 */
- (void)handlePan:(UIPanGestureRecognizer *)panGest
{
    UIView *panView = (UIView *)panGest.view;
    if ([panView isKindOfClass:[ResizableSignatureClipView class]])
    {
        // 处理签名拖动
        CGPoint point = [panGest translationInView:self.backgroundView];
        CGRect dragRect = [self.backgroundView convertRect:CGRectMake(0.0f, 0.0f, panView.frame.size.width, panView.frame.size.height) fromView:panGest.view];
        
        // 求得下一次移动时坐标位置
        dragRect = CGRectMake(dragRect.origin.x + point.x, dragRect.origin.y + point.y, dragRect.size.width, dragRect.size.height);
        if (CGRectContainsRect(self.documentDisplayView.frame, dragRect))
        {
            panGest.view.center = CGPointMake(panGest.view.center.x + point.x, panGest.view.center.y + point.y);
        }
        [panGest setTranslation:CGPointMake(0, 0) inView:self.backgroundView];
    }
    else
    {
        // 右侧签名流处理
        CGPoint point = [panGest translationInView:panView];
        CGPoint centerPoint =
        CGPointMake(panView.center.x + point.x, panView.center.y);
        CGFloat minXCenter = self.view.frame.size.width - panView.frame.size.width / 2.0;
        if (centerPoint.x < minXCenter) {
            centerPoint.x = minXCenter;
        }
        CGFloat maxXCenter = minXCenter + MaxSignFlowXOffset;
        if (centerPoint.x > maxXCenter) {
            centerPoint.x = maxXCenter;
        }
        panView.center = centerPoint;
        if (panGest.state == UIGestureRecognizerStateEnded) {
            if (centerPoint.x > minXCenter + MaxSignFlowXOffset / 2) {
                // 收起
                [self showSignFlow:NO];
            } else {
                [self showSignFlow:YES];
            }
        }
        [panGest setTranslation:CGPointMake(0, 0) inView:panView];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self showSignFlow:YES];
    }
}

#pragma mark - Draw Tools

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

#pragma mark - CASDKDraw Delegate

/**
 * @abstract 该代理方法用于处理得到签名后的静态图像的处理
 */
- (void)CASDKDraw:(CASDKDraw *)controller getDrawImage:(UIImage *)image
{
    bCreateNewSign = NO;
    
    SignatureClipView* signView = [[SignatureClipView alloc] initWithFrame:controller.imageRect];
    [signView.imgView setImage:image];
    [self addSignViewToDoc:signView withMaxWidth:signView.frame.size.width * 1.3f andMinWidth:signView.frame.size.width * 0.3f];
}

/**
 * @abstract 该代理方法用于完成操作后的处理
 */
- (void)CASDKDrawComplete:(CASDKDraw *)controller
{
    [self.directSignView setHidden:YES];
}

#pragma mark - SignatureClipListView Delegate

/**
 * @abstract 开始直接在文档上签署图片，代理SignListView
 */
- (void)SignatureClipListViewDidClickedNewSignBtn:(SignatureClipListView *)curSignsListView
{
    bCreateNewSign = YES;
    
    [self toolClear:self];
    [self.directSignView setHidden:NO];
    [self.operationBgView setHidden:YES];
    [self.submitButton setHidden:YES];
}

/**
 * @abstract 开始通过拖拽签名图在文档上签署，代理SignListView
 */
- (void)SignatureClipListView:(SignatureClipListView *)curSignsListView DidDragSign:(SignatureClipView *)curDragSign ToPoint:(CGPoint)point
{
    CGRect rectInView = [self.view convertRect:curDragSign.frame fromView:curDragSign.superview];
    
    CGRect dragRect = [self.documentDisplayView convertRect:curDragSign.frame fromView:curDragSign.superview];
    
    if (CGRectContainsRect(self.documentDisplayView.frame, dragRect))
    {
        NSLog(@"%s, 包含关系", __FUNCTION__);
        curDragSign.frame = rectInView;
        [self addSignViewToDoc:curDragSign withMaxWidth:300 andMinWidth:80];
    }
    [curDragSign removeFromSuperview];
    
    [self.operationBgView setHidden:YES];
    [self.submitButton setHidden:YES];
}

#pragma mark - SignatureClipView Delegate

/**
 * @abstract 删除一个签名图片，代理DefaultSignView
 */
- (void)SignatureClipViewDidRemove:(SignatureClipView *)signView
{
    //[[DataManager defaultInstance] deleteSignFile:signView.defaultSign];
    // 更新界面
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [signView removeFromSuperview];
    [UIView commitAnimations];
    // 删除缓存数组中的签名
    for (int i = 0; i < self.arrSigns.count; i++)
    {
        ResizableSignatureClipView *view = [self.arrSigns objectAtIndex:i];
        if (view.tag == signView.tag)
        {
            [self.arrSigns removeObjectAtIndex:i];
            break;
        }
    }
    
    // 重新打开签名相关操作
    [self.operationBgView setHidden:NO];
    [self.submitButton setHidden:!bDirtyFlag];
}

/**
 * @abstract 嵌入签名图片，代理DefaultSignView
 */
- (void)SignatureClipViewDidConfirm:(SignatureClipView *)signView
{
    ResizableSignatureClipView *sign = (ResizableSignatureClipView *)[self.arrSigns lastObject];
    CGRect signImageFrame = [self.documentDisplayView convertRect:sign.imgView.frame fromView:sign];
    
    CGPoint contentOffset = self.documentDisplayView.scrollView.contentOffset;
    // 签名图片实际显示区域
    signImageFrame = [sign.imgView.image convertRect:signImageFrame withContentMode:UIViewContentModeScaleAspectFit];
    
    // 原始比例下的左上点以及右下点
    CGPoint leftUpPoint = [self getPagePoint:signImageFrame.origin inScrollView:self.documentDisplayView.scrollView];
    CGPoint rightDownPoint = [self getPagePoint:CGPointMake(signImageFrame.origin.x + signImageFrame.size.width, signImageFrame.origin.y + signImageFrame.size.height) inScrollView:self.documentDisplayView.scrollView] ;
    
    // 根据视图滚动的位置计算实际的签名图偏移fTotalHeight
    float fTotleHeight = 0.0f;
    float scale = self.documentDisplayView.scrollView.zoomScale;
    int nIndex = 0;
    while (nIndex < self.arrPageHeight.count)
    {
        // 页面被放大，每页高度也发生变化
        CGFloat pageSizeAfterScaled = [[self.arrPageHeight objectAtIndex:nIndex] floatValue] * scale;
        fTotleHeight += pageSizeAfterScaled;
        if (fTotleHeight <= contentOffset.y + signImageFrame.origin.y)
            nIndex++;
        else
            break;
    }
    NSLog(@"%s, %d, %@, %@", __FUNCTION__, nIndex, NSStringFromCGPoint(leftUpPoint), NSStringFromCGPoint(rightDownPoint));
    
    // 将签名图写入临时文件（这一步为后来收集签名图片做准备，暂时没有用）
    NSString *uuidImage = [Util generalUUID];
    NSData *dataImage = UIImagePNGRepresentation(sign.imgView.image);
    NSString *signCachedFolder = [FileManagement signsImageCachedFolder];
    NSString *desFile = [signCachedFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", uuidImage]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:desFile isDirectory:NO]) {
        [manager removeItemAtPath:desFile error:nil];
    }
    BOOL bResult = [dataImage writeToFile:desFile atomically:YES];
    if (bResult != YES) return;
    
    // 使用PDF SDK将签名图嵌入文档
    float fWidth = 0.0f;
    float fHeight = 0.0f;
    FSPDF_Page_GetSize([m_pdfdoc getPDFPage:nIndex], &fWidth, &fHeight);
    float realHeight = fHeight / fWidth * (self.documentDisplayView.frame.size.width - WebViewWidthSpace);
    realHeight += WebViewHeightSpace;
    CGSize viewSize = CGSizeMake(self.documentDisplayView.frame.size.width, realHeight);
    [m_pdfdoc setCurPage:[m_pdfdoc getPDFPage:nIndex]];
    CGPoint deviceLeftUpPoint = [m_pdfdoc pointInPageIndex:nIndex fromPoint:leftUpPoint inViewSize:viewSize];
    CGPoint deviceRightDownPoint = [m_pdfdoc pointInPageIndex:nIndex fromPoint:rightDownPoint inViewSize:viewSize];
    NSLog(@"%@, %@",  NSStringFromCGPoint(leftUpPoint), NSStringFromCGPoint(rightDownPoint));
    
    //
    [m_pdfdoc AddStampAnnotWithPath:desFile leftTopPoint:deviceLeftUpPoint rightBottomPoint:deviceRightDownPoint];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"使用文鼎创Bluekey签名", @"使用CFCA Bluekey签名", @"使用淦蓝软证书签名", nil];
    
    [self.actionSheet showInView:self.documentDisplayView];
    
    // 重新加载文档，显示签名后的文件并去掉临时加入的图片
    
    // 设置刷新页面时文档偏移量，需要还原offset为初始比例坐标系
    contentOffsetY = contentOffset.y / scale;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [self.documentDisplayView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.fileTempPath]]];
    [sign removeFromSuperview];
    [UIView commitAnimations];
    
    // 重新打开签名相关操作
    bDirtyFlag = YES;
    [self.operationBgView setHidden:NO];
    [self.submitButton setHidden:NO];
}

/*!
 *  @abstract 重置sign的数据
 */
- (void) resetSignData
{
    [self.navigationController hideProgress];
    Client_sign_flow *currentSignFlow = clientTarget.clientFile.currentSignflow;
    [[DataManager defaultInstance] resetSignDate:currentSignFlow];
}

/**
 *  @abstract 更新还未保存的签名图的坐标
 */
- (void) updateResizableSign:(CGFloat) zoomScale
{
    ResizableSignatureClipView *curView = [self.arrSigns lastObject];
    
    CGPoint center = curView.center;
    center.x *= zoomScale;
    center.y *= zoomScale;
    curView.center = center;
    
    //边界值判断
    CGRect frame = curView.frame;
    frame.origin.x = frame.origin.x > 0 ? frame.origin.x : 2;
    frame.origin.x = frame.origin.x + frame.size.width < self.documentDisplayView.frame.size.width ? frame.origin.x : self.documentDisplayView.frame.size.width - frame.size.width-2;
    frame.origin.y = frame.origin.y > 0 ? frame.origin.y : 2;
    frame.origin.y = frame.origin.y + frame.size.height < self.documentDisplayView.frame.size.height ? frame.origin.y: self.documentDisplayView.frame.size.height - frame.size.height -2;
    //conent size 因为surSign添加在documentDisplayView上，不是在documentDisplayView的scrollView上。
    // frame.origin.y = frame.origin.y + frame.size.height < documentDisplayView.scrollView.contentSize.height ? frame.origin.y : documentDisplayView.scrollView.contentSize.height - frame.size.height -2;

    curView.frame = frame;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    
    switch (buttonIndex)
    {
        case 0:
        {
            // TODO: 使用文鼎创Bluekey签名
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在处理...";
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            
            UIImage* image = [UIImage imageNamed:@"OperationSuccess"];
			if (image != nil)
			{
				hud.mode = MBProgressHUDModeCustomView;
				hud.customView = [[UIImageView alloc] initWithImage:image];
			}
			
			hud.labelText = @"签名成功";
            
            [self performSelector:@selector(hidenProgressViewWithNotify)
                       withObject:nil
                       afterDelay:0.2f];
        }
            break;
            
        case 1:
        {
            // TODO: 使用CFCA Bluekey签名
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在处理...";
            hud.dimBackground = YES;
            hud.removeFromSuperViewOnHide = YES;
            
            UIImage* image = [UIImage imageNamed:@"OperationSuccess"];
			if (image != nil)
			{
				hud.mode = MBProgressHUDModeCustomView;
				hud.customView = [[UIImageView alloc] initWithImage:image];
			}
			
			hud.labelText = @"签名成功";
            
            [self performSelector:@selector(hidenProgressViewWithNotify)
                       withObject:nil
                       afterDelay:0.2f];
        }
        
        case 2:
        {
            // TODO: 使用淦蓝软证书签名
            return;
        }
            
        default:
            break;
    }
}

- (void)hidenProgressViewWithNotify
{
	[MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Request Manager Delegate

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        NSLog(@"Upload Sign PDF Started!");
    }
    if (request == self.upCompleteRequest)
    {
        NSLog(@"Upload Complete request started");
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.upSignRequest)
    {
        NSLog(@"Upload Sign PDF Failed!");
        [self resetSignData];
        [UIAlertView showAlertMessage:SignFailMessage];
    }
    if (request == self.upCompleteRequest)
    {
        [self resetSignData];
        [UIAlertView showAlertMessage:SignFailMessage];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    // 上传签名后的文件完成
    if (request == self.upSignRequest)
    {
        NSDictionary *resDict = [[request responseString] jsonValue];
        NSDictionary *filePath = [resDict objectForKey:@"filePath"];
        
        if (filePath && [filePath objectForKey:@"filePaths"])
        {
            NSString *url = [filePath objectForKey:@"filePaths"];
            Client_sign_flow *currentSignFlow = clientTarget.clientFile.currentSignflow;
            NSDictionary *complete = [[CompleteManager defaultInstance] uploadCompleteCommand:0 completeId:currentSignFlow.file_id completeURL:url];
            self.upCompleteRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, UploadCompleteRequestPath] Parameter:complete];
        }
        else
        {
            [self resetSignData];
            [UIAlertView showAlertMessage:SignFailMessage];
        }
    }

    // 进行签名流程完成的操作
    if (request == self.upCompleteRequest)
    {
        //进行文件拷贝
        NSString *physicalName = [NSString stringWithFormat:@"%@", clientTarget.clientFile.phsical_filename];
        [FileManagement removeFile:clientTarget.clientFile.phsical_filename];
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if (![manager fileExistsAtPath:physicalName])
        {
            NSError *error;
            BOOL bResult = [manager copyItemAtPath:self.fileTempPath toPath:physicalName error:&error];
            NSLog(@"the move action is %@", @(bResult));
        }
        
        //隐藏提交信息
        [self.navigationController hideProgress];
        [self.operationBgView setHidden:YES];
        self.submitButton.hidden = YES;//隐藏按钮
    }
}

#pragma mark - Action Manager Delegate

// 异步请求开始通知外部程序
- (void)actionRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.lockSignRequest)
    {
        NSLog(@"Lock sign file started");
    }
    if (request == self.signRequest)
    {
        NSLog(@"Sign Request started");
        [self.navigationController showProgressText:@"提交中..."];
    }
}

// 异步请求失败通知外部程序
- (void)actionRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.lockSignRequest) {
        NSLog(@"Lock sign file failed!");
        self.operationBgView.hidden = YES;
    }
    if (request == self.signRequest) {
        [self resetSignData];
        [UIAlertView showAlertMessage:SignFailMessage];
    }
}

// 异步请求结束通知外部程序
- (void)actionRequestFinished:(ASIHTTPRequest *)request
{
    //进行外部请求，这里需要进行的是将签名信息显示出来
    if (request == self.lockSignRequest)
    {
        //进行结果解析，判断是否需要显示签名版
        NSDictionary *dict = [[request responseString] jsonValue];
        NSArray *arr = [dict objectForKey:@"actions"];
        NSDictionary *str = [arr firstObject];
        
        if (str && [[str objectForKey:@"actionResult"] intValue] == 0)
        {
            self.operationBgView.hidden = NO;
            self.operationBgConstraint.constant = 56.0f;
        }
        else
        {
            self.operationBgView.hidden = YES;
            self.operationBgConstraint.constant = 0.0f;
        }
    }
    
    //进行签名处理的处理
    if (request == self.signRequest)
    {
        NSDictionary *resDict = [[request responseString] jsonValue];
        if (resDict && [resDict objectForKey:@"actions"])
        {
            if ([[resDict objectForKey:@"actions"] isKindOfClass:[NSArray class]])
            {
                NSDictionary *action = [[resDict objectForKey:@"actions"] firstObject];
                if ([[action objectForKey:@"actionResult"] intValue] == 1 )
                {
                    //签名成功，上传文件
                    NSString *physicalName = [NSString stringWithFormat:@"%@", clientTarget.clientFile.phsical_filename];
                    self.upSignRequest = [[RequestManager defaultInstance] asyncPostData:APIBaseUpload file:physicalName isPDF:YES];
                    return;
                }
                else
                {
                    [UIAlertView showAlertMessage:SignFailMessage];
                }
            }
        }

        [self resetSignData];
    }
}

@end
