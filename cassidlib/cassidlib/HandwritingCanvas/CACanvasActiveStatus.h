//
//  CACanvasActiveStatus.h
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "datatypes.h"

@interface CACanvasActiveStatus : NSObject

@property (nonatomic, retain)   UIColor *paintColor;
@property (nonatomic, readonly) BOOL eraseMode;
@property (nonatomic, assign)   PenStyle penStyle;
@property (nonatomic, assign)   float lineWidth;
@property (nonatomic, assign)   float widthRange;

+ (CACanvasActiveStatus *) sharedInstance;

@end
