//
//  Context.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    FolderType = 0,
    FileType,
} ContextType;

@interface Context : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) ContextType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger documentCount;

@end
