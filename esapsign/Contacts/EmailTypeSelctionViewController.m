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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfTypeTitleNew resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.tfTypeTitleNew.hidden == YES) {
        return;
    }
    [self changeTypeTitleWithName:self.tfTypeTitleNew.text];
}
#pragma mark -
#pragma mark - Table view data source
#define TextFieldTag    1100
#define LabelTag        (TextFieldTag + 1)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1) {
        // 最后一行
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *tfEmailTitleNew = (UITextField *)[cell viewWithTag:TextFieldTag];
        if (tfEmailTitleNew) {
            self.tfTypeTitleNew = tfEmailTitleNew;
            UILabel *lbTitle = (UILabel *)[cell viewWithTag:LabelTag];
            if (lbTitle) {
                lbTitle.hidden = YES;
            }
            if (self.tfTypeTitleNew.hidden) {
                self.tfTypeTitleNew.hidden = NO;
                self.tfTypeTitleNew.delegate = self;
                [self.tfTypeTitleNew becomeFirstResponder];
            }
        }
    }
    else {
        UITableViewCell *cell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (self.tfTypeTitleNew && self.tfTypeTitleNew.hidden == NO) {
            self.tfTypeTitleNew.hidden = YES;
            [self.tfTypeTitleNew resignFirstResponder];
        }
        [self changeTypeTitleWithName:cell.textLabel.text];
    }
}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

@end
