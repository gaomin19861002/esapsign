//
//  UIImage+CoverRect.h
//  JinherNews
//
//  Created by gjl on 14-3-10.
//  Copyright (c) 2014年 Beyondsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CoverRect)
- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode;
@end
