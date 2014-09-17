//
//  TypeSelectionTableViewController.h
//  PdfEditor
//
//  Created by MinwenYi on 14-5-9.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TypeSelectionTableViewController;

@protocol TypeSelectionTableViewControllerDelegate <NSObject>

/*!
 选择某个类型下的名称
 */
-(void)TypeSelectionTableViewController:(TypeSelectionTableViewController *)popoverController didSelectTypeTitle:(NSString *)strTitle;

@end

// 个人信息编辑状态类型名称选择视图
@interface TypeSelectionTableViewController : UITableViewController

@property(nonatomic, assign)id <TypeSelectionTableViewControllerDelegate> typeSelectionDelegate;

/*!
 更新某个类型下的名称
 */
-(void)changeTypeTitleWithName:(NSString *)strName;

@end
