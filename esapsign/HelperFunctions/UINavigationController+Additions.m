//
//  UINavigationController+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UINavigationController+Additions.h"
#import "NSArray+Additions.h"
#import "UIImage+Additions.h"

#define ButtonWidth 49
#define ButtonHeight (self.navigationBar.frame.size.height)

@implementation UINavigationController(Additions)

- (UIButton *)addButtonWithImageNamed:(NSString *)imageName title:(NSString *)title type:(BarButtonType)type target:(id)target action:(SEL)action index:(NSInteger)index {
    Assert(imageName || title, @"please set at least one of imageName and title");
    
    // Perpare for button to be added and wrapper it with UIBarButtonItem
    UIImage *backgroundImage = nil;
    UIImage *highlightedBackgroundImage = nil;
    BOOL left = (BarButtonTypeLeft == type) && (index == 0) && (title.length || imageName.length);
    BOOL right = (BarButtonTypeRight == type) && (index == 0) && (title.length || imageName.length);
//    if (left) {
//        backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(1, 1)];        highlightedBackgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(1, 1)];;
//    } else if (right) {
//        backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(1, 1)];;
//        highlightedBackgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(1, 1)];;
//    } else {
//        highlightedBackgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] size:CGSizeMake(1, 1)];
//    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, ButtonWidth, ButtonHeight);
    // make button item invisible when no content is to be shown
    if (!imageName.length && !title.length) {
        button.userInteractionEnabled = NO;
    } else {
        button.userInteractionEnabled = YES;
    }
    
    if (backgroundImage) {
        [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    }
    if (highlightedBackgroundImage) {
        [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    }
    
    if (imageName) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    } else {
        [button setImage:nil forState:UIControlStateNormal];
    }
    
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem =[[UIBarButtonItem alloc] initWithCustomView:button];
    if ([imageName length] && ![title length]) {
        buttonItem =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:target action:action];
    }
    buttonItem.tintColor = [UIColor whiteColor];
    
    UINavigationItem *navigationItem = self.topViewController.navigationItem;
    // Make a toolbar to accept and align more than one UIBarButtonItem items
    UIBarButtonItem *toolbarItem = (type == BarButtonTypeLeft) ? [navigationItem.leftBarButtonItems objectOrNilAtIndex:1] :[navigationItem.rightBarButtonItems objectOrNilAtIndex:1];
    
    UIToolbar *toolbar = (id)toolbarItem.customView;
    if (!toolbar || ![toolbar isKindOfClass:[UIToolbar class]]) {
        toolbar = [[UIToolbar alloc] init];
        toolbar.barStyle = -1;
        toolbar.backgroundColor = [UIColor clearColor];
    }
    
    NSMutableArray *items = (type == BarButtonTypeLeft) ? [NSMutableArray arrayWithArray:toolbar.items] : [NSMutableArray arrayWithArray:[toolbar.items reverseObjects]];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10.f;
    if (type == BarButtonTypeRight) {
        negativeSpacer.width = 2;
    }
    // Every new button is accompanied with a spacer
    index = index * 2;
    [items setObjectOrNil:negativeSpacer atIndex:index];
    [items setObjectOrNil:buttonItem atIndex:index + 1];
    
    // Replace possible placeholder as UIBarButtonItem item.
    for (NSUInteger idx = 0; idx < [items count]; ++idx) {
        id obj = [items objectAtIndex:idx];
        if ([obj isKindOfClass:[NSNull class]]) {
            [items replaceObjectAtIndex:idx withObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil]];
        }
    }
    
    const CGFloat offset = IsIOS7OrLater() ? 22.f : 0.f;
    toolbar.items = (type == BarButtonTypeLeft) ? items : [items reverseObjects];
    CGFloat width = ([items count] / 2) * ButtonWidth + offset;
    toolbar.frame = (type == BarButtonTypeLeft) ? CGRectMake(0, 0, width, ButtonHeight) : CGRectMake(self.navigationBar.frame.size.width - width, 0, width, ButtonHeight);
    
    // Make a negative spacer to align UIBarButtonItem item in navigation bar.
    UIBarButtonItem *negativeSpacerItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    negativeSpacerItem.width = -offset;
    
    toolbarItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    NSArray *newBarItems = @[negativeSpacerItem, toolbarItem];
    if (type == BarButtonTypeRight) {
        negativeSpacerItem.width = 5;
        newBarItems = @[negativeSpacerItem,toolbarItem,negativeSpacerItem];
    }
    
    // 如果item的标题和图片都为空，则不显示toolbar
    BOOL isEmpty = YES;
    for (UIBarButtonItem *barItem in items) {
        if ([barItem.customView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)barItem.customView;
            UIImage *im = [btn imageForState:UIControlStateNormal];
            NSString *title = [btn titleForState:UIControlStateNormal];
            if (im || [title length]) {
                isEmpty = NO;
            }
        } else if ([barItem isKindOfClass:[UIBarButtonItem class]] && barItem.target) {
            if (barItem.image) {
                isEmpty = NO;
            }
        }
    }
    
    if (!isEmpty) {
        if (type == BarButtonTypeLeft) {
            [navigationItem setLeftBarButtonItems:newBarItems animated:NO];
        } else {
            [navigationItem setRightBarButtonItems:newBarItems animated:NO];
        }
    } else {
        if (type == BarButtonTypeLeft) {
            [navigationItem setLeftBarButtonItems:nil animated:NO];
        } else {
            [navigationItem setRightBarButtonItems:nil animated:NO];
        }
    }
    
    return button;
}

- (UIButton *)buttonOfType:(BarButtonType)type atIndex:(NSInteger)index {
    UINavigationItem *navigationItem = self.topViewController.navigationItem;
    UIBarButtonItem *toolbarItem = (type == BarButtonTypeLeft) ? [navigationItem.leftBarButtonItems objectOrNilAtIndex:1] :[navigationItem.rightBarButtonItems objectOrNilAtIndex:1];
    
    UIToolbar *toolbar = (id)toolbarItem.customView;
    if (!toolbar || ![toolbar isKindOfClass:[UIToolbar class]]) {
        return nil;
    }
    
    NSMutableArray *items = (type == BarButtonTypeLeft) ? [NSMutableArray arrayWithArray:toolbar.items] : [NSMutableArray arrayWithArray:[toolbar.items reverseObjects]];
    UIBarButtonItem *buttonItem = [items objectOrNilAtIndex:index * 2 + 1];
    
    return (id)buttonItem.customView;
}

-(void)removeButtonWithType:(BarButtonType)type atIndex:(NSInteger)index {
    [self addButtonWithImageNamed:nil title:@"" type:type target:nil action:nil index:index];
}

@end
