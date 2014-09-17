//
//  SignatureClipListView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureClipView.h"
#import "RequestManager.h"

#define SignsTagBase        1000

@class SignatureClipListView;

@protocol SignatureClipListViewDelegate <NSObject>

@optional

/**
 *  点击新增按钮事件
 *
 *  @param curSignsListView 当前签名列表图
 */
- (void)SignatureClipListViewDidClickedNewSignBtn:(SignatureClipListView *)curSignsListView;

/**
 *  拖动签名
 *
 *  @param curSignsListView 当前签名列表图
 *  @param curDragSign      被拖动签名
 *  @param point            拖动位置(相对signsListDelegate.view位置)
 *  @return void            nothing
 */
- (void)SignatureClipListView:(SignatureClipListView *)curSignsListView DidDragSign:(SignatureClipView *)curDragSign ToPoint:(CGPoint)point;

@end

/**
 * 签名选择列表页
 */
@interface SignatureClipListView : UIView <SignatureClipViewDelegate>
{
    CGRect startFrame;
}

@property (nonatomic, retain) NSMutableArray *arrDefaultSigns;
@property (nonatomic, assign) id<SignatureClipListViewDelegate> signsListDelegate;
@property (nonatomic, assign) BOOL allowDragSign;  // 是否支持签名拖拽，默认No
@property (nonatomic, retain) UIButton *btnAdd;

/**
 * 将要拖拽到另一个view目标
 */
@property (nonatomic, retain) UIView *panTargetView;

/**
 * 用来显示签名的CollectionView
 */
@property (nonatomic, retain) UICollectionView *signCollectionView;

/**
 * 新增签名
 *
 *  @param signImage 新签名
 */
- (void)insertNewSign:(UIImage *)signImage;

/**
 * 新增签名，二维码
 *
 *  @param signImage 新签名
 */
- (void)addNewSign:(UIImage *)signImage;

@end
