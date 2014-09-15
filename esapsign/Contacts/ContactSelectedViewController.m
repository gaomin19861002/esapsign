//
//  ContactSelectedViewController.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-17.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "ContactSelectedViewController.h"
#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "Client_contact.h"
#import "Client_contact_item.h"
#import "pinyin.h"
#import "ContactSelectedCell.h"
#import "NSDate+Additions.h"
#import "ContactHeaderFooterView.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"
#import "ContactContextCell.h"
#import "UIAlertView+Additions.h"

@interface ContactSelectedViewController ()

/*!
 联系人列表
 */
@property(nonatomic, retain) IBOutlet UITableView *contactList;

/*!
 联系人详情
 */
@property(nonatomic, retain) IBOutlet UITableView *contactDetail;

/*!
 联系人名称
 */
// @property(nonatomic, retain) IBOutlet UILabel *contactLabel;
@property (retain, nonatomic) IBOutlet UITextField *contactName;
@property (retain, nonatomic) IBOutlet UITextField *contactAddr;

/*!
 联系人头像
 */
@property(nonatomic, retain) IBOutlet UIImageView *contactHead;

/*!
 所有用户的分组数据
 */
@property(nonatomic, retain) NSMutableArray *allUserGroups;

@property(nonatomic, assign) NSInteger allUserCount;

@property(nonatomic, retain) Client_contact *selectedUser;

/*!
 返回按钮响应方法
 */
- (void)backButtonClicked:(id)sender;

/*!
 确认按钮响应方法
 */
- (IBAction)confirmButtonClicked:(id)sender;

/*!
 更新右侧显示
 */
- (void)updateRightView:(NSIndexPath *)selectedIndexPath;

@end

@implementation ContactSelectedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply
    //                                             target:self
    //                                              action:@selector(backButtonClicked:)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmButtonClicked:)];
    
    self.contactList.sectionFooterHeight = 0.0f;
    self.contactList.sectionHeaderHeight = 20.0f;
    self.contactList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contactList.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.contactList.backgroundColor = [UIColor clearColor];
    
    self.contactDetail.sectionFooterHeight = 0.0f;
    self.contactDetail.sectionHeaderHeight = 20.0f;
    self.contactDetail.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contactDetail.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.contactDetail.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath *indexPath = nil;
    if ([self.allUserGroups count]) {
        if ([[self.allUserGroups firstObject] count]) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else if ([self.allUserGroups count] > 1){
            indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.contactList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }
    
    if (indexPath) {
        [self.contactList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self updateRightView:indexPath];
    }
}

- (NSMutableArray *)allUserGroups {
    if (!_allUserGroups) {
        _allUserGroups = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 29; i++) {
            [_allUserGroups addObject:[NSMutableArray array]];
        }
        
        NSArray *allUsers = [[DataManager defaultInstance] allContacts];
        self.allUserCount = [allUsers count];
        // 分组
        // 字母_a~z姓名排序
        for (int i = 0; i < [allUsers count]; i ++) {
            Client_contact *user = [allUsers objectAtIndex:i];
            if (user.user_name.length) {
                NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([user.user_name characterAtIndex:0])];

                NSUInteger firstLetter = [ALPHA rangeOfString:[[sectionName lowercaseString] substringToIndex:1]].location;
                if (firstLetter != NSNotFound){
                    [[_allUserGroups objectAtIndex:firstLetter] addObject:user];
                }
            }
        }
        
        // 清除没有的
        NSMutableArray *delArray = [NSMutableArray array];
        for (NSInteger i = 1; i < [_allUserGroups count]; i++) {
            if (![[_allUserGroups objectAtIndex:i] count]) {
                [delArray addObject:[_allUserGroups objectAtIndex:i]];
            }
        }
        
        if ([delArray count]) {
            [_allUserGroups removeObjectsInArray:delArray];
        }
        
        // 插入常用联系人
        NSArray *lastestUsers = [[DataManager defaultInstance] lastestConstacts];
        if (lastestUsers) {
            [_allUserGroups insertObject:lastestUsers atIndex:0];
        } else {
            [_allUserGroups insertObject:[NSMutableArray array] atIndex:0];
        }
    }
    
    return _allUserGroups;
}

#pragma -
#pragma mark Private Methods
/*!
 返回按钮响应方法
 */
- (void)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 确认按钮响应方法
 */
- (IBAction)confirmButtonClicked:(id)sender {
    if (![self.contactName.text length]) {
        [UIAlertView showAlertMessage:@"请输入用户名称"];
        return;
    }
    
    if (![self.contactAddr.text length]) {
        [UIAlertView showAlertMessage:@"请输入邮箱地址"];
        return;
    }
    
    NSString *regex = @".+@.+[\\.].+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![predicate evaluateWithObject:self.contactAddr.text]) {
        [UIAlertView showAlertMessage:@"请输入正确的邮箱地址"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(confirmSelectUser:userName:address:)]) {
        [self.delegate confirmSelectUser:self userName:self.contactName.text address:self.contactAddr.text];
    }
}

/*!
 更新右侧显示
 */
- (void)updateRightView:(NSIndexPath *)selectedIndexPath {
    if (!selectedIndexPath) {
        return;
    }
    
    if (selectedIndexPath.row == NSNotFound ||
        selectedIndexPath.section == NSNotFound) {
        return;
    }
    self.selectedUser = [[self.allUserGroups objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row];
    UIImage *headImage = [UIImage imageNamed:[self.selectedUser headIconUseLarge:YES]];
    self.contactHead.image = headImage;
    //self.contactLabel.text = self.selectedUser.user_name;
    self.contactName.text = self.selectedUser.user_name;
    [self.contactDetail reloadData];
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.selectedUser.showContents count])
    {
        Client_contact_item *context = [self.selectedUser.showContents objectAtIndex:indexPath.row];
        self.contactAddr.text = context.contentValue;
    }
}

#pragma -
#pragma mark UITableView DataSource and Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.contactList) {
        return [self.allUserGroups count];
    }
    
    if (tableView == self.contactDetail) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        if (section == 0) {
            return 25.0f;
        }
        
        return 20.0f;
    }
    
    if (tableView == self.contactDetail) {
        return 0.0f;
    }
    
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        if (section == 0) {
            return 25.0f;
        }
        
        return 0.0f;
    }
    
    if (tableView == self.contactDetail) {
        return 0.0f;
    }
    
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        return [[self.allUserGroups objectAtIndex:section] count];
    }
    
    if (tableView == self.contactDetail) {
        return [self.selectedUser.showContents count];
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        if (section == 0) {
            ContactHeaderFooterView *headerView = [ContactHeaderFooterView headerFooterView:self.storyboard];
            headerView.backgroundColor = [UIColor colorWithR:133 G:197 B:85 A:255];
            headerView.titleLabel.text = @"常用联系人";
            headerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", [self.allUserGroups[section] count]];
            headerView.rightSmallView.backgroundColor = [UIColor colorWithR:68 G:122 B:27 A:255];
            
            return headerView;
        }
        
        return nil;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        if (section == 0) {
            ContactHeaderFooterView *footerView = [ContactHeaderFooterView headerFooterView:self.storyboard];
            footerView.backgroundColor = [UIColor colorWithR:56 G:183 B:288 A:255];
            footerView.titleLabel.text = @"所有联系人";
            footerView.subTitleLabel.text = [NSString stringWithFormat:@"%d", self.allUserCount];
            footerView.rightSmallView.backgroundColor = [UIColor colorWithR:26 G:113 B:147 A:255];
            
            return footerView;
        }
        
        return nil;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.contactList) {
        if (section > 0) {
            Client_contact *firstUser = [self.allUserGroups[section] firstObject];
            NSString *sectionName = [NSString stringWithFormat:@"%c",pinyinFirstLetter([firstUser.user_name characterAtIndex:0])];
            
            return [sectionName uppercaseString];
        }
    }
    
    if (tableView == self.contactDetail) {
        
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactList) {
        ContactSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactSelectedCell" forIndexPath:indexPath];
        
        Client_contact *object = [[self.allUserGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] ;
        cell.nameLabel.text = [object user_name];
        UIImage *headImage = [UIImage imageNamed:[object headIconUseLarge:NO]];
        
        cell.headImageView.image = headImage;
        cell.selectedDateLabel.text = [object.last_used fullDateString];
        
        return cell;
    }
    
    if (tableView == self.contactDetail) {
        ContactContextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactContextCell" forIndexPath:indexPath];
        Client_contact_item *context = [self.selectedUser.showContents objectAtIndex:indexPath.row];
        cell.titleLabel.text = context.title;
        cell.subTitleLabel.text = context.contentValue;
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactList) {
        [self updateRightView:indexPath];
    }
    
    if (tableView == self.contactDetail) {
        Client_contact_item *context = [self.selectedUser.showContents objectAtIndex:indexPath.row];
        if (context != nil)
            self.contactAddr.text = context.contentValue;
    }
}

@end
