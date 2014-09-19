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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //解除绑定
    if (indexPath.section == 0) {
        [self unBundle];
    }
    
    //登出
    if (indexPath.section == 1) {
        [self logout];
    }
}

/**
 *  @abstract 解除绑定
 */
- (void) unBundle
{
    
}

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

@end
