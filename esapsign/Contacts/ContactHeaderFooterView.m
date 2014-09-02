//
//  ContactHeadFooterView.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactHeaderFooterView.h"

@implementation ContactHeaderFooterView

+ (ContactHeaderFooterView *)headerFooterView:(UIStoryboard *)stroyboard
{
    UIViewController *controller = [stroyboard instantiateViewControllerWithIdentifier:@"ContactHeaderFooter"];    
    return (ContactHeaderFooterView *)controller.view;
}

- (void)awakeFromNib
{
    self.rightSmallView.layer.cornerRadius = 10.0;
    self.rightSmallView.layer.borderWidth = 0.0f;
}

@end
