//
//  LeftTabViewController.m
//  PdfEditor
//
//  Created by 苏智 on 14-5-13.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "LeftTabViewController.h"
#import "NSObject+DelayBlocks.h"

@interface LeftTabViewController ()

@end

@implementation LeftTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LeftBackground"]]];
    for (UITabBarItem* item in self.tabBar.items)
    {

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self performBlock:^{
        if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            UIViewController *controller = [self.viewControllers objectAtIndex:selectedIndex];
            [self.delegate tabBarController:self didSelectViewController:controller];
        }
    } afterDelay:0.1];
}

@end
