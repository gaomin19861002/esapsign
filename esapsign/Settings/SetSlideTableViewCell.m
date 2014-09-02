//
//  SetSlideTableViewCell.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetSlideTableViewCell.h"

@implementation SetSlideTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction) slideValueChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(setSlideChanged:withType:)]) {
        [self.delegate setSlideChanged:self.slider.value withType:self.type];
    }
    self.numLabel.text = [NSString stringWithFormat:@"%d", (int)self.slider.value];
}

@end
