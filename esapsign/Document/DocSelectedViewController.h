//
//  DocSelectedViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_target.h"

@class DocSelectedViewController;

@protocol DocSelectedViewControllerDelegate <NSObject>

-(void)DocSelectedViewController:(DocSelectedViewController *)docSelectedViewController DidSelectClientTarget:(Client_target *)clientTarget;
-(void)DocSelectedViewControllerCancel:(DocSelectedViewController *)docSelectedViewController;

@end

// 发起文档签约界面
@interface DocSelectedViewController : UIViewController

@property(nonatomic, assign) id<DocSelectedViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *leftNavigation;
@property (retain, nonatomic) IBOutlet UIView *rightNavigation;

@end
