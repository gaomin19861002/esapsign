//
//  SetLogoutViewController.h
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CASetBaseViewController.h"

@interface SetLogoutViewController : CASetBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
