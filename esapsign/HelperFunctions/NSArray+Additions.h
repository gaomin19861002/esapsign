//
//  NSArray+Additions.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(Additions)

- (id)objectOrNilAtIndex:(NSUInteger)index;

- (NSArray *)reverseObjects;

@end

@interface NSMutableArray(Additions)

- (void)setObjectOrNil:(id)obj atIndex:(NSUInteger)idx;

- (void)addObjectOrNil:(id)obj;

@end
