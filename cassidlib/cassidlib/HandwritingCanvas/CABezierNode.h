//
//  CABezierNode.h
//  cassidlib
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * UNFINISHED
 * 贝塞尔曲线(目前只是最原始点，未加bezier处理)
 */
@interface CABezierNode : NSObject

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, retain) UIColor* lineColor;
@property (atomic, assign) CGFloat lineWidth;

- (id) initWithInPoint:(CGPoint)inPoint
           anchorPoint:(CGPoint)pt
              outPoint:(CGPoint)outPoint;

@end
