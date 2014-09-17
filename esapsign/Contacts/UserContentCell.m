//
//  UserContentCell.m
//  PdfEditor
//
//  Created by Liuxiaowei on 14-5-3.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "UserContentCell.h"

@implementation UserContentCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeSelectionButtonClicked:)];
    [self.titleLabel addGestureRecognizer:tapGesture];
    self.titleLabel.userInteractionEnabled = YES;
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	[UIView animateWithDuration:animated ? 0.35f : 0.0f animations:^{ self.starImageView.alpha = editing ? 0.0f : 1.0f; }];
}

- (void)typeSelectionButtonClicked:(id)sender
{
    DebugLog(@"%s", __FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(UserContentCellModifyTypeTitleButtonClicked:)])
        [self.delegate UserContentCellModifyTypeTitleButtonClicked:self];
}

#pragma mark - UITextFieldDelegate

- (void)changeTypeTitleWithName:(NSString *)strName
{
    if ([self.delegate respondsToSelector:@selector(UserContentCell:DidFinishEditingSubTitleWithName:)])
        [self.delegate UserContentCell:self DidFinishEditingSubTitleWithName:strName];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.subTitleTextField == textField)
        [self.subTitleTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.subTitleTextField == textField)
    {
        if ([self.delegate respondsToSelector:@selector(UserContentCellDidBeginEditing:)])
            [self.delegate UserContentCellDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.subTitleTextField == textField)
        [self changeTypeTitleWithName:self.subTitleTextField.text];
}


@end
