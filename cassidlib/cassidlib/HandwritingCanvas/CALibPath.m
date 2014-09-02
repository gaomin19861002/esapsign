//
//  CALibPath.m
//  cassidlib
//
//  Created by Suzic on 14-7-28.
//  Copyright (c) 2014 Caland. All rights reserved.
//

#import "CALibPath.h"

@implementation CALibPath

- (NSMutableArray*)nodes
{
    if (!_nodes) {
        _nodes = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _nodes;
}

@end
