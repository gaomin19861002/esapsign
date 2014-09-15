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
#import "Client_contact_item.h"
#import "TypeSelectionTableViewController.h"
#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "util.h"
#import "NSDate+Additions.h"

@interface AddContactViewController () <UITableViewDataSource, UITableViewDelegate, UserContentCellDelegate, TypeSelectionTableViewControllerDelegate, UITextFieldDelegate>

@property(nonatomic, retain) NSMutableArray *itemsInEditing;

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
    
    self.itemsInEditing = [NSMutableArray array];
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
        return [self.itemsInEditing count];
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
        NSDictionary *item = [self.itemsInEditing objectAtIndex:indexPath.row];
        switch ([[item objectForKey:@"type"] intValue])
        {
            case UserContentTypeEmail:
                cell.leftImageView.image = [UIImage imageNamed:@"Mail"];
                break;
            case UserContentTypePhone:
                cell.leftImageView.image = [UIImage imageNamed:@"phone"];
                break;
            case UserContentTypeAddress:
                cell.leftImageView.image = [UIImage imageNamed:@"Address"];
                break;
            default:
                break;
        }
        [cell setBackgroundColor:[UIColor clearColor]];

        cell.delegate = self;
        cell.titleLabel.text = [item objectForKey:@"title"];
        cell.subTitleLabel.text = [item objectForKey:@"content"];
        cell.subTitleTextField.text = [item objectForKey:@"content"];
        cell.subTitleLabel.hidden = tableView.editing;
        cell.subTitleTextField.hidden = !tableView.editing;
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
    [self.itemsInEditing removeObjectAtIndex:indexPath.row];
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
    if (self.contactTableView.editing)
    {
        [self vcResignFirstResponder];
        NSIndexPath *indexPath = [self.contactTableView indexPathForCell:cell];
        NSDictionary *item = [self.itemsInEditing objectAtIndex:indexPath.row];
        UINavigationController *navController = nil;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
        int typeValue = [[item objectForKey:@"type"] intValue];
        if (typeValue == UserContentTypeEmail || typeValue == UserContentTypeAddress)
            navController = [story instantiateViewControllerWithIdentifier:@"NavEmailSelection"];
        else if (typeValue == UserContentTypePhone)
            navController = [story instantiateViewControllerWithIdentifier:@"NavPhoneType"];

        if (navController != nil)
        {
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
    NSDictionary *item = [self.itemsInEditing objectAtIndex:indexPath.row];
    // 更新界面
    NSString* content = strName.length == 0 ? @"" : strName;
    [item setValue:content forKey:@"content"];
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
        NSDictionary *item = [self.itemsInEditing objectAtIndex:self.curUserTableSelectedIndexPath.row];
        [item setValue:strTitle forKey:@"title"];
        [self.contactTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.curUserTableSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        // 新增条目
        NSMutableDictionary *item = [[DataManager defaultInstance] createDefaultContactItemValue];
        if ([strTitle isEqualToString:@"邮箱"])
        {
            [item setValue:[NSString stringWithFormat:@"%d", UserContentTypeEmail] forKey:@"type"];
            [self.itemsInEditing addObject:item];
        }
        else if ([strTitle isEqualToString:@"电话"])
        {
            [item setValue:[NSString stringWithFormat:@"%d", UserContentTypePhone] forKey:@"type"];
            [self.itemsInEditing addObject:item];
        }
        else if ([strTitle isEqualToString:@"地址"])
        {
            [item setValue:[NSString stringWithFormat:@"%d", UserContentTypeAddress] forKey:@"type"];
            [self.itemsInEditing addObject:item];
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
    
    NSDictionary *dict = [[DataManager defaultInstance] createDefaultContactValue];

    [dict setValue:self.familyNameField.text forKey:@"familyName"];
    [dict setValue:self.personNameField.text forKey:@"personName"];

    [self.delegate AddContactViewControllerDidDone:self userBasicItems:dict contactItems:self.itemsInEditing];
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
