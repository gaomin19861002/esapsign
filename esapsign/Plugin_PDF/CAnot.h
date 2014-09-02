//
//  CAnot.h
//  PdfEditor
//
//  Created by baidu on 14-5-17.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fgsdk_common.h"

@interface CAnot : NSObject

- (FS_RESULT) doAnnotAction;
- (void)AddStampAnnotWithPngData:(NSData *)imgData
                    leftTopPoint:(CGPoint)leftTopPoint
                rightBottomPoint:(CGPoint)rightBottomPoint;
@end
