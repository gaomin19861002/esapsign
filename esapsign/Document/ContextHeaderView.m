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

/*
 背景视图
 */
@property(nonatomic, retain) IBOutlet UIView *backgroundView;

/*!
 删除按钮
 */
@property(nonatomic, retain) IBOutlet UIButton *deleteButton;

/*!
 是否开启手势
 */
@property(nonatomic, assign) BOOL enableGesture;

/*!
 手势上一次坐标点
 */
@property(nonatomic, assign) CGPoint lastPoint;

/*!
 左扫手势
 */
@property(nonatomic, retain) UISwipeGestureRecognizer *leftSwip;

@property(nonatomic, retain) UIPanGestureRecognizer *panGesture;

/*!
 背后按钮响应方法
 */
- (IBAction)backButtonClicked:(id)sender;

/*!
 右侧添加按钮响应方法
 */
//- (IBAction)rightButtonClicked:(id)sender;

/*!
 删除按钮响应方法
 */
- (IBAction)deleteButtonClicked:(id)sender;

/*!
 左扫手势响方法
 */
//- (void)handleLeftSwip:(UIGestureRecognizer *)recognizer;

/*!
 拖动手势响应方法
 */
- (void)handlePan:(UIGestureRecognizer *)recognizer;

@end

@implementation ContextHeaderView

- (void)dealloc {
    [self removeGestureRecognizer:self.leftSwip];
    [self removeGestureRecognizer:self.panGesture];
}

- (void)awakeFromNib
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    // 添加左扫手势
    _leftSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwip:)];
    _leftSwip.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwip.delegate = self;
    [self addGestureRecognizer:_leftSwip];
}

/*!
 创建HeaderView
 @param storyboard storyboard对象，用于加载controller
 @return 创建好的headerView
 */
+ (ContextHeaderView *)headerView:(UIStoryboard *)storyboard {
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"HeaderView"];
    
    return (ContextHeaderView *)controller.view;
}

/*!
 更新显示
 */
- (void)updateShowWithTargetType:(TargetType)type selected:(BOOL)selected {
    self.titleButton.font = [UIFont fontWithName:@"Libian SC" size:23.0];
    if (selected) {
        [self.titleButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.titleButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor colorWithR:255 G:255 B:255 A:127]];
        if (type == TargetTypeSystemFolder) {
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderSysRootSel"] forState:UIControlStateNormal];
            //[self.headIcon setImage:[UIImage imageNamed:@""]];

        } else {
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderDefRootSel"] forState:UIControlStateNormal];
            //[self.headIcon setImage:[UIImage imageNamed:@""]];
        }
    } else {
        [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor clearColor]];
        if (type == TargetTypeSystemFolder) {
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderSysRoot"] forState:UIControlStateNormal];
            //[self.headIcon setImage:[UIImage imageNamed:@"icon_top.png"]];
        } else {
            [self.titleButton setBackgroundImage:[UIImage imageNamed:@"FolderDefRoot"] forState:UIControlStateNormal];
            //[self.headIcon setImage:[UIImage imageNamed:@"icon_sub.png"]];
        }
    }
    
    if (type == TargetTypeSystemFolder) {
        self.enableGesture = NO;
    } else if (type == TargetTypeUserFolder) {
        self.enableGesture = YES;
    }
}

#pragma mark - Private Methods

/*!
 背后按钮响应方法
 */
- (IBAction)backButtonClicked:(id)sender
{
    CGRect frame = self.backgroundView.frame;
    if (frame.origin.x < 0) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.backgroundView.frame;
            frame.origin.x = 0;
            self.backgroundView.frame = frame;
        } completion:nil];
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(headerViewClicked:)]) {
        [self.delegate headerViewClicked:self];
    }
}

/*!
 删除按钮响应方法
 */
- (IBAction)deleteButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked:)]) {
        [self.delegate deleteButtonClicked:self];
    }
}

/*!
 左扫手势响方法
 */
- (void)handleLeftSwip:(UIGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.backgroundView.frame;
        [self.deleteButton setHidden:NO];
        frame.origin.x = - self.deleteButton.frame.size.width;
        self.backgroundView.frame = frame;
    } completion:nil];
}

/*!
 拖动手势响应方法
 */
- (void)handlePan:(UIGestureRecognizer *)recognizer
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)recognizer;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.lastPoint = [pan translationInView:self];
            break;
        case UIGestureRecognizerStateChanged: {
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
        case UIGestureRecognizerStateCancelled: {
            CGRect frame = self.backgroundView.frame;
            if (frame.origin.x < -self.deleteButton.frame.size.width * 0.5) {
                                    [self.deleteButton setHidden:NO];
                if (frame.origin.x != -self.deleteButton.frame.size.width) {
                    [UIView animateWithDuration:0.3f animations:^{
                        CGRect frame = self.backgroundView.frame;
                        frame.origin.x = - self.deleteButton.frame.size.width;
                        self.backgroundView.frame = frame;
                    } completion:nil];
                }
            } else {
                                    [self.deleteButton setHidden:YES];
                if (frame.origin.x != 0) {

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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //return self.enableGesture;
    return NO; // 现在先禁止手势
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
