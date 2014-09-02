//
//  MiniDocViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "MiniDocViewController.h"
#import "MiniDocListViewController.h"

@interface MiniDocViewController ()

@end

@implementation MiniDocViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    ContextHeaderView *headerView = [ContextHeaderView headerView:storyboard];
    
    Client_target *target = [self.levelOneFolders objectAtIndex:section];
    [headerView.titleButton setTitle:target.display_name forState:UIControlStateNormal];
    headerView.countLabel.text = [NSString stringWithFormat:@"%d", [target.subFolders count] + [target.subFiles count]];
    headerView.section = section;
    headerView.delegate = self;
    [headerView updateShowWithTargetType:[target.type intValue] selected:[super.foldStatus[section] boolValue]];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    Client_target *target = [super.levelOneFolders objectAtIndex:section];
    UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 6)];
    
    if ([target.type intValue] == TargetTypeSystemFolder)
        [footerView setImage:super.sysBg];
    else
        [footerView setImage:super.defBg];
    
    return footerView;
}

/*
 @ 该方法初始化对应文件夹右侧的文件列表视图
 */
- (DocListViewController *)listViewController
{
    //    _listViewController = nil;
    //
    //    for (UIViewController *topController in [[self.navigationController parentViewController].navigationController viewControllers]) {
    //        if ([topController isKindOfClass:[MiniDocListViewController class]]) {
    //            _listViewController = (MiniDocListViewController *)topController;
    //            break;
    //        }
    //    }
    // 不更新右侧视图
    return super.listViewController;
}

- (UIBarButtonItem *)rightBarItem
{
    // 返回空，不处理添加事件
    return nil;
}

- (void)setListViewController:(DocListViewController *)listViewController
{
    if (![super.listViewController isEqual:listViewController])
        super.listViewController = listViewController;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        DocViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MiniDocView"];
        Client_target *target = self.levelOneFolders[indexPath.section];
        controller.parent = target;
        controller.lastSection = indexPath.row;
        controller.listViewController = self.listViewController;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
