//
//  MiniDocListViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_target.h"
@class MiniDocListViewController;
@protocol MiniDocListViewControllerDelegate <NSObject>

-(void)MiniDocListViewControllerDidCancelSelection:(MiniDocListViewController *)docListViewController;

-(void)MiniDocListViewController:(MiniDocListViewController *)docListViewController DidSelectTarget:(Client_target *)clientTarget;

@end

// 签署文件选择页
@interface MiniDocListViewController : UITableViewController

/*!
 定义一级目录的target
 */
@property(nonatomic, retain) Client_target *parentTarget;

@property(nonatomic, assign)id <MiniDocListViewControllerDelegate> docListDelegate;

@end
