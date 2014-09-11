//
//  SignerFlowInsideView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_sign.h"

typedef BOOL (^ShouldDeleteClientSignBlock)(Client_sign *clienSign);

typedef void (^NewClientSignClickedBlock)(void);

/**  签名流程表 */
@interface SignerFlowInsideView : UIView

/*!
 签名流中签名列表视图
 */
@property(nonatomic, retain) NSMutableArray *clientSignViews;

@property(nonatomic, copy) ShouldDeleteClientSignBlock shouldDeleteClientSignBlock;

@property(nonatomic, copy) NewClientSignClickedBlock newClientSignClickedBlock;

@property(nonatomic, assign) BOOL supportLongPressAction;

/*!
 清除所有ClientSign视图
 */
- (void)clearAllClientSigns;

/*!
 添加一个ClientSign
 @param clientSign 当前clientSign
 */
- (void)addClientSign:(Client_sign *)clientSign;

/*!
 增加添加签名按钮
 */
- (void)addNewClientSignButton:(BOOL)bAdd;

- (void)updateSignflowConstraintsWithSignCount:(NSUInteger)count;

@end
