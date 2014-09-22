//
//  ContactDetailViewController.m
//  cassidlib
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "DocSelectedViewController.h"
#import "UINavigationController+Additions.h"
#import "DocDetailViewController.h"
#import "DocSignedWithSomeOneCell.h"

#import "DataManager.h"
#import "DataManager+Contacts.h"
#import "CAAppDelegate.h"
#import "UserContentCell.h"
#import "Client_contact_item.h"
#import "EmailTypeSelctionViewController.h"
#import "PhoneTypeSelectionViewController.h"
#import "NewTypeSelectionViewController.h"
#import "ActionManager.h"
#import "AddContentCell.h"
#import "TypeSelectionTableViewController.h"

#import "NSObject+Json.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "UIAlertView+Additions.h"
#import "UIViewController+Additions.h"
#import "NSDate+Additions.h"

#define AlertContactDelTag      1000
#define AlertContactModifyTag   (AlertContactDelTag + 1)

@interface ContactDetailViewController () <UIAlertViewDelegate, DocSelectedViewControllerDelegate, TypeSelectionTableViewControllerDelegate, UserContentCellDelegate, ActionManagerDelegate>
{
    bool bDirtyFlag;    // 是否发生了修改
    bool bInEdit;       // 是否处于编辑状态
}

@property (nonatomic, retain) Client_contact *currentContact;

@property (retain, nonatomic) UIPopoverController* selectDocPopoverController;

@property (retain, nonatomic) IBOutlet UILabel *signWithSomeOnelabel;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (retain, nonatomic) IBOutlet UIView *nameCardView;
@property (nonatomic, retain) IBOutlet UIImageView *cardBGImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topBottom;

@property (nonatomic, retain) IBOutlet UILabel *signAddrStaticLabel;
@property (nonatomic, retain) IBOutlet UIButton *startSignBtn;
@property (retain, nonatomic) IBOutlet UILabel *selectAddress;

/*!
 当前显示与某人共同签署的文件条目
 */
@property(nonatomic, retain) NSMutableArray *currentSignDocuments;

/**
 * @abstract 与某某某共同签署过的tableview
 */
@property (retain, nonatomic) IBOutlet UITableView *documentTableView;


@property(nonatomic, retain) NSIndexPath *curUserTableSelectedIndexPath;

@property(nonatomic, retain) NSArray *rightDefaultStatusItems;
@property(nonatomic, retain) NSArray *rightEditingStatusItems;
@property(nonatomic, retain) NSArray *leftEditingStatusItems;

@property(nonatomic, retain) NSMutableArray *itemsInStore;
@property(nonatomic, retain) NSMutableArray *itemsInEditing;

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
    
    // 设置一下名片区的尺寸
    bInEdit = NO;
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])];

    [self.backgroundView setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"Libian SC" size:32.0]];
    [self.signWithSomeOnelabel setFont:[UIFont fontWithName:@"Libian SC" size:22.0]];
    
    self.itemsInEditing = [NSMutableArray arrayWithCapacity:2];
    
    [[ActionManager defaultInstance] registerDelegate:self];
    
    // 当前选中的联系人如果为空，则隐藏掉
    if (self.currentUserID == nil || [self.currentUserID isEqualToString:@""])
        [self.backgroundView setHidden:YES];
    else
        [self.backgroundView setHidden:NO];
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
        self.personNameLabel.hidden = NO;
        self.personNameTextField.hidden = NO;
        self.line1.hidden = NO;
        self.line2.hidden = NO;
        
        self.deleteContactButton.hidden = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
        self.navigationItem.leftBarButtonItems = nil;

        self.familyNameTextField.hidden = YES;
        self.familyNameLabel.hidden = YES;
        self.line1.hidden = YES;
        self.personNameLabel.hidden = YES;
        self.personNameTextField.hidden = YES;
        self.line2.hidden = YES;
        
        self.nameLabel.hidden = NO;
        self.signAddrStaticLabel.hidden = NO;
        self.selectAddress.hidden = NO;
        self.signWithSomeOnelabel.hidden = NO;
        self.documentTableView.hidden = NO;

        self.deleteContactButton.hidden = YES;
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
            self.topBottom.constant = 900;
        else
            self.topBottom.constant = 638;
    }
    else
        self.topBottom.constant = 340;
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
        _rightDefaultStatusItems = @[editItem];
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
    DataManager* manager = [DataManager defaultInstance];
    bInEdit = YES;
    [self recalHeightConstrantInPortrait:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])];
    [self switchShowOfUIItems];
    
    if (self.currentContact.family_name == nil || [self.currentContact.family_name isEqualToString:@"(null)"])
        self.currentContact.family_name = @"";
    if (self.currentContact.person_name == nil || [self.currentContact.person_name isEqualToString:@"(null)"])
        self.currentContact.person_name = @"";
    
    self.personNameTextField.text = self.currentContact.person_name;
    self.familyNameTextField.text = self.currentContact.family_name;
    
    [self.itemsInEditing removeAllObjects];
    for (Client_contact_item *item in self.currentContact.items)
    {
        NSDictionary *newItem = [manager createContactItemValueByItem:item];
        [self.itemsInEditing addObject:newItem];
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
    [self.personNameTextField resignFirstResponder];
    
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
    DataManager* manager = [DataManager defaultInstance];
    [self vcResignFirstResponder];
    
#warning 应当计算bDirtyFlag 然后再决定是否要进行更新
    
    //1 本地数据更新
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@", self.familyNameTextField.text, self.personNameTextField.text];
    
    NSMutableDictionary* contactDic = [manager createDefaultContactValue];
    [contactDic setValue:self.currentContact.contact_id forKey:@"id"];
    [contactDic setValue:self.familyNameTextField.text forKey:@"familyName"];
    [contactDic setValue:self.personNameTextField.text forKey:@"personName"];
    [manager syncContact:contactDic andItems:self.itemsInEditing];
    
    NSMutableArray *arrContents = [NSMutableArray arrayWithArray:self.currentContact.showContents];
    self.itemsInStore = arrContents == nil ? [[NSMutableArray alloc] initWithCapacity:1] : arrContents;
    [self.userDetailInfoTable setEditing:NO animated:NO];
    [self.userDetailInfoTable reloadData];
    
    //2 向服务器请求更新
    // 更新联系人，通知服务器端 gaomin@20140904 修改更新联系人时为使用ActionManager方式
    NSDictionary *action = [[ActionManager defaultInstance] contactUpdateAction:self.currentContact];
    self.contactUpdateRequest = [[ActionManager defaultInstance] addToQueue:action sendAtOnce:YES];
    
    // 通知列表页更新
    [[NSNotificationCenter defaultCenter] postNotificationName:ContactUpdateNotification object:self];
}

/**
 * @abstract 取消操作
 */
- (void)cancelBtnClicked:(id)sender
{
    [self vcResignFirstResponder];

    [self.itemsInEditing removeAllObjects];
    [self.userDetailInfoTable setEditing:NO animated:YES];
    [self.userDetailInfoTable reloadData];
}

#pragma mark - 删除联系人

- (IBAction)deleteContactBtnClicked:(id)sender
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
                NSDictionary *action = [[ActionManager defaultInstance] contactDelAction:self.currentContact];
                self.contactDelRequest = [[ActionManager defaultInstance] addToQueue:action sendAtOnce:YES];
                
                // 删除
                [[DataManager defaultInstance] deleteClientUser:self.currentContact];
                [[NSNotificationCenter defaultCenter] postNotificationName:ContactDeleteNotification object:nil];
            }
            break;
        default:
            break;
    }
}

- (void)addContextBtnClicked:(id)sender
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
                return [self.itemsInEditing count];
            else
                return [self.itemsInStore count];
        }
        else
            return 1;
    }

    return [self.currentSignDocuments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.userDetailInfoTable)
    {
        if (indexPath.section == 0)
        {
            UserContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserContentCell" forIndexPath:indexPath];
            NSDictionary *activeItem = nil;
            if (!tableView.editing)
                activeItem = [self.itemsInStore objectAtIndex:indexPath.row];
            else
                activeItem = [self.itemsInEditing objectAtIndex:indexPath.row];
            
            switch ([[activeItem objectForKey:@"type"] intValue])
            {
                case UserContentTypeEmail:
                    cell.leftImageView.image = [UIImage imageNamed:@"Mail"];
                    if ([[activeItem objectForKey:@"major"] intValue] == 1 || ![[activeItem objectForKey:@"id"] isEqualToString:@""])
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

            cell.delegate = self;
            cell.titleLabel.text = [activeItem objectForKey:@"title"];
            cell.subTitleLabel.text = [activeItem objectForKey:@"content"];
            cell.subTitleTextField.text = [activeItem objectForKey:@"content"];
            
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
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;
        }
        else
        {
            AddContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddContentCell" forIndexPath:indexPath];
            [cell.addCellBtn setImage:[UIImage imageNamed:@"AddContactItem"] forState:UIControlStateNormal];
            [cell.addCellBtn addTarget:self action:@selector(addContextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;
        }
    }
    
    Client_target *fileTarget = [self.currentSignDocuments objectAtIndex:indexPath.row];
    DocSignedWithSomeOneCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DocSignedWithSomeOneCell" forIndexPath:indexPath];
    cell.docNameLabel.text = fileTarget.display_name;
    Client_file *file = fileTarget.refFile;
    if ([file.file_type intValue] == FileExtendTypePdf)
        cell.docFaceImageView.image = [UIImage imageNamed:@"FileTypePDF"];
    else if ([file.file_type intValue] == FileExtendTypeTxt)
        cell.docFaceImageView.image = [UIImage imageNamed:@"FileTypeText"];
    else
        cell.docFaceImageView.image = [UIImage imageNamed:@"FileTypeImage"];
    cell.dateLabel.text = [fileTarget.last_time_stamp fullDateString];
    cell.docNameLabel.font = [UIFont fontWithName:@"Libian SC" size:18.0];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.userDetailInfoTable && !self.userDetailInfoTable.editing)
    {
        NSMutableArray* contents = bInEdit ? self.itemsInEditing : self.itemsInStore;
        NSMutableDictionary *content = [contents objectAtIndex:indexPath.row];
        
        if ([[content objectForKey:@"type"] intValue] == UserContentTypeEmail)
            self.selectAddress.text = [content objectForKey:@"content"];
    }
    else if (tableView == self.documentTableView)
    {
#warning 暂时先不导航，否则必须处理文件下载功能
        // Client_target *fileTarget = [self.currentSignDocuments objectAtIndex:indexPath.row];
        // UINavigationController *navDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"NavDocDetail"];
        // DocDetailViewController *viewDetail = (DocDetailViewController *)[navDetail topViewController];
        // viewDetail->clientTarget = fileTarget;
        // navDetail.modalPresentationStyle = UIModalPresentationFullScreen;
        // [self presentViewController:navDetail animated:YES completion:nil];
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
    [self.itemsInEditing removeObjectAtIndex:indexPath.row];
    [self.userDetailInfoTable reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UserContentCellDelegate <NSObject>

- (void)UserContentCellDidBeginEditing:(UserContentCell *)cell
{
    self.curUserTableSelectedIndexPath = [self.userDetailInfoTable indexPathForCell:cell];
}

// 编辑完成
- (void)UserContentCell:(UserContentCell *)cell DidFinishEditingSubTitleWithName:(NSString *)strName
{
    NSIndexPath *indexPath = [self.userDetailInfoTable indexPathForCell:cell];
    NSMutableDictionary *item = [self.itemsInEditing objectAtIndex:indexPath.row];
    // 更新界面
    NSString* newName = strName.length == 0 ? @"" : strName;
    [item setValue:newName forKey:@"content"];
}

// 类型编辑按钮点击事件
- (void)UserContentCellModifyTypeTitleButtonClicked:(UserContentCell *)cell
{
    if (self.userDetailInfoTable.editing)
    {
        // [self vcResignFirstResponder];
        NSIndexPath *indexPath = [self.userDetailInfoTable indexPathForCell:cell];
        NSMutableDictionary *item = [self.itemsInEditing objectAtIndex:indexPath.row];
        UINavigationController *navController = nil;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
        int contentType = [[item objectForKey:@"type"] intValue];
        if (contentType == UserContentTypeEmail || contentType == UserContentTypeAddress)
        {
            // 编辑邮件类型
            navController = [story instantiateViewControllerWithIdentifier:@"NavEmailSelection"];
        }
        else if (contentType == UserContentTypePhone)
        {
            // 编辑电话类型
            navController = [story instantiateViewControllerWithIdentifier:@"NavPhoneType"];
        }
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

#pragma mark - TypeSelectionTableViewControllerDelegate <NSObject>

// 选择某个类型下的名称
- (void)TypeSelectionTableViewController:(TypeSelectionTableViewController *)popoverController didSelectTypeTitle:(NSString *)strTitle
{
    [self.typeSelectionPopoverController dismissPopoverAnimated:YES];
    if (self.curUserTableSelectedIndexPath.section == 0)
    {
        // 更新界面
        NSMutableDictionary *item = [self.itemsInEditing objectAtIndex:self.curUserTableSelectedIndexPath.row];
        [item setValue:strTitle forKey:@"title"];
        [self.userDetailInfoTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.curUserTableSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        // 新增条目
        NSMutableDictionary* newItem = [[DataManager defaultInstance] createDefaultContactItemValue];
        if ([strTitle isEqualToString:@"邮箱"])
        {
            [newItem setValue:[NSString stringWithFormat:@"%d", UserContentTypeEmail] forKey:@"type"];
            [self.itemsInStore addObject:newItem];
        }
        else if ([strTitle isEqualToString:@"电话"])
        {
            [newItem setValue:[NSString stringWithFormat:@"%d", UserContentTypePhone] forKey:@"type"];
            [self.itemsInStore addObject:newItem];
        }
        else if ([strTitle isEqualToString:@"地址"])
        {
            [newItem setValue:[NSString stringWithFormat:@"%d", UserContentTypeAddress] forKey:@"type"];
            [self.itemsInStore addObject:newItem];
        }
        [self.userDetailInfoTable reloadData];
        // 定位编辑状态
        [self.userDetailInfoTable scrollToRowAtIndexPath:self.curUserTableSelectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Private Methods

- (void)setCurrentContact:(Client_contact *)newUser
{
    if ([_currentContact isEqual:newUser])
        return;

    // 注意保存导航控制器的标题
    NSString* backupTitle = self.navigationController.title;
    self.navigationItem.title = [NSString stringWithFormat:@"%@", @"名片详情"];
    self.navigationController.title = backupTitle;

    if (newUser == nil)
    {
        [self.backgroundView setHidden:YES];
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.leftBarButtonItems = nil;
        return;
    }
    
    [self.backgroundView setHidden:NO];
    self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
    self.navigationItem.leftBarButtonItems = nil;
    
    // 点击其他联系人时和编辑状态点击取消按钮时执行同样操作 gaomin@20140805
    self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
    self.navigationItem.leftBarButtonItems = nil;
    [self vcResignFirstResponder];
    
    [self.userDetailInfoTable setEditing:NO animated:YES];
    [self.itemsInEditing removeAllObjects];
    [self.userDetailInfoTable reloadData];
    
    self.signWithSomeOnelabel.hidden = YES;
    self.nameCardView.hidden = YES;

    _currentContact = newUser;
    self.nameCardView.hidden = NO;
    
    NSString *name = @"名片详情";
    // 从服务器获取到的联系人family_name字段为空
    if (newUser.family_name == nil || [newUser.family_name isEqualToString:@""] || [newUser.family_name isEqualToString:@"(null)"])
        name = newUser.person_name;
    // 从服务器获取到的联系人person_name字段为("null")
    if ([newUser.person_name isEqualToString:@"(null)"] || newUser.person_name == nil || [newUser.person_name isEqualToString:@""])
        name = newUser.family_name;
    // 从本地通讯录导入的联系人familyName和personName都不为空
    if ((newUser.family_name != nil && ![newUser.family_name isEqualToString:@""] && ![newUser.family_name isEqualToString:@"(null)"]) &&
        (![newUser.person_name isEqualToString:@"(null)"] && newUser.person_name != nil && ![newUser.person_name isEqualToString:@""]))
        name = [NSString stringWithFormat:@"%@ %@", newUser.family_name, newUser.person_name];
    self.nameLabel.text = name;
    
    backupTitle = self.navigationController.title;
    self.navigationItem.title = [NSString stringWithFormat:@"%@", name];
    self.navigationController.title = backupTitle;
    [_headImageView setImage:[UIImage imageNamed:[self.currentContact headIconUseLarge:YES]]];
    
    // 暂时不启用，尚未完全做好
    //self->startSignBtn.hidden = NO;

    User *user = [Util currentLoginUser];
    bool contactIsCurrentLoginUser = NO;
    // 签约用地址
    self.selectAddress.text = @"未选择";
    for (Client_contact_item *content in _currentContact.items)
    {
        if (content.account_id != nil && [user.accountId isEqualToString:content.account_id])
            contactIsCurrentLoginUser = YES;
        if ([content.contentType intValue] == UserContentTypeEmail && (content.major || content.account_id != nil))
        {
            self.selectAddress.text = content.contentValue;
            break;
        }
    }

    self.signWithSomeOnelabel.hidden = NO;
    if (contactIsCurrentLoginUser)
        self.signWithSomeOnelabel.text = @"我参与签署的文件";
    else
        self.signWithSomeOnelabel.text = [NSString stringWithFormat:@"我与%@共同签署过的文件", name];

    // 初始化一些通讯录条目的数据
    self.navigationItem.rightBarButtonItems = self.rightDefaultStatusItems;
    [self.userDetailInfoTable setEditing:NO animated:YES];
    NSMutableArray *arrContents = [NSMutableArray arrayWithArray:_currentContact.showContents];
    self.itemsInStore = arrContents == nil ? [NSMutableArray array] : arrContents;
    self.curUserTableSelectedIndexPath = nil;
    [self.userDetailInfoTable reloadData];

    // 自动滚动到选中的地址位置
    NSIndexPath* firstSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.userDetailInfoTable cellForRowAtIndexPath:firstSelectedIndexPath] != nil)
        [self.userDetailInfoTable selectRowAtIndexPath:firstSelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

    // 刷新共同签署文件列表
    self.currentSignDocuments = [[DataManager defaultInstance] allTargetsWithClientUser:newUser];
    [self.documentTableView reloadData];
}

- (void)setCurrentUserID:(NSString *)UserID
{
    if (![_currentUserID isEqualToString:UserID])
    {
        Client_contact* newUser = [[DataManager defaultInstance] findContactWithId:UserID];
        self.currentContact = newUser;
    }
}

- (IBAction)signWithSomeOneBtnClicked:(id)sender
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Contact_iPad" bundle:nil];
    DocSelectedViewController *selectedController = [story instantiateViewControllerWithIdentifier:@"DocSelectedViewController"];
    self.selectDocPopoverController = [[UIPopoverController alloc] initWithContentViewController:selectedController];
    selectedController.delegate = self;
    UIButton* signButton = (UIButton*)sender;
    [self.selectDocPopoverController presentPopoverFromRect:signButton.frame
                                                     inView:self.view
                                   permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
        
        __unused NSDictionary *resDict = [[request responseString] jsonValue];

        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.contactUpdateRequest = nil;
    }
    else if (request == self.contactDelRequest)
    {
        __unused NSDictionary *resDelDict = [[request responseString] jsonValue];
        NSLog(@"Contact Del Action Request Finished! JSON:%@", [request responseString]);
        
        [[CAAppDelegate sharedDelegate].window.rootViewController hideProgress];
        self.contactDelRequest = nil;
    }
}

@end
