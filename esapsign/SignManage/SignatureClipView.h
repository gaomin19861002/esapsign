//
//  SignatureClipView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_signfile.h"

#define SignViewItemWidth   140.0f
#define SignViewDistance    10.0f
#define SignViewItemHeight  56.0f
#define SignViewImageWidth  (SignViewItemWidth - 2.0f)
#define DefaultAddSignWitdh 48.0f

#define ItemDefaultAlpha    1.0f

@class SignatureClipView;

/**
 * @abstract The delegate of SinatureClipView
 */
@protocol SignatureClipViewDelegate <NSObject>

@optional

- (void)SignatureClipViewDidRemove:(SignatureClipView *)signView;

- (void)SignatureClipViewDidConfirm:(SignatureClipView *)signView;

- (void)SignatureClipViewDidStartDrag:(SignatureClipView *)signView;

- (void)SignatureClipViewDidEndDrag:(SignatureClipView *)signView;

@end

/**
 * @abstract 默认签名视图
 */
@interface SignatureClipView : UIView
{
    BOOL bInEdit;
    UIButton* btnDelete;
    UIButton* btnConfirm;
}

@property (nonatomic, assign) id <SignatureClipViewDelegate> del;

@property (nonatomic, retain) Client_signfile *defaultSign;

@property (nonatomic, assign) BOOL bInEdit;

@property (nonatomic, retain) UIImageView *imgView;

@property (nonatomic, retain) UIButton *btnDelete;

@property (nonatomic, retain) UIButton *btnConfirm;

@property (nonatomic, retain) UIView *rootView;

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;

@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGesture;

/**
 *  @abstract 允许进行拖拽
 *  @param  view：将要拖拽到的目标view
 */
- (void) allowPanWithRootView:(UIView *) view;

/**
 *  @abstract 允许进行拖拽
 */
- (void) allowDelete;

@end
