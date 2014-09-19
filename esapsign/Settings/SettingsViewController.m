//
//  SettingsViewController.m
//  PdfEditor
//
//  Created by MinwenYi on 14-3-19.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "SettingsViewController.h"
#import "CAAppDelegate.h"
#import "CAViewController.h"
#import "UIAlertView+Additions.h"
#import "AllNaviViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *labelGeneral;
@property (strong, nonatomic) IBOutlet UILabel *labelContact;
@property (strong, nonatomic) IBOutlet UILabel *labelBluekey;
@property (strong, nonatomic) IBOutlet UILabel *labelAbout;
@property (strong, nonatomic) IBOutlet UILabel *labelLawText;
@property (strong, nonatomic) IBOutlet UILabel *labelExit;

@property (nonatomic, retain) NSArray *tableArray;

@property (nonatomic, retain) UITabBarController *settingControllers;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Setting Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.labelGeneral setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
    [self.labelContact setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
    [self.labelBluekey setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
    [self.labelAbout setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
    [self.labelLawText setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
    [self.labelExit setFont:[UIFont fontWithName:@"Libian SC" size:20.0]];
}

#pragma mark - UITableViewDelegate method

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 0:
            //处理通用
            if (indexPath.row == 0)
                self.settingControllers.selectedIndex = 0;
            break;
        case 1:
            //处理通讯录
            if (indexPath.row == 0)
                self.settingControllers.selectedIndex = 1;
            //处理蓝牙盾
            if (indexPath.row == 1)
                self.settingControllers.selectedIndex = 2;
            break;
        case 2:
            //处理关于
            if (indexPath.row == 0)
                self.settingControllers.selectedIndex = 3;
            //处理法律声明
            if (indexPath.row == 1)
                self.settingControllers.selectedIndex = 4;
            break;
        case 3:
            //处理退出
            if (indexPath.row == 0)
                self.settingControllers.selectedIndex = 5;
            break;
        default:
            break;
    }
}

#pragma mark - getter and setter method

- (UITabBarController *) settingControllers
{
    if (!_settingControllers)
    {
        CAViewController *containController = [self.splitViewController.viewControllers lastObject];
        UITabBarController *tabbar = (UITabBarController *) containController.contantTabBar;
        
        if (tabbar != nil)
        {
            UINavigationController *nav = (UINavigationController *) tabbar.selectedViewController;
            if ([nav.title isEqualToString:@"Settings Tab"])
            {
                UIViewController *viewController = [nav topViewController];
                if ([viewController isKindOfClass:[UITabBarController class]])
                    _settingControllers = (UITabBarController *) viewController;
            }
        }
    }
    return _settingControllers;
}

@end
