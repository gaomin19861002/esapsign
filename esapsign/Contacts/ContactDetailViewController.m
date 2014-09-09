//
//  ContactDetailViewController.m
//  cassidlib
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "UINavigationController+Additions.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "DataManager.h"
#import "UserContentCell.h"
#import "Client_content.h"
#import "DocSelectedViewController.h"
#import "DocDetailViewController.h"
#import "NSDate+Additions.h"
#import "EmailTypeSelctionViewController.h"
#import "PhoneTypeSelectionViewController.h"
#import "NewTypeSelectionViewController.h"
#import "ClientContentInEdit.h"
#import "ActionManager.h"
#import "AddContentCell.h"
#import "TypeSelectionTableViewController.h"
#import "CAAppDelegate.h"
#import "UIViewController+Additions.h"
#import "UIAlertView+Additions.h"
#import "NSObject+Json.h"

#define AlertContactDelTag      1000
#define AlertContactModifyTag   (AlertContactDelTag + 1)

@interface ContactDetailViewController () <UIAlertViewDelegate, DocSelectedViewControllerDelegate, TypeSelectionTableViewControllerDelegate, UserContentCellDelegate, ActionManagerDelegate>
{
    bool bDirtyFlag;    // 是否发生了修改
    bool bInEdit;       // 是否处于编辑状态
}

@property (nonatomic, retain) Client_user *currentUser;

/*!
 用户当前编辑的条目
 */
@property(nonatomic, retain) NSIndexPath *curUserTableSelectedIndexPath;

/*!
 右侧默认状态下的工具按钮
 */
@property(nonatomic, retain) NSArray *rightDefaultStatusItems;

/*!
 右侧编辑状态下的工具按钮
 */
@property(nonatomic, retain) NSArray *rightEditingStatusItems;

/*!
 左侧编辑状态下的工具按钮
 */
@property(nonatomic, retain) NSArray *leftEditingStatusItems;

/*!
 当前显示的通讯录条目信息
 */
@property(nonatomic, retain) NSMutableArray *currentContents;

/*!
 当前显示的通讯录条目信息
 */
@property(nonatomic, retain) NSMutableArray *currentContentsInEdit;

/*!
 当前显示与某人共同签署的文件条目
 */
@property(nonatomic, retain) NSMutableArray *currentSignDocuments;

/*!
 当前用户信息编辑状态下，context类型选择框
 */
@property(nonatomic, retain) UIPopoverController *typeSelectionPopoverController;

// 修改ContactUpdateAction为ActionManager方式 gaomin@20140904
@property (nonatomic, retain) ASIFormDataRequest *contactUpdateRequest;

@property (nonatomic, retain) ASIFormDataRequest *contactDelRequest;

@end

@implementation ContactDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s %@", __FUNCTION__, self);

    // 设置一下名片区的尺寸
    bInEdit = NO;
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])];
    
    [[self bottomBarView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BarBottomRight"]]];
    [[self backgroundView] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"RightBackground"]]];
    self.userDetailInfoTable.backgroundColor = [UIColor clearColor];
    self.documentTableView.backgroundColor = [UIColor clearColor];
    
    [self.nameLabel setFont:[UIFont fontWithName:@"Libian SC" size:32.0]];
    [self.signWithSomeOnelabel setFont:[UIFont fontWithName:@"Libian SC" size:22.0]];
    
    [[ActionManager defaultInstance] registerDelegate:self];
}

- (void)dealloc
{
    [[ActionManager defaultInstance] unRegisterDelegate:self];
}

#pragma mark - 视图方法

/**
 * @abstract 切换在编辑和非编辑状态下UI元素的显示
 */
- (void)switchShowOfUIItems
{
    if (bInEdit)
    {
        self.navigationItem.rightBarButtonItems = self.rightEditingStatusItems;
        self.navigationItem.leftBarButtonItems = self.leftEditingStatusItems;
        
        self.nameLabel.hidden = YES;
        self.signAddrStaticLabel.hidden = YES;
        self.selectAddress.hidden = YES;
        self.signWithSomeOnelabel.hidden = YES;
        self.documentTableView.hidden = YES;
        
        self.familyNameLabel.hidden = NO;
        self.familyNameTextField.hidden = NO;
        self.firstNameLabel.hidden = NO;
        self.firstNameTextField.hidden = NO;
        self.line1.hidden = NO;
        self.line2.hidden = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
        self.navigationItem.leftBarButtonItems = nil;
        

        self.familyNameTextField.hidden = YES;
        self.familyNameLabel.hidden = YES;
        self.line1.hidden = YES;

        self.firstNameLabel.hidden = YES;
        self.firstNameTextField.hidden = YES;
        self.line2.hidden = YES;
        
        self.nameLabel.hidden = NO;
        self.signAddrStaticLabel.hidden = NO;
        self.selectAddress.hidden = NO;
        self.signWithSomeOnelabel.hidden = NO;
        self.documentTableView.hidden = NO;
    }
}

/**
 * @abstract 重新计算名片区的高度，根据编辑状态和屏幕方向
 */
- (void)recalHeightConstrantInPortrait:(UIInterfaceOrientation)isPortraitOrientation
{
    if (bInEdit)
    {
        if (isPortraitOrientation)
        {
            self.topBottom.constant = 900;
        }
        else
        {
            self.topBottom.constant = 638;
        }
    }
    else
    {
        self.topBottom.constant = 340;
    }
}

/**
 * @abstract 响应旋转屏幕事件
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // 旋转过后的Orientation正好与之相对
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)];
}

#pragma mark - 右上角按钮及相应action方法

/*!
 * @abstract 右侧默认状态下的工具按钮
 */
- (NSArray *)rightDefaultStatusItems
{
    if (!_rightDefaultStatusItems)
    {
        // 添加工具按钮 暂时隐藏编辑按钮
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBtnClicked:)];
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteContactBtnClicked:)];
        _rightDefaultStatusItems = @[editItem, deleteItem];
    }

    return _rightDefaultStatusItems;
}

/*!
 * @abstract 右侧编辑状态下的工具按钮
 */
- (NSArray *)rightEditingStatusItems
{
    if (!_rightEditingStatusItems)
    {
        // 添加工具按钮
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnClicked:)];
        _rightEditingStatusItems = @[doneItem];
    }
    
    return _rightEditingStatusItems;
}

/*!
 * @abstract 左侧编辑状态下的工具按钮
 */
- (NSArray *)leftEditingStatusItems
{
    if (!_leftEditingStatusItems)
    {
        // 添加工具按钮
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked:)];
        _leftEditingStatusItems = @[cancelItem];
    }
    
    return _leftEditingStatusItems;
}

/**
 * @abstract 进入编辑状态
 */
- (void)editBtnClicked:(id)sender
{
    bInEdit = YES;
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])];
    [self switchShowOfUIItems];
    
    if (self.currentUser.family_name == nil || [self.currentUser.family_name isEqualToString:@""])
    {
        self.familyNameTextField.text = nil;
        self.firstNameTextField.text = self.currentUser.person_name;
    }
    
    if ([self.currentUser.person_name isEqualToString:@"(null)"] || self.currentUser.person_name == nil)
    {
        self.familyNameTextField.text = nil;
        self.firstNameTextField.text = self.currentUser.family_name;
    }
    
    if (self.currentUser.family_name != nil && ![self.currentUser.family_name isEqualToString:@""] && ![_currentUser.person_name isEqualToString:@"(null)"])
    {
        self.familyNameTextField.text = self.currentUser.family_name;
        self.firstNameTextField.text = self.currentUser.person_name;
    }
    
    [self.currentContentsInEdit removeAllObjects];
    for (Client_content *item in self.currentUser.clientContents)
    {
        ClientContentInEdit *newItem = [[ClientContentInEdit alloc] initWithClientContent:item];
        [self.currentContentsInEdit addObject:newItem];
    }
    [self.userDetailInfoTable setEditing:YES animated:YES];
    [self.userDetailInfoTable reloadData];
}

/**
 * @abstract 当失去编辑控制状态后自动取消编辑
 */
- (void)vcResignFirstResponder
{
    bInEdit = NO;
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])];
    [self switchShowOfUIItems];
    
    [self.familyNameTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    
    if (self.curUserTableSelectedIndexPath != nil)
    {
        UserContentCell *cell = (UserContentCell *)[self.userDetailInfoTable cellForRowAtIndexPath:self.curUserTableSelectedIndexPath];
        if ([cell isKindOfClass:[UserContentCell class]] && cell.subTitleTextField.hidden == NO && cell.isFirstResponder)
        {
            [cell.subTitleTextField resignFirstResponder];
        }
    }
    for (UserContentCell *cell in self.userDetailInfoTable.visibleCells)
    {
        if ([cell isKindOfClass:[UserContentCell class]] && cell.subTitleTextField.hidden == NO && cell.subTitleTextField.isFirstResponder)
        {
            [cell.subTitleTextField resignFirstResponder];
        }
    }
}

/**
 * @abstract 完成操作
 */
- (void)doneBtnClicked:(id)sender
{
    [self vcResignFirstResponder];
    
    #warning 应当计算bDirtyFlag 然后再决定是否要进行更新
    
    //1 本地数据更新
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@", self.familyNameTextField.text, self.firstNameTextField.text];
    [[DataManager defaultInstance] modifyUser:self.currentUser.user_id withFirstName:self.firstNameTextField.text familyName:self.familyNameTextField.text];
    [[DataManager defaultInstance] updateClientUser:self.currentUser WithContents:self.currentContentsInEdit];
    
    NSMutableArray *arrContents = [NSMutableArray arrayWithArray:self.currentUser.showContexts];
    self.currentContents = arrContents == nil ? [[NSMutableArray alloc] initWithCapacity:1] : arrContents;
    [self.userDetailInfoTable setEditing:NO animated:NO];
    [self.userDetailInfoTable reloadData];
    
    //2 向服务器请求更新
    // 更新联系人，通知服务器端 gaomin@20140904 修改更新联系人时为使用ActionManager方式
    NSDictionary *action = [[ActionManager defaultInstance] contactUpdateAction:self.currentUser];
    self.contactUpdateRequest = [[ActionManager defaultInstance] addToQueue:action];
    
    // 通知列表页更新
    [[NSNotificationCenter defaultCenter] postNotificationName:ContactUpdateNotification object:self];
}

/**
 * @abstract 取消操作
 */
- (void)cancelBtnClicked:(id)sender
{
    [self vcResignFirstResponder];

    [self.currentContentsInEdit removeAllObjects];
    [self.userDetailInfoTable setEditing:NO animated:YES];
    [self.userDetailInfoTable reloadData];
}

#pragma mark - 删除联系人

- (void)deleteContactBtnClicked:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除联系人" message:@"确认删除当前联系人吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = AlertContactDelTag;
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case AlertContactDelTag:
            if (buttonIndex == 1)
            {
                // 删除联系人，通知服务器端 gaomin@20140904 修改更新联系人时为使用ActionManager方式
                NSDictionary *action = [[ActionManager defaultInstance] contactDelAction:self.currentUser];
                self.contactDelRequest = [[ActionManager defaultInstance] addToQueue:action];
                
                // 删除
                [[DataManager defaultInstance] deleteClientUser:self.currentUser];
                [[NSNotificationCenter defaultCenter] postNotificationName:ContactDeleteNotification object:nil];
            }
            break;
        default:
            break;
    }
}

#pragma mark -

- (IBAction)signWithSomeOneBtnClicked:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    DocSelectedViewController *selectedController = [story instantiateViewControllerWithIdentifier:@"DocSelectedViewController"];
    _selectDocPopoverController = [[UIPopoverController alloc] initWithContentViewController:selectedController];
    selectedController.delegate = self;
    UIButton* signButton = (UIButton*)sender;
    [_selectDocPopoverController presentPopoverFromRect:signButton.frame
                                                 inView:self.view
                               permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)addContextBtnClicked:(id)sender
{
    // 弹出提示框，给用户选择
    
    UINavigationController *navController = nil;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    // 编辑电话类型
    navController = [story instantiateViewControllerWithIdentifier:@"NavNewTypeSelection"];
    TypeSelectionTableViewController *typeSelectionController = (TypeSelectionTableViewController *)[navController topViewController];
    typeSelectionController.typeSelectionDelegate = self;
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.typeSelectionPopoverController = popController;
    self.typeSelectionPopoverController.popoverContentSize = CGSizeMake(320.0f, 350.0f);
    UIButton *btn = (UIButton *)sender;
    UITableViewCell *cellAdd = [self.userDetailInfoTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    CGRect rectInSelf = [self.view convertRect:btn.frame fromView:cellAdd];
    [popController presentPopoverFromRect:rectInSelf inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.curUserTableSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.userDetailInfoTable && self.userDetailInfoTable.editing == YES) {
        // 增加一行，点击可以新增栏目s
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.userDetailInfoTable)
    {
        if (section == 0) {
            if (bInEdit)
                return [self.currentContentsInEdit count];
            else
                return [self.currentContents count];
        }
        else
            return 1;
    }
    if (tableView == self.documentTableView)
    {
        return [self.currentSignDocuments count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.userDetailInfoTable)
    {
        if (indexPath.section == 0)
        {
            UserContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserContentCell" forIndexPath:indexPath];
            Client_content *content = nil;
            ClientContentInEdit *contentEditing = nil;
            
            if (!tableView.editing)
                content = [self.currentContents objectAtIndex:indexPath.row];
            else
                contentEditing = [self.currentContentsInEdit objectAtIndex:indexPath.row];
            
            if (!tableView.editing)
            {
                switch ([content.contentType intValue])
                {
                    case UserContentTypeEmail:
                        cell.leftImageView.image = [UIImage imageNamed:@"Mail"];
                        if ([content.major isEqual: @(YES)] || content.account_id != nil || ![content.account_id isEqualToString:@""])
                            cell.starImageView.image = [UIImage imageNamed:@"MajorAddressStar"];
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
            }
            else
            {
                switch (contentEditing.contentType)
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
            }

            [cell setBackgroundColor:[UIColor clearColor]];
            cell.delegate = self;
            if (tableView.editing)
            {
                cell.titleLabel.text = contentEditing.title;
                cell.subTitleLabel.text = contentEditing.contentValue;
                cell.subTitleTextField.text = contentEditing.contentValue;
                cell.subTitleLabel.hidden = YES;
                cell.subTitleTextField.hidden = NO;
            }
            else
            {
                cell.titleLabel.text = content.title;
                cell.subTitleLabel.text = content.contentValue;
                cell.subTitleTextField.text = content.contentValue;
                cell.subTitleLabel.hidden = NO;
                cell.subTitleTextField.hidden = YES;
            }

            return cell;
        }
        else
        {
            AddContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddContentCell" forIndexPath:indexPath];
            [cell.addCellBtn setImage:[UIImage imageNamed:@"AddContactItem"] forState:UIControlStateNormal];
            [cell.addCellBtn addTarget:self action:@selector(addContextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.userDetailInfoTable && !self.userDetailInfoTable.editing)
    {
        NSMutableArray* contents = bInEdit ? self.currentContentsInEdit : self.currentContents;
        Client_content *content = [contents objectAtIndex:indexPath.row];
        if ([content.contentType intValue] == UserContentTypeEmail)
        {
            self.selectAddress.text = content.contentValue;
        }
    }
    else if (tableView == self.documentTableView)
    {
        Client_target *fileTarget = [self.currentSignDocuments objectAtIndex:indexPath.row];
        UINavigationController *navDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NavDocDetail"];
        DocDetailViewController *viewDetail = (DocDetailViewController *)[navDetail topViewController];
        viewDetail->clientTarget = fileTarget;
        navDetail.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navDetail animated:YES completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (tableView == self.userDetailInfoTable)
    {
        if (indexPath.section == 0) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentContentsInEdit removeObjectAtIndex:indexPath.row];
    [self.userDetailInfoTable reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark UserContentCellDelegate <NSObject>

- (void)UserContentCellDidBeginEditing:(UserContentCell *)cell
{
    self.curUserTableSelectedIndexPath = [self.userDetailInfoTable indexPathForCell:cell];
}

/*!
 编辑完成
 */
- (void)UserContentCell:(UserContentCell *)cell DidFinishEditingSubTitleWithName:(NSString *)strName
{
    NSIndexPath *indexPath = [self.userDetailInfoTable indexPathForCell:cell];
    ClientContentInEdit *content = [self.currentContentsInEdit objectAtIndex:indexPath.row];
    // 更新界面
    content.contentValue = strName.length == 0 ? @"" : strName;
    // [self.userTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*!
 类型编辑按钮点击事件
 */
- (void)UserContentCellModifyTypeTitleButtonClicked:(UserContentCell *)cell
{
    if (self.userDetailInfoTable.editing)
    {
        // [self vcResignFirstResponder];
        NSIndexPath *indexPath = [self.userDetailInfoTable indexPathForCell:cell];
        ClientContentInEdit *content = [self.currentContentsInEdit objectAtIndex:indexPath.row];
        UINavigationController *navController = nil;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
        if (content.contentType == UserContentTypeEmail || content.contentType == UserContentTypeAddress)
        {
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

#pragma mark TypeSelectionTableViewControllerDelegate <NSObject>

/*!
 选择某个类型下的名称
 */
- (void)TypeSelectionTableViewController:(TypeSelectionTableViewController *)popoverController didSelectTypeTitle:(NSString *)strTitle
{
    [self.typeSelectionPopoverController dismissPopoverAnimated:YES];
    if (self.curUserTableSelectedIndexPath.section == 0)
    {
        // 更新界面
        ClientContentInEdit *content = [self.currentContentsInEdit objectAtIndex:self.curUserTableSelectedIndexPath.row];
        content.title = strTitle;
        [self.userDetailInfoTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.curUserTableSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        // 新增条目
        // NSArray *arrTypeTitles = [NSArray arrayWithObjects:@"邮箱", @"电话", nil];
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
        [self.userDetailInfoTable reloadData];
        // 定位编辑状态
        [self.userDetailInfoTable scrollToRowAtIndexPath:self.curUserTableSelectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - DocSelectedViewControllerDelegate <NSObject>

- (void)DocSelectedViewController:(DocSelectedViewController *)docSelectedViewController DidSelectClientTarget:(Client_target *)clientTarget
{
    __block id weakSelf = self;
    [docSelectedViewController dismissViewControllerAnimated:YES completion:^(){
        ContactDetailViewController *wSelf = (ContactDetailViewController *)weakSelf;
        UINavigationController *navDetail = [wSelf.storyboard instantiateViewControllerWithIdentifier:@"NavDocDetail"];
        DocDetailViewController *viewDetail = (DocDetailViewController *)[navDetail topViewController];
        viewDetail->clientTarget = clientTarget;
        navDetail.modalPresentationStyle = UIModalPresentationFullScreen;
        [wSelf presentViewController:navDetail animated:YES completion:nil];}];
}

- (void)DocSelectedViewControllerCancel:(DocSelectedViewController *)docSelectedViewController
{
    [self.selectDocPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Private Methods

- (void)setCurrentUser:(Client_user *)newUser
{
    if (![_currentUser isEqual:newUser])
    {
        // 点击其他联系人时和编辑状态点击取消按钮时执行同样操作 gaomin@20140805
        self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
        self.navigationItem.leftBarButtonItems = nil;
        [self vcResignFirstResponder];
        
        [self.userDetailInfoTable setEditing:NO animated:YES];
        [self.currentContentsInEdit removeAllObjects];
        [self.userDetailInfoTable reloadData];
        
        self.signWithSomeOnelabel.hidden = YES;
        self.nameCardView.hidden = YES;

        // 尚未处理newUser为空，也即列表中没有联系人的情况
        if (newUser == nil) {
            DebugLog(@"此处未处理");
        }

        _currentUser = newUser;
        self.nameCardView.hidden = NO;
        
        NSString *name;
        
        // 从服务器获取到的联系人family_name字段为空
        if (newUser.family_name == nil || [newUser.family_name isEqualToString:@""] || [newUser.family_name isEqualToString:@"(null)"])
        {
            name = newUser.person_name;
        }
        
        // 从服务器获取到的联系人person_name字段为("null")
        if ([newUser.person_name isEqualToString:@"(null)"] || newUser.person_name == nil || [newUser.person_name isEqualToString:@""])
        {
            name = newUser.family_name;
        }
        
        // 从本地通讯录导入的联系人familyName和personName都不为空
        if ((newUser.family_name != nil && ![newUser.family_name isEqualToString:@""] && ![newUser.family_name isEqualToString:@"(null)"]) &&
            (![newUser.person_name isEqualToString:@"(null)"] && newUser.person_name != nil && ![newUser.person_name isEqualToString:@""]))
        {
            name = [NSString stringWithFormat:@"%@ %@", newUser.family_name, newUser.person_name];
        }

        self.nameLabel.text = name;
        
        // 暂时不启用，尚未完全做好
        //self->startSignBtn.hidden = NO;
        self.signWithSomeOnelabel.hidden = NO;
        self.signWithSomeOnelabel.text = [NSString stringWithFormat:@"我与%@共同签署过的文件", name];
        
        // 注意保存导航控制器的标题
        NSString* backupTitle = self.navigationController.title;
        self.navigationItem.title = [NSString stringWithFormat:@"%@", name];
        self.navigationController.title = backupTitle;
        [_headImageView setImage:[UIImage imageNamed:[self.currentUser contentWithType:UserContentTypePhoto useLarge:YES]]];
        // 签约用地址
        self.selectAddress.text = @"未选择";
        for (Client_content *content in _currentUser.clientContents)
        {
            if ([content.contentType intValue] == UserContentTypeEmail) {
                if (content.major || content.account_id != nil)
                {
                    self.selectAddress.text = content.contentValue;
                    break;
                }
            }
        }

        self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
        [self.userDetailInfoTable setEditing:NO animated:YES];
        NSMutableArray *arrContents = [NSMutableArray arrayWithArray:_currentUser.showContexts];
        self.currentContents = arrContents == nil ? [NSMutableArray array] : arrContents;
        self.curUserTableSelectedIndexPath = nil;
        [self.userDetailInfoTable reloadData];
        
        NSIndexPath* firstSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if ([self.userDetailInfoTable cellForRowAtIndexPath:firstSelectedIndexPath] != nil)
        {
            [self.userDetailInfoTable selectRowAtIndexPath:firstSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        
        // 刷新共同签署文件列表
        // dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.currentSignDocuments = [[DataManager defaultInstance] allTargetsWithClientUser:newUser];
        // dispatch_async(dispatch_get_main_queue(), ^{
                [self.documentTableView reloadData];
        // });
        // });
    }
}

- (void)setCurrentUserID:(NSString *)UserID
{
    if (![_currentUserID isEqualToString:UserID])
    {
        Client_user* newUser = [[DataManager defaultInstance] findUserWithId:UserID];
        self.currentUser = newUser;
    }
}

#pragma mark - Action Manager Delegate

// 异步请求开始通知外部程序
- (void)actionRequestStarted:(ASIHTTPRequest *)request
{
    if (request == self.contactUpdateRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController showProgressText:@"更新联系人中..."];
    }
    else if (request == self.contactDelRequest)
    {
        [[CAAppDelegate sharedDelegate].window.rootViewController showProgressText:@"删除联系人中..."];
    }
}

// 异步请求失败通知外部程序
- (void)actionRequestFailed:(ASIHTTPRequest *)request
{
    if (request == self.contactUpdateRequest)
    {
        NSLog(@"Contact Update Action Request Failed!");
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        [UIAlertView showAlertMessage:@"提交失败"];
        self.contactUpdateRequest = nil;
    }
    else if (request == self.contactDelRequest)
    {
        self.contactDelRequest = nil;
    }
}

// 异步请求结束通知外部程序
- (void)actionRequestFinished:(ASIHTTPRequest *)request
{
    if (request == self.contactUpdateRequest)
    {
        NSLog(@"Contact New Action Request Finished!");
        
        NSDictionary *resDict = [[request responseString] jsonValue];

        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.contactUpdateRequest = nil;
    }
    else if (request == self.contactDelRequest)
    {
        NSLog(@"Contact Del Action Request Finished!");

        NSDictionary *resDelDict = [[request responseString] jsonValue];
        
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.contactDelRequest = nil;
    }
}

@end
