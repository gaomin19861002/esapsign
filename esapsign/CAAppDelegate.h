//
//  CAAppDelegate.h
//  esapsign
//
//  Created by 苏智 on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewManager.h"

@interface CAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// Things for IB
@property (nonatomic, retain) UISplitViewController *splitViewController;
// DetailViewManager is assigned as the Split View Controller's delegate.
// However, UISplitViewController maintains only a weak reference to its
// delegate.  Someone must hold a strong reference to DetailViewManager
// or it will be deallocated after the interface is finished unarchieving.
@property (nonatomic, retain) DetailViewManager *detailViewManager;

/*!
 登录界面
 */
@property(nonatomic, retain) UINavigationController *loginNavigationController;

@property(nonatomic, assign) BOOL loginSucceed;

@property(nonatomic, assign) BOOL offlineMode;

- (void)popLoginView;

+ (CAAppDelegate *)sharedDelegate;

@end
