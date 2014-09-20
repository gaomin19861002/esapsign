//
//  RootSectionView.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootFolderSection;

@protocol RootFolderSectionDelegate<NSObject>

@optional

// 被点击时能知外部程序
- (void)rootSectionClicked:(RootFolderSection *)rootSection;

// 点击删除按钮，通知外部程序
- (void)deleteButtonClicked:(RootFolderSection *)rootSection;

@end

@interface RootFolderSection : UIView <UIGestureRecognizerDelegate>

// 创建HeaderView
+ (RootFolderSection *)rootSection;

@property(nonatomic, retain) IBOutlet UIButton* titleButton;
@property(nonatomic, retain) IBOutlet UILabel *countLabel;

// 定义所在行的索引
@property(nonatomic, assign) NSInteger section;

@property(nonatomic, assign) id<RootFolderSectionDelegate> delegate;

// 更新显示
- (void)updateShowWithTargetType:(TargetType)type selected:(BOOL)selected;

@end
