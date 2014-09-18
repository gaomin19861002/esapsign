//
//  CASetBaseViewController.m
//  esapsign
//
//  Created by 苏智 on 14-9-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SettingsDetailViewController.h"

@interface SettingsDetailViewController ()

@end

@implementation SettingsDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self bottomBar] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedSettings"])
        self.settingsTabBar = (UITabBarController*)[segue destinationViewController];
}

@end
