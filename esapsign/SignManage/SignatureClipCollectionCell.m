//
//  SignatureClipCollectionCell.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignatureClipCollectionCell.h"

@implementation SignatureClipCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SignBack"]];
        self.clipsToBounds = NO;
    }
    return self;
}

@end
