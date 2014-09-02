//
//  DocViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DocViewController.h"
#import "ContextTableViewCell.h"
#import "DetailViewManager.h"
#import "DocDetailViewController.h"
#import "DataManager.h"
#import "ContextHeaderView.h"
#import "Client_target.h"
#import "DocListViewController.h"
#import "UINavigationController+Additions.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

/*!
 定义AlertView的Tag标记
 */
#define TagAlertViewRootFolder      100
#define TagAlertViewSectionFolder   101

@interface DocViewController ()

/*!
 定义所有显示在一级的目录
 */
@property(nonatomic, retain) NSArray *levelOneFolders;

/*!
 定义所有一级目录的展开状态
 */
@property(nonatomic, retain) NSMutableArray *foldStatus;

@property(nonatomic, assign) BOOL lastSectionStatus;

/*!
 定义导航栏左侧按钮
 */
@property(nonatomic, retain) UIBarButtonItem *leftBarItem;

/*!
 定义导航栏右侧按钮
 */
@property(nonatomic, retain) UIBarButtonItem *rightBarItem;

/*!
 返回按钮响应方法
 */
- (void)backButtonClicked:(id)sender;

/*!
 更新通知监听方法
 */
- (void)updateNotification:(NSNotification *)notification;

/*!
 添加目录按钮响应方法
 */
- (void)addFolderButtonClicked:(id)sender;

/*!
 同步更新完成通知监听方法
 @param notification 通知对象
 */
- (void)handleSyncUpdateNotification:(NSNotification *)notification;

@end

@implementation DocViewController

@synthesize listViewController = _listViewController;

- (void) resetViewData
{
    self.lastSectionStatus = YES;
    self.lastSection = 0;
    if (_levelOneFolders)
    {
        _levelOneFolders = nil;
    }
    if (_foldStatus)
    {
        _foldStatus = nil;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resetViewData];

    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.sectionHeaderHeight = 44.0f;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.view.backgroundColor = [UIColor clearColor];
    
    if (self.parent) {
        self.navigationItem.leftBarButtonItem = self.leftBarItem;
        [self.navigationItem setTitle:self.parent.display_name];
    }
    
    self.sysBg = [UIImage imageNamed:@"FolderSysTail"];
    self.defBg = [UIImage imageNamed:@"FolderDefTail"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotification:) name:DocViewUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncUpdateNotification:) name:SyncUpdateFinishedNotification object:nil];
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.foldStatus containsObject:@(YES)]) {
        NSInteger index = [self.foldStatus indexOfObject:@(YES)];
        self.listViewController.parentTarget = self.levelOneFolders[index];
    }

    [self decideShowAddButton];
}

- (UIBarButtonItem *)leftBarItem {
    if (!_leftBarItem) {
        _leftBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                     target:self
                                                                     action:@selector(backButtonClicked:)];
    }
    
    return _leftBarItem;
}

- (UIBarButtonItem *)rightBarItem {
    if (!_rightBarItem) {
        _rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addFolderButtonClicked:)];
    }
    
    return _rightBarItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.levelOneFolders count];
}

/*
 @是否显示脚标：仅当文件夹选中展开并且有子文件夹时显示
 */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    BOOL isFold = [self.foldStatus[section] boolValue];
    return isFold && section == self.lastSection ? 4 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

/*
 @脚标的填充色受一级文件夹的类型影响
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    Client_target *target = [self.levelOneFolders objectAtIndex:section];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
    CGFloat width = isPortrait ? 314.0f : 320.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 6)];
    
    UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 6)];
    footerView.contentMode = UIViewContentModeScaleToFill;
    if ([target.type intValue] == TargetTypeSystemFolder)
        [footerView setImage:self.sysBg];
    else
        [footerView setImage:self.defBg];
    [view addSubview:footerView];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ContextHeaderView *headerView = [ContextHeaderView headerView:self.storyboard];

    Client_target *target = [self.levelOneFolders objectAtIndex:section];
    [headerView.titleButton setTitle:target.display_name forState:UIControlStateNormal];
    
    headerView.countLabel.text = [NSString stringWithFormat:@"%d", [target.subFolders count] + [target.subFiles count]];
    headerView.section = section;
    headerView.delegate = self;
    [headerView updateShowWithTargetType:[target.type intValue] selected:[self.foldStatus[section] boolValue]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.foldStatus[section] boolValue]) {
        Client_target *target = self.levelOneFolders[section];
        return [target.subFolders count];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocCell";
    ContextTableViewCell *cell =(ContextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Client_target *target = self.levelOneFolders[indexPath.section];

    Client_target *subTarget = target.subFolders[indexPath.row];
    [cell.nameButton setTitle:subTarget.display_name forState:UIControlStateNormal];
    cell.countLabel.text = [NSString stringWithFormat:@"%d", [subTarget.subFolders count] + [subTarget.subFiles count]];
    [cell updateColorWithTargetType:[subTarget.type intValue] andParentType:[target.type intValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        DocViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DocViewContoller"];
        Client_target *target = self.levelOneFolders[indexPath.section];
        controller.parent = target;
        controller.lastSection = indexPath.row;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Client_target *target = self.levelOneFolders[indexPath.section];
    Client_target *subTarget = target.subFolders[indexPath.row];
    if ([subTarget.type intValue] == TargetTypeSystemFolder) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Client_target *target = self.levelOneFolders[indexPath.section];
    Client_target *subTarget = [target.subFolders objectAtIndex:indexPath.row];
    [[DataManager defaultInstance] deleteFolders:subTarget.client_id];
    target.subFolders = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Private Methods

/*
 @ 该方法初始化所有一级目录对象
 */
- (NSArray *)levelOneFolders
{
    if (!_levelOneFolders)
    {
        NSString *client_id = @"0";
        if (self.parent)
            client_id = self.parent.client_id;
        _levelOneFolders = [[DataManager defaultInstance] foldersWithParentTarget:client_id];
    }
    
    return _levelOneFolders;
}

/*
 @ 该方法初始化对应存储折叠状态的数组
 */
- (NSMutableArray *)foldStatus
{
    if (!_foldStatus)
    {
        _foldStatus = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < [self.levelOneFolders count]; i++)
            [_foldStatus addObject:@NO];
        if ([_foldStatus count] > 0)
            _foldStatus[self.lastSection] = @(self.lastSectionStatus);
    }
    
    return _foldStatus;
}

/*
 @ 该方法初始化对应文件夹右侧的文件列表视图
 */
- (DocListViewController *)listViewController
{
    _listViewController = nil;
    
    // 尝试访问右侧控制器
    UITabBarController *controller = (UITabBarController*)[self.splitViewController.viewControllers lastObject];
    if (controller != nil)
    {
        // 检查当前激活控制器是否是对应标签为“Document Tab”的导航控制器
        UINavigationController *navController = (UINavigationController*)[((UITabBarController *)controller) selectedViewController];
        if ([navController.title isEqualToString:@"Document Tab"])
        {
            // 从该导航控制器中读取导航到的位置，判断是否是所需要的文件列表视图
            UIViewController *topController = [navController topViewController];
            if ([topController isKindOfClass:[DocListViewController class]])
                _listViewController = (DocListViewController *)topController;
        }
    }
    
    return _listViewController;
}

/*!
 返回按钮响应方法
 */
- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*!
 更新通知监听方法
 */
- (void)updateNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

/*!
 添加目录按钮响应方法
 */
- (void)addFolderButtonClicked:(id)sender
{
    UIAlertView *folderAlert = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"请输入目录名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    folderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    folderAlert.tag = TagAlertViewSectionFolder;//TagAlertViewRootFolder;
    [folderAlert show];
}

/*
 根据最后选择的目录类型及其展开状态决定是否要显示增加目录按钮
 */
- (void)decideShowAddButton
{
    if (self.levelOneFolders == nil || [self.levelOneFolders count] <= 0)
        return;
    
    Client_target *target = [self.levelOneFolders objectAtIndex:self.lastSection];
    self.navigationItem.rightBarButtonItem = (([target.type intValue] == TargetTypeSystemFolder &&
                                               ![target.client_id isEqualToString:@"00000000-0000-0000-0000-000000000000"])
                                              || ![self.foldStatus[self.lastSection] boolValue]) ? nil : self.rightBarItem;
}

/*!
 同步更新完成通知监听方法
 @param notification 通知对象
 */
- (void)handleSyncUpdateNotification:(NSNotification *)notification
{
    self.parent = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self resetViewData];
    self.navigationController.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = @"目录";
    [self.tableView reloadData];
    
    if ([self.foldStatus containsObject:@(YES)]) {
        NSInteger index = [self.foldStatus indexOfObject:@(YES)];
        self.listViewController.parentTarget = self.levelOneFolders[index];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 点击确定按钮
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == TagAlertViewRootFolder) {
            UITextField *field = [alertView textFieldAtIndex:0];
            [[DataManager defaultInstance] addFolder:field.text parentID:@"0"];
            self.levelOneFolders = nil;
            self.foldStatus = nil;
            [self updateNotification:nil];
        } else if (alertView.tag == TagAlertViewSectionFolder) {
            UITextField *field = [alertView textFieldAtIndex:0];
            Client_target *target = self.levelOneFolders[self.lastSection];
            [[DataManager defaultInstance] addFolder:field.text parentID:target.client_id];
            target.subFolders = nil;
            [self updateNotification:nil];
        }
    }
}

#pragma mark - ContextHeaderViewDelegate Methods

/*!
 HeaderView被点击时能知外部程序
 @param headerView 被点击的headerView
 */
- (void)headerViewClicked:(ContextHeaderView *)headerView
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if (headerView.section == self.lastSection) {
        BOOL isFold = [self.foldStatus[self.lastSection] boolValue];
        self.foldStatus[self.lastSection] = @(!isFold);
        [indexSet addIndex:self.lastSection];
    } else {
        self.foldStatus[self.lastSection] = @(NO);
        self.foldStatus[headerView.section]= @(YES);
        [indexSet addIndex:self.lastSection];
        [indexSet addIndex:headerView.section];
        self.lastSection = headerView.section;
    }
    self.lastSectionStatus = [self.foldStatus[self.lastSection] boolValue];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    self.listViewController.parentTarget = self.levelOneFolders[self.lastSection];
    
    NSLog(@"header");
    
    [self decideShowAddButton];
}

/*!
 点击删除按钮，通知外部程序
 */
- (void)deleteButtonClicked:(ContextHeaderView *)headerView
{
    Client_target *target = self.levelOneFolders[headerView.section];
    [[DataManager defaultInstance] deleteFolders:target.client_id];
    self.levelOneFolders = nil;
    self.foldStatus = nil;
    if (headerView.section == self.lastSection) {
        self.lastSection = 0;
        self.lastSectionStatus = YES;
    }
    [self.tableView reloadData];
}


@end
