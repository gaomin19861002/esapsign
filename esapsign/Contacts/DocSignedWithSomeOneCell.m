//
//  DocSignedWithSomeOneCell.m
//  PdfEditor
//
//  Created by MinwenYi on 14-4-1.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "DocSignedWithSomeOneCell.h"

@implementation DocSignedWithSomeOneCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
