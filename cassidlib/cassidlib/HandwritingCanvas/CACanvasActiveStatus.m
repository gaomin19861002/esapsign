//
//  CACanvasActiveStatus.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CACanvasActiveStatus.h"

@implementation CACanvasActiveStatus

+ (CACanvasActiveStatus *) sharedInstance
{
    static CACanvasActiveStatus *toolManager = nil;
    
    if (!toolManager)
    {
        toolManager = [[CACanvasActiveStatus alloc] init];
        toolManager.lineWidth = 10.0f;
        toolManager.widthRange = 7.0f;
        toolManager.penStyle = FixWidth;
        toolManager.paintColor = [UIColor blackColor];
    }
    
    return toolManager;
}
@end
