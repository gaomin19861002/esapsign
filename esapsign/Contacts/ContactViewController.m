//
//  ContactViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactViewController.h"

#import "Util.h"
#import "User.h"
#import "CAAppDelegate.h"

#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "Client_contact.h"
#import "ContactManager.h"
#import "ContactHeader.h"
#import "ContactTableViewCell.h"
#import "pinyin.h"
#import "ContactDetailViewController.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"
#import "MBProgressHUD.h"
#import "ContactHeaderFooterView.h"

#import "ActionManager.h"
#import "ASIHTTPRequest.h"
#import "RequestManager.h"
#import "UIAlertView+Additions.h"
#import "AddContactViewController.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"

#define AlertViewTagImportContact   100
#define AlertViewModifyContactName  101

@interface ContactViewController () <MBProgressHUDDelegate, AddContactViewControllerDelegate, ActionManagerDelegate>
{
    NSMutableArray *arrAllUsers;
    MBProgressHUD *HUD;
    
    bool firstUpdateGroupUserData;
}

@property (nonatomic, strong) NSMutableArray *arrAllUsers;
@property (nonatomic, strong) NSMutableArray *arrAllSections;

// 新增索引名称数组 gaomin@20140818
@property (nonatomic, retain) NSMutableArray *arrAllIndexTitles;
@property (nonatomic, retain) NSIndexPath *curSelectedIndexPath;
@property (nonatomic, retain) ContactDetailViewController *detailViewController;
@property (nonatomic, retain) UIPopoverController *AddContactPopover;

// 提交新建联系人时采用ActionManager方式
@property (nonatomic, retain) ASIFormDataRequest *contactNewRequest;

@end

@implementation ContactViewController

@synthesize arrAllUsers;
@synthesize curSelectedIndexPath;

- (void)dealloc
{
    // 清除异步请求管理器的代理
    [[ActionManager defaultInstance] unRegisterDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    firstUpdateGroupUserData = YES;
    self.view.backgroundColor = [UIColor clearColor];
 
    // 添加工具按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
    // UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    NSArray *actionButtonItems = @[addItem/*, shareItem*/];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    // 注册多个消息通知处理程序
    self.curSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delNotification:) name:ContactDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotification:) name:ContactUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importSucceedNotification:) name:ContactImportSucceedNotification object:nil];

    // 定义表格大标题“所有联系人”
    ContactHeaderFooterView *headerView = [ContactHeaderFooterView headerFooterView:self.storyboard];
    headerView.backgroundColor = [UIColor colorWithR:56 G:183 B:288 A:255];
    headerView.titleLabel.text = @"所有联系人";
    headerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", [self.arrAllUsers count]];
    headerView.rightSmallView.backgroundColor = [UIColor colorWithR:26 G:113 B:147 A:255];
    headerView.frame = CGRectMake(0, 0, 320, 25);
    self.tableView.tableHeaderView = headerView;
    
    // 注册异步请求管理器的代理
    [[ActionManager defaultInstance] registerDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([Util valueForKey:LoginUser] && [CAAppDelegate sharedDelegate].loginSucceed)
    {
        if (firstUpdateGroupUserData)
        {
            firstUpdateGroupUserData = NO;
            [self updateAndGroupUsers];
        }

        if (self.detailViewController.currentUserID == nil && self.arrAllSections.count > 0)
        {
            self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:self.curSelectedIndexPath.section] objectAtIndex:self.curSelectedIndexPath.row] contact_id];
            UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
            if (firstCell) firstCell.selected = YES;
        }
    }
}

#pragma mark - Private Methods

/**
 * @abstract 更新，分组用户
 */
- (void)updateAndGroupUsers
{
    // 所有用户对象，获取时先排序一次
    self.arrAllUsers = [NSMutableArray arrayWithArray:[[[DataManager defaultInstance] allContacts] sortedArrayUsingSelector:@selector(compare:)]];
    ContactHeaderFooterView *headerView = (ContactHeaderFooterView *)self.tableView.tableHeaderView;
    headerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", [self.arrAllUsers count]];

    // 所有分组块
    self.arrAllSections = [NSMutableArray arrayWithCapacity:29];
    for (int i = 0; i < 29; i++)
        [self.arrAllSections addObject:[NSMutableArray array]];
    
    // 字母_a~z姓名归类
	for (int i = 0; i < [self.arrAllUsers count]; i++)
    {
        Client_contact *user = [self.arrAllUsers objectAtIndex:i];
        if (user.user_name.length > 0)
        {
            NSString *sectionName = [NSString stringWithFormat:@"%c", pinyinFirstLetter([user.user_name characterAtIndex:0])];
            NSLog(@"%@, %@", sectionName, user.user_name);
            NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
            if (firstLetter != NSNotFound)
                [[self.arrAllSections objectAtIndex:firstLetter] addObject:[self.arrAllUsers objectAtIndex:i]];
            else
                [[self.arrAllSections objectAtIndex:1] addObject:[self.arrAllUsers objectAtIndex:i]]; // 其他的内容放到 "_"栏目中
        }
	}

    // 清除没有的section
    for (int j = self.arrAllSections.count - 1; j >= 0; j--)
    {
        if ([[self.arrAllSections objectAtIndex:j] count] == 0)
            [self.arrAllSections removeObjectAtIndex:j];
    }
    
    [self.tableView reloadData];
}

/**
 * @abstract 添加新联系人
 */
- (void)addContact:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    UINavigationController* navController = [storyboard instantiateViewControllerWithIdentifier:@"AddContact"];
    
    AddContactViewController *acvc = (AddContactViewController *)[navController topViewController];
    acvc.delegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    self.AddContactPopover = popController;
    self.AddContactPopover.popoverContentSize = CGSizeMake(500, 500);
    
    UIBarButtonItem *addItem = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    [self.AddContactPopover presentPopoverFromBarButtonItem:addItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

/**
 * @abstract 获取对应的详情视图的控制器
 */
- (ContactDetailViewController *)detailViewController
{
    _detailViewController = nil;
    if ([self.splitViewController.viewControllers count])
    {
        UIViewController *controller = [self.splitViewController.viewControllers lastObject];
        if ([controller isKindOfClass:[UITabBarController class]])
        {
            UINavigationController *navController = (UINavigationController*)[((UITabBarController *)controller) selectedViewController];
            if ([navController.title isEqualToString:@"Contact Tab"])
            {
                UIViewController *topController = [navController topViewController];
                if ([topController isKindOfClass:[ContactDetailViewController class]]) {
                    _detailViewController = (ContactDetailViewController *)topController;
                }
            }
        }
    }
    
    return _detailViewController;
}

#pragma mark - Notification methods

// 导入完成通知
- (void)importSucceedNotification:(NSNotification *)noti
{
    // 更新界面
    [self updateAndGroupUsers];
    
    if (self.arrAllSections.count > 0)
    {
        self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:0] objectAtIndex:0] contact_id] ;
        UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (firstCell != nil) firstCell.selected = YES;
    }
    
    [HUD removeFromSuperview];
    HUD = nil;
}

// 删除通知
- (void)delNotification:(NSNotification *)noti
{
    if (self.curSelectedIndexPath == nil)
    {
        [self.tableView reloadData];
        return;
    }
    
    // 注意self.arrAllUsers与DataManager里的并不是同一对象，需要额外删除。
    // 诚然，调用updateAndGroupUsers方法可以取得同步，但小量的改动，尽量不去频繁调用它
    
    // 获取当前选择的联系人并直接删除
    NSMutableArray *arrSection = [self.arrAllSections objectAtIndex:self.curSelectedIndexPath.section];
    Client_contact *user = [arrSection objectAtIndex:self.curSelectedIndexPath.row];
    [self.arrAllUsers removeObject:user];
    [arrSection removeObject:user];
    ContactHeaderFooterView *headerView = (ContactHeaderFooterView *)self.tableView.tableHeaderView;
    headerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", [self.arrAllUsers count]];

    // 所有联系人都删空
    if (self.arrAllUsers.count <= 0)
    {
        self.curSelectedIndexPath = nil;
        [self.arrAllSections removeObject:arrSection];
        self.detailViewController.currentUserID = nil;
        [self.tableView reloadData];
        return;
    }

    bool isPrevSection = NO;
    int newSection = self.curSelectedIndexPath.section;
    int newRow = self.curSelectedIndexPath.row;
    
    if (arrSection.count <= 0)
    {
        [self.arrAllSections removeObject:arrSection];

        // 如果删除section后当前section的索引越界，则减少
        if (self.curSelectedIndexPath.section >= self.arrAllSections.count)
        {
            isPrevSection = YES;
            newSection = self.arrAllSections.count - 1;
        }
        
        arrSection = [self.arrAllSections objectAtIndex:newSection];
        
        if (isPrevSection)
            newRow = arrSection.count - 1;
        else
            newRow = 0;
    }
    else
    {
        if (self.curSelectedIndexPath.row >= arrSection.count)
            newRow = arrSection.count - 1;
    }
    
    self.curSelectedIndexPath = [NSIndexPath indexPathForRow:newRow inSection:newSection];
    user = [arrSection objectAtIndex:self.curSelectedIndexPath.row];
    self.detailViewController.currentUserID = user.contact_id;
    
    [self.tableView reloadData];

    UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
    if (firstCell != nil) firstCell.selected = YES;
}

- (void)updateNotification:(NSNotification *)noti
{
    // not necessary for reindex the contact array. (If so, it will cause a bug which only shows a sub set of the whole contacts) by weikai 2014-8-15
    // [self updateAndGroupUsers];
    [self.tableView reloadData];
    UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
    if (firstCell != nil) firstCell.selected = YES;
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrAllSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.arrAllSections objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ContactHeader *header = [ContactHeader headSection:self.storyboard];
    Client_contact *firstUser = [self.arrAllSections[section] firstObject];
    if (!firstUser)
    {
        return nil;
    }
    NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([firstUser.user_name characterAtIndex:0])];
    NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
    if (firstLetter != NSNotFound) {
    }
    else
    {
        sectionName = @"_";
    }

    header.sectionName.text = [sectionName uppercaseString];
    header.countLabel.text = [NSString stringWithFormat:@"%d", [self.arrAllSections[section] count]];
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Client_contact *firstUser = [self.arrAllSections[section] firstObject];
    if (!firstUser)
    {
        return nil;
    }
    NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([firstUser.user_name characterAtIndex:0])];
    NSLog(@"%s, %@", __FUNCTION__, sectionName);
    NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
    if (firstLetter != NSNotFound) {
        return [sectionName uppercaseString];
    }
    else {
        return @"_";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    Client_contact *user = [[self.arrAllSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] ;
    [cell.nameButton setTitle:user.user_name forState:UIControlStateNormal];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIImage *headImage = [UIImage imageNamed:[user headIconUseLarge:NO]];
    cell.headImageView.image = headImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *lastSelectedCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
    if (indexPath.row == self.curSelectedIndexPath.row && indexPath.section == self.curSelectedIndexPath.section)
    {
    }
    else
    {
        lastSelectedCell.selected = NO;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] contact_id];
    }
    self.curSelectedIndexPath = indexPath;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    self.arrAllIndexTitles = [NSMutableArray array];
    for (int i = 0; i < [self.arrAllSections count]; i++)
    {
        Client_contact *firstUser = [[self.arrAllSections objectAtIndex:i] firstObject];
        if (firstUser != nil)
        {
            NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([firstUser.user_name characterAtIndex:0])];
            NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
            if (firstLetter != NSNotFound)
                [self.arrAllIndexTitles addObject:[sectionName uppercaseString]];
            else
                [self.arrAllIndexTitles addObject:@"_"];
        }
    }
    return self.arrAllIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - AddContactViewControllerDelegate

/**
 * @abstract 添加新联系人操作取消
 */
- (void)AddContactViewControllerDidCancel:(AddContactViewController *)addContactController
{
    if (self.AddContactPopover)
    {
        [self.AddContactPopover dismissPopoverAnimated:YES];
        self.AddContactPopover = nil;
    }
}

/**
 * @abstract 添加新联系人完成，该操作将发送contactnew Action以及插入新联系人条目
 */
- (void)AddContactViewControllerDidDone:(AddContactViewController *)addContactController
                         userBasicItems:(NSDictionary *)userBasic
                           contactItems:(NSArray *)contactItems
{
    DataManager* manager = [DataManager defaultInstance];
    if (self.AddContactPopover)
    {
        // 更新本地数据库条目
        Client_contact* user = [manager syncContact:userBasic andItems:contactItems];
        [self updateAndGroupUsers];
        
        // 新建联系人，通知服务器端 gaomin@20140904 修改提交新建联系人时为使用ActionManager方式
        NSDictionary *action = [[ActionManager defaultInstance] contactNewAction:user];
        self.contactNewRequest = [[ActionManager defaultInstance] addToQueue:action sendAtOnce:YES];
        
        // 取消原有选中单元
        UITableViewCell *originCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (originCell) originCell.selected = NO;
        
        // 重新加载表格
        [self.tableView reloadData];

        // 寻找并设置新加的联系人为选定状态
        self.detailViewController.currentUserID = user.contact_id;
        for (int section = 0; section < self.arrAllSections.count; section++)
        {
            NSMutableArray *arrSectionUsers = [self.arrAllSections objectAtIndex:section];
            for (int row = 0; row < arrSectionUsers.count; row++)
            {
                Client_contact *item = [arrSectionUsers objectAtIndex:row];
                if ([item.contact_id isEqualToString:user.contact_id])
                    self.curSelectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
        
        originCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (originCell)  originCell.selected = YES;
        
        [self.AddContactPopover dismissPopoverAnimated:YES];
        self.AddContactPopover = nil;
    }
}

#pragma mark - Action Manager Delegate

// 异步请求开始通知外部程序
- (void)actionRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController showProgressText:@"添加联系人中..."];
    }
}

// 异步请求失败通知外部程序
- (void)actionRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        NSLog(@"Contact New Action Request Failed!");
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        //[self removeLastData];  没必要回滚，自然有其他方法会更新结果
        [UIAlertView showAlertMessage:@"提交失败"];
        self.contactNewRequest = nil;
    }
}

// 异步请求结束通知外部程序
- (void)actionRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        NSLog(@"Contact New Action Request Finished!");
        if (request == self.contactNewRequest)
        {
            __unused NSDictionary *resDict = [[request responseString] jsonValue];
        }
        
        // ActionManager里面对拒绝的返回已经处理（调用同步还原结果），如果没有特殊的事情，无需修正客户端数据结果
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.contactNewRequest = nil;
    }
}

@end
