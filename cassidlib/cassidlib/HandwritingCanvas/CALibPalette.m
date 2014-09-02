//
//  CALibPalette.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CALibPalette.h"

@implementation CALibPalette

/*
 * Override the drawRect method to display the drawing
 *
 */
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);

	// Redraw all lines from memory
	if ([allLines count] > 0)
	{
		for (int i = 0; i < [allLines count]; i++)
		{
			NSArray* tempArray = [NSArray arrayWithArray:[allLines objectAtIndex:i]];
			//----------------------------------------------------------------
			if ([allColors count] > 0)
			{
				Intsegmentcolor = [[allColors objectAtIndex:i] intValue];
				Intsegmentwidth = [[allWidths objectAtIndex:i] floatValue] + 1;
			}
			//-----------------------------------------------------------------
			if ([tempArray count] > 1)
			{
				CGContextBeginPath(context);
				CGPoint myStartPoint = [[tempArray objectAtIndex:0] CGPointValue];
				CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
				
				for (int j = 0; j < [tempArray count] - 1; j++)
				{
					CGPoint endPoint = [[tempArray objectAtIndex:j + 1] CGPointValue];
					CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
				}
				
                [self convertIntToColor];

				CGContextSetStrokeColorWithColor(context, segmentColor);
				CGContextSetLineWidth(context, Intsegmentwidth);
				CGContextStrokePath(context);
			}
		}
	}
    
	// Draw current new line
	if ([allPoints count] > 1)
	{
		CGContextBeginPath(context);
        
		CGPoint startPoint = [[allPoints objectAtIndex:0] CGPointValue];
		CGContextMoveToPoint(context, startPoint.x, startPoint.y);

		// Add all points to array
		for (int i = 0; i < [allPoints count] - 1; i++)
		{
			CGPoint endPoint = [[allPoints objectAtIndex:i + 1] CGPointValue];
			CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
		}
        
		// Get color and width value
		Intsegmentcolor = [[allColors lastObject] intValue];
		Intsegmentwidth = [[allWidths lastObject] floatValue] + 1;
		
        [self convertIntToColor];

		CGContextSetStrokeColorWithColor(context, segmentColor);
		CGContextSetFillColorWithColor(context, segmentColor);
        CGContextSetLineWidth(context, Intsegmentwidth);

		// Draw all points in the array
		CGContextStrokePath(context);
	}
}

#pragma mark - Initialize for array memebers

/*
 * Initialize all points
 */
- (void)initAllPoints
{
	NSLog(@"in init allPoint");
	allPoints = [[NSMutableArray alloc] initWithCapacity:10];
}

/*
 * Initialize all lines with putting all points array into it.
 */
- (void)initAllLinesIncludeAllPoints
{
	[allLines addObject:allPoints];
}

/*
 * Add a point (CGPoint type) into all points array.
 */
- (void)addPoint:(CGPoint)sender
{
	NSValue* pointvalue = [NSValue valueWithCGPoint:sender];
	[allPoints addObject:pointvalue];
}

/*
 * Add a color (integer type) into all colors array.
 */
- (void)addColor:(int)sender
{
	NSLog(@"Palette sender:%i", sender);
	NSNumber* Numbersender = [NSNumber numberWithInt:sender];
	[allColors addObject:Numbersender];
}

/*
 * Add a width (integer type) into all widths array.
 */
-(void)addWidth:(int)sender
{
	NSLog(@"Palette sender:%i", sender);
	NSNumber* Numbersender = [NSNumber numberWithInt:sender];
	[allWidths addObject:Numbersender];
}

#pragma mark - Drawing functions

/*
 * Clear all lines.
 */
- (void)toolClearAll
{
	if ([allLines count] > 0)
	{
		[allLines removeAllObjects];
		[allColors removeAllObjects];
		[allWidths removeAllObjects];
		[allPoints removeAllObjects];
		allLines = [[NSMutableArray alloc] initWithCapacity:10];
		allColors = [[NSMutableArray alloc] initWithCapacity:10];
		allWidths = [[NSMutableArray alloc] initWithCapacity:10];
		[self setNeedsDisplay];
	}
}

/*
 * Undo last line.
 */
- (void)toolUndoLast
{
	if ([allLines count] > 0)
	{
		[allLines removeLastObject];
		[allColors removeLastObject];
		[allWidths removeLastObject];
		[allPoints removeAllObjects];
	}
	[self setNeedsDisplay];
}

/*
 * Rubber tool.
 * Now, just use a white pen! how about other background? It SHOULD be BACKGROUND_COLOR.
 */
- (void)toolErase
{
	segmentColor = [[UIColor whiteColor]CGColor];
}

/*
 * Save image tool.
 */
- (UIImage*)toolSaveImage
{
	// Set clear color to background when saving
	self.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
    // UIGraphicsBeginImageContextWithOptions(self.bounds.size, 0.0f, 1.0f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
    
    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGSize(image.size));
    
    CGRect rectSign = [self imageFrame];
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rectSign);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    
    NSLog(@"%@", NSStringFromCGSize(result.size));
    
    return result;
}

#pragma mark - Touches handlers

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* touch = [touches anyObject];
	beginPoint = [touch locationInView:self];

	[self initAllPoints];
	[self addPoint:beginPoint];
    [self addColor:self.curSegmentColor];
	[self addWidth:self.curSegmentWidth];
    
    minPoint = beginPoint;
    maxPoint = beginPoint;
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	NSArray* movePointArray = [touches allObjects];
	movePoint = [[movePointArray objectAtIndex:0] locationInView:self];
    
    //不停检测更新矩形定位点坐标
    if (movePoint.x < minPoint.x)
        minPoint.x = movePoint.x;
    if (movePoint.y < minPoint.y)
        minPoint.y = movePoint.y;
    if (movePoint.x > maxPoint.x)
        maxPoint.x = movePoint.x;
    if (movePoint.y > maxPoint.y)
        maxPoint.y = movePoint.y;
    
	[self addPoint:movePoint];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self initAllLinesIncludeAllPoints];
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touches Canelled");
}

#pragma mark - Inner Functions

/*
 * Calculate the image size
 */
- (CGRect)imageFrame
{
    return CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    return CGRectMake(minPoint.x - 10 > 0 ? minPoint.x - 10 : 0,
                      minPoint.y - 10 > 0 ? minPoint.y - 10 : 0,
                      (maxPoint.x - minPoint.x + 20) < self.bounds.size.width ? (maxPoint.x - minPoint.x + 20) : self.bounds.size.width,
                      (maxPoint.y - minPoint.y + 20) < self.bounds.size.height ? (maxPoint.y - minPoint.y + 20) : self.bounds.size.height);
}

/*
 * Convert integer color value to CGColor
 *  ONLY 11 Colors supportted now.
 */
- (void)convertIntToColor
{
	switch (Intsegmentcolor)
	{
		case 0:
			segmentColor = [[UIColor blackColor] CGColor];
			break;
		case 1:
			segmentColor = [[UIColor redColor] CGColor];
			break;
		case 2:
			segmentColor = [[UIColor blueColor] CGColor];
			break;
		case 3:
			segmentColor = [[UIColor greenColor] CGColor];
			break;
		case 4:
			segmentColor = [[UIColor yellowColor] CGColor];
			break;
		case 5:
			segmentColor = [[UIColor orangeColor] CGColor];
			break;
		case 6:
			segmentColor = [[UIColor grayColor] CGColor];
			break;
		case 7:
			segmentColor = [[UIColor purpleColor]CGColor];
			break;
		case 8:
			segmentColor = [[UIColor brownColor]CGColor];
			break;
		case 9:
			segmentColor = [[UIColor magentaColor]CGColor];
			break;
		case 10:
			segmentColor = [[UIColor whiteColor]CGColor];
			break;
		default:
			break;
	}
}

@end
