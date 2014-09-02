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

/*!
 HeaderView被点击时能知外部程序
 @param headerView 被点击的headerView
 */
- (void)headerViewClicked:(ContextHeaderView *)headerView;

/*!
 点击添加按钮，通知外部程序
 */
//- (void)addButtonClicked:(ContextHeaderView *)headerView;

/*!
 点击删除按钮，通知外部程序
 */
- (void)deleteButtonClicked:(ContextHeaderView *)headerView;

@end

@interface ContextHeaderView : UIView <UIGestureRecognizerDelegate>

/*
 定义标题按钮
 */
@property(nonatomic, retain) IBOutlet UIButton* titleButton;

/*!
 定义数量控件
 */
@property(nonatomic, retain) IBOutlet UILabel *countLabel;

/*!
 定义图标
 */
@property (retain, nonatomic) IBOutlet UIImageView *headIcon;

/*!
 定义所在行的索引
 */
@property(nonatomic, assign) NSInteger section;

/*!
 定义delegate
 */
@property(nonatomic, assign) id<ContextHeaderViewDelegate> delegate;

/*!
 创建HeaderView
 @param storyboard storyboard对象，用于加载controller
 @return 创建好的headerView
 */
+ (ContextHeaderView *)headerView:(UIStoryboard *)storyboard;

/*!
 更新显示
 */
- (void)updateShowWithTargetType:(TargetType)type selected:(BOOL)selected;

@end
