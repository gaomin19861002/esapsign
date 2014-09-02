//
//  LoginViewController.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-5-12.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "Util.h"
#import "UIAlertView+Additions.h"
#import "RequestManager.h"
#import "SyncManager.h"
#import "CAAppDelegate.h"
#import "NSObject+DelayBlocks.h"
#import "Client_account.h"
#import "DataManager.h"
#import "UIViewController+Additions.h"
#import "NSObject+Json.h"

@interface LoginViewController ()<RequestManagerDelegate>

@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *pwdTextField;
@property (retain, nonatomic) IBOutlet UIView *loginPartView;

@property(nonatomic, retain) ASIFormDataRequest *loginRequest;

/*!
 登录按钮响应方法
 */
- (IBAction)loginBtnClicked:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户登录";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackground"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.nameTextField becomeFirstResponder];
    
    // 添加默认用户
    NSData *userData = [Util valueForKey:LoginUser];
    if (userData) {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        self.nameTextField.text = user.name;
        self.pwdTextField.text = user.password;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RequestManager defaultInstance] registerDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[RequestManager defaultInstance] unRegisterDelegate:self];
}

#pragma mark - Private Methods

/*!
 登录按钮响应方法
 */
- (IBAction)loginBtnClicked:(id)sender
{
    
    if (![self.nameTextField.text length]) {
        [UIAlertView showAlertMessage:@"请输入用户名"];
        return;
    }
    
    if (![self.pwdTextField.text length]) {
        [UIAlertView showAlertMessage:@"请输入密码"];
        return;
    }
    
    [self.nameTextField resignFirstResponder];
    [self.pwdTextField resignFirstResponder];
    
    if (self.canOffline.isOn)
    {
        // 需要判断本地缓存匹配问题
        
        // 存储登录成功对象
        User *user = [[User alloc] init];
        user.name = self.nameTextField.text;
        user.password = self.pwdTextField.text;
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
        [Util setValue:userData forKey:LoginUser];
        
        [CAAppDelegate sharedDelegate].loginSucceed = YES;
        // 登录
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSDictionary *para = @{@"alias": self.nameTextField.text,
                               @"password": self.pwdTextField.text,
                               @"requireCert": @"0"};
        self.loginRequest = [[RequestManager defaultInstance] asyncPostData:[NSString stringWithFormat:@"%@/%@", APIBaseURL, LoginRequestPath] Parameter:para];
    }
}

// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest) {
        [self.navigationController showProgressText:@"登录中..."];
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest) {
        [self.navigationController hideProgress];
        DebugLog(@"login failed=%@", self.loginRequest.error);
        [UIAlertView showAlertMessage:@"登录失败"];
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest) {
        [self.navigationController hideProgress];
        NSString *resString = [self.loginRequest responseString];
        DebugLog(@"res= %@", resString);
        
        NSDictionary *resDict = [resString jsonValue];
        if ([[resDict objectForKey:@"result"] intValue] == 1)
        {
            // 存储登录成功对象
            User *user = [[User alloc] init];
            user.name = self.nameTextField.text;
            user.password = self.pwdTextField.text;
            user.accountId = [resDict objectForKey:@"accountId"];
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
            [Util setValue:userData forKey:LoginUser];
            
            //查看ClientAccount,如果没有则添加
            Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:[NSString stringWithFormat:@"%@", user.accountId]];
            if (!account) {
                [[DataManager defaultInstance] createAccountWithUser:user];
            }
            
            [CAAppDelegate sharedDelegate].loginSucceed = YES;
            [self dismissViewControllerAnimated:YES completion:^{
                // 自动执行一次同步
                [SyncManager defaultInstance].parentController = [CAAppDelegate sharedDelegate].window.rootViewController;
                [[SyncManager defaultInstance] startSync];
            }];
            
            
            //if ([[resDict objectForKey:@"requireSign"] intValue] == 1) {
                // 需要跳转到签名页
            //    [[NSNotificationCenter defaultCenter] postNotificationName:NeedCreateHandSignNotification object:nil];
            //}
        }
        else
        {
            [UIAlertView showAlertMessage:@"登录失败"];
        }
    }
}

- (IBAction)editDidBegin:(id)sender
{
    if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        self.loginPartView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -150.0f);
    }
}

- (IBAction)editDidEnd:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.loginPartView.transform = CGAffineTransformIdentity;
    }];
}

- (IBAction) registFromWeb:(id)sender
{
    //打开web页面
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REGISTERWEBURL]];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.loginPartView.transform = CGAffineTransformIdentity;
        }];
    }
    else
    {
        if (self.nameTextField.isFirstResponder
            || self.pwdTextField.isFirstResponder) {
            [UIView animateWithDuration:0.2 animations:^{
                self.loginPartView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -150);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.loginPartView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

@end
