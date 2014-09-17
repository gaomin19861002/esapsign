//
//  SetLogoutViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetLogoutViewController.h"
#import "Util.h"
#import "CAAppDelegate.h"
#import "NSObject+DelayBlocks.h"
#import "DataManager.h"
#import "UIViewController+Additions.h"

#define SetLogoutCellIdentifier @"SetLogoutCellIdentifier"

@interface SetLogoutViewController ()

@end

@implementation SetLogoutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SetLogoutCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"登出";
    }
    
    if (section == 1) {
        return @"缓存管理";
    }
    
    if (section == 2) {
        return @"绑定";
    }
    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SetLogoutCellIdentifier forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //todo: logical
    if (indexPath.section == 0) {
        cell.textLabel.text = @"登出";
    }
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @"清空缓存";
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = @"解除绑定";
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //todo: logical
    //登出
    if (indexPath.section == 0) {
        [self logout];
    }
    
    //清空缓存
    if (indexPath.section == 1) {
        [self clearCache];
    }
    
    //解除绑定
    if (indexPath.section == 2) {
        [self unBundle];
    }
}

#pragma mark - function method

/**
 *  @abstract   登出
 */
- (void) logout
{
    NSLog(@"%s", __FUNCTION__);
    // 清除导入通讯录标记
    NSData *userData = [Util valueForKey:LoginUser];
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    [Util setValue:@"0" forKey:user.name];
    
    UITabBarController *leftTabBar = (UITabBarController *)[self.splitViewController.viewControllers firstObject];
    [leftTabBar setSelectedIndex:0];
    
    CAAppDelegate *delegate = [CAAppDelegate sharedDelegate];
    delegate.loginSucceed = NO;
    [delegate popLoginView];
}

/**
 *  @abstract   清空缓存
 */
- (void) clearCache
{
    NSLog(@"%s", __FUNCTION__);
    
    UIViewController *controller = [CAAppDelegate sharedDelegate].window.rootViewController;
    [controller showProgressText:@"删除中..."];
    
    [[DataManager defaultInstance] clearnCaches];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ClearCacheFinishedNotification object:nil];
    
    [self performBlock:^{
        [controller hideProgress];
    } afterDelay:0.5];
}

/**
 *  @abstract 解除绑定
 */
- (void) unBundle
{
    
}

@end
