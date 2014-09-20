//
//  CAViewController.h
//  esapsign
//
//  Created by 苏智 on 14-9-19.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *containRight;
@property (strong, nonatomic) IBOutlet UIView *signatureFlow;

// 该属性为containRight容器导航到内容TabBar后，记录TabBar的引用
@property (assign, nonatomic) UITabBarController *contantTabBar;

@end
