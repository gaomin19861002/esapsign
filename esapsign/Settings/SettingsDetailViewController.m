//
//  SettingsDetailViewController.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-6-24.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "SettingsDetailViewController.h"
#import "CAAppDelegate.h"
#import "DataManager.h"
#import "DataManager+Targets.h"
#import "Util.h"
#import "User.h"
#import "DownloadManager.h"
#import "UIAlertView+Additions.h"
#import "NSString+Additions.h"

@interface SettingsDetailViewController ()

@property(nonatomic, strong) IBOutlet UITextField *downloadField;
/*
 *  签名图数量
 */
@property (nonatomic, strong) IBOutlet UITextField *signcountField;

- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)clearCacheButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)clearAllFile:(id)sender;

@end

@implementation SettingsDetailViewController

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
    [[self bottomBarView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
    
    self.downloadField.text = [NSString stringWithFormat:@"%d", [DownloadManager defaultInstance].downloadCount];
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    
    //设置签名图数量
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:[NSString stringWithFormat:@"%@", user.accountId]];
    Assert(account, @"account shouldn't be null");
    NSString *str = [[NSString alloc] initWithFormat:@"%@",account.sign_count ];
    self.signcountField.text = str;
    
}


- (IBAction)logoutButtonClicked:(id)sender {
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

- (IBAction)clearCacheButtonClicked:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [[DataManager defaultInstance] clearUnusedFiles];
}

- (IBAction)clearAllFile:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [[DataManager defaultInstance] clearAllLocalFiles];
}

- (IBAction)saveButtonClicked:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    if (![self.downloadField.text length]) {
        [UIAlertView showAlertMessage:@"请输入数字"];
        
        return;
    }
    
    if (![self.downloadField.text isNumberString]) {
        [UIAlertView showAlertMessage:@"请输入数字"];
        
        return;
    }
    
    NSInteger count = [self.downloadField.text integerValue];
    
    if (count< 1 || count > 5) {
        [UIAlertView showAlertMessage:@"请输入1~5之间的数字"];
        
        return;
    }
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    [DownloadManager defaultInstance].downloadCount = count;
    [nd setValue:@(count) forKeyPath:DownloadCountKey];
    [nd synchronize];
}

/**
 *  @abstract 签名图数量保存按钮
 *  根据文档中说明，签名图默认数量为10，是4到20之间的正整数
 */
- (IBAction) signcountSave:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (![self.signcountField.text length]) {
        [UIAlertView showAlertMessage:@"请输入数字"];
        
        return;
    }
    
    if (![self.signcountField.text isNumberString]) {
        [UIAlertView showAlertMessage:@"请输入数字"];
        
        return;
    }
    
    NSInteger count = [self.signcountField.text intValue];
    if (count < 4 || count > 20) {
        [UIAlertView showAlertMessage:@"请输入4~20之间的数字"];
        
        return;
    }
    
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
    account.sign_count = @(count);
    
    
}

@end
