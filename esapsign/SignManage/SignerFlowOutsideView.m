//
//  SignerFlowOutsideView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignerFlowOutsideView.h"
#import "UIImage+Additions.h"
#import "Client_user.h"

#define TagDeleteButtonStart 3000

@interface SignerFlowOutsideView()

@property (nonatomic, retain) UIImageView *signImageView;
@property (nonatomic, retain) UIImageView *signStatus;
@property (nonatomic, retain) UILabel *signLabel;

@end

@implementation SignerFlowOutsideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 2_bottom2_empty.png
    }
    return self;
}

- (void)awakeFromNib
{
    self.signImageView.image = [UIImage imageNamed:@"2_bottom2_empty.png"];
    self.signStatus.hidden = YES;
}

- (void)clear
{
    self.signLabel.text = nil;
    self.signImageView.image = [UIImage imageNamed:@"SignSlot"];
    self.signStatus.hidden = YES;
    self.alpha = 0.8;
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    if (_editing) {
        if (!self.sign.sign_date && !self.sign.refuse_date) {
            //没有签过名的人，添加删除按钮
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
            btn.tag = TagDeleteButtonStart;
            [self addSubview:btn];
            [btn setImage:[UIImage imageNamed:@"MarkDelete"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }

    } else {
        UIButton *btn = (UIButton *)[self viewWithTag:TagDeleteButtonStart];
        [btn removeFromSuperview];
    }
}

- (void)setSign:(Client_sign *)sign
{
    _sign = sign;
    UIImage *headImage = [UIImage imageNamed:[_sign.clientUser contentWithType:UserContentTypePhoto useLarge:YES]];
    if (!headImage)
    {
        NSString *defaultImage = @"IconHeadBig";
        headImage = [UIImage imageWithFile:defaultImage];
    }
    [self.signImageView setImage:headImage];
    [self setAlpha:1];
    self.signLabel.text = _sign.displayName;
}

- (UIImageView *)signImageView
{
    if (!_signImageView)
    {
        _signImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 60, 60)];
        [self addSubview:_signImageView];
    }
    return _signImageView;
}

- (UIImageView*)signStatus
{
    if (!_signStatus)
    {
        _signStatus = [[UIImageView alloc] initWithFrame:CGRectMake(50, 40, 20, 20)];
        [self addSubview:_signStatus];
    }
    return _signStatus;
}

- (UILabel *)signLabel
{
    if (!_signLabel)
    {
        _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 80, 21)];
        _signLabel.backgroundColor = [UIColor clearColor];
        _signLabel.font = [UIFont systemFontOfSize:13];
        _signLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_signLabel];
    }
    
    return _signLabel;
}

- (void)deleteButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willRemoveSign:)]) {
        [self.delegate willRemoveSign:self];
    }
}

@end
