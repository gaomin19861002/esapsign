//
//  CASetBaseViewController.m
//  esapsign
//
//  Created by 苏智 on 14-9-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "CASetBaseViewController.h"

@interface CASetBaseViewController ()

@end

@implementation CASetBaseViewController

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
    
    [[self bottomBar] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
