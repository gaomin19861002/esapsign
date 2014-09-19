//
//  ContextHeaderView.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContextHeaderView.h"
#import "UIColor+Additions.h"

@interface ContextHeaderView()

// 背景视图
@property(nonatomic, retain) IBOutlet UIView *backgroundView;

// 删除按钮
@property(nonatomic, retain) IBOutlet UIButton *deleteButton;

@property(nonatomic, assign) BOOL enableGesture;
@property(nonatomic, assign) CGPoint lastPoint;
@property(nonatomic, retain) UISwipeGestureRecognizer *leftSwip;
@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;

@end

@implementation ContextHeaderView

// 创建HeaderView
+ (ContextHeaderView *)headerView
{
    ContextHeaderView *header = [[NSBundle mainBundle] loadNibNamed:@"ContextHeader" owner:self options:nil].lastObject;
    return header;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.leftSwip];
    [self removeGestureRecognizer:self.panGesture];
}

- (void)awakeFromNib
{
    // 添加拖动手势
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    // 添加左扫手势
    _leftSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwip:)];
    _leftSwip.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwip.delegate = self;
    [self addGestureRecognizer:_leftSwip];
}

// 更新显示
- (void)updateShowWithTargetType:(TargetType)type selected:(BOOL)selected
{
    [self.titleButton.titleLabel setFont:[UIFont fontWithName:@"Libian SC" size:23.0]];
    
    if (selected)
    {
        [self.titleButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.titleButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

        if (type == TargetTypeSystemFolder)
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderSysRootSel"] forState:UIControlStateNormal];
        else
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderDefRootSel"] forState:UIControlStateNormal];
    }
    else
    {
        [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        if (type == TargetTypeSystemFolder)
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderSysRoot"] forState:UIControlStateNormal];
        else
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderDefRoot"] forState:UIControlStateNormal];
    }
    
    self.enableGesture = (type != TargetTypeSystemFolder);
}

#pragma mark - Private Methods

// 点击名称取消删除
- (IBAction)backButtonClicked:(id)sender
{
    CGRect frame = self.backgroundView.frame;
    if (frame.origin.x < 0)
    {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.backgroundView.frame;
            frame.origin.x = 0;
            self.backgroundView.frame = frame;
        } completion:nil];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(headerViewClicked:)])
        [self.delegate headerViewClicked:self];
}

// 删除按钮响应方法
- (IBAction)deleteButtonClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked:)])
        [self.delegate deleteButtonClicked:self];
}

// 左扫手势响方法
- (void)handleLeftSwip:(UIGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.backgroundView.frame;
        [self.deleteButton setHidden:NO];
        frame.origin.x = - self.deleteButton.frame.size.width;
        self.backgroundView.frame = frame;
    } completion:nil];
}

// 拖动手势响应方法
- (void)handlePan:(UIGestureRecognizer *)recognizer
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
            self.lastPoint = [pan translationInView:self];
            break;
            
        case UIGestureRecognizerStateChanged:
            {
                CGPoint point = [pan translationInView:self];
                CGFloat offset = point.x - self.lastPoint.x;
                self.lastPoint = point;
                CGRect frame = self.backgroundView.frame;
                frame.origin.x += offset;
                frame.origin.x = frame.origin.x > 0 ? 0 : frame.origin.x;
                frame.origin.x = frame.origin.x < -self.deleteButton.frame.size.width ? -self.deleteButton.frame.size.width : frame.origin.x;
                self.backgroundView.frame = frame;
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            {
                CGRect frame = self.backgroundView.frame;
                if (frame.origin.x < -self.deleteButton.frame.size.width * 0.5)
                {
                    [self.deleteButton setHidden:NO];
                    if (frame.origin.x != -self.deleteButton.frame.size.width)
                    {
                        [UIView animateWithDuration:0.3f animations:^{
                            CGRect frame = self.backgroundView.frame;
                            frame.origin.x = - self.deleteButton.frame.size.width;
                            self.backgroundView.frame = frame;
                        } completion:nil];
                    }
                }
                else
                {
                    [self.deleteButton setHidden:YES];
                    if (frame.origin.x != 0)
                    {
                        [UIView animateWithDuration:0.3f animations:^{
                            CGRect frame = self.backgroundView.frame;
                            frame.origin.x = 0;
                            self.backgroundView.frame = frame;
                        } completion:nil];
                    }
                }
            }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.enableGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
