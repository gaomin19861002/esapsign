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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"LeftBackground"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self performBlock:^{
        if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            UIViewController *controller = [self.viewControllers objectAtIndex:selectedIndex];
            [self.delegate tabBarController:self didSelectViewController:controller];
        }
    } afterDelay:0.1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
