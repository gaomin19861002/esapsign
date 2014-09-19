//
//  FileDetailCell.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_target.h"
#import "Client_file.h"

@class FileDetailCell;

@protocol FileDetailCellDelegate<NSObject>

- (void)statusButtonClicked:(FileDetailCell *)cell;

- (void)modifyButtonClicked:(FileDetailCell *)cell;

- (void)downLoadButtonClicked:(FileDetailCell *)cell;

/**
 * @abstract 增加签名人按钮被点击
 */
- (void)addSignButtonClicked:(FileDetailCell *)cell sender:(id)sender;

/**
 * @abstract 提交签名流程按钮被点击
 */
- (void)submitSignButtonClicked:(FileDetailCell*)cell sender:(id)sender;

@end

@interface FileDetailCell : UITableViewCell

@property(nonatomic, retain) Client_target* targetInfo;

@property(nonatomic, assign) id<FileDetailCellDelegate> delegate;

/*!
 文件类型图标
 */
@property(nonatomic, retain) IBOutlet UIImageView *leftImageView;

/*!
 文件名称
 */
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;

/*!
 签名发起人
 */
@property(nonatomic, retain) IBOutlet UILabel *signLabel;

/*!
 创建时间
 */
@property(nonatomic, retain) IBOutlet UILabel *createLabel;

/*!
 更新时间
 */
@property(nonatomic, retain) IBOutlet UILabel *updateLabel;

/*!
 下载状态文字
 */
@property(nonatomic, retain) IBOutlet UILabel *statusLabel;

/*!
 下载状态按钮
 */
@property(nonatomic, retain) IBOutlet UIButton *statusButton;

/*!
 签名流程切换图标按钮
 */
@property(nonatomic, retain) IBOutlet UIButton *rightImageButton;

/*!
 下载进度视图
 */
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;

/*!
 整体签名进度标签
 */
@property (retain, nonatomic) IBOutlet UIImageView *signProgressTotal;

/*!
 当前用户签名进度标签
 */
@property (retain, nonatomic) IBOutlet UIImageView *signProgressCurrent;

/*!
 添加签名人按钮
 */
@property(nonatomic, retain) IBOutlet UIButton *addSignButton;

/*!
 提交签名流程按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitSignFlowButton;

/*!
 文件下载状态值
 */
@property(nonatomic, assign) FileDownloadStatus status;

/*!
 是否是文件的所有者
 */
@property(nonatomic, assign) BOOL isOwner;

/*!
 是否有编辑签名流程的权限
 */
@property(nonatomic, assign) BOOL signManageAvaliable;

/*!
 更新签名流程
 */
- (void)updateSignFlow:(Client_sign_flow *)signFlow;

@end
