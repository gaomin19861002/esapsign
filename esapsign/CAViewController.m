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
#import "SignatureClipListView.h"
#import "HandSignViewController.h"
#import "DataManager.h"
#import "NoRotateNaviViewController.h"

@interface CAViewController () <SignatureClipListViewDelegate, HandSignViewControllerDelegate>

// 定义底部的预置签名界面
@property(nonatomic, retain) SignatureClipListView *signListView;

// 签名界面
@property(nonatomic, retain) HandSignViewController *handSignController;

@end

@implementation CAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.signatureFlow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSignPicUpdateComplete:) name:SignPicUpdateCompleteNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 此处纠正位置是因为，在初始生成的时候，还无法判定旋转屏状态，第一次进入页面重新刷下
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) || UIDeviceOrientationIsPortrait(self.interfaceOrientation) )
    {
        self.signListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth - 320.0), 0);
        CGRect frame = _signListView.signCollectionView.frame;
        frame.origin.x = -31;
        frame.size.width = 604;
        _signListView.signCollectionView.frame = frame;
        NSLog(@"%@", NSStringFromCGRect(_signListView.signCollectionView.frame));
    }
    else
    {
        self.signListView.transform = CGAffineTransformIdentity;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.signListView setArrDefaultSigns:[DataManager defaultInstance].allSignPics];
}

- (SignatureClipListView *)signListView
{
    if (!_signListView)
    {
        _signListView = [[SignatureClipListView alloc] initWithFrame:CGRectMake(0, 0, 704, 56)];
        _signListView.signsListDelegate = self;
        _signListView.clipsToBounds = NO;
        [_signListView.btnAdd setImage:[UIImage imageNamed:@"SignNew"] forState:UIControlStateNormal];
        [_signListView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
        [self.signatureFlow addSubview:_signListView];
    }
    return _signListView;
}

- (HandSignViewController *)handSignController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Toolkits_iPad" bundle:nil];
    _handSignController = [storyBoard instantiateViewControllerWithIdentifier:@"NewSignViewController"];
    // _handSignController.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f];
    _handSignController.delegate = self;
    // _handSignController.view.frame = CGRectMake(0.0f,64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f - 60.0f);
    return _handSignController;
}

- (void)resetSignListFrame
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.signListView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -(ScreenHeight - ScreenWidth - 320.0), 0); // 320为左侧菜单宽度
            
            CGRect frame = _signListView.signCollectionView.frame;
            frame.origin.x = -31;
            frame.size.width = 604;
            _signListView.signCollectionView.frame = frame;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.signListView.transform = CGAffineTransformIdentity;
            CGRect frame = _signListView.signCollectionView.frame;
            frame.origin.x = 0;
            frame.size.width = 604;
            _signListView.signCollectionView.frame = frame;
        }];
    }
}


#pragma mark - SignsListViewDelegate Methods

// 点击新增按钮事件
- (void)SignatureClipListViewDidClickedNewSignBtn:(SignatureClipListView *)curSignsListView
{
    [self popHandSignController:YES];
}

- (void)popHandSignController:(BOOL)needVerifyCount
{
    NSLog(@"%s", __FUNCTION__);
    
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] fetchAccount:[NSString stringWithFormat:@"%@", user.accountId]];
    Assert(account, @"account shouldn't be null");
    int limitCount = [account.sign_count intValue];
    int signCount = (int)[DataManager defaultInstance].allSignPics.count;
    
    if (signCount >= limitCount && needVerifyCount)
    {
        NSString* info = [NSString stringWithFormat:@"已达到预设签名图数量上限(%d)", limitCount];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:info message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    UINavigationController *nav = [[NoRotateNaviViewController alloc] initWithRootViewController:self.handSignController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)HandSignViewController:(HandSignViewController *)controller DidFinishSignWithImage:(UIImage *)image
{
    [self.signListView insertNewSign:image];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)HandSignViewController:(HandSignViewController *)controller qrFinishSignWithImage:(UIImage *)image
{
    [self.signListView addNewSign:image];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSignPicUpdateComplete:(NSNotification *)notification
{
    DataManager* manager = [DataManager defaultInstance];
    [self.signListView setArrDefaultSigns:manager.allSignPics];
}

#pragma mark - UIViewController Rotate

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resetSignListFrame];
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
        
//        [appDelegate performBlock:^{
//            appDelegate.loginSucceed = NO;
//            [appDelegate popLoginView];
//        } afterDelay:0.01];
    }
}

@end
