//
//  ContextHeaderView.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContextHeaderView;

@protocol ContextHeaderViewDelegate<NSObject>

// HeaderView被点击时能知外部程序
- (void)headerViewClicked:(ContextHeaderView *)headerView;

// 点击添加按钮，通知外部程序
//- (void)addButtonClicked:(ContextHeaderView *)headerView;

// 点击删除按钮，通知外部程序
- (void)deleteButtonClicked:(ContextHeaderView *)headerView;

@end

@interface ContextHeaderView : UIView <UIGestureRecognizerDelegate>

// 创建HeaderView
+ (ContextHeaderView *)headerView;

@property(nonatomic, retain) IBOutlet UIButton* titleButton;
@property(nonatomic, retain) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIImageView *headIcon;

// 定义所在行的索引
@property(nonatomic, assign) NSInteger section;

@property(nonatomic, assign) id<ContextHeaderViewDelegate> delegate;

// 更新显示
- (void)updateShowWithTargetType:(TargetType)type selected:(BOOL)selected;

@end
