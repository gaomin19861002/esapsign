//
//  DocSelectedViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DocSelectedViewController.h"
#import "DocViewController.h"
#import "MiniDocListViewController.h"
#import "MiniDocViewController.h"

@interface DocSelectedViewController () <MiniDocListViewControllerDelegate>

@property (retain) UINavigationController *leftNavDoc;
@property (retain) UINavigationController *rightNavDoc;

@end

@implementation DocSelectedViewController

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
    // Do any additional setup after loading the view.
    // 添加子视图
    //UINavigationController *navController = (UINavigationController*)[self.leftNavigation nextResponder];// instantiateViewControllerWithIdentifier:@"MiniDocViewNav"];
    //navController.view.frame = CGRectMake(0.0f, 0.0f, 250.0f, 620.0f);
    //navController.view.clipsToBounds = YES;
    //[self addChildViewController:navController];
    //[navController.view setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    //[self.view addSubview:navController.view];
    // 右视图
    //UINavigationController *docListNavController = self.rightNavigation.subviews[0];//[self.storyboard instantiateViewControllerWithIdentifier:@"MiniDocListNav"];
    //docListNavController.view.frame = CGRectMake(251.0f, 0.0f, 289.0f, 620.0f);
    //docListNavController.view.clipsToBounds = YES;
    //[self addChildViewController:docListNavController];
    //[docListNavController.view setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    //[self.view addSubview:docListNavController.view];
    
    // 设置左右联动关系
    MiniDocViewController *docViewController = (MiniDocViewController *)[self.leftNavDoc topViewController];
    MiniDocListViewController *docListViewController = (MiniDocListViewController *)[self.rightNavDoc topViewController];
    docListViewController.docListDelegate = self;
    docViewController.listViewController = (DocListViewController*)docListViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"leftdoc"])
    {
        _leftNavDoc = (UINavigationController*)segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"rightdoc"])
    {
        _rightNavDoc = (UINavigationController*)segue.destinationViewController;
    }
}

#pragma mark - MiniDocListViewControllerDelegate <NSObject>

-(void)MiniDocListViewControllerDidCancelSelection:(MiniDocListViewController *)docListViewController
{
    DebugLog(@"%s", __FUNCTION__);
    [self.delegate DocSelectedViewControllerCancel:self];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)MiniDocListViewController:(MiniDocListViewController *)docListViewController DidSelectTarget:(Client_target *)clientTarget
{
    DebugLog(@"%s", __FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(DocSelectedViewController:DidSelectClientTarget:)]) {
        [self.delegate DocSelectedViewController:self DidSelectClientTarget:clientTarget];
    }
}

@end
