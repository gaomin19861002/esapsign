//
//  datatypes.h
//  cassidlib
//
//  Created by Suzic on 14-7-30.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#ifndef cassidlib_datatypes_h
#define cassidlib_datatypes_h

// 画笔风格
typedef enum
{
    FixWidth = 0,               // 默认画笔，粗细均匀
    FastThinSlowThick = 1,      // 越快越细
    FastThickSlowThin,          // 越慢越细(未完成)
    HThickVThin,                // 横粗竖细(未完成)
} PenStyle;

#endif
