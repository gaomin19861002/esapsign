//
//  DocListViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactSelectedViewController.h"

@class Client_target;

@interface DocListViewController : UIViewController <UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, ContactSelectedViewControllerDelegate>

@property (nonatomic, retain) UIPopoverController* addSignerPopoverController;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

/*!
 底部背景视图
 */
@property (retain, nonatomic) IBOutlet UIView *bottomBarView;

/*!
 定义一级目录的target
 */
@property(nonatomic, retain) Client_target *parentTarget;

- (void)popHandSignController:(BOOL)needVerifyCount;

@end
