//
//  ContactSelectedCell.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-20.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSelectedCell : UITableViewCell

/*!
 联系人图标
 */
@property(nonatomic, retain) IBOutlet UIImageView *headImageView;

/*!
 联系人名称
 */
@property(nonatomic, retain) IBOutlet UILabel *nameLabel;

/*!
 操作日期
 */
@property(nonatomic, retain) IBOutlet UILabel *selectedDateLabel;

@end
