//
//  CAViewController.m
//  esapsign
//
//  Created by 苏智 on 14-9-19.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "CAViewController.h"
#import "CAAppDelegate.h"
#import "NSObject+DelayBlocks.h"

@interface CAViewController ()

@end

@implementation CAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.signatureFlow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContents"])
        self.contantTabBar = (UITabBarController*)[segue destinationViewController];

    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CAAppDelegate* appDelegate = [CAAppDelegate sharedDelegate];
        
        UISplitViewController *splitViewController = appDelegate.detailViewManager.splitViewController;
        appDelegate.detailViewManager.detailFrameController = [splitViewController.viewControllers lastObject];
        
        splitViewController.delegate = appDelegate.detailViewManager;
        if ([appDelegate.splitViewController respondsToSelector:@selector(setPresentsWithGesture:)])
            [appDelegate.splitViewController setPresentsWithGesture:YES];
        
        [appDelegate performBlock:^{
            appDelegate.loginSucceed = NO;
            [appDelegate popLoginView];
        } afterDelay:0.01];
    }
}

@end
