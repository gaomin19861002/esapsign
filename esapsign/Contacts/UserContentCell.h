//
//  UserContentCell.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-5-3.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserContentCell;

@protocol UserContentCellDelegate <NSObject>

/*!
 编辑开始
 */
- (void)UserContentCellDidBeginEditing:(UserContentCell *)cell;

/*!
 编辑完成
 */
- (void)UserContentCell:(UserContentCell *)cell DidFinishEditingSubTitleWithName:(NSString *)strName;

/*!
 类型编辑按钮点击事件
 */
- (void)UserContentCellModifyTypeTitleButtonClicked:(UserContentCell *)cell;

@end


@interface UserContentCell : UITableViewCell

/*!
 回调对象
 */
@property(nonatomic, assign)id <UserContentCellDelegate> delegate;

/*!
 左侧图标
 */
@property(nonatomic, retain) IBOutlet UIImageView *leftImageView;

/*!
 标题
 */
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;

/*!
 副标题
 */
@property(nonatomic, retain) IBOutlet UILabel *subTitleLabel;

/*!
 编辑状态下副标题
 */
@property (retain, nonatomic) IBOutlet UITextField *subTitleTextField;

@property (nonatomic, retain) IBOutlet UIImageView *starImageView;

@end
