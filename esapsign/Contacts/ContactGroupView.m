//
//  ContactHeadFooterView.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactGroupView.h"

@implementation ContactGroupView

+ (ContactGroupView *)headerFooterView
{
    ContactGroupView *header = [[NSBundle mainBundle] loadNibNamed:@"ContactGroup" owner:self options:nil].lastObject;
    return header;
}

- (void)awakeFromNib
{
    self.rightSmallView.layer.cornerRadius = 10.0;
    self.rightSmallView.layer.borderWidth = 0.0f;
}

@end
