//
//  SettingsViewController.m
//  PdfEditor
//
//  Created by MinwenYi on 14-3-19.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "SettingsViewController.h"
#import "QRCodeViewController.h"
#import "CAAppDelegate.h"
#import "UIAlertView+Additions.h"
#import "AllNaviViewController.h"

@interface SettingsViewController () <QRCodeViewControllerDelegate>

@property (nonatomic, retain) NSArray *tableArray;

@property (nonatomic, retain) UITabBarController *settingControllers;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Setting Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    UITableViewCell *firstCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    if (firstCell) {
//        firstCell.selected = YES;
//    }
}

#pragma mark
#pragma mark - UITableViewDelegate method
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            //处理通用
            if (indexPath.row == 0) {
                self.settingControllers.selectedIndex = 0;
            }
        }
            break;
        case 1:
        {
            //处理通信录
            if (indexPath.row == 0) {
                self.settingControllers.selectedIndex = 1;
            }
        }
            break;
        case 2:
        {
            //处理蓝牙盾
            if (indexPath.row == 0) {
                self.settingControllers.selectedIndex = 2;
            }
            
            //处理扫一扫
            if (indexPath.row == 1) {
                [self openCamera];
            }
        }
            break;
        case 3:
        {
            //处理关于
            if (indexPath.row == 0) {
                self.settingControllers.selectedIndex = 3;
            }
            
            //处理法律声明
            if (indexPath.row == 1) {
                self.settingControllers.selectedIndex = 4;
            }
        }
            break;
        case 4:
        {
            //处理退出
            if (indexPath.row == 0) {
                self.settingControllers.selectedIndex = 5;
            }
        }
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - private methods
- (void) openCamera
{
    //判断是否有摄像头
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [UIAlertView showAlertMessage:@"No avaliable camera found!"];
        return ;
    }
    
    CAAppDelegate *appDelegate = [CAAppDelegate sharedDelegate];
    
    UIPopoverController *pop = appDelegate.detailViewManager.navigationPopoverController;
    if (pop) {
        [pop dismissPopoverAnimated:YES];
    }
    
    UIStoryboard *storyBoard = self.storyboard;
    QRCodeViewController *qrcoder = (QRCodeViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"QRCodeSearchController"];
    UINavigationController *nav = [[AllNaviViewController alloc] initWithRootViewController:qrcoder];
    qrcoder.delegate = self;
    [appDelegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
}


#pragma mark - QRCodeSearchController Delegate Methods
- (void) qrCodeVideControllerCanceledSearch:(QRCodeViewController *)qrCodeViewController
{
    [UIAlertView showAlertMessage:@"二维码扫描已取消..."];
}

- (void) qrCodeVideController:(QRCodeViewController *)qrCodeViewController didFinishedWithString:(NSString *)str
{
    [UIAlertView showAlertMessage:[NSString stringWithFormat:@"二维码扫描结果:%@", str]];
}



#pragma mark
#pragma mark - getter and setter method
- (NSArray *) tableArray {
    if (!_tableArray) {
        _tableArray = [[NSArray alloc] initWithObjects:@"通用", @"二维码", nil];
    }
    return _tableArray;
}

- (UITabBarController *) settingControllers
{
    if (!_settingControllers) {
        
        UITabBarController *tabbar = (UITabBarController *) [self.splitViewController.viewControllers lastObject];
        
        if (tabbar != nil) {
            
            UINavigationController *nav = (UINavigationController *) tabbar.selectedViewController;
            
            if ([nav.title isEqualToString:@"Settings Tab"]) {
                
                UIViewController *viewController = [nav topViewController];
                
                if ([viewController isKindOfClass:[UITabBarController class]]) {
                    
                    _settingControllers = (UITabBarController *) viewController;
                    
                }
            }
        }
    }
    return _settingControllers;
}
@end
