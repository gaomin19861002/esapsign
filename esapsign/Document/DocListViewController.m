//
//  DocListViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DocListViewController.h"
#import "Client_target.h"
#import "UINavigationController+Additions.h"
#import "DataManager.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "FileDetailCell.h"
#import "NSDate+Additions.h"
#import "Client_file.h"
#import "NSArray+Additions.h"
#import "UIAlertView+Additions.h"
#import "SignatureClipListView.h"
#import "HandSignViewController.h"
#import "ContactSelectedViewController.h"
#import "DocDetailViewController.h"
#import "AllNaviViewController.h"
#import "SyncManager.h"
#import "DownloadManager.h"
#import "Util.h"
#import "RequestManager.h"
#import "ActionManager.h"
#import "CAAppDelegate.h"
#import "NoRotateNaviViewController.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"

/*!
 定义AlertView相关Tag
 */
#define AlertViewModifyFolder   100
#define AlertViewCreateFile     101
#define AlertViewModifyFile     102

@interface DocListViewController ()<FileDetailCellDelegate, SignatureClipListViewDelegate, HandSignViewControllerDelegate, RequestManagerDelegate>

@property(nonatomic, retain) NSMutableArray *foldStatus;
@property(nonatomic, assign) NSInteger lastRow;
@property(nonatomic, assign) NSInteger selectedRow;

@property(nonatomic, retain) ASIFormDataRequest *signflowRequest;
@property(nonatomic, retain) Client_sign *currentAppendSign;

/*!
 导航栏右侧按钮
 */
@property(nonatomic, retain) UIBarButtonItem *addFileBarItem;
@property(nonatomic, retain) UIBarButtonItem *changeFolderNameItem;

/*!
 定义底部的预置签名界面
 */
@property(nonatomic, retain) SignatureClipListView *signListView;

/*!
 签名界面
 */
@property(nonatomic, retain) HandSignViewController *handSignController;

/*!
 修改目录名称按钮响应方法
 */
- (void)modifyFolderButtonClicked:(id)sender;

/*!
 新建按钮响应方法
 */
- (void)addFileButtonClicked:(id)sender;

- (void)handleSignFileDownloadUpdate:(NSNotification *)notification;

@end

@implementation DocListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s", __FUNCTION__);
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[self bottomBarView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"RightBackground"]]];

    // 添加左侧搜索栏
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor blueColor];
    searchBar.placeholder = @"输入文件名进行检索";
    
#warning 搜索功能按钮暂时尚未完成
    // UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    
    // 添加右侧操作按钮
    _changeFolderNameItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                           target:self
                                                                           action:@selector(modifyFolderButtonClicked:)];
    _addFileBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                     target:self
                                                                     action:@selector(addFileButtonClicked:)];
    
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.sectionHeaderHeight = 0.0f;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.signListView setArrDefaultSigns:[DataManager defaultInstance].allDefaultSignFiles];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSignFileDownloadUpdate:) name:DownloadSignFileUpdateNotification object:nil];
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RequestManager defaultInstance] registerDelegate:self];
    
    // 此处纠正位置是因为，在初始生成的时候，还无法判定旋转屏状态，第一次进入页面重新刷下
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) || UIDeviceOrientationIsPortrait(self.interfaceOrientation) ) {
        
        self.signListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth - 320.0), 0);
        CGRect frame = _signListView.signCollectionView.frame;
        frame.origin.x = -31;
        frame.size.width = 604;
        _signListView.signCollectionView.frame = frame;
        NSLog(@"%@", NSStringFromCGRect(_signListView.signCollectionView.frame));
    }else {
        self.signListView.transform = CGAffineTransformIdentity;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[RequestManager defaultInstance] unRegisterDelegate:self];
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setParentTarget:(Client_target *)parentTarget
{
    if (![_parentTarget isEqual:parentTarget])
    {
        _parentTarget = parentTarget;

        // 修改当前视图的标题会影响到其归属NavigationController，注意保存现场
        NSString* keep = [[self parentViewController] title];
        [self setTitle:[NSString stringWithFormat:@"%@", parentTarget.display_name]];
        [[self parentViewController] setTitle:keep];

        if ([self.parentTarget.type intValue] == TargetTypeSystemFolder) {
#warning 暂时屏蔽新建文件按钮
            //self.navigationItem.rightBarButtonItems = @[_addFileBarItem];
        } else {
#warning 暂时屏蔽新建文件按钮
            self.navigationItem.rightBarButtonItems = @[/*_addFileBarItem,*/_changeFolderNameItem];
        }
        
        self.lastRow = 0;
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)foldStatus
{
    if (!_foldStatus)
    {
        if ([self.parentTarget.subFiles count])
        {
            _foldStatus = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i < [self.parentTarget.subFiles count]; i++) {
                [_foldStatus addObject:@(NO)];
            }
        }
    }
    
    return _foldStatus;
}

- (SignatureClipListView *)signListView
{
    if (!_signListView)
    {
        _signListView = [[SignatureClipListView alloc] initWithFrame:CGRectMake(0, 0, 704, 56)];
        _signListView.signsListDelegate = self;
        // _signListView.allowDragSign = YES;
        _signListView.clipsToBounds = NO;
        [_signListView.btnAdd setImage:[UIImage imageNamed:@"SignNew"] forState:UIControlStateNormal];
        _signListView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]];
        [self.bottomBarView addSubview:_signListView];
    }
    
    return _signListView;
}

- (HandSignViewController *)handSignController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Toolkits_iPad" bundle:nil];
    _handSignController = [storyBoard instantiateViewControllerWithIdentifier:@"NewSignViewController"];
    // _handSignController.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f];
    _handSignController.delegate = self;
    // _handSignController.view.frame = CGRectMake(0.0f,64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f - 60.0f);
    return _handSignController;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    FileDetailCell* cell = (FileDetailCell*)sender;
    if (!cell)
        return NO;
    
    if ([identifier isEqualToString:@"openFile"] && cell != nil)
    {
        if (cell.status != FileStatusFinished)
            return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FileDetailCell* cell = (FileDetailCell*)sender;
    if ([segue.identifier isEqualToString:@"openFile"] && cell != nil)
    {
        if (cell.status == FileStatusFinished)
        {
            UINavigationController* nc = (UINavigationController*)segue.destinationViewController;
            DocDetailViewController* viewFileController = (DocDetailViewController*)nc.topViewController;
            viewFileController->clientTarget = cell.targetInfo;
        }
    }
}

#pragma mark - Private Methods

/*!
 修改目录名称按钮响应方法
 */
- (void)modifyFolderButtonClicked:(id)sender
{
    UIAlertView *folderAlert = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"请输入目录名称"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定", nil];
    folderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [folderAlert textFieldAtIndex:0];
    field.text = self.parentTarget.display_name;
    folderAlert.tag = AlertViewModifyFolder;
    [folderAlert show];
}

/*!
 新建按钮响应方法
 */
- (void)addFileButtonClicked:(id)sender
{
    UIAlertView *fileAlert = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"请输入文件名称"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    fileAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    fileAlert.tag = AlertViewCreateFile;
    [fileAlert show];
}

/**
 * @abstract 设置签名状态标签
 */
- (void)setSignStatusLabel:(FileDetailCell*)cell bySignFlow:(Client_sign_flow*) signFlow
{
    // 如果没有签名流程，隐藏所有状态标签并返回
    if ([signFlow.clientSigns count] == 0)
    {
        [cell.signProgressView setHidden:YES];
        [cell.signStatusView setHidden:YES];
        return;
    }
    
    [cell.signProgressView setHidden:NO];
    [cell.signStatusView setHidden:NO];
    
    // 当前用户id
    NSString* currentUserId = [Util currentLoginUserId];
    
    SignProgressStatus signProgress = SignProgressOK;
    
    // 遍历所有签名包
    for (Client_sign * sign in signFlow.clientSigns)
    {
        // 当前签名人如果已经完成签名，或者尚无当前签名人，则要求后续判断时注意新的签名顺序
        bool needSequence = NO;
        if (([sign.sign_id isEqualToString:signFlow.current_sign_id] && sign.sign_date != nil)
            || signFlow.current_sign_id == nil || [signFlow.current_sign_id isEqualToString:@""])
            needSequence = YES;
        
        // 当前用户参与该签名流程，设置个人签名状态标签
        if ([sign.sign_account_id isEqualToString:currentUserId])
        {
            if (sign.sign_date != nil)
            {
                [cell.signStatusView setImage:[UIImage imageNamed:@"signAccept"]];
            }
            else if (sign.refuse_date != nil)
            {
                [cell.signStatusView setImage:[UIImage imageNamed:@"signReject"]];
                signProgress = SignProgressFail;
                break;
            }
            else if ([sign.sign_id isEqualToString:signFlow.current_sign_id]
                     || (needSequence && signFlow.current_sequence == sign.sequence)) // 轮到当前用户签名
            {
                [cell.signStatusView setImage:[UIImage imageNamed:@"SignWaiting"]];
                signProgress = SignProgressInProgress;
            }
            else
                [cell.signStatusView setHidden:YES];
        }
        else // 其他签名包处理
        {
            if (sign.refuse_date != nil)
                signProgress = SignProgressFail;
            else if (sign.sign_date == nil && signProgress != SignProgressFail)
                signProgress = SignProgressInProgress;
        }
    }
    
    // 根据整体签名状态设置对应的签名状态标签。
    switch (signProgress)
    {
        case SignProgressOK:
            [cell.signProgressView setImage:[UIImage imageNamed:@"progressOK"]];
            break;
        case SignProgressFail:
            [cell.signProgressView setImage:[UIImage imageNamed:@"progressFail"]];
            break;
        case SignProgressInProgress:
            [cell.signProgressView setImage:[UIImage imageNamed:@"progress"]];
            break;
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 点击确定按钮
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == AlertViewModifyFolder)
        {
            UITextField *field = [alertView textFieldAtIndex:0];
            self.title = field.text;
            [[DataManager defaultInstance] modifyTarget:self.parentTarget.client_id displayName:field.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:DocViewUpdateNotification object:nil];
        }
        else if (alertView.tag == AlertViewCreateFile)
        {
            UITextField *field = [alertView textFieldAtIndex:0];
            [[DataManager defaultInstance] addFile:FileExtendTypePdf
                                       displayName:field.text
                                              path:nil
                                          parentID:self.parentTarget.client_id];
            self.parentTarget.subFiles = nil;
            [self.tableView reloadData];
        }
        else if (alertView.tag == AlertViewModifyFile)
        {
            if (self.selectedRow > -1) {
                UITextField *field = [alertView textFieldAtIndex:0];
                Client_target *fileTarget = [self.parentTarget.subFiles objectAtIndex:self.selectedRow];
                [[DataManager defaultInstance] modifyTarget:fileTarget.client_id displayName:field.text];
                self.parentTarget.subFiles = nil;
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return [self.parentTarget.subFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FileDetailCell" forIndexPath:indexPath];
    Client_target *fileTarget = (Client_target *)[self.parentTarget.subFiles objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.targetInfo = fileTarget;
    cell.delegate = self;
    cell.titleLabel.font = [UIFont fontWithName:@"Libian SC" size:20.0];
    cell.titleLabel.text = fileTarget.display_name;
    cell.signLabel.text = nil;
    cell.createLabel.text = [fileTarget.create_time fullDateString];
    cell.updateLabel.text = [fileTarget.update_time fullDateString];
    cell.status = [fileTarget.clientFile fileStatus];
#warning 现在不允许编辑签名流程
    cell.signManageAvaliable = NO;
    
    Client_file *file = fileTarget.clientFile;
    if ([file.file_type intValue] == FileExtendTypePdf) {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypePDF"];
    } else if ([file.file_type intValue] == FileExtendTypeTxt) {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypeText"];
    } else {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypeImage"];
    }

    cell.rightImageButton.hidden = [file.file_type intValue] != FileExtendTypePdf;
    
    if ([file.file_type intValue] == FileExtendTypePdf)
    {
        [cell.rightImageButton setBackgroundImage:[UIImage imageNamed:@"FlowManage"] forState:UIControlStateNormal];
        if ([[self.foldStatus objectOrNilAtIndex:indexPath.row] boolValue]) {
            [cell updateSignFlow:[file sortedSignFlows]];
        }
    }
    
    // 根据sign flow来设置当前文件的签署流程状态标签和个人签署状态标签
    [self setSignStatusLabel:cell bySignFlow:file.currentSignflow];

    cell.isOwner = !![[Util currentLoginUser].accountId isEqualToString:file.owner_account_id];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.foldStatus objectOrNilAtIndex:indexPath.row] boolValue])
        return 175.0f;
    return 75.0f;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - FileDetailCellDelegate Methods

/**
 * @abstract 展开或收缩签名流程
 */
- (void)statusButtonClicked:(FileDetailCell *)cell
{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    if(index.row == self.lastRow)
    {
        BOOL isFold = [self.foldStatus[self.lastRow] boolValue];
        self.foldStatus[self.lastRow] = @(!isFold);
    }
    else
    {
        self.foldStatus[self.lastRow] = @(NO);
        self.foldStatus[index.row] = @(YES);
    }
    
    self.lastRow = index.row;
    [self.tableView reloadData];
}

/**
 * @abstract 修改文件名
 */
- (void)modifyButtonClicked:(FileDetailCell *)cell
{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    self.selectedRow = index.row;
    if (self.selectedRow > -1)
    {
        UIAlertView *fileNameAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"请输入文件名称"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
        fileNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        fileNameAlert.tag = AlertViewModifyFile;
        Client_target *fileTarget = [self.parentTarget.subFiles objectAtIndex:self.selectedRow];
        UITextField *field = [fileNameAlert textFieldAtIndex:0];
        field.text = fileTarget.display_name;
        [fileNameAlert show];
    }
    else
    {
        [UIAlertView showAlertMessage:@"请选择要修改的文件"];
    }
}

/**
 * @abstract 添加签名人
 */
- (void)addSignButtonClicked:(FileDetailCell *)cell sender:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    ContactSelectedViewController *selectedController = [story instantiateViewControllerWithIdentifier:@"ContactSelectedViewController"];
    _addSignerPopoverController = [[UIPopoverController alloc] initWithContentViewController:selectedController];
    UIButton* addButton = (UIButton*)sender;
    CGRect source = addButton.frame;
    source.origin.x += cell.frame.origin.x - [self.tableView contentOffset].x;
    source.origin.y += cell.frame.origin.y - [self.tableView contentOffset].y;
    
    selectedController.delegate = self;
    [_addSignerPopoverController presentPopoverFromRect:source inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)submitSignButtonClicked:(FileDetailCell *)cell sender:(id)sender
{
    
}

/**
 * @abstract 文件下载管理按钮
 */
- (void)downLoadButtonClicked:(FileDetailCell *)cell
{
    if (cell.status == FileStatusDownloading)
    {
        // 暂停下载
        BOOL pause = [[DownloadManager defaultInstance] pauseDownloadingWithFile:cell.targetInfo.clientFile.file_id];
        if (pause)
            cell.status = FileStatusPauseDownload;
    }
    else if (cell.status == FileStatusPauseDownload || cell.status == FileStatusNotStarted)
    {
        [[DownloadManager defaultInstance] startDownloadingWithFile:cell.targetInfo.clientFile.file_id];
    }
    else if (cell.status == FileStatusWaitingDownload)
    {
        [[DownloadManager defaultInstance] cancelDownloadingWithFile:cell.targetInfo.clientFile.file_id];
    }
}

#pragma mark - ContactSelectedViewControllerDelegate Methods

/*!
 点击确定按钮，通知外部程序，外部需要调用dismiss退出当前页
 */
- (void)confirmSelectUser:(ContactSelectedViewController *)controller
                 userName:(NSString *)userName
                  address:(NSString *)address
{
    Client_target *fileTarget = (Client_target *)[self.parentTarget.subFiles objectAtIndex:self.lastRow];
    self.currentAppendSign = [fileTarget.clientFile addUserToSignFlow:userName address:address];
    [self.tableView reloadData];
    [_addSignerPopoverController dismissPopoverAnimated:YES];
    
    NSDictionary *signsetAction = [[ActionManager defaultInstance] signsetAction:fileTarget.clientFile];
    self.signflowRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, ActionRequestPath] Parameter:signsetAction];
}

#pragma mark - SignsListViewDelegate Methods

/**
 *  点击新增按钮事件
 *
 *  @param curSignsListView 当前签名列表图
 */
- (void)SignatureClipListViewDidClickedNewSignBtn:(SignatureClipListView *)curSignsListView
{
    [self popHandSignController:YES];
}

- (void)popHandSignController:(BOOL)needVerifyCount
{
    NSLog(@"%s", __FUNCTION__);
    
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:[NSString stringWithFormat:@"%@", user.accountId]];
    Assert(account, @"account shouldn't be null");
    int limitCount = [account.sign_count intValue];
    int signCount = [DataManager defaultInstance].allSignFiles.count;
    
    if (signCount >= limitCount && needVerifyCount)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已达签名上限" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    UINavigationController *nav = [[NoRotateNaviViewController alloc] initWithRootViewController:self.handSignController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)HandSignViewController:(HandSignViewController *)controller DidFinishSignWithImage:(UIImage *)image
{
    [self.signListView insertNewSign:image];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSignFileDownloadUpdate:(NSNotification *)notification
{
    [DataManager defaultInstance].allSignFiles = nil;
    [self.signListView setArrDefaultSigns:[DataManager defaultInstance].allDefaultSignFiles];
}

#pragma mark - RequestManager Delegate

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.signflowRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController showProgressText:@"提交中..."];
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.signflowRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        [UIAlertView showAlertMessage:@"提交签名人失败"];
        
        // 删除刚添加的签名人
        [[DataManager defaultInstance].objectContext deleteObject:self.currentAppendSign];
        self.currentAppendSign = nil;
        [self.tableView reloadData];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.signflowRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        NSString *resString = [request responseString];
        DebugLog(@"res= %@", resString);
        
        NSDictionary *resDict = [resString jsonValue];
        NSArray *actions = [resDict objectForKey:@"actions"];
        if ([actions count])
        {
            NSDictionary *actionDict = [actions firstObject];
            if ([[actionDict objectForKey:@"actionResult"] intValue] == 0) {
                [UIAlertView showAlertMessage:@"提交签名人失败"];
                // 删除刚添加的签名人
                [[DataManager defaultInstance].objectContext deleteObject:self.currentAppendSign];
                self.currentAppendSign = nil;
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark - UIViewController Rotate

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetSignListFrame];
}

- (void)resetSignListFrame
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.signListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth - 320.0), 0); // 320为左侧菜单宽度
            
           CGRect frame = _signListView.signCollectionView.frame;
           frame.origin.x = -31;
           frame.size.width = 604;
          _signListView.signCollectionView.frame = frame;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.signListView.transform = CGAffineTransformIdentity;
            CGRect frame = _signListView.signCollectionView.frame;
            frame.origin.x = 0;
            frame.size.width = 604;
            _signListView.signCollectionView.frame = frame;
        }];
    }
}

@end
