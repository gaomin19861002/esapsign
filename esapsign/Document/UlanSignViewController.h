//
//  UlanSignViewController.h
//  esapsign
//
//  Created by Gaomin on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ULAN.h"

//==============================================================================
#pragma mark - 宏定义

#define CERT_TYPE_SM2               @"SM2"
#define CERT_TYPE_RSA1024           @"RSA1024"
#define CERT_TYPE_RSA2048           @"RSA2048"

#define HASH_ALGORITHM_SHA1         @"SHA1"
#define HASH_ALGORITHM_SHA256       @"SHA256"

//==============================================================================
#pragma mark - SignViewUlanDelegate协议定义

@protocol SignViewUlanDelegate <NSObject>
@optional
//type 0;成功 1:取消
-(void) afterDone:(CFISTError*)err type:(int)type result:(NSObject *)result;
@end

//==============================================================================
#pragma mark - CFCA蓝牙盾签名界面操作类

@interface UlanSignViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *pinField;
@property (strong, nonatomic)  IBOutlet UIButton *doneButton;
@property (strong, nonatomic)  IBOutlet UIButton *cancelButton;
@property (strong, nonatomic)  IBOutlet UILabel * pinHint;
@property (strong, nonatomic)  IBOutlet UIView*  midView;

@property (strong, nonatomic) ULAN      *ble;
@property (assign, nonatomic) id <SignViewUlanDelegate>  delegate;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) NSString *certType;
@property (strong, nonatomic) NSString *keyID;

-(void)sign:(NSData *)dataToSign parentView:(UIView *)parent
  delegate:(id<SignViewUlanDelegate>)delegate
   signType:(NSString *)signType
   certType:(NSString *)certType
       hash:(NSString *)hash
      keyID:(NSString *)keyID
isExternalHash:(BOOL)isExternalHash;

-(void)setLable:(int)index isHighLight:(BOOL)isHighLight text:(NSString*)text;
-(void) removeSelfView:(NSNumber *)duration;

@end

//==============================================================================

