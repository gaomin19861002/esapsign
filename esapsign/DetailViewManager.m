
/*
     File: DetailViewManager.m
 Abstract: The split view controller's delegate.  It coordinates the display of detail view controllers.
 
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "DetailViewManager.h"
#import "CAViewController.h"

#import "DocViewController.h"
#import "SettingsViewController.h"

#import "UIAlertView+Additions.h"
#import "UIColor+Additions.h"
#import "SyncManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "DataManager.h"
#import "RequestManager.h"

@interface DetailViewManager () <UIPopoverControllerDelegate>

// Holds a reference to the split view controller's bar button item
// if the button should be shown (the device is in portrait).
// Will be nil otherwise.
@property (nonatomic, retain) UIBarButtonItem *navigationPaneButtonItem;

// Holds a reference to the popover that will be displayed
// when the navigation button is pressed.
//@property (nonatomic, retain) UIPopoverController *navigationPopoverController;

@end


@implementation DetailViewManager

- (void)setDetailFrameController:(UIViewController *)detailFrameController
{
    if (_detailFrameController != detailFrameController)
    {
        _detailFrameController = detailFrameController;
        
        if (detailFrameController.navigationItem == nil)
            [detailFrameController.navigationItem setLeftBarButtonItem:self.navigationPaneButtonItem animated:YES];

        // viewControllers 中的0位置实际上是UITabBarController
        UITabBarController *tabBarController = [self.splitViewController.viewControllers objectAtIndex:0];
        tabBarController.delegate = self;
        NSArray *viewControllers = [[NSArray alloc] initWithObjects:tabBarController, _detailFrameController, nil];
        self.splitViewController.viewControllers = viewControllers;
        //[self.splitViewController setMaximumPrimaryColumnWidth:180];
    }
    
    // Dismiss the navigation popover if one was present.  This will
    // only occur if the device is in portrait.
    if (self.navigationPopoverController)
        [self.navigationPopoverController dismissPopoverAnimated:YES];
}

// 根据导航控制器的标题进行切换
- (void)switchNavDetailByTitleText:(NSString*)titleText
{
    CAViewController* base = (CAViewController*)_detailFrameController;
    if (![base isKindOfClass:[CAViewController class]])
        return;
    
    if (![base.contantTabBar.selectedViewController.title isEqualToString:titleText])
    {
        [(UINavigationController*)([base.contantTabBar selectedViewController]) popToRootViewControllerAnimated:YES];
        for (UIViewController* detailController in base.contantTabBar.viewControllers)
        {
            if ([detailController.title isEqualToString:titleText])
            {
                [base.contantTabBar setSelectedViewController:detailController];
                break;
            }
        }
    }
}

#pragma mark - UITabBarViewControllerDelegate

// 左侧Tab切换开始前处理
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        // 当是sync和setting时，不进行页面的切换;
        if ([navController.title isEqualToString:@"Sync Tab"])
        {
            // [UIAlertView showAlertMessage:@"未连接到网络"];
            
            [SyncManager defaultInstance].parentController = self.splitViewController;
            [[SyncManager defaultInstance] startSync];

            return NO;
        }
    }
    return YES;
}

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    DebugLog(@"upload failed!");
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    DebugLog(@"upload succeed!");
}


// 左侧Tab切换完成处理
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController *)viewController;
        // 当显示文档管理第一个界面时，传入一级目录的parent_id = "0";
        if ([navController.title isEqualToString:@"Document Tab"])
        {
            UIViewController *controller = [navController.viewControllers firstObject];
            if ([controller isKindOfClass:[DocViewController class]])
            {
                DocViewController *docController = (DocViewController *)controller;
                docController.parent = nil;
            }
        }
        else
        {
            [navController popToRootViewControllerAnimated:YES];
        }
        
        [self switchNavDetailByTitleText:navController.title];
    }
}

#pragma mark - UISplitViewDelegate

// -------------------------------------------------------------------------------
//	splitViewController:shouldHideViewController:inOrientation:
// -------------------------------------------------------------------------------
- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ;
    bool inDocTab = NO;
    UITabBarController* tabBarLeft = (UITabBarController*)vc;
    if ([tabBarLeft isKindOfClass:[UITabBarController class]])
    {
        UINavigationController* leftNav = (UINavigationController*)tabBarLeft.selectedViewController;
        inDocTab = [leftNav.title isEqualToString:@"Document Tab"];
    }
    return UIInterfaceOrientationIsPortrait(orientation) && inDocTab;
}

// 切分视图转置时的隐藏方式：将要隐藏
- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    NSLog(@"%s", __FUNCTION__);
    
    CAViewController* base = (CAViewController*)_detailFrameController;
    
    self.navigationPaneButtonItem = barButtonItem;
    barButtonItem.title = NSLocalizedString(@"导航", @"Master");
    for (UINavigationController *navDetailTabItem in base.contantTabBar.viewControllers)
    {
        UIViewController *rootCtroller = navDetailTabItem.viewControllers[0];
        [rootCtroller.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    }
    
    self.navigationPopoverController = popoverController;
//    self.navigationPopoverController.delegate = self;
    
//    UITabBarController *tab = (UITabBarController *) viewController;
//    if ([tab.selectedViewController.title isEqualToString:@"Settings Tab"]) {
//        UIBarButtonItem *b = barButtonItem;
//        id target = [b target];
//        SEL s = [b action];
//        [target performSelector:s withObject:nil afterDelay:0.5f];
//    }
}

// 切分视图转置时的隐藏方式：将要显示
- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSLog(@"%s", __FUNCTION__);
    
    CAViewController* base = (CAViewController*)_detailFrameController;
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    for (UINavigationController *navDetailTabItem in base.contantTabBar.viewControllers)
    {
        UIViewController *rootCtroller = navDetailTabItem.viewControllers[0];
        [rootCtroller.navigationItem setLeftBarButtonItem:nil animated:YES];
    }
    self.navigationPopoverController = nil;
}

@end
