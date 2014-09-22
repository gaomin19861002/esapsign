//
//  CAAppDelegate.m
//  esapsign
//
//  Created by 苏智 on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "CAAppDelegate.h"

#import "LeftNaviViewController.h"
#import "RightNaviViewController.h"
#import "AllNaviViewController.h"
#import "NoRotateNaviViewController.h"

#import "UIColor+Additions.h"
#import "NSObject+DelayBlocks.h"
#import "FileManagement.h"

#import "LoginViewController.h"
#import "DocViewController.h"

@implementation CAAppDelegate

- (DetailViewManager *)detailViewManager
{
    if (!_detailViewManager) {
        _detailViewManager = [[DetailViewManager alloc]  init];
    }
    return _detailViewManager;
}

- (void)popLoginView
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    [splitViewController presentViewController:self.loginNavigationController animated:YES completion:nil];
}

- (UINavigationController *)loginNavigationController
{
    if (!_loginNavigationController)
    {
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Toolkits_iPad" bundle:nil];
        _loginNavigationController = [storyBoard instantiateViewControllerWithIdentifier:@"NavLoginViewController"];
    }
    
    return _loginNavigationController;
}

- (void)handleCreateHandSign:(NSNotification *)notification
{
    [self performBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设置签名"
                                                        message:@"您在Web上调用了移动设备签名创建功能，是否需要立即设置手写签名?"
                                                       delegate:self
                                              cancelButtonTitle:@"等一会儿再说"
                                              otherButtonTitles:@"好", nil];
        [alert show];
    } afterDelay:.5];
}

/**
 * This function for testing purpurse only
 */
- (void)testForListFont
{
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    NSLog(@"[familyNames count]===%lu",(unsigned long)[familyNames count]);
    for (indFamily = 0; indFamily < [familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
        for (indFont = 0; indFont < [fontNames count]; ++indFont)
        {
            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [self testForListFont];
    
    // 系统状态栏采用浅色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Libian SC" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    // [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor colorWithR:255 G:255 B:255 A:100]];
    
    // 导航栏设置默认背景和系统UI颜色
    [[UINavigationBar appearanceWhenContainedIn:[AllNaviViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"BarTopAll"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[LeftNaviViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"BarTopLeft"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[RightNaviViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"BarTopRight"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[NoRotateNaviViewController class], nil] setBackgroundImage:[UIImage imageNamed:@"BarTopAll"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // 导航栏设置默认文字字体效果和颜色
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithR:245 G:245 B:245 A:255],
                                                          NSForegroundColorAttributeName,
                                                          shadow,
                                                          NSShadowAttributeName,
                                                          [UIFont fontWithName:@"Libian SC" size:24.0], NSFontAttributeName, nil]];

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    self.detailViewManager.splitViewController = splitViewController;
    self.detailViewManager.detailFrameController = [splitViewController.viewControllers lastObject];

    [self.window makeKeyAndVisible];
    self.loginSucceed = NO;
    [self popLoginView];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.loginSucceed = YES; // 该标记将停止登录后的自动同步
    [self popLoginView];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

+ (CAAppDelegate *)sharedDelegate
{
    return (CAAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
