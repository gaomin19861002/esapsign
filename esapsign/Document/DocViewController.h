//
//  DocViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootFolderSection.h"
#import "DocListViewController.h"


@class Client_target;

/**
 * @abstract 文档导航部分控制器
 */
@interface DocViewController : UITableViewController

// 定义当前列表上级目录的target
@property (nonatomic, retain) Client_target *parent;

// 定义上次展开的目录索引
@property (nonatomic, assign) NSInteger lastSection;

// 定义右侧文档列表对象
@property (nonatomic, assign) DocListViewController *listViewController;

// 定义所有显示在一级的目录
@property (nonatomic, retain) NSArray *levelOneFolders;

// Show to derived class
- (NSMutableArray *)foldStatus;

// 通过该方法重置文档视图数据，更新显示
- (void)resetViewData;

@end
