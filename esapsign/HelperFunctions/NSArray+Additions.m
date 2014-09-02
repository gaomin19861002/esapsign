//
//  NSArray+Additions.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray(Additions)

- (id)objectOrNilAtIndex:(NSUInteger)index {
    if ([self count] <= index) {
        return nil;
    }
    
    return [self objectAtIndex:index];
}

- (NSArray *)reverseObjects {
    NSMutableArray *reverseObjects = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [reverseObjects addObject:obj];
    }];
    
    return reverseObjects;
}

@end

@implementation NSMutableArray(Additions)

- (void)setObjectOrNil:(id)obj atIndex:(NSUInteger)idx {
    if (!obj) {
        return;
    }
    
    if (idx < self.count) {
        [self replaceObjectAtIndex:idx withObject:obj];
    } else {
        int placeHolderCount = idx - self.count;
        if (placeHolderCount) {
            for (int i = 0; i < placeHolderCount; ++i) {
                [self addObject:[NSNull null]];
            }
        }
        [self addObject:obj];
    }
}

- (void)addObjectOrNil:(id)obj {
    if (obj) {
        [self addObject:obj];
    }
}

@end
