//
//  SignerFlowOutsideView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_sign.h"

@class SignerFlowOutsideView;

/**
 * @abstract Delegate
 */
@protocol SignInfoViewDelegate<NSObject>

- (void)willRemoveSign:(SignerFlowOutsideView *)infoView;

@end;

/**
 * @abstract Interface declaration
 *
 */
@interface SignerFlowOutsideView : UIView

@property(nonatomic, retain) Client_sign *sign;
@property(nonatomic, assign) BOOL editing;
@property(nonatomic, assign) id<SignInfoViewDelegate> delegate;

- (void)clear;

- (void)deleteButtonClicked:(id)sender;

@end
