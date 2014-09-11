//
//  AddContactViewController.m
//  esapsign
//
//  Created by Gaomin on 14-8-7.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "AddContactViewController.h"
#import "AddContentCell.h"
#import "UserContentCell.h"
#import "Client_content.h"
#import "TypeSelectionTableViewController.h"
#import "ClientContentInEdit.h"
#import "DataManager.h"
#import "util.h"
#import "NSDate+Additions.h"

@interface AddContactViewController () <UITableViewDataSource, UITableViewDelegate, UserContentCellDelegate, TypeSelectionTableViewControllerDelegate, UITextFieldDelegate>

@property(nonatomic, retain) NSMutableArray *currentContents;

/*!
 当前用户信息编辑状态下，context类型选择框
 */
@property(nonatomic, retain) UIPopoverController *typeSelectionPopoverController;

/*!
 用户当前编辑的条目
 */
@property(nonatomic, retain) NSIndexPath *curUserTableSelectedIndexPath;

- (IBAction)tapCancel:(id)sender;
- (IBAction)tapDone:(id)sender;

@end

@implementation AddContactViewController

@synthesize headImageView = _headImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_headImageView setImage:[UIImage imageNamed:@"IconHeadBig"]];
    _headImageView.layer.masksToBounds = YES;
    [self.contactTableView setEditing:YES animated:NO];
    [self.contactTableView reloadData];
    
    self.currentContents = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - <UITableviewDatasource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.editing)
    {
        // 增加一行，点击可以新增栏目
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.currentContents count];
    }
    else
    {
         return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UserContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserContentCell" forIndexPath:indexPath];
        ClientContentInEdit *content = [self.currentContents objectAtIndex:indexPath.row];
        switch (content.contentType)
        {
            case UserContentTypeEmail:
            {
                cell.leftImageView.image = [UIImage imageNamed:@"Mail"];
            }

            break;
                
            case UserContentTypePhone:
            {
                cell.leftImageView.image = [UIImage imageNamed:@"phone"];
            }
            
            break;
                
            case UserContentTypeAddress:
            {
                cell.leftImageView.image = [UIImage imageNamed:@"Address"];
            }
                
            break;
            
            default:
                break;
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.delegate = self;
        cell.titleLabel.text = content.title;
        cell.subTitleLabel.text = content.contentValue;
        cell.subTitleTextField.text = content.contentValue;
        if (tableView.editing)
        {
            cell.subTitleLabel.hidden = YES;
            cell.subTitleTextField.hidden = NO;
        }
        else
        {
            cell.subTitleLabel.hidden = NO;
            cell.subTitleTextField.hidden = YES;
        }
        
        return cell;
    }
    else
    {
        AddContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddContentCell" forIndexPath:indexPath];
        [cell.addCellBtn addTarget:self action:@selector(addContextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
   
    return nil;
}

#pragma mark - <UITableviewDelegate>

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleInsert;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentContents removeObjectAtIndex:indexPath.row];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - <UserContentCellDelegate>

-(void)UserContentCellDidBeginEditing:(UserContentCell *)cell
{
    self.curUserTableSelectedIndexPath = [self.contactTableView indexPathForCell:cell];
}

/*!
 类型编辑按钮点击事件
 */
-(void)UserContentCellModifyTypeTitleButtonClicked:(UserContentCell *)cell
{
    if (self.contactTableView.editing) {
        [self vcResignFirstResponder];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:cell];
        ClientContentInEdit *content = [self.currentContents objectAtIndex:indexPath.row];
        UINavigationController *navController = nil;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
        if (content.contentType == UserContentTypeEmail || content.contentType == UserContentTypeAddress) {
            // 编辑邮件类型
            navController = [story instantiateViewControllerWithIdentifier:@"NavEmailSelection"];
        }
        else if (content.contentType == UserContentTypePhone) {
            // 编辑电话类型
            navController = [story instantiateViewControllerWithIdentifier:@"NavPhoneType"];
        }
        if (navController != nil) {
            TypeSelectionTableViewController *typeSelectionController = (TypeSelectionTableViewController *)[navController topViewController];
            typeSelectionController.typeSelectionDelegate = self;
            UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:navController];
            self.typeSelectionPopoverController = popController;
            CGRect rectInSelf = [self.view convertRect:cell.titleLabel.frame fromView:cell.titleLabel.superview];
            [popController presentPopoverFromRect:rectInSelf inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            self.curUserTableSelectedIndexPath = indexPath;
        }
    }
}

/*!
 编辑完成
 */
-(void)UserContentCell:(UserContentCell *)cell DidFinishEditingSubTitleWithName:(NSString *)strName
{
    NSIndexPath *indexPath = [self.contactTableView indexPathForCell:cell];
    ClientContentInEdit *content = [self.currentContents objectAtIndex:indexPath.row];
    // 更新界面
    content.contentValue = strName.length == 0 ? @"" : strName;
    [self.contactTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - <TypeSelectionTableViewControllerDelegate>

/*!
 选择某个类型下的名称
 */
-(void)TypeSelectionTableViewController:(TypeSelectionTableViewController *)popoverController didSelectTypeTitle:(NSString *)strTitle
{
    [self.typeSelectionPopoverController dismissPopoverAnimated:YES];
    if (self.curUserTableSelectedIndexPath.section == 0)
    {
        // 更新界面
        ClientContentInEdit *content = [self.currentContents objectAtIndex:self.curUserTableSelectedIndexPath.row];
        content.title = strTitle;
        [self.contactTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.curUserTableSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        // 新增条目
        //        NSArray *arrTypeTitles = [NSArray arrayWithObjects:@"邮箱", @"电话", nil];
        if ([strTitle isEqualToString:@"邮箱"]) {
            //
            ClientContentInEdit *item = [[ClientContentInEdit alloc] initWithContentTitle:strTitle contentType:UserContentTypeEmail contentValue:@"" major:NO];
            [self.currentContents addObject:item];
        }
        else if ([strTitle isEqualToString:@"电话"]) {
            //
            ClientContentInEdit *item = [[ClientContentInEdit alloc] initWithContentTitle:strTitle contentType:UserContentTypePhone contentValue:@"" major:NO];
            [self.currentContents addObject:item];
        }
        else if ([strTitle isEqualToString:@"地址"]) {
            //
            ClientContentInEdit *item = [[ClientContentInEdit alloc] initWithContentTitle:strTitle contentType:UserContentTypeAddress contentValue:@"" major:NO];
            [self.currentContents addObject:item];
        }
        [self.contactTableView reloadData];
        // 定位编辑状态
        [self.contactTableView scrollToRowAtIndexPath:self.curUserTableSelectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - <UIAlertviewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (![self.familyNameField isFirstResponder])
        {
            [self.familyNameField becomeFirstResponder];
        }
    }
}

#pragma mark - 点击事件

- (IBAction)addContextBtnClicked:(id)sender
{
    // 弹出提示框，给用户选择
    [self vcResignFirstResponder];
    
    UINavigationController *navController = nil;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    // 编辑电话类型
    navController = [story instantiateViewControllerWithIdentifier:@"NavNewTypeSelection"];
    TypeSelectionTableViewController *typeSelectionController = (TypeSelectionTableViewController *)[navController topViewController];
    typeSelectionController.typeSelectionDelegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.typeSelectionPopoverController = popController;
    UIButton *btn = (UIButton *)sender;
    UITableViewCell *cellAdd = [self.contactTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    CGRect rectInSelf = [self.view convertRect:btn.frame fromView:cellAdd];
    [popController presentPopoverFromRect:rectInSelf inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.curUserTableSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
}

- (IBAction)tapCancel:(id)sender
{
    [self.delegate AddContactViewControllerDidCancel:self];
}

- (IBAction)tapDone:(id)sender
{
    if ((self.familyNameField.text == nil || [self.familyNameField.text isEqualToString:@""])
        && (self.personNameField.text == nil || [self.personNameField.text isEqualToString:@""]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建联系人" message:@"联系人名称不可为空！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.delegate = self;
        [alert show];        
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.familyNameField.text forKey:@"familyName"];
    [dict setObject:self.personNameField.text forKey:@"personName"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"gender"];
    
    NSString *date = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    date = [[NSDate date] fullDateString];
    
    [dict setObject:date forKey:@"lastTimeStamp"];
    [dict setObject:[Util generalUUID] forKey:@"id"];

    [self.delegate AddContactViewControllerDidDone:self userBasicItems:dict contactItems:self.currentContents];
}

#pragma mark - 私有方法

- (void)vcResignFirstResponder
{
    if (self.familyNameField.isFirstResponder)
    {
        [self.familyNameField resignFirstResponder];
    }
    
    if (self.personNameField.isFirstResponder)
    {
        [self.personNameField resignFirstResponder];
    }
    
    if (self.curUserTableSelectedIndexPath != nil) {
        UserContentCell *cell = (UserContentCell *)[self.contactTableView cellForRowAtIndexPath:self.curUserTableSelectedIndexPath];
        if ([cell isKindOfClass:[UserContentCell class]] && cell.subTitleTextField.hidden == NO && cell.isFirstResponder) {
            [cell.subTitleTextField resignFirstResponder];
        }
    }
    for (UserContentCell *cell in self.contactTableView.visibleCells) {
        if ([cell isKindOfClass:[UserContentCell class]] && cell.subTitleTextField.hidden == NO && cell.subTitleTextField.isFirstResponder) {
            [cell.subTitleTextField resignFirstResponder];
        }
    }
}

@end
