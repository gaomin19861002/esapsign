//
//  UIView+Addons.h
//  
//
//  Created by Liuxiaowei on 14-4-2.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Addons)

- (UIView *)subviewWithTag:(NSInteger)tag class:(Class)class;

- (UIView *)subviewWithTag:(NSInteger)tag;

@end

@interface UIView (Shortcuts)

/*!
   Shortcut for frame.origin.x.

   Setter frame.origin.x = left
 */
@property (nonatomic, assign) CGFloat left;

/*!
   Shortcut for frame.origin.y

   Setter frame.origin.y = top
 */
@property (nonatomic, assign) CGFloat top;

/*!
   Shortcut for frame.origin.x + frame.size.width

   Setter frame.origin.x = right - frame.size.width
 */
@property (nonatomic, assign) CGFloat right;

/*!
   Shortcut for frame.origin.y + frame.size.height

   Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic, assign) CGFloat bottom;

/*!
   Shortcut for frame.size.width

   Sets frame.size.width = width
 */
@property (nonatomic, assign) CGFloat width;

/*!
   Shortcut for frame.size.height

   Sets frame.size.height = height
 */
@property (nonatomic, assign) CGFloat height;

/*!
   Shortcut for center.x

   Sets center.x = centerX
 */
@property (nonatomic, assign) CGFloat centerX;

/*!
   Shortcut for center.y

   Sets center.y = centerY
 */
@property (nonatomic, assign) CGFloat centerY;

/*!
   Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/*!
   Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

/*!
   Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/*!
   Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/*!
   Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/*!
   Return all views including self and recursively subviews
 */
@property (nonatomic, readonly) NSArray *allSubviews;

@end

@interface UIView (Roundify)

- (void)addRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii;

- (CALayer*)maskForRoundedCorners:(UIRectCorner)corners withRadii:(CGSize)radii;

@end
