//
//  DocViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContextHeaderView.h"
#import "DocListViewController.h"


@class Client_target;

@interface DocViewController : UITableViewController

/*!
 定义一级目录的target
 */
@property (nonatomic, retain) Client_target *parent;

/*!
 定义上次展开的目录索引
 */
@property (nonatomic, assign) NSInteger lastSection;

/*!
 定义右侧文档列表对象(By Yi Minwen 放到.h中，方便派生类访问)
 */
@property (nonatomic, assign) DocListViewController *listViewController;

/*!
 定义所有显示在一级的目录
 */
@property(nonatomic, retain, readonly) NSArray *levelOneFolders;

/*
 * 定义角落视图
 */
@property(nonatomic, retain) UIImage* sysBg;
@property(nonatomic, retain) UIImage* defBg;

/*
 Show to derived class
 */
- (NSMutableArray *)foldStatus;

/*
 通过该方法重置文档视图数据，更新显示
 */
- (void) resetViewData;

@end
