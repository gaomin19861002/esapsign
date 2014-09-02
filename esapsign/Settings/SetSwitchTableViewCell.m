//
//  SetSwitchTableViewCell.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetSwitchTableViewCell.h"

@implementation SetSwitchTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction) switchValueChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(toogleSwitchTo:withType:)]) {
        [self.delegate toogleSwitchTo:self.switcher.on withType:self.type];
    }
}
@end
