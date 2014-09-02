//
//  UIView+Addons.m
//  
//
//  Created by Liuxiaowei on 14-4-2.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UIView+Addons.h"

@implementation UIView (Addons)

- (UIView *)subviewWithTag:(NSInteger)tag {
	UIView *subView = nil;
	for (UIView *view in self.subviews) {
		if (view.tag == tag) {
			subView = view;
			break;
		}
	}

	return subView;
}

- (UIView *)subviewWithTag:(NSInteger)tag class:(Class)class {
	UIView *subView = nil;
	for (UIView *view in self.subviews) {
		if (view.tag == tag && [view isKindOfClass:class]) {
			subView = view;
			break;
		}
	}

	return subView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	CGRect bounds = self.bounds;
	if ([self isKindOfClass:[UIControl class]]) {
		CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
		CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
		if (widthDelta || heightDelta) {
			bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
		}
	}
	return CGRectContainsPoint(bounds, point);
}

@end

@implementation UIView (Shortcuts)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
	return self.frame.origin.x;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
	return self.frame.origin.y;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
	return self.center.x;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
	return self.center.y;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
	return self.frame.size.width;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
	return self.frame.size.height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
	CGFloat x = 0;
	for (UIView *view = self; view; view = view.superview) {
		x += view.left;

		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *)view;
			x -= scrollView.contentOffset.x;
		}
	}

	return x;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
	CGFloat y = 0;
	for (UIView *view = self; view; view = view.superview) {
		y += view.top;

		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *)view;
			y -= scrollView.contentOffset.y;
		}
	}
	return y;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
	return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
	return self.frame.origin;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
	return self.frame.size;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

- (NSArray *)allSubviews {
	NSMutableArray *arr = [NSMutableArray array];
	[arr addObject:self];
	for (UIView *subview in self.subviews) {
		[arr addObjectsFromArray:(NSArray *)[subview allSubviews]];
	}
	return arr;
}

@end

@implementation UIView (Roundify)

- (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii {
    CALayer *tMaskLayer = [self maskForRoundedCorners:corners withRadii:radii];
    self.layer.mask = tMaskLayer;
}

- (CALayer*)maskForRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii {
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:
                                 self.bounds byRoundingCorners:corners cornerRadii:radii];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [roundedPath CGPath];
    
    return maskLayer;
}

@end
