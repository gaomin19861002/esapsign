//
//  SetGeneralViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetGeneralViewController.h"
#import "DownloadManager.h"
#import "Util.h"
#import "User.h"
#import "DataManager.h"
#import "UIAlertView+Additions.h"
#import "CAAppDelegate.h"
#import "UIViewController+Additions.h"
#import "NSObject+DelayBlocks.h"

@interface SetGeneralViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *switcherAddSelf;
@property (strong, nonatomic) IBOutlet UISwitch *switcherAllowDup;
@property (strong, nonatomic) IBOutlet UIStepper *stepperSignPicCount;
@property (strong, nonatomic) IBOutlet UIStepper *stepperDownloadCount;
@property (strong, nonatomic) IBOutlet UILabel *countSignPic;
@property (strong, nonatomic) IBOutlet UILabel *countDownload;

@end

@implementation SetGeneralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化最大下载数目 对于所有用户
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSNumber *downloadCount = [nd objectForKey:DownloadCountKey];
    if (downloadCount == nil)
    {
        [nd setObject:[NSNumber numberWithInt:1] forKey:DownloadCountKey];
    }
    else
    {
        self.stepperDownloadCount.value = [downloadCount integerValue];
        self.countDownload.text = [NSString stringWithFormat:@"%ld", (long)[downloadCount integerValue]];
    }
    
    //初始化签名图数量对于每个用户
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
    self.stepperSignPicCount.value = account.sign_count.integerValue;
    self.countSignPic.text = [NSString stringWithFormat:@"%ld", (long)[account.sign_count integerValue]];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)switchAddSelf:(id)sender
{
    //处理发起签约时，始终添加当前用户
    UISwitch* switchButton = (UISwitch*)sender;
    
    if (switchButton.isOn)
    {
    }
    else
    {
    }
}

- (IBAction)switchAddDup:(id)sender
{
    //不允许添加重复联系人
    UISwitch* switchButton = (UISwitch*)sender;
    
    if (switchButton.isOn)
    {
    }
    else
    {
    }
}

- (IBAction)adjustSignPicCountLimit:(id)sender
{
    UIStepper* stepperButton = (UIStepper*)sender;
    NSInteger count = (int)stepperButton.value;
    self.countSignPic.text = [NSString stringWithFormat:@"%ld", (long)count];
    
    User *user = [Util currentLoginUser];
    Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
    account.sign_count = @(count);
}

- (IBAction)adjustDownloadCountLimit:(id)sender
{
    UIStepper* stepperButton = (UIStepper*)sender;
    NSInteger count = (int)stepperButton.value;
    self.countDownload.text = [NSString stringWithFormat:@"%ld", (long)count];
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    [DownloadManager defaultInstance].downloadCount = count;
    [nd setValue:@(count) forKeyPath:DownloadCountKey];
    [nd synchronize];
}

- (IBAction)actionCleanCache:(id)sender
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

@end
