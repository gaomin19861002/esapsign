//
//  ContactDetailViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_contact.h"

@interface ContactDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

// 改直接从联系人列表赋值Client_user为userID以解决类之间直接赋值coredata数据程序有时暴死的情况 gaomin@20140808
@property (nonatomic ,copy) NSString *currentUserID;

/** 联系人头像及姓名的展示和编辑 */
@property (nonatomic, strong) IBOutlet UIImageView *headImageView;
@property (nonatomic, strong) IBOutlet UILabel *familyNameLabel;
@property (nonatomic, strong) IBOutlet UITextField *familyNameTextField;
@property (nonatomic, strong) IBOutlet UILabel *personNameLabel;
@property (nonatomic, strong) IBOutlet UITextField *personNameTextField;

@property (nonatomic, strong) IBOutlet UIImageView *line1;
@property (nonatomic, strong) IBOutlet UIImageView *line2;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteContactButton;

/**
 * @abstract 用户信息列表
 */
@property(nonatomic, retain) IBOutlet UITableView *userDetailInfoTable;

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
- (void)addContextBtnClicked:(id)sender;

@end
