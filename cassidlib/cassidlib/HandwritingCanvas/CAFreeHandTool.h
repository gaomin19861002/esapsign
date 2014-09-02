//
//  CAFreeHandTool.h
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CALibPath.h"
#import "CALibCanvas.h"

@class CAFreeHandTool;

@interface CAFreeHandTool : NSObject

+ (CAFreeHandTool*) tool;

- (void) paintPath:(CALibPath*)path inCanvas:(CALibCanvas *)canvas;

- (void) gestureBegan:(UIPanGestureRecognizer *)recognizer;
- (void) gestureMoved:(UIPanGestureRecognizer *)recognizer;
- (void) gestureEnded:(UIPanGestureRecognizer *)recognizer;
- (void) gestureCanceled:(UIGestureRecognizer *)recognizer;

@end
