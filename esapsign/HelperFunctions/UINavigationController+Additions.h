//
//  UINavigationController+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 导航条按钮位置
 */
typedef NS_ENUM(NSInteger, BarButtonType) {
    
    /*!
     导航左侧
     */
    BarButtonTypeLeft = 0,
    
    /*!
     导航右侧
     */
    BarButtonTypeRight,
};

@interface UINavigationController(Additions)

/*!
 Add a custom button with image or title on navigation bar
 
 @param imageName name of image
 @param title     content of title
 @param type      type of button
 @param target    receiver of action
 @param action    action when button is pressed
 @param index     order of button in navigation bar,
 0 stands for the most left side as type is BarButtonTypeLeft;
 0 stands for the most right side as type is BarButtonTypeRight;
 @note imageName or title must not be nil at the same time
 
 @return button new added
 */
- (UIButton *)addButtonWithImageNamed:(NSString *)imageName title:(NSString *)title type:(BarButtonType)type target:(id)target action:(SEL)action index:(NSInteger)index;


/*!
 Get the custom button on navigation bar
 
 @param type  type of button
 @param index order of button in navigation bar,
 0 stands for the most left side as type is BarButtonTypeLeft;
 0 stands for the most right side as type is BarButtonTypeRight.
 
 @return button wanted or nil if not found
 */
- (UIButton *)buttonOfType:(BarButtonType)type atIndex:(NSInteger)index;

/*!
 Remove the custom button on navigtion bar
 
 @param type  type of button
 @param index order of button in navigation bar,
 0 stands for the most left side as type is BarButtonTypeLeft;
 0 stands for the most right side as type is BarButtonTypeRight.
 */
- (void)removeButtonWithType:(BarButtonType)type atIndex:(NSInteger)index;

@end
