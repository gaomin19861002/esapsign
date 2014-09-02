//
//  DataManager.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager.h"
#import "Util.h"
#import "NSString+Additions.h"
#import "User.h"
#import "ClientContentInEdit.h"
#import "DownloadManager.h"
#import "FileManagement.h"

@interface DataManager()

/*!
 如果目录不存在，则创建目录
 */
- (void)createPathIfNoExist:(NSString *)path;

/*!
 存储当前的数据
 */
- (void)saveContext;

/*!
 从数据库中取得数据
 */
- (NSArray *)arrayFromCoreData:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                         limit:(NSUInteger)limit
                        offset:(NSUInteger)offset
                       orderBy:(NSSortDescriptor *)sortDescriptor;

/*!
 添加默认数据
 */
- (void)addDefalutData;

/*!
 查找当前target下的所有子target
 @param clientID指定的target id
 */
- (NSArray *)allTagetsWithID:(NSString *)clientID;

/*!
 处理程序将进入后台的通知
 @param notification 通知
 */
- (void)applicationWillEnterbackground:(NSNotification *)notification;

- (void)syncDataToFile;

@end

@implementation DataManager

DefaultInstanceForClass(DataManager);

- (id)init
{
    if (self = [super init])
    {
        // NO default NOW!
        //[self addDefalutData];
        // 监听程序进入前后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterbackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [NSTimer scheduledTimerWithTimeInterval:2 * 60 target:self selector:@selector(syncDataToFile) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Target Operations (Folders & Files)

/*!
 返回指定parent_id的所有文件夹
 @param parent_id 父id
 @return 所有的文件夹target
 */
- (NSArray *)foldersWithParentTarget:(NSString *)parent_id
{
    if (![parent_id length])
    {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent_id==%@ AND (type==0 OR type==1)", parent_id];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"create_time" ascending:YES];
    NSArray *folders =[self arrayFromCoreData:EntityClientTarget
                                    predicate:predicate
                                        limit:NSUIntegerMax
                                       offset:0
                                      orderBy:sort];

    for (Client_target *target in folders) {
        target.manager = self;
    }
    
    return folders;
}

/*!
 返回指定parent_id下的所有文件
 @param parent_id 父id
 @return 所有的文件target
 */
- (NSArray *)filesWithParentTarget:(NSString *)parent_id {
    //if (![parent_id length]) {
    //    return nil;
    //}
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent_id==%@ AND type==2", parent_id];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"display_name" ascending:NO];

    return [self arrayFromCoreData:EntityClientTarget
                         predicate:predicate
                             limit:NSUIntegerMax
                            offset:0
                           orderBy:sort];
}

/*!
 修改指定Target的显示名称
 */
- (void)modifyTarget:(NSString *)targetID displayName:(NSString *)displayName
{
    Client_target *target = [self fetchTarget:targetID];
    if (target != nil)
    {
        target.display_name = displayName;
    }
}

/*
 这个方法用来清空target
 */
- (void)resetTarget
{
#warning message(resetTarget method)
    // to do
}

/*!
 同步写入一个target；，创建。
 */
- (Client_target*)syncTarget:(NSDictionary *)dictTargetValue
{
    Client_target* orgTarget = [self fetchTarget:[dictTargetValue objectForKey:@"id"]];
    if (orgTarget == nil)
    {
        orgTarget = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget
                                                                   inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgTarget.client_id = [dictTargetValue objectForKey:@"id"];
        [self.allTargets addObject:orgTarget];
        [self.objectContext insertObject:orgTarget];
    }

    orgTarget.parent_id = [dictTargetValue objectForKey:@"parentId"];
    if (![orgTarget.parent_id length]) {
        orgTarget.parent_id = @"0";
    }
    orgTarget.display_name = [dictTargetValue objectForKey:@"displayName"];;
    orgTarget.type = @([[dictTargetValue objectForKey:@"type"] integerValue]);
    orgTarget.record_status = @(1);
    orgTarget.record_status =  @([[dictTargetValue objectForKey:@"type"] integerValue]);;
    orgTarget.create_time = [NSDate date]; // 注意：这里的时间，当type＝2是文件的时候，要从对应的物理文件读取，该操作可能发生在文件下载完成后补充。
    orgTarget.update_time = [NSDate date];

    return orgTarget;
}

/*!
 同步写入一个file；首先判断是否已经有该对象，如果有，更新；如果没有，创建。
 */
- (Client_file*)syncFile:(NSDictionary *)dictFileValue;
{
    Client_file* orgFile = [self fetchFile:[dictFileValue objectForKey:@"id"]];
    if (orgFile == nil)
    {
        orgFile = (Client_file *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientFile
                                                               inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgFile.file_id = [dictFileValue objectForKey:@"id"];
        //[self.allFiles addObject:orgFile];
        [self.objectContext insertObject:orgFile];
    }

    // orgFile.total_size = file.total_size; // 文件的大小应当在下载完成后根据物理文件尺寸填写
    orgFile.server_version = @([[dictFileValue objectForKey:@"serverVersion"] integerValue]);;
    orgFile.file_type = @([[dictFileValue objectForKey:@"type"] integerValue]);
    orgFile.owner_account_id = [dictFileValue objectForKey:@"ownerAccount"];
    orgFile.store_type = @([[dictFileValue objectForKey:@"storeType"] integerValue]);
    orgFile.locker_account_id = [dictFileValue objectForKey:@"lockerAccount"];
    //orgFile.record_references = file.record_references;

    return orgFile;
}

/*
 根据TargetID获取对应Target对象
 */
- (Client_target*) fetchTarget:(NSString*) targetID
{
    Client_target *target = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"client_id==%@", targetID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        target = [fetchObjects firstObject];

    return target;
}

/*
 根据文件ID获取文件数据对象
 */
- (Client_file*) fetchFile:(NSString*) fileID
{
    Client_file* file = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_id==%@", fileID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientFile
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        file = [fetchObjects firstObject];
    
    return file;
}

/*!
 添加一个目录
 */
- (void)addFolder:(NSString *)name parentID:(NSString *)parentID
{
    Client_target *folder = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget inManagedObjectContext:self.objectContext];
    folder.client_id = [Util generalUUID];
    folder.parent_id = parentID;
    folder.display_name = name;
    folder.type = @(1);
    folder.record_status = @(1);
    folder.create_time = [NSDate date];
    folder.update_time = [NSDate date];
    [self.allTargets addObject:folder];
    [self.objectContext insertObject:folder];
}

/*!
 删除目录及子目录
 */
- (void)deleteFolders:(NSString *)clientID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"client_id==%@", clientID];
    NSArray *targets = [self arrayFromCoreData:EntityClientTarget
                                     predicate:predicate
                                         limit:NSUIntegerMax
                                        offset:0 orderBy:nil];
    if (![targets count])
    {
        DebugLog(@"can't find the target with id %@", clientID);
        return;
    }
    NSMutableArray *allSubTargets = [[NSMutableArray alloc] init];
    [allSubTargets addObjectsFromArray:targets];
    Client_target *target = targets[0];
    NSArray *subTargets = [self allTagetsWithID:target.client_id];
    if ([subTargets count])
    {
        [allSubTargets addObjectsFromArray:subTargets];
    }
    
    for (Client_target *target in allSubTargets)
    {
        // 如果是文件Target,则删除实体文件，相关签名
        if ([target.type intValue] == TargetTypeFile) {
            Client_file *clientFile = target.clientFile;
            
            for (Client_sign *sign in clientFile.currentSignflow.clientSigns) {
                [self.objectContext deleteObject:sign];
            }
            [self.objectContext deleteObject:clientFile.currentSignflow];
            
            [[NSFileManager defaultManager] removeItemAtPath:clientFile.phsical_filename error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:clientFile.phsical_backup_filename error:nil];
            [self.objectContext deleteObject:clientFile];
        }
        
        [self.objectContext deleteObject:target];
    }
    
    [self.allTargets removeObjectsInArray:allSubTargets];
}

/*!
 查找当前target下的所有子target
 @param clientID指定的target id
 */
- (NSArray *)allTagetsWithID:(NSString *)clientID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent_id==%@", clientID];
    NSArray *subTargets = [self arrayFromCoreData:EntityClientTarget
                                        predicate:predicate
                                            limit:NSUIntegerMax
                                           offset:0
                                          orderBy:nil];
    if (![subTargets count]) {
        return nil;
    }
    NSMutableArray *allSubTargets = [NSMutableArray array];
    [allSubTargets addObjectsFromArray:subTargets];
    for (Client_target *target in subTargets) {
        NSArray *subTarget = [self allTagetsWithID:target.client_id];
        if ([subTarget count]) {
            [allSubTargets addObjectsFromArray:subTarget];
        }
    }
    
    return allSubTargets;
}

/*!
 添加一个文件
 */
- (void)addFile:(FileExtendType)type
    displayName:(NSString *)displayName
           path:(NSString *)path
       parentID:(NSString *)parentID
{
    Client_target *fileTarget = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget inManagedObjectContext:self.objectContext];
    fileTarget.client_id = [Util generalUUID];
    fileTarget.parent_id = parentID;
    fileTarget.display_name = displayName;
    fileTarget.type = @(2);
    fileTarget.record_status = @(1);
    fileTarget.create_time = [NSDate date];
    fileTarget.update_time = [NSDate date];
    
    // 生成文件关联对象
    Client_file *file = (Client_file *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientFile inManagedObjectContext:self.objectContext];
    file.file_id = fileTarget.client_id;
    file.file_type = @(type);
    file.phsical_filename = path;
    file.phsical_backup_filename = path;
    file.record_references = @(1);
    file.version = @(1);
#warning message(file.total_size)
    fileTarget.clientFile = file;
    [self.allTargets addObject:fileTarget];
    [self.objectContext insertObject:fileTarget];
    [self.objectContext insertObject:file];
}

/*!
 更新指定文件的本地版本为server版本，主要应用于下载完成
 @param fileID 文件id
 */
- (void)syncLocalVersionToServer:(NSString *)fileID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_id==%@", fileID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientFile
                                          predicate:predicate
                                              limit:NSIntegerMax
                                             offset:0
                                            orderBy:nil];
    
    if ([fetchObjects count]) {
        Client_file *file = [fetchObjects firstObject];
        file.local_version = file.server_version;
    }
}

#pragma mark - Contact Operation

-(NSMutableArray *)allClientUsers
{
    return self.allUsers;
}

/*!
 添加一个通讯录用户
 @param userName 用户名称
 @return 当前用户对象
 */
- (Client_user *)addContactUser:(NSString *)firstName lastName:(NSString *)lastName
{
    Client_user *user = [NSEntityDescription insertNewObjectForEntityForName:EntityClientUser inManagedObjectContext:self.objectContext];
    user.person_name = firstName;
    user.family_name = lastName;
    user.user_id = [Util generalUUID];
    [self.allUsers addObject:user];
    [self.objectContext insertObject:user];
    
    return user;
}

- (Client_user *)addContactWithName:(NSString *)contactName
{
    Client_user *user = (Client_user *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientUser inManagedObjectContext:self.objectContext];
    // By Yi Minwen 先用person_name字段存储新建联系人名称
    user.person_name = contactName;
    user.user_id = [Util generalUUID];
    [self.allUsers addObject:user];
    [self.objectContext insertObject:user];
    return user;
}

/*!
 添加一条通讯录用户条目
 @param user 指定的用户对象
 @param contextType 条目类型
 @param contextValue 条目的值
 */
- (void)addContent:(Client_user *)user
      contentTitle:(NSString *)title
       contentType:(UserContentType)contentType
      contentValue:(NSString *)contentVlaue
             major:(BOOL)major
{
    Client_content *content = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContent inManagedObjectContext:self.objectContext];
    content.user_id = user.user_id;
    content.content_id = [Util generalUUID];
    content.contentType = @(contentType);
    content.contentValue = contentVlaue;
    content.clientUser = user;
    content.major = @(major);
    content.title = title;
    [self.objectContext insertObject:content];
}

- (Client_content *)insertContentWithUser:(Client_user *)user
                             contentTitle:(NSString *)title
                              contentType:(UserContentType)contentType
                             contentValue:(NSString *)contentVlaue
                                    major:(BOOL)major
{
    Client_content *content = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContent inManagedObjectContext:self.objectContext];
    content.user_id = user.user_id;
    content.content_id = [Util generalUUID];
    content.contentType = @(contentType);
    content.contentValue = contentVlaue;
    content.clientUser = user;
    content.major = @(major);
    content.title = title;
    return content;
}

- (void)modifyUser:(NSString *)userID withFirstName:(NSString *)firstName familyName:(NSString *)familyName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id==%@", userID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientUser
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count]) {
        Client_user *target = [fetchObjects firstObject];
        target.person_name = firstName;
        target.family_name = familyName;
    }
}

/*!
 获取5个常用联系人
 */
- (NSArray *)lastestConstacts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selectedDate != NULL"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"selectedDate" ascending:NO];
    return [self arrayFromCoreData:EntityClientUser
                         predicate:predicate
                             limit:5
                            offset:0
                           orderBy:sort];
}

/**
 *  获取与联系人所有相关签名文档(By Yi Minwen)
 *
 *  @param user 相关联系人
 */
- (NSMutableArray *)allTargetsWithClientUser:(Client_user *)user
{
    // NSData *userData = [Util valueForKey:LoginUser];
    // User *curUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    NSMutableArray *arrResult = [[NSMutableArray alloc] initWithCapacity:1];
    // 枚举所有target
    for (Client_target *targetItem in self.allTargets)
    {
        if (targetItem.type.intValue != 2)
        {
            continue;
        }
        Client_file *file = targetItem.clientFile;
        // 获取当前文件下签名流
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientFile.file_id==%@", file.file_id];
        NSArray *arrSignFlows = [self arrayFromCoreData:EntityClientSignFlow
                                              predicate:predicate
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:nil];
        DebugLog(@"%s, arrSignFlows:%d", __FUNCTION__, arrSignFlows.count);
        if ([arrSignFlows count])
        {
            for (Client_sign_flow *signFlowItem in arrSignFlows)
            {
                __block BOOL bFind = NO;
                // 枚举当前签名流下所有签名
                for (Client_sign *sign in signFlowItem.clientSigns)
                {
                    // 判定是否存在未签署的签名，存在则认为此targetItem不是想要的，则跳出此次检查
                    if (sign.sign_date == nil || sign.refuse_date == nil)
                    {
                        bFind = NO;
                        break;
                    }
                    // 再枚举签名流中是否有对应用户
                    [user.clientContents enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        Client_content *item = (Client_content *)obj;
                        if ([item.contentValue isEqualToString:sign.sign_address]) {
                            bFind = YES;
                            *stop = YES;
                        }
                    }];
                }
                if (bFind)
                {
                    [arrResult addObject:targetItem];
                    break;
                }
            }
        }
    }
    return arrResult;
}

- (void)deleteClientUser:(Client_user *)client
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id==%@", client.user_id];
    NSArray *users = [self arrayFromCoreData:EntityClientUser
                                   predicate:predicate
                                       limit:NSUIntegerMax
                                      offset:0 orderBy:nil];
    NSLog(@"%s, self.arrUser.count = %d", __FUNCTION__, self.allUsers.count);
    for (Client_user *item in users) {
        [self.objectContext deleteObject:item];
    }
    [self.allUsers removeObjectsInArray:users];

    NSLog(@"%s, self.arrUser.count = %d", __FUNCTION__, self.allUsers.count);
}

// 删除所有联系人接口 gaomin@20140815
- (void)deleteAllClientUsers
{
    NSArray *users = [self arrayFromCoreData:EntityClientUser
                                   predicate:nil
                                       limit:NSUIntegerMax
                                      offset:0 orderBy:nil];
    NSLog(@"%s, self.arrUser.count = %d", __FUNCTION__, self.allUsers.count);
    for (Client_user *item in users)
    {
        // [self clearAllContent:item];
        [self.objectContext deleteObject:item];
    }
    [self.allUsers removeObjectsInArray:users];
    self.allUsers = nil;
}

/**
 *  更新联系人条目信息(By Yi Minwen)
 *
 *  @param user 相关联系人
 *  @param userContents 相关条目信息
 */
- (void)updateClientUser:(Client_user *)user WithContents:(NSArray *)userContents
{
    for (Client_content *item in user.clientContents)
    {
        [self.objectContext deleteObject:item];
    }
    
    user.clientContents = nil;

    for (ClientContentInEdit *content in userContents)
    {
        [[DataManager defaultInstance] addContent:user
                                     contentTitle:content.title
                                      contentType:content.contentType
                                     contentValue:content.contentValue
                                            major:content.major];
    }
}

-(void)removeContents:(NSArray *)userContentsToDel inClientUser:(Client_user *)user
{
    for (Client_content *item in userContentsToDel)
    {
        [self.objectContext deleteObject:item];
    }
}

/*!
 清除已有的target对象
 */
- (void)clearAllTargets
{
    NSArray *allTargets = [self arrayFromCoreData:EntityClientTarget
                                        predicate:nil
                                            limit:NSIntegerMax
                                           offset:0
                                          orderBy:nil];
    for (Client_target *target in allTargets)
    {
        [self.objectContext refreshObject:target mergeChanges:YES];
        [self.objectContext deleteObject:target];
    }
    
    self.allTargets = nil;
    self.allFiles = nil;
}

/*!
 清除不在使用的文件
 */
- (void)clearUnusedFiles
{
    NSMutableArray *delFiles = [NSMutableArray array];
    for (Client_file *file in self.allFiles)
    {
        if ([file.clientTargets count] == 0) {
            [delFiles addObject:file];
        }
    }
    
    for (Client_file *file in delFiles)
    {
        [[NSFileManager defaultManager] removeItemAtPath:file.phsical_filename error:nil];
        [self.objectContext deleteObject:file];
    }
    self.allFiles = nil;
}

/*!
 清除本地所有下载文件
 */
- (void)clearAllLocalFiles
{
    NSMutableArray *delFiles = [NSMutableArray array];
    for (Client_file *file in self.allFiles)
    {
        [delFiles addObject:file];
    }
    
    for (Client_file *file in delFiles)
    {
        [[NSFileManager defaultManager] removeItemAtPath:file.phsical_filename error:nil];
        file.local_version = @(0);
       // [self.objectContext deleteObject:file];
    }
    //self.allFiles = nil;
    [[DownloadManager defaultInstance] resetDownloadFileList];
}

/*!
 清除本地签名文件
 */
- (void)clearLocalSignFile
{
    for (Client_signfile *signFile in self.allSignFiles)
    {
        [[NSFileManager defaultManager] removeItemAtPath:signFile.signfile_path error:nil];
        [self.objectContext deleteObject:signFile];
    }
    
    self.allSignFiles = nil;
}

/*!
 清除所有的签流程
 */
- (void)clearAllSignFlow
{
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignFlow
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    for (Client_sign_flow *flow in fetchObjects) {
        [self.objectContext refreshObject:flow mergeChanges:YES];
        [self.objectContext deleteObject:flow];
    }
}

/*!
 清除所有的签名人信息
 */
- (void)clearAllSign
{
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSign
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    for (Client_sign *sign in fetchObjects) {
        [self.objectContext deleteObject:sign];
    }
    
}

#pragma mark - Client_account Methods

/**
 *  @abstract 根据用户名（登陆账号）匹配用户，如果没有则创建一个新的用户信息
 */
- (Client_account *) queryAccountByAccountId:(NSString *) accountId;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account_id==%@", accountId];
    NSArray *arrAccounts = [self arrayFromCoreData:EntityClientAccount
                                         predicate:predicate
                                             limit:NSUIntegerMax
                                            offset:0
                                           orderBy:nil];
    if ([arrAccounts count]) {
        return [arrAccounts firstObject];
    }
    
    return nil;
}

/**
 *  @abstract 创建一个新的用户信息
 *  @param user User
 */
- (Client_account *) createAccountWithUser:(User *) user
{
    Client_account *account = (Client_account *) [NSEntityDescription insertNewObjectForEntityForName:EntityClientAccount
                                                                               inManagedObjectContext:self.objectContext];
    account.name = user.name;
    account.account_id = user.accountId;
    account.major_email = @"";
    account.password = @"";
    account.cert = nil;
    account.sign_count = @(10);
    
    //创建新的用户
    return account;
}

#pragma mark - MiniDocList

/**
 *  判定是否有对应签名流程(By Yi Minwen)
 *
 *  @param file 当前文件
 */
- (BOOL)hasSignFlowWithClientFile:(Client_file *)file
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientFile.file_id==%@", file.file_id];
    NSArray *arrSignFlows = [self arrayFromCoreData:EntityClientSignFlow
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    DebugLog(@"%s, arrSignFlows:%d", __FUNCTION__, arrSignFlows.count);
    if ([arrSignFlows count]) {
        return YES;
    }
    return NO;
}

#pragma mark - DocDetail

/*!
 保存签名 修改签名日期
 @param signFlow 当前signflow
 @param signStatus 签名状态
 */
- (Client_sign* )finishSignFlow:(Client_sign_flow *)signFlow withStatus:(NSNumber *)signStatus
{
    Client_sign* currentSign = nil;
    NSData *userData = [Util valueForKey:LoginUser];
    if (userData) {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        for (Client_sign *sign in signFlow.clientSigns) {
            if ([sign.sign_address isEqualToString:user.name])
            {
                sign.sign_date = [NSDate date];
                currentSign = sign;
                break;
            }
        }
    }
#warning 将来可能还需要修改signflow相关信息
    return currentSign;
}

/*!
 *  清空签名的signdate
 *  @param signFlow 当前signflow
 */
- (Client_sign *) resetSignDate:(Client_sign_flow *) signFlow
{
    Client_sign * currentSign = nil;
    NSData *userData = [Util valueForKey:LoginUser];
    if (userData)
    {
        User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        for (Client_sign *sign in signFlow.clientSigns)
        {
            if ([sign.sign_address isEqualToString:user.name])
            {
                sign.sign_date = nil;
                currentSign = sign;
                currentSign.sign_date = nil;
                break;
            }
        }
    }
    return currentSign;
}

- (BOOL)isClientFileFinishedSign:(Client_file *)file
{
    // 获取当前文件下签名流
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientFile.file_id==%@", file.file_id];
    NSArray *arrSignFlows = [self arrayFromCoreData:EntityClientSignFlow
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    DebugLog(@"%s, arrSignFlows:%d", __FUNCTION__, arrSignFlows.count);
    BOOL bFinished = YES;
    if ([arrSignFlows count])
    {
        for (Client_sign_flow *signFlowItem in arrSignFlows)
        {
            // 枚举当前签名流下所有签名
            for (Client_sign *sign in signFlowItem.clientSigns)
            {
                // 判定是否存在未签署的签名，存在则认为此targetItem不是想要的，则跳出此次检查
                if (sign.sign_date == nil && sign.refuse_date == nil)
                {
                    bFinished = NO;
                    break;
                }
            }
            if (!bFinished) {
                break;
            }
        }
    }
    
    return bFinished;
}

- (BOOL)isClientTargetEditable:(Client_target *)target
{
    // 获取收件箱id
    NSString *inboxId = @"311BAE9-7449-45BD-855A-F33E1E534A70";
    return [target.parent_id isEqualToString:inboxId];
}

#pragma mark - Sign Picture Operations

- (NSMutableArray *)allDefaultSignFiles
{
    return self.allSignFiles;
}

/**
 *  用户创建一个签名图
 *
 *  @param signFilePath 签名文件路径
 */
- (Client_signfile *)addSignWithPath:(NSString *)signFilePath withID:(NSString*)givenID
{
    Client_signfile *sign = (Client_signfile *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignfile inManagedObjectContext:self.objectContext];
    sign.signfile_id = givenID;
    sign.signfile_path = signFilePath;
    [self.allSignFiles addObject:sign];
    [self.objectContext insertObject:sign];
    return sign;
}

/*!
 从服务器同步添加一个签名文件信息
 */
- (Client_signfile*)syncSignFileInfo:(NSString *)fileId serverPath:(NSString *)serverPath
{
    Client_signfile* orgSignfile = [self fetchSignFile:fileId];
    if (orgSignfile == nil)
    {
        orgSignfile = (Client_signfile *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignfile
                                                                       inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgSignfile.signfile_id = fileId;
        [self.allSignFiles addObject:orgSignfile];
        [self.objectContext insertObject:orgSignfile];

        // 如果本地没有该签名图，记录其服务器地址，从上面更新下来
        orgSignfile.signfile_serverpath = serverPath;
        NSString *fileName = [serverPath fileNameInPath];
        NSString *localPath = [[FileManagement signsImageCachedFolder] stringByAppendingPathComponent:fileName];
        orgSignfile.signfile_path = localPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:orgSignfile.signfile_path])
    {
        // 如果本地已经有该签名图，不计其服务器地址，避免重复下载
        orgSignfile.signfile_serverpath = nil;
    }
    else
    {
        orgSignfile.signfile_serverpath = serverPath;
    }
    
    return orgSignfile;
}

/*!
 *  @abstract   从服务器同步添加一个签名文件信息
 *  @param dict
 */
- (Client_signfile *) syncSignFileWithDict:(NSDictionary *) dict
{
    NSString *fileId = [dict objectForKey:@"id"];
    NSString *serverPath = [dict objectForKey:@"picUrl"];
    NSString *updateDate = [dict objectForKey:@"updateDate"];
    
    Client_signfile* orgSignfile = [self fetchSignFile:fileId];
    if (orgSignfile == nil)
    {
        orgSignfile = (Client_signfile *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignfile
                                                                       inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgSignfile.signfile_id = fileId;
        //[self.allSignFiles addObject:orgSignfile];
        [self.objectContext insertObject:orgSignfile];
        
        if (updateDate && ![updateDate isEqualToString:@""]) {
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
            orgSignfile.signfile_updatedate = [dateFormater dateFromString:updateDate];
        }else {
            orgSignfile.signfile_updatedate = nil;
        }
        
        
        // 如果本地没有该签名图，记录其服务器地址，从上面更新下来
        orgSignfile.signfile_serverpath = serverPath;
        NSString *fileName = [serverPath fileNameInPath];
        NSString *localPath = [[FileManagement signsImageCachedFolder] stringByAppendingPathComponent:fileName];
        orgSignfile.signfile_path = localPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:orgSignfile.signfile_path])
    {
        // 如果本地已经有该签名图，不计其服务器地址，避免重复下载
        orgSignfile.signfile_serverpath = nil;
    } else {
        orgSignfile.signfile_serverpath = serverPath;
    }
    
    return orgSignfile;
}

/*!
 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 */
- (Client_user *)syncSignUser:(NSString *)address displayName:(NSString *)displayName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentValue==%@", address];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContent
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count]) {
        Client_content *content = (Client_content *)[fetchObjects firstObject];
        return content.clientUser;
    }
    
    Client_user *user = [NSEntityDescription insertNewObjectForEntityForName:EntityClientUser inManagedObjectContext:self.objectContext];
    user.family_name = displayName;
    user.user_id = [Util generalUUID];

    Client_content *content = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContent inManagedObjectContext:self.objectContext];
    content.content_id = [Util generalUUID];
    content.title = @"邮箱";
    // content.contentTypeName = @"邮箱";
    content.contentType = @(UserContentTypeEmail);
    content.contentValue = address;
    content.major = @(YES);
    content.clientUser = user;
    [self.allUsers addObject:user];
    [self.objectContext insertObject:user];
    [self.objectContext insertObject:content];
    
    return user;
}

/*!
 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 */
- (Client_user *)syncSignUser:(NSString *)address displayName:(NSString *)displayName userid:(NSString *) userid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentValue==%@", address];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContent
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count]) {
        Client_content *content = (Client_content *)[fetchObjects firstObject];
        return content.clientUser;
    }
    
    Client_user *user = [NSEntityDescription insertNewObjectForEntityForName:EntityClientUser inManagedObjectContext:self.objectContext];
    user.family_name = displayName;
    
    // gaomin@20140805
    user.user_id = [Util generalUUID];
    // user.user_id = userid;
    
    Client_content *content = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContent inManagedObjectContext:self.objectContext];
    content.content_id = [Util generalUUID];
    content.title = @"邮箱";
    // content.contentTypeName = @"邮箱";
    content.contentType = @(UserContentTypeEmail);
    content.contentValue = address;
    content.major = @(YES);
    content.clientUser = user;
    [self.allUsers addObject:user];
    [self.objectContext insertObject:user];
    [self.objectContext insertObject:content];
    
    return user;
}

/*!
 *  @abstract 根据id找对应的用户
 *  @param  userid NSString对象 用户的id
 *  @return Client_user对象
 */
- (Client_user *) findUserWithId:(NSString *) userid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id==%@", userid];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientUser
                                          predicate:predicate limit:NSUIntegerMax
                                             offset:0 orderBy:nil];
    if ([fetchObjects count]) {
        Client_user *user = (Client_user *) [fetchObjects firstObject];
        return user;
    }
    return nil;
}

/*!
 *  @abstract 根据signerAddress找对应的用户
 *  @param  address NSString对象 用户的签约地址（目前为只支持邮件，以后还会支持电话短信）
 *  @return Client_user对象
 */
- (Client_user *) findUserWithAddress:(NSString *) address
{
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientUser
                                          predicate:nil limit:NSUIntegerMax
                                             offset:0 orderBy:nil];
    
    for (int i = 0; i < [fetchObjects count]; i++)
    {
        Client_user *user = [fetchObjects objectAtIndex:i];
        
        for (Client_content *content in user.clientContents)
        {
            if ([content.contentValue isEqualToString:address])
            {
                return user;
            }
        }
    }
    
    return nil;
}

/*!
 *  @abstract 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 *  @param  contentType:条目类型（0：email，1：电话号码，2：文字信息）
 *  @return Client_user对象，如果没找到，则返回nil。
 */
- (Client_user *) syncUser:(NSString *) contentType andValue:(NSString *) contentValue
{
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"contentValue==%@ and contentType==%@", contentValue, contentType];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContent
                                          predicate:predict
                                              limit:NSUIntegerMax offset:0
                                            orderBy:nil];
    if ([fetchObjects count]) {
        Client_content *content = (Client_content *) [fetchObjects firstObject];
        return content.clientUser;
    }
    return nil;
}

/*!
 *  @abstract 创建一个用户,并添加到数据库中
 *  @param
 *  @return Client_user对象
 */
- (Client_user *) createUserWithDictionary:(NSDictionary *) dict
{
    Client_user *user = [NSEntityDescription insertNewObjectForEntityForName:EntityClientUser inManagedObjectContext:self.objectContext];
    
    user.family_name = [dict objectForKey:@"familyName"]? [dict objectForKey:@"familyName"]: @"";
    user.gender = [dict objectForKey:@"gender"]? [NSNumber numberWithInteger:[[dict objectForKey:@"gender"] integerValue]]: [NSNumber numberWithInt:0];
    
    NSDate *date = nil;
    // 修改逻辑错误，lastTimeStamp字段为空时，设置为当前时间
    if ([[dict objectForKey:@"lastTimeStamp"] isEqualToString:@""]) {
        date = [NSDate date];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [dateFormatter dateFromString:[dict objectForKey:@"lastTimeStamp"]];
    }
    user.last_timestamp = date;
    user.person_name = [dict objectForKey:@"personName"]? [dict objectForKey:@"personName"]: @"";
    user.user_id = [dict objectForKey:@"id"]? [dict objectForKey:@"id"]: [Util generalUUID];
    
    [self.objectContext insertObject:user];
    return user;
}

/*!
 *  @abstract 创建并添加一个ClientContent
 *  @param user Client_user对象，用于关联。 dict Dictionary对象，用于设置值Client_content的值。
 *  @return Client_user对象
 */
- (Client_content *) addContentWithUser:(Client_user *) user content:(NSDictionary *) dict
{
    Client_content *content = [NSEntityDescription insertNewObjectForEntityForName:EntityClientContent inManagedObjectContext:self.objectContext];

    content.clientUser = user;
    content.content_id = [dict objectForKey:@"id"];
    content.contentType = [NSNumber numberWithInt:[[dict objectForKey:@"type"] intValue] ];
    content.contentValue = [dict objectForKey:@"content"];
    content.major = [NSNumber numberWithInt:0];
    content.title = [dict objectForKey:@"title"];
    content.user_id = user.user_id;
    content.account_id = user.user_id;
    
    
    [self.objectContext insertObject:content];
    
    return content;
}

/*!
 *  @abstract 清除Client_user的所有联系方式
 *  @param user 要清除联系方式的Client_user对象
 *  @return Client_user对象
 */
- (void) clearAllContent:(Client_user *) user
{
    for (Client_content *content in user.clientContents) {
        [self.objectContext refreshObject:content mergeChanges:YES];
        [self.objectContext deleteObject:content];
    }
}

/*
 根据签名图ID获取对应签名图对象
 */
- (Client_signfile*) fetchSignFile:(NSString*) signfile_id
{
    Client_signfile *signfile = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"signfile_id==%@", signfile_id];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignfile
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        signfile = [fetchObjects firstObject];
    
    return signfile;
}

/*!
 删除一个签名文件信息
 */
-(void)deleteSignFile:(Client_signfile *)signToDel
{
    for (int i = self.allSignFiles.count - 1; i>= 0; i--) {
        Client_signfile *item = [self.allSignFiles objectAtIndex:i];
        if ([item.signfile_id isEqualToString:signToDel.signfile_id]) {
            [self.objectContext deleteObject:item];
            [self.allSignFiles removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark - Clear Cache

/**
 *  @abstract 清空缓存文件
 */
- (void) clearnCaches
{
    //修改文件转台，并清除所有本地文件
    NSArray *allClientFiles = [self arrayFromCoreData:EntityClientFile predicate:nil limit:NSUIntegerMax offset:0 orderBy:nil];
    
    for (Client_file *file in allClientFiles) {
        [[NSFileManager defaultManager] removeItemAtPath:file.phsical_filename error:nil];
    }
    //通知下载管理器重置列表
    [[DownloadManager defaultInstance] resetDownloadFileList];
}

#pragma mark - Sign Flow Management

/*!
 添加一个用户到指定文件的签名流程中
 */
- (Client_sign *)addFileSignFlow:(Client_file *)file
                     displayName:(NSString *)displayName
                         address:(NSString *)address
{
    Client_sign_flow *signFlow = file.currentSignflow;
    if (!signFlow) {
        signFlow = [NSEntityDescription insertNewObjectForEntityForName:EntityClientSignFlow inManagedObjectContext:self.objectContext];
        signFlow.sign_flow_id = [Util generalUUID];
        signFlow.clientFile = file;
        signFlow.status = @(0);
        [self.objectContext insertObject:signFlow];
    }
    
    Client_sign *sign = [NSEntityDescription insertNewObjectForEntityForName:EntityClientSign inManagedObjectContext:self.objectContext];
    sign.sign_id = [Util generalUUID];
    sign.sign_flow_id = signFlow.sign_flow_id;
    sign.sign_displayname = displayName;
    sign.sign_address = address;
    
    if (![signFlow.clientSigns count]) {
        signFlow.current_sign_id = sign.sign_id;
        signFlow.current_sequence = @(1);
        signFlow.current_sign_status = @(0);
    }
    sign.sequence = @([signFlow.clientSigns count] + 1);
    sign.sign_flow = signFlow;
    [self.objectContext insertObject:sign];
    
    return sign;
}

- (BOOL)removeClientSign:(Client_sign *)sign
          fromClientFile:(Client_file *)file
{
    NSMutableSet *mutSet = [NSMutableSet setWithSet:file.currentSignflow.clientSigns];
    [mutSet removeObject:sign];
    [self.objectContext deleteObject:sign];
    file.currentSignflow.clientSigns = mutSet;
    return YES;
}

/*!
 返回指定地址信息的User
 */
- (Client_user *)clientUserWithAddress:(NSString *)address
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contentValue==%@", address];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContent
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count] == 0) {
        return nil;
    }
    Client_content *content = [fetchObjects firstObject];
    
    return content.clientUser;
}

#pragma mark - Private Methods

// 为不同的登录帐户创建不同的数据存储路径
- (NSString *)userPath
{
    if (!_userPath)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
#warning 将来添加用户信息，以区分不同用户的数据
        
        // 添加默认用户
        NSData *userData = [Util valueForKey:LoginUser];
        if (userData) {
            User *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
            _userPath = [NSString stringWithFormat:@"%@/%@", path, user.name];
        }
        else
        {
            DebugLog(@"no login user so using default document path");
            _userPath = [NSString stringWithFormat:@"%@", path];
        }
        
        [self createPathIfNoExist:_userPath];
    }
    
    return _userPath;
}

// 全部的目录对象（文件夹和文件的头部）
- (NSMutableArray *)allTargets
{
    if (!_allTargets)
    {
        NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                              predicate:nil
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:nil];
        if (fetchObjects) {
            _allTargets = [[NSMutableArray alloc] initWithArray:fetchObjects];
        } else {
            _allTargets = [[NSMutableArray alloc] init];
        }
    }
    
    return _allTargets;
}

// 全部的文件对象（文件体）
- (NSMutableArray *)allFiles
{
    if (!_allFiles) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==2"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"display_name" ascending:NO];
        
        NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                              predicate:predicate
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:sort];
        _allFiles = [[NSMutableArray alloc] init];
        for (Client_target *target in fetchObjects) {
            if (![_allFiles containsObject:target.clientFile]) {
                [_allFiles addObject:target.clientFile];
            }
        }
    }
    
    return _allFiles;
}

// 全部的通讯录联系人
- (NSMutableArray *)allUsers
{
    // 解决新添加联系人仔联系人列表不显示问题 gaomin@20140814
    // if (!_allUsers) {
        NSArray *fetchObjects = [self arrayFromCoreData:EntityClientUser
                                              predicate:nil
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:nil];
        if (fetchObjects) {
            _allUsers = [[NSMutableArray alloc] initWithArray:fetchObjects];
        } else {
            _allUsers = [[NSMutableArray alloc] init];
        }
        
    // }
    
    return _allUsers;
}

// 全部的有签名信息的文档
- (NSMutableArray *)allSignFiles
{
    if (!_allSignFiles)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"signfile_updatedate" ascending:YES];
        NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignfile
                                              predicate:nil
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:sort];
        if (fetchObjects) {
            _allSignFiles = [[NSMutableArray alloc] initWithArray:fetchObjects];
        } else {
            _allSignFiles = [[NSMutableArray alloc] init];
        }
    }
    return _allSignFiles;
}

// Method for create path
- (void)createPathIfNoExist:(NSString *)path
{
    if (!path.length) {
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        NSError *err;
        BOOL rt = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
        if (!rt) {
            DebugLog(@"failed to create %@", [err localizedDescription]);
        }
    }
    Assert([manager fileExistsAtPath:path], @"can't create %@", path);
}

// Default data for demo (in real edition, no need more)
- (void)addDefalutData
{
    // 判断是否已添加数据
    /*if (![self.allTargets count])
    {
        // 添加默认的系统目录
        // 签署中的合同
        Client_target *signingFolder = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget inManagedObjectContext:self.objectContext];
        signingFolder.client_id = @"1311BAE9-7449-45BD-855A-F33E1E534A70"; //[Util generalUUID]; 固定这个ID
        signingFolder.parent_id = @"0";
        signingFolder.display_name = @"收件箱";
        signingFolder.type = @(0);
        signingFolder.record_status = @(1);
        signingFolder.create_time = [NSDate date];
        signingFolder.update_time = [NSDate date];
        [self.allTargets addObject:signingFolder];
        [self.objectContext insertObject:signingFolder];
    }*/
}

- (void)syncDataToFile
{
    [self saveContext];
}

#pragma mark - Application enter background or foreground

- (void)applicationWillEnterbackground:(NSNotification *)notification
{
    [self saveContext];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)objectContext
{
    if (!_objectContext)
    {
        NSPersistentStoreCoordinator *coordinator = [self storeCoordinator];
        Assert(coordinator != nil, @"failed to create NSPersistentStoreCoordinator");
        _objectContext = [[NSManagedObjectContext alloc] init];
        [_objectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _objectContext;
}

- (NSManagedObjectModel *)objectModel
{
    if (!_objectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"clientInfo" withExtension:@"momd"];
        Assert(modelURL != nil, @"clientInfo.momd couldn't be found");
        _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _objectModel;
}

- (NSPersistentStoreCoordinator *)storeCoordinator
{
    if (!_storeCoordinator) {
        NSString *dbFilePath = [self.userPath stringByAppendingPathComponent:DBFileName];
        NSURL *dbURL = [NSURL fileURLWithPath:dbFilePath];
        NSError *error = nil;
        _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self objectModel]];
        BOOL retry = NO;
        if (![_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                                       URL:dbURL
                                                   options:nil
                                                     error:&error]) {
            retry = YES;
        }
        
        if (retry) {
            [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:&error];
            DebugLog(@"deleting dbFilePath:%@ error:%@", dbFilePath, error);
            if (![_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:dbURL
                                                       options:nil
                                                         error:&error]) {
                Assert(nil, @"failed to setup persistentStoreCoordinator_. error:%@", error);
            }
        }
    }
    
    return _storeCoordinator;
}

/*!
 存储当前的数据
 */
- (void)saveContext
{
    NSError *error = nil;
    if (self.objectContext) {
        if ([self.objectContext hasChanges] && ![self.objectContext save:&error]) {
            Assert(nil, @"failed to saveContext. error:%@", error);
        }
    }
}

/*!
 从数据库中取得数据
 */
- (NSArray *)arrayFromCoreData:(NSString *)entityName
                     predicate:(NSPredicate *)predicate
                         limit:(NSUInteger)limit
                        offset:(NSUInteger)offset
                       orderBy:(NSSortDescriptor *)sortDescriptor
{
    NSManagedObjectContext *context = [self objectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    if (sortDescriptor) {
        [request setSortDescriptors:@[sortDescriptor]];
    }
    
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    [request setFetchLimit:limit];
    [request setFetchOffset:offset];
    
    NSError *error = nil;
    NSArray *fetchObjects = [context executeFetchRequest:request error:&error];
    
    if (error) {
        DebugLog(@"fetch request error=%@", error);
        
        return nil;
    }
    
    return fetchObjects;
}

@end
