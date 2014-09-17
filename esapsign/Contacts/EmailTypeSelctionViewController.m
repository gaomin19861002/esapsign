//
//  EmailTypeSelctionViewController.m
//  PdfEditor
//
//  Created by MinwenYi on 14-5-9.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "EmailTypeSelctionViewController.h"

@interface EmailTypeSelctionViewController () <UITextFieldDelegate>
@end

@implementation EmailTypeSelctionViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfTypeTitleNew resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.tfTypeTitleNew.hidden == YES)
        return;
    [self changeTypeTitleWithName:self.tfTypeTitleNew.text];
}

#pragma mark - Table view data source

#define TextFieldTag    1100
#define LabelTag        (TextFieldTag + 1)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1)
    {
        // 最后一行
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *tfEmailTitleNew = (UITextField *)[cell viewWithTag:TextFieldTag];
        if (tfEmailTitleNew)
        {
            self.tfTypeTitleNew = tfEmailTitleNew;
            UILabel *lbTitle = (UILabel *)[cell viewWithTag:LabelTag];
            if (lbTitle)
                lbTitle.hidden = YES;

            if (self.tfTypeTitleNew.hidden)
            {
                self.tfTypeTitleNew.hidden = NO;
                self.tfTypeTitleNew.delegate = self;
                [self.tfTypeTitleNew becomeFirstResponder];
            }
        }
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (self.tfTypeTitleNew && self.tfTypeTitleNew.hidden == NO)
        {
            self.tfTypeTitleNew.hidden = YES;
            [self.tfTypeTitleNew resignFirstResponder];
        }
        [self changeTypeTitleWithName:cell.textLabel.text];
    }
}

@end
