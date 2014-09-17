//
//  SignerFlowInsideView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignerFlowInsideView.h"
#import "SignerLabelInsideView.h"
#import "CAAppDelegate.h"
#import "Client_sign_flow.h"


// 单个签名留种签名高度
#define SignItemHeight 45.0

@interface SignerFlowInsideView ()

@property(nonatomic, assign) BOOL inEdit;
@property(nonatomic, retain) UIView *maskView;
@property(nonatomic, assign) NSUInteger signCount;

@end

@implementation SignerFlowInsideView


- (void)setInEdit:(BOOL)bInEdit
{
    [self.clientSignViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        SignerLabelInsideView *item = obj;
        if ([item isKindOfClass:[SignerLabelInsideView class]])
        {
            item.bInEdit = bInEdit;
        }
     }];
    _inEdit = bInEdit;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        CGRect frame = CGRectMake(0.0f, 0.0f, 1024.0f, 1024.0f);
        _maskView = [[UIView alloc] initWithFrame:frame];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.supportLongPressAction = YES;
    UILongPressGestureRecognizer *gestLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:gestLongPress];
}

// maskview点击事件
- (void)tapped:(UIGestureRecognizer *)gest
{
    __block BOOL bHasItemDeleted = NO;
    
    [self.clientSignViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
        SignerLabelInsideView *item = obj;
        if ([item isKindOfClass:[SignerLabelInsideView class]])
        {
            CGPoint point = [gest locationInView:item];
            if (CGRectContainsPoint(CGRectMake(0, 4, 32, 32), point))
            {
                [item deleteButtonClicked:nil];
                bHasItemDeleted = YES;
                *stop = YES;
            }
        }
     }];
    
    if (!bHasItemDeleted)
    {
        [self.maskView removeFromSuperview];
        self.inEdit = NO;
    }
}

- (void)longPress:(UIGestureRecognizer *)gest
{
    if (!self.supportLongPressAction) {
        return;
    }
    
    //长按事件
    if ([gest isMemberOfClass:[UITapGestureRecognizer class]]) {
        // 点击事件
        self.inEdit = NO;
        
    }
    // allowDragSign为YES时，长按无响应
    else if ([gest isMemberOfClass:[UILongPressGestureRecognizer class]])
    {
        if (self.inEdit) {
            return;
        }
        // 增加maskview
        [self.maskView removeFromSuperview];
        [[CAAppDelegate sharedDelegate].window addSubview:self.maskView];
        self.inEdit = YES;
    }
}

- (void)clearAllClientSigns
{
    [self.clientSignViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    [self.clientSignViews removeAllObjects];
}

- (void)deleteClientSignView:(SignerLabelInsideView *)clientSignView
{
    BOOL shouldDelete = NO;
    if (self.shouldDeleteClientSignBlock) {
        shouldDelete = self.shouldDeleteClientSignBlock(clientSignView.clientSign);
    }
    if (!shouldDelete) {
        return;
    }
    NSUInteger index = [self.clientSignViews indexOfObject:clientSignView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [clientSignView removeFromSuperview];
    for (int i = index; i < self.clientSignViews.count; i++) {
        SignerLabelInsideView *item = self.clientSignViews[i];
        if (item) {
            CGRect frame = item.frame;
            frame.origin.y -= ClientSignViewHeight;
            item.frame = frame;
        }
    }
    [self.clientSignViews removeObject:clientSignView];
    [UIView commitAnimations];
    if (!self.clientSignViews.count) {
        self.inEdit = NO;
    }
    
    // 更新界面
    self.signCount--;
    [self updateSignflowConstraintsWithSignCount:self.signCount];
}

- (void)addClientSign:(Client_sign *)clientSign
{
    SignerLabelInsideView *clientSignView = [[NSBundle mainBundle] loadNibNamed:@"SignerLabelInside" owner:self options:nil].lastObject;
    CGFloat yPos = self.clientSignViews.count * ClientSignViewHeight + 20;
    UIView *addbuttonView = [self.clientSignViews lastObject];
    if ([addbuttonView isKindOfClass:[UIButton class]])
    {
        addbuttonView.frame = CGRectMake(0.0, yPos, ClientSignViewWidth, ClientSignViewHeight);
        yPos -= ClientSignViewHeight;
    }
    if (clientSignView)
    {
        clientSignView.frame = CGRectMake(0.0, yPos, ClientSignViewWidth, ClientSignViewHeight);
        clientSignView.clientSign = clientSign;
        BlockWeakObject(self, wself);
        clientSignView.deleteBtnClickedBlock = ^(SignerLabelInsideView *item) {
            BlockStrongObject(wself, self);
            [self deleteClientSignView:item];
        };
        [self addSubview:clientSignView];
        [self.clientSignViews addObject:clientSignView];
        
        // FIXME: 此方法需suzhi确认
        bool needSequence = NO;
        Client_sign_flow *signFlow = clientSign.sign_flow;
        if (([clientSign.sign_id isEqualToString:signFlow.current_sign_id] && clientSign.sign_date != nil)
            || signFlow.current_sign_id == nil || [signFlow.current_sign_id isEqualToString:@""]) {
            needSequence = YES;
        }
        if (signFlow.current_sign_id == clientSign.sign_id
            || (needSequence && signFlow.current_sequence == clientSign.sequence)) {
            clientSignView.isCurrentSigner = YES;
        }
        
        //TODO:添加灰色，红色、黄色三种状态值
        //红色：拒签；
        //黄色：待签；
        //绿色：已签；
        if (clientSign.refuse_date != nil) {
            //已经拒绝，设置为红色
            [clientSignView setColor:[UIColor redColor]];
            
        }else if (clientSign.sign_date != nil) {
            //已经签署
            [clientSignView setColor:[UIColor greenColor]];
            
        }else {
            //没有拒签也没有签署，可能是已经轮到的用户
            [clientSignView setColor:[UIColor yellowColor]];
        }
    }
}

- (void)addNewClientSignButton:(BOOL)bAdd
{
    if (bAdd)
    {
        CGFloat yPos = self.clientSignViews.count * ClientSignViewHeight + 20;
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn setBackgroundColor:[UIColor redColor]];
        addBtn.frame = CGRectMake(40.0, yPos, ClientSignViewWidth - 60, ClientSignViewHeight);
        [addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addBtn];
        [self.clientSignViews addObject:addBtn];
    }
}

- (void)addBtnClicked:(id)sender
{
    if (self.newClientSignClickedBlock)
    {
        self.newClientSignClickedBlock();
    }
}

/*!
 更新signflow高度
 @param count sign个数
 */
- (void)updateSignflowConstraintsWithSignCount:(NSUInteger)count
{
    self.signCount = count;
    NSArray *constraints = self.constraints;
    for (NSLayoutConstraint *item in constraints)
    {
        if (item.firstAttribute == NSLayoutAttributeHeight)
        {
            [self removeConstraint:item];
            NSLayoutConstraint *newWidth =
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:count * SignItemHeight];
            [self addConstraint:newWidth];
        }
    }
}

#pragma mark - getter

- (NSMutableArray *)clientSignViews
{
    if (!_clientSignViews)
    {
        _clientSignViews = [[NSMutableArray alloc] init];
    }
    return _clientSignViews;
}

@end
