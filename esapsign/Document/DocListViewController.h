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

@interface DocListViewController : UITableViewController <UISearchBarDelegate, ContactSelectedViewControllerDelegate>

// 所属目录的target
@property(nonatomic, retain) Client_target *parentTarget;

@end
