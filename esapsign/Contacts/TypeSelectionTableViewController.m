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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeTypeTitleWithName:(NSString *)strName
{
    NSLog(@"%s, %@", __FUNCTION__, strName);
    if ([self.typeSelectionDelegate respondsToSelector:@selector(TypeSelectionTableViewController:didSelectTypeTitle:)])  {
        [self.typeSelectionDelegate TypeSelectionTableViewController:self didSelectTypeTitle:strName];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self changeTypeTitleWithName:cell.textLabel.text];
}
@end
