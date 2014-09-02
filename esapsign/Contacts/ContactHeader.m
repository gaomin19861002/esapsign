//
//  ContactHeader.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactHeader.h"

@implementation ContactHeader

+ (ContactHeader *)headSection:(UIStoryboard *)storyboard
{
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ContactSection"];
    return (ContactHeader *)controller.view;
}

@end
