//
//  SetGeneralViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetGeneralViewController.h"
#import "SetSwitchTableViewCell.h"
#import "SetSlideTableViewCell.h"
#import "DownloadManager.h"
#import "Util.h"
#import "User.h"
#import "DataManager.h"
#import "UIAlertView+Additions.h"

#define SetGeneralCellIdentifier @"SetGeneralCellIdentifier"
#define SetGeneralSlideCellIdentifier @"SetGeneralSlideCellIdentifier"
#define SetGeneralSwitchCellIdentifier @"SetGeneralSwitchCellIdentifier"


#define CurrentSignMessageOn  @"已经设置默认开启将当前用户作为流程中得签名人"
#define CurrentSignMessageOff  @"已经设置默认关闭将当前用户作为流程中得签名人"

#define NoRepeatSignMessageOn @"已经开启不允许签名流程中出现重复联系人"
#define NoRepeatSignMessageOff @"已经开启允许签名流程中出现重复联系人"



@interface SetGeneralViewController () <SetSwitchTableViewCellDelegate, SetSlideTableViewCellDelegate>

@property (nonatomic, retain) NSArray *sectionNames;

@property (nonatomic, retain) NSArray *switchNames;

@end

@implementation SetGeneralViewController

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SetGeneralCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SetSlideTableViewCell" bundle:nil] forCellReuseIdentifier:SetGeneralSlideCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SetSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:SetGeneralSwitchCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell ;
    //= [tableView dequeueReusableCellWithIdentifier:SetGeneralCellIdentifier forIndexPath:indexPath];
    
    //todo: logical
    if (indexPath.section == 0) {
        SetSwitchTableViewCell *switchCell =  [tableView dequeueReusableCellWithIdentifier:SetGeneralSwitchCellIdentifier forIndexPath:indexPath];
        
        switchCell.nameLabel.text = [self.switchNames objectAtIndex:indexPath.row];
        switchCell.type = [self.switchNames objectAtIndex:indexPath.row];
        switchCell.delegate = self;
        
        cell = switchCell;
    }else {
        SetSlideTableViewCell *slideCell  = [tableView dequeueReusableCellWithIdentifier:SetGeneralSlideCellIdentifier forIndexPath:indexPath];
        if (indexPath.section == 1) {
            slideCell.type = [self.sectionNames objectAtIndex:indexPath.section];
            slideCell.slider.minimumValue = 1;
            slideCell.slider.maximumValue = 5;
            slideCell.nameLabel.text = @"同时下载最大数量";//与联系人签署记录条目数量
            
            //初始化最大下载书目     对于所有用户
            NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
            NSNumber *downloadCount = [nd objectForKey:DownloadCountKey];
            if (downloadCount) {
                slideCell.slider.value = [downloadCount integerValue];
                slideCell.numLabel.text = [NSString stringWithFormat:@"%d",[downloadCount integerValue]];
            }else {
                slideCell.slider.value = [downloadCount integerValue];
                slideCell.numLabel.text = [NSString stringWithFormat:@"%d",[downloadCount integerValue]];
            }
        }
        
        if (indexPath.section == 2) {
            slideCell.type = [self.sectionNames objectAtIndex:indexPath.section];
            slideCell.slider.minimumValue = 50;
            slideCell.slider.maximumValue = 150;
            slideCell.slider.value = 50;//需要设置
            slideCell.numLabel.text = @"50";
            slideCell.nameLabel.text = @"与联系人签署记录条目数量";
            
        }
        
        if (indexPath.section == 3) {
            slideCell.type = [self.sectionNames objectAtIndex:indexPath.section];
            slideCell.slider.minimumValue = 4;
            slideCell.slider.maximumValue = 20;
            slideCell.nameLabel.text = @"签名图数量";
            
            //初始化签名图数量      对于每个用户
            User *user = [Util currentLoginUser];
            Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
            slideCell.slider.value = account.sign_count.integerValue;
            slideCell.numLabel.text = [NSString stringWithFormat:@"%d", [account.sign_count integerValue]];
        }
        
        slideCell.delegate = self;
        
        cell = slideCell;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Accessor Method

- (NSArray *) sectionNames
{
    if (!_sectionNames) {
        _sectionNames = [NSArray arrayWithObjects:@"签名", @"下载", @"联系人", @"签名图", nil];
    }
    return _sectionNames;
}
- (NSArray *) switchNames
{
    if (!_switchNames) {
        _switchNames = [NSArray arrayWithObjects:@"发起签约时始终添加当前用户", @"不允许添加重复签名人", nil];
    }
    return _switchNames;
}

#pragma mark - SetSwitchTableViewCellDelegate methods

- (void) toogleSwitchTo:(BOOL)on withType:(NSString *)type
{
    //处理发起签约时，始终添加当前用户
    if (0 == [self.switchNames indexOfObject:type]) {
        if (on) {
            [UIAlertView showAlertMessage:CurrentSignMessageOn];
        }else {
            [UIAlertView showAlertMessage:CurrentSignMessageOff];
        }
    }
    
    //不允许添加重复联系人
    if (1 == [self.switchNames indexOfObject:type]) {
        if (on) {
            [UIAlertView showAlertMessage:NoRepeatSignMessageOn];
        }else {
            [UIAlertView showAlertMessage:NoRepeatSignMessageOff];
        }
    }
}

#pragma mark - SetSlideTableViewCellDelegate methods

- (void) setSlideChanged:(CGFloat)value withType:(NSString *)type
{
    int index = [self.sectionNames indexOfObject:type];
    NSInteger count = (int) value;
    if (index == 1) {
        NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
        [DownloadManager defaultInstance].downloadCount = count;
        [nd setValue:@(count) forKeyPath:DownloadCountKey];
        [nd synchronize];
    }
    
    if (index == 2) {
        
    }
    
    if (index == 3) {
        User *user = [Util currentLoginUser];
        Client_account *account = [[DataManager defaultInstance] queryAccountByAccountId:user.accountId];
        account.sign_count = @(((int)value));
    }
}

@end
