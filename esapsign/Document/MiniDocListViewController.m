//
//  MiniDocListViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "MiniDocListViewController.h"
#import "NSDate+Additions.h"
#import "FileDetailCell.h"
#import "MiniFileDetailCell.h"
#import "DataManager.h"
@interface MiniDocListViewController ()

@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, retain) NSMutableArray  *arrSubFiles;
@end

@implementation MiniDocListViewController
@synthesize docListDelegate;

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RightBackground"]];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply
    //                                                                                     target:self
    //                                                                                     action:@selector(backButtonClicked:)];confirmButtonClicked
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(backButtonClicked:)];
    self.selectedRow = -1;
}

-(void)backButtonClicked:(id)sender
{
    if ([docListDelegate respondsToSelector:@selector(MiniDocListViewControllerDidCancelSelection:)]) {
        [docListDelegate MiniDocListViewControllerDidCancelSelection:self];
    }
}
-(void)confirmButtonClicked:(id)sender
{
    if (self.selectedRow < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请选择要签署的文件" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([docListDelegate respondsToSelector:@selector(MiniDocListViewController:DidSelectTarget:)]) {
        MiniFileDetailCell *cell = (MiniFileDetailCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
        [docListDelegate MiniDocListViewController:self DidSelectTarget:cell->targetInfo];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.parentTarget.subFiles.count > 0) {
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        self.selectedRow = 0;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrSubFiles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MiniFileDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MiniFileDetailCell" forIndexPath:indexPath];
    Client_target *fileTarget = (Client_target *)[self.arrSubFiles objectAtIndex:indexPath.row];
    cell->targetInfo = fileTarget;
    cell.titleLabel.text = fileTarget.display_name;
    cell.createLabel.text = [fileTarget.create_time fullDateString];
    
    Client_file *file = fileTarget.clientFile;
    if ([file.file_type intValue] == FileExtendTypePdf) {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypePDF"];
    } else if ([file.file_type intValue] == FileExtendTypeTxt) {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypeText"];
    } else {
        cell.leftImageView.image = [UIImage imageNamed:@"FileTypeImage"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma Private Methods

-(NSMutableArray *)arrSubFiles
{
    if (!_arrSubFiles) {
        _arrSubFiles = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _arrSubFiles;
}

- (void)setParentTarget:(Client_target *)parentTarget {
    if (![_parentTarget isEqual:parentTarget]) {
        _parentTarget = parentTarget;
        
        // 修改当前视图的标题会影响到其归属NavigationController，注意保存现场
        NSString* keep = [[self parentViewController] title];
        [self setTitle:[NSString stringWithFormat:@"%@", parentTarget.display_name]];
        [[self parentViewController] setTitle:keep];
        self.selectedRow = -1;
        NSArray *arrFiles = _parentTarget.subFiles;
        // 此处做过滤操作
        [self.arrSubFiles removeAllObjects];
        for (int i = 0; i < arrFiles.count; i++) {
            Client_target *item = [arrFiles objectAtIndex:i];
            if (![[DataManager defaultInstance] hasSignFlowWithClientFile:item.clientFile]) {
                [self.arrSubFiles addObject:item];
            }
        }
        [self.tableView reloadData];
    }
}


@end
