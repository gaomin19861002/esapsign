//
//  SignerLabelInsideView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignerLabelInsideView.h"
#import "UIImage+Additions.h"
#import "Client_user.h"

@interface SignerLabelInsideView ()

@end

@implementation SignerLabelInsideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*!
 修改item的透明度
 @param fAlpha 透明度
 @param timeDelay 延迟
 */
- (void)changeItemAlpha:(float)fAlpha withDelay:(float)timeDelay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationDelay:timeDelay];
    self.alpha = fAlpha;
    [UIView commitAnimations];
}

- (void)setClientSign:(Client_sign *)clientSign
{
    _clientSign = clientSign;
    self.displayNameLabel.text = clientSign.displayName;
}

- (void)setBInEdit:(BOOL)bEdit
{
    if (bEdit && (self.clientSign.sign_date == nil && self.clientSign.refuse_date == nil))
    {
        [self changeItemAlpha:0.8 withDelay:0.0f];
        self.deleteButton.hidden = NO;
    }
    else
    {
        [self changeItemAlpha:1.0 withDelay:0.0f];
        self.deleteButton.hidden = YES;
    }
    _bInEdit = bEdit;
}

- (void)setIsCurrentSigner:(BOOL)isCurrentSigner
{
    _isCurrentSigner = isCurrentSigner;
    self.outstandingMode.hidden = !_isCurrentSigner;
    self.normalMode.hidden = _isCurrentSigner;
}

- (IBAction)deleteButtonClicked:(id)sender
{
    if (self.deleteBtnClickedBlock) {
        self.deleteBtnClickedBlock(self);
        self.deleteBtnClickedBlock = nil;
    }
}

@end
