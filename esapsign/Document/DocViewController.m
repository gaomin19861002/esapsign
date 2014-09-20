//
//  DocViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DocViewController.h"
#import "CAViewController.h"
#import "SubFolderCell.h"
#import "DetailViewManager.h"
#import "DocDetailViewController.h"
#import "DataManager.h"
#import "DataManager+Targets.h"
#import "RootFolderSection.h"
#import "Client_target.h"
#import "DocListViewController.h"
#import "UINavigationController+Additions.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"


@interface DocViewController ()<RootFolderSectionDelegate>

// 定义所有一级目录的展开状态
@property (nonatomic, retain) NSMutableArray *foldStatus;

@property (nonatomic, assign) BOOL lastSectionStatus;

@property (nonatomic, retain) UIBarButtonItem *leftBarItem;
@property (nonatomic, retain) UIBarButtonItem *rightBarItem;

@end

@implementation DocViewController

- (void)resetViewData
{
    self.lastSectionStatus = YES;
    self.lastSection = 0;
    if (_levelOneFolders)
        _levelOneFolders = nil;
    if (_foldStatus)
        _foldStatus = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resetViewData];
    
    if (self.parent)
    {
        self.navigationItem.leftBarButtonItem = self.leftBarItem;
        [self.navigationItem setTitle:self.parent.display_name];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotification:) name:DocViewUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncUpdateNotification:) name:SyncUpdateFinishedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.foldStatus containsObject:@(YES)])
    {
        NSInteger index = [self.foldStatus indexOfObject:@(YES)];
        self.listViewController.parentTarget = self.levelOneFolders[index];
    }
    [self decideShowAddButton];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // 旋转以后重新加载目录以避免Constraint的计算问题
    [self.tableView reloadData];
}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.levelOneFolders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // 是否显示Footer：仅当文件夹选中展开并且有子文件夹时显示
    BOOL isFold = [self.foldStatus[section] boolValue];
    return isFold && section == self.lastSection ? 4 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // Footer的显示素材受一级文件夹的类型影响
    Client_target *target = [self.levelOneFolders objectAtIndex:section];
    
    BOOL isPortrait = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
    CGFloat width = isPortrait ? 308.0f : 320.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 6)];
    UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 6)];
    footerView.contentMode = UIViewContentModeScaleToFill;
    if ([target.type intValue] == TargetTypeSystemFolder)
        [footerView setImage:[UIImage imageNamed:@"FolderSysTail"]];
    else
        [footerView setImage:[UIImage imageNamed:@"FolderDefTail"]];
    [view addSubview:footerView];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RootFolderSection *headerView = [RootFolderSection rootSection];

    Client_target *target = [self.levelOneFolders objectAtIndex:section];
    [headerView.titleButton setTitle:target.display_name forState:UIControlStateNormal];
    
    headerView.countLabel.text = [NSString stringWithFormat:@"%u", [target.subFolders count] + [target.subFiles count]];
    headerView.section = section;
    headerView.delegate = self;
    [headerView updateShowWithTargetType:[target.type intValue] selected:[self.foldStatus[section] boolValue]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.foldStatus[section] boolValue])
    {
        Client_target *target = self.levelOneFolders[section];
        return [target.subFolders count];
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubFolderCell *cell =(SubFolderCell *)[tableView dequeueReusableCellWithIdentifier:@"SubFolderCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Client_target *target = self.levelOneFolders[indexPath.section];

    Client_target *subTarget = target.subFolders[indexPath.row];
    [cell.nameButton setTitle:subTarget.display_name forState:UIControlStateNormal];
    [cell.countLabel setText:[NSString stringWithFormat:@"%u", subTarget.subFolders.count + subTarget.subFiles.count]];
    [cell updateColorWithTargetType:[subTarget.type intValue] andParentType:[target.type intValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        DocViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DocViewContoller"];
        Client_target *target = self.levelOneFolders[indexPath.section];
        controller.parent = target;
        controller.lastSection = indexPath.row;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Client_target *target = self.levelOneFolders[indexPath.section];
    Client_target *subTarget = target.subFolders[indexPath.row];
    return ([subTarget.type intValue] != TargetTypeSystemFolder);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Client_target *target = self.levelOneFolders[indexPath.section];
    Client_target *subTarget = [target.subFolders objectAtIndex:indexPath.row];
    [[DataManager defaultInstance] deleteFolders:subTarget.target_id];
    target.subFolders = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Private Methods

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

- (UIBarButtonItem *)rightBarItem
{
    if (!_rightBarItem)
    {
        _rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addFolderButtonClicked:)];
    }
    return _rightBarItem;
}

- (NSArray *)levelOneFolders
{
    if (!_levelOneFolders)
    {
        NSString *target_id = @"0"; // 使用0表示根目录，不同于nil
        if (self.parent)
            target_id = self.parent.target_id;
        _levelOneFolders = [[DataManager defaultInstance] foldersWithParentTarget:target_id];
    }
    return _levelOneFolders;
}

- (NSMutableArray *)foldStatus
{
    if (!_foldStatus)
    {
        _foldStatus = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < [self.levelOneFolders count]; i++)
            [_foldStatus addObject:@(NO)];
        if ([_foldStatus count] > 0)
            _foldStatus[self.lastSection] = @(self.lastSectionStatus);
    }
    return _foldStatus;
}

- (DocListViewController *)listViewController
{
    _listViewController = nil;
    
    // 尝试访问右侧控制器
    CAViewController* containerView = (CAViewController*)[self.splitViewController.viewControllers lastObject];
    UITabBarController *controller = (UITabBarController*)[containerView contantTabBar];
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

// 返回上一级目录
- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 更新通知监听方法
- (void)updateNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

// 添加目录按钮响应方法
- (void)addFolderButtonClicked:(id)sender
{
    UIAlertView *folderAlert = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"请输入目录名称"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定", nil];
    folderAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [folderAlert show];
}

// 根据最后选择的目录类型及其展开状态决定是否要显示增加目录按钮
- (void)decideShowAddButton
{
    if (self.levelOneFolders == nil || [self.levelOneFolders count] <= 0)
        return;
    
    Client_target *target = [self.levelOneFolders objectAtIndex:self.lastSection];
    self.navigationItem.rightBarButtonItem =
        (([target.type intValue] == TargetTypeSystemFolder && ![target.target_id isEqualToString:@"00000000-0000-0000-0000-000000000000"]) // 条件1: 用户文件夹根目录以外的系统目录
                                              || ![self.foldStatus[self.lastSection] boolValue]) ?  // 条件2: 不是选中并展开的文件夹子
                                                nil : self.rightBarItem;    // 满足条件1或2，便不可新建文件夹
}

// 同步更新完成通知监听方法
- (void)handleSyncUpdateNotification:(NSNotification *)notification
{
    self.parent = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self resetViewData];
    self.navigationController.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = @"目录";
    [self.tableView reloadData];
    
    if ([self.foldStatus containsObject:@(YES)])
    {
        NSInteger index = [self.foldStatus indexOfObject:@(YES)];
        self.listViewController.parentTarget = self.levelOneFolders[index];
    }
}

#pragma mark - UIAlertView Delegate

// 新建文件夹对话框成功后
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 点击确定按钮
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        UITextField *field = [alertView textFieldAtIndex:0];
        Client_target *target = self.levelOneFolders[self.lastSection];
        [[DataManager defaultInstance] addFolder:field.text parentID:target.target_id];
        [self.tableView reloadData];
    }
}

#pragma mark - RootFolderSectionDelegate Methods

// RootSection 选中后处理
- (void)rootSectionClicked:(RootFolderSection *)rootSection
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if (rootSection.section == self.lastSection)
    {
        BOOL isFold = [self.foldStatus[self.lastSection] boolValue];
        self.foldStatus[self.lastSection] = @(!isFold);
        [indexSet addIndex:self.lastSection];
    }
    else
    {
        self.foldStatus[self.lastSection] = @(NO);
        self.foldStatus[rootSection.section]= @(YES);
        [indexSet addIndex:self.lastSection];
        [indexSet addIndex:rootSection.section];
        self.lastSection = rootSection.section;
    }
    self.lastSectionStatus = [self.foldStatus[self.lastSection] boolValue];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    self.listViewController.parentTarget = self.levelOneFolders[self.lastSection];
    
    [self decideShowAddButton];
}

// RootSection 删除按钮点击处理
- (void)deleteButtonClicked:(RootFolderSection *)rootSection
{
    Client_target *target = self.levelOneFolders[rootSection.section];
    [[DataManager defaultInstance] deleteFolders:target.target_id];
    self.levelOneFolders = nil;
    self.foldStatus = nil;
    if (rootSection.section == self.lastSection)
    {
        self.lastSection = 0;
        self.lastSectionStatus = YES;
    }
    [self.tableView reloadData];
}

@end
