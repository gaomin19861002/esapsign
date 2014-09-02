//
//  ContactDetailViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_user.h"

@interface ContactDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UIPopoverController* selectDocPopoverController;

// 改直接从联系人列表赋值Client_user为userID以解决类之间直接赋值coredata数据程序有时暴死的情况 gaomin@20140808
@property (nonatomic ,copy) NSString *currentUserID;

/** 联系人头像及姓名的展示和编辑 */
@property (retain, nonatomic) IBOutlet UIImageView *headImageView;
@property (nonatomic, retain) IBOutlet UILabel *familyNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *familyNameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *line1;
@property (nonatomic, retain) IBOutlet UILabel *firstNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *line2;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

/**
 * @abstract 签约用地址
 */
@property (nonatomic, retain) IBOutlet UILabel *signAddrStaticLabel;

/**
 * @abstract 发起签约按钮
 */
@property (nonatomic, retain) IBOutlet UIButton *startSignBtn;

/**
 * @abstract 背景视图
 */
@property (nonatomic, retain) IBOutlet UIView *backgroundView;

/**
 * @abstract 我与某某某共同签署过的文件Label
 */
@property (retain, nonatomic) IBOutlet UILabel *signWithSomeOnelabel;

/**
 * @abstract 与某某某共同签署过的tableview
 */
@property (retain, nonatomic) IBOutlet UITableView *documentTableView;

/**
 * @abstract 底部占位栏
 */
@property (retain, nonatomic) IBOutlet UIView *bottomBarView;

/**
 * @abstract 用户信息列表
 */
@property(nonatomic, retain) IBOutlet UITableView *userDetailInfoTable;

/*
 默认使用的签约地址
 */
@property (retain, nonatomic) IBOutlet UILabel *selectAddress;

/**
 * @abstract 其他辅助UI元素
 */
@property (retain, nonatomic) IBOutlet UIView *nameCardView;
@property (nonatomic, retain) IBOutlet UIImageView *cardBGImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topBottom;

/**
 *  发起与某人签名
 *
 *  @param sender
 */
- (IBAction)signWithSomeOneBtnClicked:(id)sender;

/**
 *  新增一条目
 *
 *  @param sender
 */
- (IBAction)addContextBtnClicked:(id)sender;

@end
