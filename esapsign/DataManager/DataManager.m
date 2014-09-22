//
//  DataManager.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager.h"

#import "NSString+Additions.h"
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterbackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [NSTimer scheduledTimerWithTimeInterval:2 * 60 target:self selector:@selector(syncDataToFile) userInfo:nil repeats:YES];
    }
    return self;
}

// 获取与联系人所有相关签名文档(By Yi Minwen)
- (NSMutableArray *)allTargetsWithClientUser:(Client_contact *)user
{
    NSMutableArray *collectedTargets = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *collectedFiles = [[NSMutableArray alloc] initWithCapacity:1];
    
#warning 对target进行排序，以最新签署时间（最后修改时间）优先
    // 枚举所有target
    for (Client_target *targetItem in self.allTargets)
    {
        if (targetItem.type.intValue != TargetTypeFile)
            continue;
        
        Client_file *file = targetItem.clientFile;
        if ([collectedFiles containsObject:file])
            continue;
        
        // 获取当前文件下签名流
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientFile.file_id==%@", file.file_id];
        NSArray *arrSignFlows = [self arrayFromCoreData:EntityClientSignFlow
                                              predicate:predicate
                                                  limit:NSUIntegerMax
                                                 offset:0
                                                orderBy:nil];
        if (arrSignFlows.count > 0)
        {
            for (Client_sign_flow *signFlowItem in arrSignFlows)
            {
                __block BOOL bFind = NO;
                // 枚举当前签名流下所有签名
                for (Client_sign *sign in signFlowItem.clientSigns)
                {
                    // 判定是否存在未签署的签名，存在则认为此targetItem不是想要的，则跳出此次检查
                    //if (sign.sign_date == nil || sign.refuse_date == nil)
                    //{
                    //    bFind = NO;
                    //    break;
                    //}
                    // 再枚举签名流中是否有对应用户
                    [user.clientItems enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        Client_contact_item *item = (Client_contact_item *)obj;
                        if ([item.contentValue isEqualToString:sign.sign_address]) {
                            bFind = YES;
                            *stop = YES;
                        }
                    }];
                }
                if (bFind)
                {
                    [collectedFiles addObject:file];
                    [collectedTargets addObject:targetItem];
                    
#warning 设置文件数量上限
                    break;
                }
            }
        }
    }
    return collectedTargets;
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
    DebugLog(@"%s, arrSignFlows:%lu", __FUNCTION__, (unsigned long)arrSignFlows.count);
    if ([arrSignFlows count]) {
        return YES;
    }
    return NO;
}

#pragma mark - DocDetail

/*!
 提交签名并检查是否整个签名流程已经完成
 @param signFlow 当前signflow
 @param sign 签名
 */
- (bool)finishSignFlow:(Client_sign_flow *)signFlow withSign:(Client_sign*)sign
{
    // 过滤非当前流程的sign
    if (![signFlow.sign_flow_id isEqualToString:sign.sign_flow_id])
        return NO;
    
    // 一旦有人拒绝签署也就完事儿了
    if (sign.refuse_date != nil)
        return YES;

    bool finished = NO;
    NSNumber *minSequence = nil;
    for (Client_sign *member in signFlow.clientSigns)
    {
        // 如果还有同等或更大序列号的签名包没有签署
        if ([member.sequence intValue] >= [sign.sequence intValue] && member.sign_date == nil)
        {
            // 最小值如果是nil表示还没有记录初始化，无条件接受当前签名包的顺序值
            if (minSequence == nil) minSequence = member.sequence;
            // 记录一个符合条件的最小序号值
            else minSequence = [minSequence intValue] < [member.sequence intValue] ? minSequence : member.sequence;
        }
    }
    signFlow.current_sequence = minSequence;

    return finished;
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
    DebugLog(@"%s, arrSignFlows:%lu", __FUNCTION__, (unsigned long)arrSignFlows.count);
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

#pragma mark - Clear Cache


#pragma mark - Sign Flow Management

/*!
 添加一个用户到指定的签名流程中
 */
- (Client_sign *)addFileSignFlow:(Client_sign_flow *)flow
                     displayName:(NSString *)displayName
                         address:(NSString *)address
{
    if (!flow)
    {
        flow = [NSEntityDescription insertNewObjectForEntityForName:EntityClientSignFlow inManagedObjectContext:self.objectContext];
        flow.sign_flow_id = [Util generalUUID];
        // flow.clientFile = file;
        flow.status = @(0);
        [self.objectContext insertObject:flow];
    }
    
    Client_sign *sign = [NSEntityDescription insertNewObjectForEntityForName:EntityClientSign inManagedObjectContext:self.objectContext];
    sign.sign_id = [Util generalUUID];
    sign.sign_flow_id = flow.sign_flow_id;
    sign.sign_displayname = displayName;
    sign.sign_address = address;
    
    if (![flow.clientSigns count]) {
        flow.current_sign_id = sign.sign_id;
        flow.current_sequence = @(1);
        flow.current_sign_status = @(0);
    }
    sign.sequence = @([flow.clientSigns count] + 1);
    sign.sign_flow = flow;
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
    NSMutableArray* targets = nil;
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if (fetchObjects != nil)
        targets = [[NSMutableArray alloc] initWithArray:fetchObjects];
    else
        targets = [[NSMutableArray alloc] init];
    return targets;
}

// 全部的文件对象（文件体）
- (NSMutableArray *)allFiles
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type==%d", TargetTypeFile];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"display_name" ascending:NO];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:sort];
    NSMutableArray* files = [[NSMutableArray alloc] init];
    
    for (Client_target *target in fetchObjects)
    {
        if (![files containsObject:target.clientFile])
                [files addObject:target.clientFile];
    }
    return files;
}

// 全部的通讯录联系人
- (NSMutableArray *)allContacts
{
    NSMutableArray* contacts = nil;
    // 解决新添加联系人仔联系人列表不显示问题 gaomin@20140814
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientContact
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if (fetchObjects)
        contacts = [[NSMutableArray alloc] initWithArray:fetchObjects];
    else
        contacts = [[NSMutableArray alloc] init];
    
    return contacts;
}

// 全部的有签名信息的文档
- (NSMutableArray *)allSignPics
{
    NSMutableArray* pics = nil;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"signpic_updatedate" ascending:NO];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignPic
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:sort];
    if (fetchObjects)
        pics = [[NSMutableArray alloc] initWithArray:fetchObjects];
    else
        pics = [[NSMutableArray alloc] init];
    
    return pics;
}

// 全部的签名流程
- (NSMutableArray *)allSignFlows
{
    NSMutableArray* flows = nil;
    // 解决新添加联系人仔联系人列表不显示问题 gaomin@20140814
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignFlow
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if (fetchObjects)
        flows = [[NSMutableArray alloc] initWithArray:fetchObjects];
    else
        flows = [[NSMutableArray alloc] init];
    return flows;
}

- (NSMutableArray *)contactCache
{
    if (_contactCache == nil)
        _contactCache = [NSMutableArray arrayWithArray:self.allContacts];
    return _contactCache;
}

- (void)syncContactCache
{
    _contactCache = nil;
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
        signingFolder.target_id = @"1311BAE9-7449-45BD-855A-F33E1E534A70"; //[Util generalUUID]; 固定这个ID
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
