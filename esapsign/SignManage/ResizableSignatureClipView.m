//
//  ResizableSignatureClipView.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ResizableSignatureClipView.h"

#define MaxWidth 500.0f
#define MinWidth 80.0f
#define ResizeDragViewWidth 20.0f

@interface ResizableSignatureClipView()
{
    UIImageView *resizeDragView;
}

@end

@implementation ResizableSignatureClipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.imgView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        resizeDragView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - ResizeDragViewWidth,
                                                                       frame.size.height - ResizeDragViewWidth,
                                                                       ResizeDragViewWidth, ResizeDragViewWidth)];
        resizeDragView.image = [UIImage imageNamed:@"ResizeArrow"];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [resizeDragView addGestureRecognizer:panRecognizer];
        [self addSubview:resizeDragView];
        resizeDragView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        self.maxWidth = MaxWidth;
        self.minWidth = MinWidth;
        
        self.imgView.layer.borderWidth = 2.0f;
        self.imgView.backgroundColor = [UIColor whiteColor];
        self.imgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gest
{
    CGPoint point = [gest translationInView:self];
    
    if (self.frame.size.width < self.minWidth)
    {
        NSLog(@"\n%f, \n", self.frame.size.width);
        [gest setTranslation:CGPointMake(0, 0) inView:self];
        return;
    }
    if (self.frame.size.height + self.frame.size.height / self.frame.size.width * point.x < 50) {
        NSLog(@"%f_%f", self.frame.size.height + self.frame.size.height / self.frame.size.width * point.x, self.minWidth);
        [gest setTranslation:CGPointMake(0, 0) inView:self];
        return;
    }
    
    CGRect drag  = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                              self.frame.size.width + point.x,
                              self.frame.size.height + self.frame.size.height / self.frame.size.width * point.x);
    if (drag.size.width < self.minWidth)
    {
        drag = CGRectMake(drag.origin.x, drag.origin.y,
                          self.minWidth,
                          self.minWidth * drag.size.height / drag.size.width);
    }
    if (CGRectContainsRect(self.backgroundView.frame, drag)) {
        self.frame = drag;
        self.imgView.frame = CGRectMake(0.0f,0.0f, self.frame.size.width, self.frame.size.height);
        resizeDragView.frame = CGRectMake(self.frame.size.width - ResizeDragViewWidth,
                                          self.frame.size.height - ResizeDragViewWidth,
                                          ResizeDragViewWidth, ResizeDragViewWidth);
        btnConfirm.frame = CGRectMake(self.frame.size.width - ResizeDragViewWidth, 0,
                                      ResizeDragViewWidth, ResizeDragViewWidth);
    }
    
    [gest setTranslation:CGPointMake(0, 0) inView:self.backgroundView];
    [gest setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)setBInEdit:(BOOL)bEdit
{
    if (bEdit)
    {
        btnDelete.hidden = NO;
        btnConfirm.hidden = NO;
    }
    else
    {
        btnDelete.hidden = YES;
        btnConfirm.hidden = YES;
    }
    bInEdit = bEdit;
}

@end
