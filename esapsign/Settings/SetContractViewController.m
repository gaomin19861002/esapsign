//
//  SetContractViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetContractViewController.h"
#import "ContactManager.h"
#import "Util.h"
#import "User.h"
#import "DataManager.h"

@interface SetContractViewController ()

@property (strong, nonatomic) IBOutlet UILabel *countHistory;
@property (strong, nonatomic) IBOutlet UIStepper *stepperHistoryCount;
@property (strong, nonatomic) IBOutlet UISwitch *switcherMerge;

@end

@implementation SetContractViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    //初始化历史记录对于每个用户
    //User *user = [Util currentLoginUser];
    //Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
    self.stepperHistoryCount.value = 50; // account.sign_count.integerValue;
    self.countHistory.text = [NSString stringWithFormat:@"%d", (int)self.stepperHistoryCount.value];
}

- (IBAction)stepperHistory:(id)sender
{
    UIStepper* stepperButton = (UIStepper*)sender;
    NSInteger count = (int)stepperButton.value;
    self.countHistory.text = [NSString stringWithFormat:@"%ld", (long)count];
    
//    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
//    [DownloadManager defaultInstance].downloadCount = count;
//    [nd setValue:@(count) forKeyPath:DownloadCountKey];
//    [nd synchronize];
}

- (IBAction)switchMerge:(id)sender
{
    UISwitch* switchButton = (UISwitch*)sender;
    
    if (switchButton.isOn)
    {
    }
    else
    {
    }
}

- (IBAction)importContact:(id)sender
{
    [[ContactManager defaultInstance] importAddressBook];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
