//
//  TypeSelectionTableViewController.m
//  PdfEditor
//
//  Created by MinwenYi on 14-5-9.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import "TypeSelectionTableViewController.h"

@interface TypeSelectionTableViewController ()

@end

@implementation TypeSelectionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)changeTypeTitleWithName:(NSString *)strName
{
    if ([self.typeSelectionDelegate respondsToSelector:@selector(TypeSelectionTableViewController:didSelectTypeTitle:)])
        [self.typeSelectionDelegate TypeSelectionTableViewController:self didSelectTypeTitle:strName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self changeTypeTitleWithName:cell.textLabel.text];
}

@end
