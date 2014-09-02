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
#import "Client_user.h"
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

@interface ContactViewController () <MBProgressHUDDelegate, RequestManagerDelegate, AddContactViewControllerDelegate>
{
    NSMutableArray *arrAllUsers;
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) NSMutableArray *arrAllUsers;
@property (nonatomic, retain) NSMutableArray *arrAllSections;

// 新增索引名称数组 gaomin@20140818
@property (nonatomic, retain) NSMutableArray *arrAllIndexTitles;
@property (nonatomic, retain) NSIndexPath *curSelectedIndexPath;
@property (nonatomic, retain) ContactDetailViewController *detailViewController;
@property (nonatomic, assign) BOOL groupUserData;
@property (nonatomic, retain) UIPopoverController *AddContactPopover;

@property (nonatomic, retain) ASIHTTPRequest *contactNewRequest;

- (void)importSucceedNotification:(NSNotification *)noti;

@end

@implementation ContactViewController

@synthesize arrAllUsers;
@synthesize curSelectedIndexPath;

- (void)dealloc
{
    // 清除异步请求管理器的代理
    [[RequestManager defaultInstance] unRegisterDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [[RequestManager defaultInstance] registerDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear self.groupUserData %d", self.groupUserData);
    [super viewDidAppear:animated];
    if ([Util valueForKey:LoginUser] && [CAAppDelegate sharedDelegate].loginSucceed)
    {
        if (!self.groupUserData)
        {
            self.groupUserData = YES;
            [self updateAndGroupUsers];
        }
        
        // 是否是不在提醒
        //        NSData *userData = [Util valueForKey:LoginUser];
        //        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        //        // 判定是否曾经导入过通讯录
        //        //annotated by weikaikai 移除导入本地通信录功能
        //        if (![[Util valueForKey:user.name] intValue]) {
        //            // 是否是不在提醒
        //            BOOL disabledAsk = [[Util valueForKey:ContactImportDisabledAskedKey] boolValue];
        //            if (!disabledAsk) {
        //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
        //                                                                message:@"是否从系统通讯录中导入联系人？"
        //                                                               delegate:self
        //                                                      cancelButtonTitle:nil
        //                                                      otherButtonTitles:@"导入", @"不导入", @"不再询问", nil];
        //                alert.tag = AlertViewTagImportContact;
        //                [alert show];
        //                [alert release];
        //            }
        //        }
        
        if (self.detailViewController.currentUserID == nil)
        {
            if (self.arrAllSections.count > 0)
            {
                self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:0] objectAtIndex:0] user_id];
                // 选定当前行
                UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
                if (firstCell)
                {
                    firstCell.selected = YES;
                }
            }
        }
    }
}

#pragma mark - Private Methods

/**
 * @abstract 更新，分组用户
 */
- (void)updateAndGroupUsers
{
    self.arrAllUsers = [[DataManager defaultInstance] allClientUsers];
    self.arrAllSections = [NSMutableArray array];
    
    for(int i = 0; i < 29; i ++)
    {
        [self.arrAllSections addObject:[NSMutableArray array]];
    }
    
    ContactHeaderFooterView *headerView = (ContactHeaderFooterView *)self.tableView.tableHeaderView;
    headerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", [self.arrAllUsers count]];
    
    // 分组
    
    // 字母_a~z姓名排序
	for (int i = 0; i < [self.arrAllUsers count]; i ++)
    {
        Client_user *user = [self.arrAllUsers objectAtIndex:i];
        if (user.user_name.length > 0)
        {
            NSString *sectionName = [NSString stringWithFormat:@"%c", pinyinFirstLetter([user.user_name characterAtIndex:0])];
            NSLog(@"%@, %@", sectionName, user.user_name);
            NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
            if (firstLetter != NSNotFound)
            {
                [[self.arrAllSections objectAtIndex:firstLetter] addObject:[self.arrAllUsers objectAtIndex:i]];
            }
            else
            {
                // 其他的内容放到 "_"栏目中
                [[self.arrAllSections objectAtIndex:1] addObject:[self.arrAllUsers objectAtIndex:i]];
            }
        }
	}
    
    // 清除没有的section
    for (int j = self.arrAllSections.count-1; j >= 0; j--)
    {
        if ([[self.arrAllSections objectAtIndex:j] count] == 0) {
            [self.arrAllSections removeObjectAtIndex:j];
        }
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
 * @abstract Remove Data for add Contact Fail
 */
- (void) removeLastData
{
    [self.navigationController.parentViewController.parentViewController hideProgress];
    
    // 删除数据
    Client_user *user = [[DataManager defaultInstance] findUserWithId:self.detailViewController.currentUserID];
    [self.arrAllUsers removeObject:user];
    self.curSelectedIndexPath = [[NSIndexPath alloc] init];
    self.detailViewController.currentUserID = [[[self.arrAllSections objectAtIndex:0] objectAtIndex:0] user_id];
    
    //重新排序
    [self updateAndGroupUsers];
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

- (void)importSucceedNotification:(NSNotification *)noti
{
    // 更新界面
    [self updateAndGroupUsers];
    NSLog(@"updateNotification %d", self.arrAllUsers.count);
    [self.tableView reloadData];
    
    if (self.arrAllSections.count > 0)
    {
        self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:0] objectAtIndex:0] user_id] ;
        // 选定当前行
        UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (firstCell)
        {
            firstCell.selected = YES;
        }
    }
    
    [HUD removeFromSuperview];
    HUD = nil;
}

- (void)delNotification:(NSNotification *)noti
{
    // 查找下一个对应的user信息
    Client_user *user = [(NSArray *)[self.arrAllSections objectAtIndex:self.curSelectedIndexPath.section] objectAtIndex:self.curSelectedIndexPath.row];
    if (self.curSelectedIndexPath != nil)
    {
        NSArray *arrSection = [self.arrAllSections objectAtIndex:self.curSelectedIndexPath.section];
        if (self.curSelectedIndexPath.row == arrSection.count - 1)
        {
            if (self.curSelectedIndexPath.row == 0) {
                // 取下一个或者上一个section
                if (self.curSelectedIndexPath.section == self.arrAllSections.count - 1)
                {
                    // 取上一个section
                    if (self.curSelectedIndexPath.section > 0)
                    {
                        arrSection = [self.arrAllSections objectAtIndex:0];
                        user = [arrSection lastObject];
                    }
                    else
                    {
                        // 为空
                        user = nil;
                    }
                }
                else
                {
                    // 取下一个section
                    arrSection = [self.arrAllSections objectAtIndex:self.curSelectedIndexPath.section + 1];
                    user = [arrSection firstObject];
                }
            }
            else
            {
                user = [arrSection objectAtIndex:1];
            }
        }
        else
        {
            user = [arrSection objectAtIndex:self.curSelectedIndexPath.row + 1];
        }
    }
    
    [self updateAndGroupUsers];
    [self.tableView reloadData];
    
    // 更新选中栏目信息
    for (int section = 0; section < self.arrAllSections.count; section++) {
        NSMutableArray *arrSectionUsers = [self.arrAllSections objectAtIndex:section];
        for (int row = 0; row < arrSectionUsers.count; row++) {
            Client_user *item = [arrSectionUsers objectAtIndex:row];
            if ([item.user_id isEqualToString:user.user_id]) {
                self.curSelectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    self.detailViewController.currentUserID =  user.user_id;
    UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
    if (firstCell) {
        firstCell.selected = YES;
    }
}

- (void)updateNotification:(NSNotification *)noti
{
    // not necessary for reindex the contact array. (If so, it will cause a bug which only shows a sub set of the whole contacts) by weikai 2014-8-15
    // [self updateAndGroupUsers];
    [self.tableView reloadData];
    UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
    if (firstCell) {
        firstCell.selected = YES;
    }
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
    Client_user *firstUser = [self.arrAllSections[section] firstObject];
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
    Client_user *firstUser = [self.arrAllSections[section] firstObject];
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
    // Client_user *object = self.arrAllUsers[indexPath.row];
    Client_user *object = [[self.arrAllSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] ;
    [cell.nameButton setTitle:[object user_name] forState:UIControlStateNormal];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIImage *headImage = [UIImage imageNamed:[object contentWithType:UserContentTypePhoto useLarge:NO]];
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
        self.detailViewController.currentUserID =  [[[self.arrAllSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] user_id];
    }
    self.curSelectedIndexPath = indexPath;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    self.arrAllIndexTitles = [NSMutableArray array];
    for (int i = 0; i < [self.arrAllSections count]; i++)
    {
        Client_user *firstUser = [[self.arrAllSections objectAtIndex:i] firstObject];
        if (!firstUser)
        {
            continue;
        }
        else
        {
            NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([firstUser.user_name characterAtIndex:0])];
            NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
            if (firstLetter != NSNotFound)
            {
                [self.arrAllIndexTitles addObject:[sectionName uppercaseString]];
            }
            else
            {
                [self.arrAllIndexTitles addObject:@"_"];
            }
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
- (void)AddContactViewControllerDidDone:(AddContactViewController *)addContactController userBasicItems:(NSDictionary *)userBasic contactItems:(NSArray *)contactItems
{
    if (self.AddContactPopover)
    {
        // 更新本地数据库条目
        Client_user* user = [[DataManager defaultInstance] createUserWithDictionary:userBasic];
        [[DataManager defaultInstance] updateClientUser:user WithContents:contactItems];
        [self updateAndGroupUsers];
        
        // 新建联系人，通知服务器端
        NSDictionary *param = [[ActionManager defaultInstance] contactNewAction:user];
        self.contactNewRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, ActionRequestPath] Parameter:param];
        self.detailViewController.currentUserID = user.user_id;
        
        // 设置新加的联系人为选定状态
        UITableViewCell *originCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (originCell)
        {
            originCell.selected = NO;
        }
        
        for (int section = 0; section < self.arrAllSections.count; section++)
        {
            NSMutableArray *arrSectionUsers = [self.arrAllSections objectAtIndex:section];
            for (int row = 0; row < arrSectionUsers.count; row++)
            {
                Client_user *item = [arrSectionUsers objectAtIndex:row];
                if ([item.user_id isEqualToString:user.user_id])
                {
                    self.curSelectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }
        
        [self.tableView reloadData];
        originCell = [self.tableView cellForRowAtIndexPath:self.curSelectedIndexPath];
        if (originCell)
        {
            originCell.selected = YES;
        }
        
        [self.AddContactPopover dismissPopoverAnimated:YES];
        self.AddContactPopover = nil;
    }
}

#pragma mark - RequestDelegateMethod

- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        [self.navigationController.parentViewController.parentViewController showProgressText:@"添加联系人中..."];
    }
}

- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        // [self.navigationController hideProgress];
        [self removeLastData];
        [UIAlertView showAlertMessage:@"提交失败"];
    }
}

- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.contactNewRequest)
    {
        NSDictionary *resDict = [[request responseString] jsonValue];
        
        if ([resDict objectForKey:@"actions"] && [[resDict objectForKey:@"actions"] isKindOfClass:[NSArray class]])
        {
            NSArray *actions = [resDict objectForKey:@"actions"];
            NSDictionary *action = [actions firstObject];
            if (action)
            {
                if ([[action objectForKey:@"actionResult"] intValue] == 1)
                {
                    //添加成功
                    [self.navigationController.parentViewController.parentViewController hideProgress];
                    return ;
                }
            }
        }
        [self removeLastData];
        return ;
    }
}

@end
