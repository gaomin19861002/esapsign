//
//  ContactHeader.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactSectionView.h"

@implementation ContactSectionView

+ (ContactSectionView *)headSection
{
    ContactSectionView *header = [[NSBundle mainBundle] loadNibNamed:@"ContactSection" owner:self options:nil].lastObject;
    return header;
}

@end
