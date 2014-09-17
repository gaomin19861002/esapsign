//
//  SignerLabelInsideView.h
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_sign.h"

#define ClientSignViewHeight 45.0
#define ClientSignViewWidth 190.0

@class SignerLabelInsideView;

typedef void (^DeleteBtnClickedBlock)(SignerLabelInsideView *clienSignView);

/*!
 单个签名
 */
@interface SignerLabelInsideView : UIView

@property (nonatomic, retain) Client_sign *clientSign;
@property (nonatomic, assign) BOOL bInEdit;
@property (nonatomic, assign) BOOL isCurrentSigner;
@property (nonatomic, copy) DeleteBtnClickedBlock deleteBtnClickedBlock;

@property (retain, nonatomic) IBOutlet UILabel *displayNameLabel;

@property (retain, nonatomic) IBOutlet UIButton *deleteButton;

@property (retain, nonatomic) IBOutlet UIView *outstandingMode;

@property (retain, nonatomic) IBOutlet UIView *normalMode;

- (IBAction)deleteButtonClicked:(id)sender;

- (void) setColor:(UIColor *) color;

@end
