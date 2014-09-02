//
//  CALibPalette.h
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALibPalette : UIView
{
    // Arrays for saving drawing data
	NSMutableArray* allPoints;
	NSMutableArray* allLines;
	NSMutableArray* allColors;
	NSMutableArray* allWidths;

	// Integer values for loading color and width
    int Intsegmentcolor;
	float Intsegmentwidth;
    
    // Coverted color from integer color
	CGColorRef segmentColor;

    // Points used in movings
	CGPoint beginPoint;
	CGPoint movePoint;
    CGPoint minPoint;
    CGPoint maxPoint;
}

/*
 * @当前画笔颜色，用于绘制
 */
@property (nonatomic, assign)int curSegmentColor;
/*
 * @当前画笔粗细，用于绘制
 */
@property (nonatomic, assign)int curSegmentWidth;

- (void)initAllPoints;
- (void)initAllLinesIncludeAllPoints;
- (void)addPoint:(CGPoint)sender;
- (void)addColor:(int)sender;
- (void)addWidth:(int)sender;

- (void)toolClearAll;
- (void)toolUndoLast;
- (void)toolErase;
- (UIImage*)toolSaveImage;

@end
