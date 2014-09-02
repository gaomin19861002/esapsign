//
//  ContactHeadFooterView.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactHeaderFooterView : UIView

+ (ContactHeaderFooterView *)headerFooterView:(UIStoryboard *)stroyboard;

/*!
 标题;
 */
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;

/*!
 副标题
 */
@property(nonatomic, retain) IBOutlet UILabel *subTitleLabel;

/*!
 右侧小背景
 */
@property(nonatomic, retain) IBOutlet UIView *rightSmallView;

@end
