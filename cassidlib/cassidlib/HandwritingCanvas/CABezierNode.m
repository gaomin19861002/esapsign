//
//  CABezierNode.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CABezierNode.h"
#import "CACanvasActiveStatus.h"

@implementation CABezierNode

- (id) initWithInPoint:(CGPoint)inPoint
           anchorPoint:(CGPoint)pt
              outPoint:(CGPoint)outPoint
{
    if (self = [super init])
    {
        self.startPoint = inPoint;
        self.anchorPoint = pt;
        self.endPoint = outPoint;
        self.lineWidth = [[CACanvasActiveStatus sharedInstance] lineWidth];
    }
    return self;
}

@end
