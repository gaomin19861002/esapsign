//
//  CALibPath.h
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CABezierNode;

@interface CALibPath : NSObject

/*
 * 存储点
 */
@property (nonatomic, retain) NSMutableArray* nodes;

@end
