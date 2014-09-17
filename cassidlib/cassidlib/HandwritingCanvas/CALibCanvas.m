//
//  CALibCanvas.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CALibPath.h"
#import "CALibCanvas.h"
#import "CAFreeHandTool.h"
#import "CABezierNode.h"

@interface CALibCanvas ()
{
    BOOL currentlyPainting;
    BOOL hasPath;
}

/** 手写工具 */
@property (nonatomic, retain) CAFreeHandTool* handTool;
@property (nonatomic, retain) NSMutableArray* paths;
@property (nonatomic, readwrite, assign) CGRect signFrame;

@property (nonatomic, retain) UIImage *signImage;
@property (nonatomic, assign) CGRect  signImageRect;

- (CAFreeHandTool*)activeTool;

@end;

@implementation CALibCanvas

- (CAFreeHandTool*)handTool
{
    if (!_handTool) {
        _handTool = [CAFreeHandTool tool];
    }
    return _handTool;
}

- (NSMutableArray*)paths
{
    if (!_paths) {
        _paths = [[NSMutableArray alloc] initWithCapacity:1];
        [self addNewEmptyPath];
    }
    return _paths;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureGestures];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureGestures];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);
    // CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    // CGContextSetAllowsAntialiasing(context, YES);
    // CGContextSetShouldSmoothFonts(context, YES);

    //如果有图，则开始画图
    if (self.signImage) {
        [self.signImage drawInRect:self.signImageRect];
        return ;
    }

    self.signFrame = CGRectZero;
    for (CALibPath *pathItem in self.paths)
    {
        if (pathItem.nodes.count > 0)
        {
            CABezierNode *firstNode = [pathItem.nodes objectAtIndex:0];
            // CGContextMoveToPoint(context, firstNode.startPoint.x, firstNode.startPoint.y);
            
            CGContextSetStrokeColorWithColor(context, [firstNode lineColor].CGColor);
            CGContextSetFillColorWithColor (context, [firstNode lineColor].CGColor);
            for (int i = 1; i < [pathItem.nodes count] - 1; i++)
            {
                CGContextBeginPath(context);
                CABezierNode *s = [pathItem.nodes objectAtIndex:i-1];
                CABezierNode *c = [pathItem.nodes objectAtIndex:i];
                CABezierNode *e = [pathItem.nodes objectAtIndex:i+1];
                
                CGFloat x = s.startPoint.x + (c.startPoint.x - s.startPoint.x) / 2;
                CGFloat y = [self coordinateYWithX:x StartPoint:s.startPoint EndPoint:c.startPoint];
                
                CGFloat x1 = c.startPoint.x + (e.startPoint.x - c.startPoint.x) / 2;
                CGFloat y1 = [self coordinateYWithX:x1 StartPoint:c.startPoint EndPoint:e.startPoint];
                
				CGContextMoveToPoint(context, x, y);
                CGContextSetLineWidth(context, c.lineWidth);
                CGContextAddQuadCurveToPoint(context, c.startPoint.x, c.startPoint.y, x1, y1);
                
                if (CGRectIsEmpty(self.signFrame))
                {
                    self.signFrame = CGContextGetPathBoundingBox(context);
                }
                else
                {
                    self.signFrame = CGRectUnion(self.signFrame, CGContextGetPathBoundingBox(context));
                }
                CGContextStrokePath(context);
            }
        }
    }
    
    if (!CGRectIsEmpty(self.signFrame))
    {
        float fExternWidth = 10.0f;
        self.signFrame = CGRectMake(self.signFrame.origin.x -fExternWidth >0 ? self.signFrame.origin.x - fExternWidth : 0.0f ,self.signFrame.origin.y -fExternWidth >0 ? self.signFrame.origin.y - fExternWidth : 0.0f  , self.signFrame.size.width + self.signFrame.origin.x + 2 * fExternWidth < self.frame.size.width ? self.signFrame.size.width + 2 * fExternWidth : self.frame.size.width - self.signFrame.origin.x , self.signFrame.size.height + self.signFrame.origin.y + 2 *fExternWidth < self.frame.size.height ? self.signFrame.size.height + 2 *fExternWidth : self.frame.size.height - self.signFrame.origin.y);
    }
}

- (void)addNewEmptyPath
{
    CALibPath *newPath = [[CALibPath alloc] init];
    [self.paths addObject:newPath];
}

- (void)configureGestures
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    self.userInteractionEnabled = YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        hasPath = YES;
        currentlyPainting = YES;
        [[self activeTool] gestureBegan:sender];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        [[self activeTool] gestureMoved:sender];
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        currentlyPainting = NO;
        [[self activeTool] gestureEnded:sender];
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        currentlyPainting = NO;
        [[self activeTool] gestureCanceled:sender];
    }
}

- (void)paintPath:(CALibPath*)path
{
    // 存储点
    if (![self.paths containsObject:path])
    {
        [self.paths addObject:path];
    }
    
    // 重绘页面
    [self setNeedsDisplay];
}

/**
 *  当前笔画
 *
 *  @return
 */
-(CALibPath *)lastPath
{
    return [self.paths lastObject];
}

/**
 *  完成一笔画
 */
-(void)closePath
{
    [self addNewEmptyPath];
    // 重绘页面
    [self setNeedsDisplay];
}

/**
 *  撤销
 */
- (void)undo
{
    //  删除最后一个空Path
    [self.paths removeLastObject];
    //  删除上一Path
    [self.paths removeLastObject];
    //  添加空Path
    [self addNewEmptyPath];
    // 重绘页面
    [self setNeedsDisplay];
}

- (void)clear
{
    [self.paths removeAllObjects];
    [self addNewEmptyPath];
    // 重绘页面
    [self setNeedsDisplay];
}

- (UIImage*)save
{
    if (self.signImage)
    {
        return self.signImage;
    }
    
    UIColor *bgColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], self.bounds);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
	UIGraphicsEndImageContext();
    
    // 画布大小
    float fWidth = self.bounds.size.height * 2.3;
    UIGraphicsBeginImageContext(CGSizeMake(fWidth, self.bounds.size.height));
    
    CGRect rectClip = CGRectMake((fWidth - self.bounds.size.width ) / 2.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    [result drawInRect:rectClip];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();

    self.backgroundColor = bgColor;
    return image;
}

- (UIImage*)saveWithoutCompress
{
    if (self.signImage)
    {
        return self.signImage;
    }
    
    UIColor *bgColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.bounds.size);
	
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], self.signFrame);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
	
    UIGraphicsEndImageContext();
    self.backgroundColor = bgColor;
    return result;
}

/*!
 *  @abstract 从新设置signFrame
 */
- (void) resetSignFrame:(CGRect ) rect
{
    self.signFrame = rect;
}

/*!
 *  @abstract 判断是否有笔画
 */
- (BOOL) isEmpty
{
    return hasPath;
}

/*!
 *  @abstract 判断是否有笔画
 *  @param image 添加的签名图
 *  @param rect image所在的rect
 */
- (void) setSignImage:(UIImage *) image inRect:(CGRect) rect
{
    self.signImage = image;
    self.signImageRect = rect;
    [self setNeedsDisplay];
}

/*!
 *  @abstract 判断是否还有图像，如果含有，表明是图像模式
 */
- (BOOL) hasImage
{
    if (self.signImage)
    {
        return YES;
    }
    return NO;
}

/*!
 *  @abstract 清除image
 */
- (void) clearImage
{
    self.signImageRect = CGRectZero;
    self.signImage = nil;
}

#pragma mark - Private Methods

- (CAFreeHandTool*)activeTool
{
    return self.handTool;
}

- (CGFloat)coordinateYWithX:(CGFloat)aX StartPoint:(CGPoint)aStartPoint EndPoint:(CGPoint)aEndPoint
{
	if ((aEndPoint.x < aStartPoint.x && (aX < aEndPoint.x || aX > aStartPoint.x)) ||
        (aStartPoint.x < aEndPoint.x && (aX < aStartPoint.x || aX > aEndPoint.x)))
	{
		NSLog(@"out of range");
		return -1;
	}
	
	if (fabsf(aEndPoint.x - aStartPoint.x) < 0.05)
	{
		return aStartPoint.y;
	}
	
	CGFloat k = (aEndPoint.y - aStartPoint.y) / (aEndPoint.x - aStartPoint.x);
	return k * (aX - aStartPoint.x) + aStartPoint.y;
}

@end
