//
//  ContactContextCell.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-4-22.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactContextCell : UITableViewCell

/*!
 图标
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

@end
