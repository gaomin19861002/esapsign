//
//  UIImageCoverRect.h
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CoverRect)

- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode;

@end
