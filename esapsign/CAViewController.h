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

@property (strong, nonatomic) UITabBarController *contantTabBar;

@end
