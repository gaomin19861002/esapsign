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

- (void)recalHeightConstrantInPortrait:(UIInterfaceOrientation)isPortraitOrientation
{
    CGRect rectProtrait = self.view.frame;
    if (isPortraitOrientation)
        self.view.frame = CGRectMake(rectProtrait.origin.x, rectProtrait.origin.y,
                                       314, rectProtrait.size.height);
    else
        self.view.frame = CGRectMake(rectProtrait.origin.x, rectProtrait.origin.y,
                                       320, rectProtrait.size.height);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)];
    [self.tabBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomLeft"]]];
}

@end
