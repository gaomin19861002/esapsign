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
#import "DataManager+SignPic.h"
#import "DataManager+Targets.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "FileDetailCell.h"
#import "FilePaddingCell.h"
#import "NSDate+Additions.h"
#import "Client_file.h"
#import "NSArray+Additions.h"
#import "UIAlertView+Additions.h"
#import "ContactSelectedViewController.h"
#import "DocDetailViewController.h"
#import "AllNaviViewController.h"
#import "SyncManager.h"
#import "DownloadManager.h"
#import "Util.h"
#import "RequestManager.h"
#import "ActionManager.h"
#import "CAAppDelegate.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"

/*!
 定义AlertView相关Tag
 */
#define AlertViewModifyFolder   100
#define AlertViewCreateFile     101
#define AlertViewModifyFile     102

@interface DocListViewController ()<FileDetailCellDelegate, RequestManagerDelegate>

@property (nonatomic, retain) UIPopoverController* addSignerPopoverController;
@property (nonatomic, assign) NSInteger expandRow;
@property (nonatomic, assign) NSInteger selectedRow;

@property(nonatomic, retain) ASIFormDataRequest *signflowRequest;
@property(nonatomic, retain) Client_sign *currentAppendSign;

// 导航栏右侧按钮
@property(nonatomic, retain) UIBarButtonItem *addFileBarItem;
@property(nonatomic, retain) UIBarButtonItem *changeFolderNameItem;

@end

@implementation DocListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%s", __FUNCTION__);

#warning 搜索功能按钮暂时尚未完成
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor blueColor];
    searchBar.placeholder = @"输入文件名进行检索";
    // UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    
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
    
    [[RequestManager defaultInstance] registerDelegate:self];
}

- (void)dealloc
{
    [[RequestManager defaultInstance] unRegisterDelegate:self];
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

        if ([self.parentTarget.type intValue] == TargetTypeSystemFolder)
        {
#warning 暂时屏蔽新建文件按钮
            //self.navigationItem.rightBarButtonItems = @[_addFileBarItem];
        }
        else
        {
#warning 暂时屏蔽新建文件按钮
            self.navigationItem.rightBarButtonItems = @[/*_addFileBarItem,*/_changeFolderNameItem];
        }
        self.expandRow = -1;
        self.selectedRow = -1;
        [self.tableView reloadData];
        if ([self.tableView numberOfRowsInSection:0] > 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

// 设置签名状态标签
- (void)setSignStatusLabel:(FileDetailCell*)cell bySignFlow:(Client_sign_flow*) signFlow
{
    // 如果没有签名流程，隐藏所有状态标签并返回
    if ([signFlow.signs count] == 0)
    {
        [cell.signProgressTotal setHidden:YES];
        [cell.signProgressCurrent setHidden:YES];
        return;
    }
    
    [cell.signProgressTotal setHidden:NO];
    [cell.signProgressCurrent setHidden:NO];
    
    // 当前用户id
    NSString* currentUserId = [Util currentLoginUserId];
    
    SignProgressStatus signProgress = SignProgressOK;
    
    // 遍历所有签名包
    for (Client_sign * sign in signFlow.signs)
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
                [cell.signProgressCurrent setImage:[UIImage imageNamed:@"signAccept"]];
            }
            else if (sign.refuse_date != nil)
            {
                [cell.signProgressCurrent setImage:[UIImage imageNamed:@"signReject"]];
                signProgress = SignProgressFail;
                break;
            }
            else if ([sign.sign_id isEqualToString:signFlow.current_sign_id]
                     || (needSequence && signFlow.current_sequence == sign.sequence)) // 轮到当前用户签名
            {
                [cell.signProgressCurrent setImage:[UIImage imageNamed:@"SignWaiting"]];
                signProgress = SignProgressInProgress;
            }
            else
                [cell.signProgressCurrent setHidden:YES];
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
            [cell.signProgressTotal setImage:[UIImage imageNamed:@"progressOK"]];
            break;
        case SignProgressFail:
            [cell.signProgressTotal setImage:[UIImage imageNamed:@"progressFail"]];
            break;
        case SignProgressInProgress:
            [cell.signProgressTotal setImage:[UIImage imageNamed:@"progress"]];
            break;
    }
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    FileDetailCell* cell = (FileDetailCell*)sender;
    if (!cell)
        return NO;
    
    if ([identifier isEqualToString:@"openFile"] && cell != nil)
    {
        if (cell.status != FileStatusFinished
            || [cell.targetInfo.refFile.file_type intValue] != FileExtendTypePdf) // 暂时不打开除PDF以外类型的文件
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

            // 设置当前用户对应的签名包
            viewFileController->currentSign = nil;
            Client_sign_flow* signFlow = cell.targetInfo.refFile.fileFlow;
            if (signFlow != nil)
            {
                for (Client_sign * sign in signFlow.signs)
                {
                    // 当前用户参与该签名流程，设置个人签名状态标签
                    if ([sign.sign_account_id isEqualToString:[Util currentLoginUserId]])
                        viewFileController->currentSign = sign;
                }
            }
        }
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
            [[DataManager defaultInstance] modifyTarget:self.parentTarget.target_id displayName:field.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:DocViewUpdateNotification object:nil];
        }
        else if (alertView.tag == AlertViewCreateFile)
        {
            UITextField *field = [alertView textFieldAtIndex:0];
            [[DataManager defaultInstance] addFile:FileExtendTypePdf
                                       displayName:field.text
                                              path:nil
                                          parentID:self.parentTarget.target_id];
            self.parentTarget.subFiles = nil;
            [self.tableView reloadData];
        }
        else if (alertView.tag == AlertViewModifyFile)
        {
            if (self.selectedRow > -1) {
                UITextField *field = [alertView textFieldAtIndex:0];
                Client_target *fileTarget = [self.parentTarget.subFiles objectAtIndex:self.selectedRow];
                [[DataManager defaultInstance] modifyTarget:fileTarget.target_id displayName:field.text];
                self.parentTarget.subFiles = nil;
                [self.tableView reloadData];
            }
        }
    }
}

// 修改目录名称按钮响应方法
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

// 新建按钮响应方法
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

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? [self.parentTarget.subFiles count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        FileDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FileDetailCell" forIndexPath:indexPath];
        Client_target *fileTarget = (Client_target *)[self.parentTarget.subFiles objectAtIndex:indexPath.row];
        NSLog(@"File ID is : %@", fileTarget.file_id);
        cell.backgroundColor = [UIColor clearColor];
        cell.targetInfo = fileTarget;
        cell.delegate = self;
        cell.titleLabel.font = [UIFont fontWithName:@"Libian SC" size:20.0];
        cell.titleLabel.text = fileTarget.display_name;
        cell.signLabel.text = nil;
        cell.createLabel.text = [fileTarget.create_time fullDateString];
        cell.updateLabel.text = [fileTarget.update_time fullDateString];
        cell.status = [fileTarget.refFile fileDownloadStatus];
#warning 现在不允许编辑签名流程
        cell.signManageAvaliable = NO;
        cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
        
        Client_file *file = fileTarget.refFile;
        if ([file.file_type intValue] == FileExtendTypePdf)
            cell.leftImageView.image = [UIImage imageNamed:@"FileTypePDF"];
        else if ([file.file_type intValue] == FileExtendTypeTxt)
            cell.leftImageView.image = [UIImage imageNamed:@"FileTypeText"];
        else
            cell.leftImageView.image = [UIImage imageNamed:@"FileTypeImage"];
        
        bool isPDFfile = ([file.file_type intValue] == FileExtendTypePdf);
        [cell.rightImageButton setBackgroundImage:[UIImage imageNamed:@"FlowManage"] forState:UIControlStateNormal];
        [cell.rightImageButton setHidden:!isPDFfile];
        if (isPDFfile && (self.expandRow == indexPath.row))
            [cell updateSignFlow:file.fileFlow];
    
        // 根据sign flow来设置当前文件的签署流程状态标签和个人签署状态标签
        [self setSignStatusLabel:cell bySignFlow:file.fileFlow];
        cell.isOwner = [[Util currentLoginUser].accountId isEqualToString:file.owner_account_id];
    
        return cell;
    }
    else // indexPath.section == 1
    {
        FilePaddingCell* cell = (FilePaddingCell*)[self.tableView dequeueReusableCellWithIdentifier:@"PaddingCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        [cell.paddingTitle setHidden:([self.parentTarget.subFiles count] > 0)];
        // [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return self.expandRow == indexPath.row ? 175.0f : 75.0f;
    else
        return 75.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    if (self.selectedRow != self.expandRow)
        self.expandRow = -1;
    [tableView reloadData];

    FileDetailCell* cell = (FileDetailCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == [self.tableView.visibleCells lastObject])
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    else if (cell == [self.tableView.visibleCells firstObject])
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    else
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - FileDetailCellDelegate Methods

/**
 * @abstract 展开或收缩签名流程
 */
- (void)statusButtonClicked:(FileDetailCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.expandRow != indexPath.row)
        self.expandRow = indexPath.row;
    else
        self.expandRow = -1;
    self.selectedRow = indexPath.row;
    [self.tableView reloadData];
    
    if (cell == [self.tableView.visibleCells lastObject])
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    else if (cell == [self.tableView.visibleCells firstObject])
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    else
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
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
 * @abstract 文件下载管理按钮
 */
- (void)downLoadButtonClicked:(FileDetailCell *)cell
{
    if (cell.status == FileStatusDownloading)
    {
        // 暂停下载
        BOOL pause = [[DownloadManager defaultInstance] pauseDownloadingWithFile:cell.targetInfo.refFile.file_id];
        if (pause)
            cell.status = FileStatusPauseDownload;
    }
    else if (cell.status == FileStatusPauseDownload || cell.status == FileStatusNotStarted)
    {
        [[DownloadManager defaultInstance] startDownloadingWithFile:cell.targetInfo.refFile.file_id];
    }
    else if (cell.status == FileStatusWaitingDownload)
    {
        [[DownloadManager defaultInstance] cancelDownloadingWithFile:cell.targetInfo.refFile.file_id];
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
    Client_target *fileTarget = (Client_target *)[self.parentTarget.subFiles objectAtIndex:self.expandRow];
    self.currentAppendSign = [fileTarget.refFile.fileFlow addUserToSignFlow:userName address:address];
    [self.tableView reloadData];
    [_addSignerPopoverController dismissPopoverAnimated:YES];
    
    //NSDictionary *signsetAction = [[ActionManager defaultInstance] signsetAction:fileTarget.refFile];
    //self.signflowRequest = [[ActionManager defaultInstance] addToQueue:signsetAction];
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

@end
