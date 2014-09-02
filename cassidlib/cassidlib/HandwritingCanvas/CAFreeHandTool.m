//
//  CAFreeHandTool.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CABezierNode.h"
#import "CAFreeHandTool.h"
#import "CACanvasActiveStatus.h"

@interface CAFreeHandTool()

@property (nonatomic, retain) CALibPath *curPath;

@end

/*
 * 影响因子，与速率有关，此值越大，求得压力值变化越敏感
 */
#define Factor 1.0

@implementation CAFreeHandTool

- (void) paintPath:(CALibPath*)path inCanvas:(CALibCanvas*)canvas
{
    [canvas paintPath:path];
}

- (void) gestureBegan:(UIPanGestureRecognizer*)pan
{
    CGPoint touchPoint = [pan locationInView:pan.view];
    CALibCanvas* curCavas = (CALibCanvas*)(pan.view);
    self.curPath = [curCavas lastPath];
    
    CABezierNode *node = [[CABezierNode alloc] initWithInPoint:touchPoint anchorPoint:touchPoint outPoint:touchPoint];
    [self.curPath.nodes addObject:node];
    node.lineColor = [CACanvasActiveStatus sharedInstance].paintColor;
}

- (void) gestureMoved:(UIPanGestureRecognizer*)pan
{
    CGPoint touchPoint = [pan locationInView:pan.view];
    CABezierNode *lastcp = [self.curPath.nodes lastObject];
    float baseWidth = [CACanvasActiveStatus sharedInstance].lineWidth;
    float widthRange = [CACanvasActiveStatus sharedInstance].widthRange;
    if ([CACanvasActiveStatus sharedInstance].penStyle != FastThinSlowThick)
    {
        widthRange = 0.0f;
    }
    CGFloat width = baseWidth + widthRange;
    if ([CACanvasActiveStatus sharedInstance].penStyle == FastThinSlowThick)
    {
        CGPoint velocity = [pan velocityInView:pan.view];
        CGFloat v = sqrtf(velocity.x * velocity.x + velocity.y * velocity.y); // pixels/millisecond
        float pressure = v / 1000;
        pressure = WDSineCurve(1.0f - MIN(Factor, pressure) / Factor);
        pressure = 1.0f - pressure;
        width = baseWidth - widthRange * pressure;
        //NSLog(@"%f,%f, pressure:%f", v, width, pressure);
        // 均匀化粒子，在两点之间添加补充点
        if (fabs(lastcp.lineWidth - width) > 0.2)
        {
            int nSteps = (int)(fabs(lastcp.lineWidth - width) / 0.35);  //低阶宽度,每0.35增一个点
            for (float fRate = 1.0f / (float)nSteps; fRate < 1; fRate += 1.0f / (float)nSteps)
            {
                //NSLog(@"%f %d", fRate, nSteps);
                CGPoint pt = CGPointMake(lastcp.startPoint.x + (touchPoint.x - lastcp.startPoint.x ) * fRate, lastcp.startPoint.y + (touchPoint.y - lastcp.startPoint.y) * fRate);
                CABezierNode *node = [[CABezierNode alloc] initWithInPoint:pt anchorPoint:pt outPoint:pt];
                node.lineColor = [CACanvasActiveStatus sharedInstance].paintColor;
                node.lineWidth = lastcp.lineWidth + ( width - lastcp.lineWidth) * fRate;
                [self.curPath.nodes addObject:node] ;
            }
        }
    }
    CABezierNode *node = [[CABezierNode alloc] initWithInPoint:touchPoint anchorPoint:touchPoint outPoint:touchPoint];
    node.lineColor = [CACanvasActiveStatus sharedInstance].paintColor;
    node.lineWidth = width;
    [self.curPath.nodes addObject:node] ;
    [self paintPath:self.curPath inCanvas:(CALibCanvas *)(pan.view)];
}

- (void) gestureEnded:(UIPanGestureRecognizer*)recognizer
{
    CALibCanvas* curCavas = (CALibCanvas*)(recognizer.view);
    [curCavas closePath];
}

- (void) gestureCanceled:(UIGestureRecognizer*)recognizer
{
    CALibCanvas* curCavas = (CALibCanvas*)(recognizer.view);
    [curCavas closePath];
}

#pragma mark - Static Methods

/*
 * 压力转换
 */
float WDSineCurve(float input)
{
    float result;
    
    input *= M_PI; // move from [0.0, 1.0] tp [0.0, Pi]
    input -= M_PI_2; // shift back onto a trough
    
    result = sin(input) + 1; // add 1 to put in range [0.0,2.0]
    result /= 2; // back to [0.0, 1.0];
    
    return result;
}

/*
 * Init static tool object
 */
+ (CAFreeHandTool *) tool
{
    return [[[self class] alloc] init];
}

@end
