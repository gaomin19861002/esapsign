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


@property (nonatomic, retain) IBOutlet UILabel *tipsLabel;
@property (nonatomic, retain) IBOutlet UITextField *verifyTextField;
@property (nonatomic, retain) IBOutlet UIButton *verifyButton;
@property (nonatomic, retain) IBOutlet UIView *verifyView;

@property (nonatomic, assign) BOOL isNeedVerifyNumber;
@property (nonatomic, retain) ASIHTTPRequest *verifyRequest;
@property (nonatomic, retain) NSString *userAccountId;
@property (nonatomic, retain) NSTimer *verifyTimer;
@property (nonatomic, assign) int currentTime;
@property (nonatomic, assign) BOOL allowLogin;

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
    self.isNeedVerifyNumber = NO;
    self.allowLogin = YES;
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
    self.allowLogin = NO;
    [self.verifyTimer invalidate];
    self.verifyButton.titleLabel.text = @"获取验证码";
    self.tipsLabel.text = @"";

    
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
        NSDictionary *para;
        if (self.isNeedVerifyNumber) {
            
            para = @{@"id":[Util generalUUID],
                     @"alias": self.nameTextField.text,
                     @"type": @"0",
                     @"password": self.pwdTextField.text,
                     @"requireCert": @"0",
                     @"verifyNumber" : self.verifyTextField.text,
                     @"deviceId" : [Util getUDID],
                     @"deviceType": @"2"};
            
        }else {
            para = @{@"id":[Util generalUUID],
                    @"alias": self.nameTextField.text,
                    @"type": @"0",
                    @"password": self.pwdTextField.text,
                    @"requireCert": @"0",
                    @"deviceId" : [Util getUDID],
                    @"deviceType": @"2"};
        }
        
        self.loginRequest = [[RequestManager defaultInstance] asyncPostData:LoginRequestPath Parameter:para];
    }
}

/**
 *  @abstract 获取验证码按钮点击，需要进行获取验证码请求
 */
- (IBAction) askForVerifyNumber:(id)sender
{
    NSDictionary *para = @{@"accountId":self.userAccountId,
                           @"deviceId": [Util getUDID],
                           @"deviceType":@"2"
                           };
    self.verifyRequest = [[RequestManager defaultInstance] asyncPostData:VerifyCodePath Parameter:para];
}


#pragma mark - ASIHttpRequest Delegate
// 异步请求开始通知外部程序
- (void)asynRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest) {
        [self.navigationController showProgressText:@"登录中..."];
    }
    if (request == self.verifyRequest) {
        
    }
}

// 异步请求失败通知外部程序
- (void)asynRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest) {
        [self.navigationController hideProgress];
        DebugLog(@"login failed=%@", self.loginRequest.error);
        [UIAlertView showAlertMessage:@"登录失败"];
        self.allowLogin = YES;
    }
    if (request == self.verifyRequest) {
        
        //请求验证码失败
        self.verifyButton.enabled = YES;
        
    }
}

// 异步请求结束通知外部程序
- (void)asynRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.loginRequest)
    {
        self.allowLogin = YES;
        
        [self.navigationController hideProgress];
        NSString *resString = [self.loginRequest responseString];
        
        NSDictionary *resDict = [resString jsonValue];
        if ([[resDict objectForKey:@"result"] intValue] == 0)
        {
            //需要发送验证码
            
            self.tipsLabel.text = @"请输入验证码";
            //进行请求验证码操作
            self.userAccountId = [resDict objectForKey:@"accountId"];
            self.isNeedVerifyNumber = YES;
            
            //disable verify button
            self.verifyButton.enabled = NO;
            
            //发送请求
            [self askForVerifyNumber:nil];
            
            //TODO:禁用登陆按钮。
            self.allowLogin = NO;
            
            
            
        }else if([[resDict objectForKey:@"result"] intValue] == 1)
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
#warning 进行签名的处理。
//            NSString *cert = [resDict objectForKey:@"cert"];
            
            [CAAppDelegate sharedDelegate].loginSucceed = YES;
            [self dismissViewControllerAnimated:YES completion:^{
                // 自动执行一次同步
                [SyncManager defaultInstance].parentController = [CAAppDelegate sharedDelegate].window.rootViewController;
                [[SyncManager defaultInstance] startSync];
            }];
            
            self.isNeedVerifyNumber = NO;
        }else if([[resDict objectForKey:@"result"] intValue] == 2)
        {
            //用户不存在
            self.tipsLabel.text = @"该用户不存在";
            
        }else if([[resDict objectForKey:@"result"] intValue] == 3)
        {
            
            //用户输入的密码错误
            self.tipsLabel.text = @"密码错误，请重新输入";
            
        }else if([[resDict objectForKey:@"result"] intValue] == 4)
        {
            self.tipsLabel.text = @"拒绝对该设备授权";
        }
        else
        {
            [UIAlertView showAlertMessage:@"登录失败"];
        }
    }
    
    //请求完验证码
    if (request == self.verifyRequest) {
        
        self.allowLogin = YES;
        self.verifyView.hidden = NO;
        self.tipsLabel.text = @"";
        
        NSDictionary *resDict = [[request responseString] jsonValue];
        
        if (resDict && [[resDict objectForKey:@"result"] intValue] == 1) {
            NSString *accountId = [resDict objectForKey:@"id"];
            NSString *deviceId = [resDict objectForKey:@"deviceId"];
            NSString *verifyAddress = [resDict objectForKey:@"verifyAddress"];
            
            if (![self.userAccountId isEqualToString:accountId] || ![[Util getUDID] isEqualToString:deviceId]) {
                self.tipsLabel.text = @"请重新获取验证码";
                self.verifyButton.enabled = YES;
                return ;
            }
            
            self.tipsLabel.text = [NSString stringWithFormat:@"验证码已经发送到地址:%@。", verifyAddress];
            self.verifyButton.enabled = NO;
            
            //开启定时器
            [self openTimer];
            
        }else {
            self.tipsLabel.text = @"请重新获取验证码";
            self.verifyButton.enabled = YES;
        }
    }
}

- (void) openTimer
{
    if (self.verifyTimer) {
        return ;
    }
    self.currentTime = 30;
    self.verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    self.verifyView.hidden = NO;
}
- (void) timerMethod
{
    if (self.currentTime == 0) {
        //清空定时器
        self.verifyButton.enabled = YES;
        self.tipsLabel.text = @"请重新获取验证码";
        [self.verifyTimer invalidate];
        return ;
    }
//    self.verifyButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.verifyButton.titleLabel.text = [NSString stringWithFormat:@"重新获取%d", self.currentTime--];
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
