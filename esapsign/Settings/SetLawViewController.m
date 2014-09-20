//
//  SetLowViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetLawViewController.h"

@interface SetLawViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *contentPDF;

@end

@implementation SetLawViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *boundleFolder = [[NSBundle mainBundle] bundlePath];;
    NSString* documentPath = [NSString stringWithFormat:@"%@", [boundleFolder stringByAppendingPathComponent:@"law.pdf"]];
    [self.contentPDF loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:documentPath]]];
    [self.contentPDF setDelegate:self];
    //[self.contentPDF setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [webView.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
        [webView.scrollView setBounces:NO];

        for (UIView *shadowView in [webView.scrollView subviews])
        {
            [shadowView setBackgroundColor:[UIColor clearColor]];
        }
    });
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect rectProtrait = self.contentPDF.frame;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        self.contentPDF.frame = CGRectMake(rectProtrait.origin.x, rectProtrait.origin.y,
                                     703, rectProtrait.size.height);
    else
        self.contentPDF.frame = CGRectMake(rectProtrait.origin.x, rectProtrait.origin.y,
                                     768, rectProtrait.size.height);
    [self webViewDidFinishLoad:self.contentPDF];
}

@end
