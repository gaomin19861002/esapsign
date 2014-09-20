//
//  DataManager+Targets.m
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager+Targets.h"
#import "DownloadManager.h"
#import "NSDate+Additions.h"

@implementation DataManager (Targets)

// 清除已有的target对象
- (void)clearAllTargets
{
    for (Client_target *target in self.allTargets)
    {
        //[self.objectContext refreshObject:target mergeChanges:YES];
        [self.objectContext deleteObject:target];
    }
}

// 清除所有的签流程
- (void)clearAllSignFlow
{
    for (Client_sign_flow *flow in self.allSignFlows)
    {
        //[self.objectContext refreshObject:flow mergeChanges:YES];
        [self.objectContext deleteObject:flow];
    }
}

// 清除所有的签名人信息
- (void)clearAllSign
{
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSign
                                          predicate:nil
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    for (Client_sign *sign in fetchObjects)
    {
        [self.objectContext deleteObject:sign];
    }
}

// 从服务器同步写入一个target
- (Client_target*)syncTarget:(NSDictionary *)dictTargetValue
{
    Client_target* orgTarget = [self fetchTarget:[dictTargetValue objectForKey:@"id"]];
    if (orgTarget == nil)
    {
        orgTarget = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget
                                                                   inManagedObjectContext:self.objectContext];
        orgTarget.target_id = [dictTargetValue objectForKey:@"id"];
        [self.objectContext insertObject:orgTarget];
    }
    
    orgTarget.parent_id = [dictTargetValue objectForKey:@"parentId"];
    if (orgTarget.parent_id.length == 0)
        orgTarget.parent_id = @"0";
    
    orgTarget.display_name = [dictTargetValue objectForKey:@"displayName"];;
    orgTarget.type = @([[dictTargetValue objectForKey:@"type"] integerValue]);
    orgTarget.record_status =  @([[dictTargetValue objectForKey:@"type"] integerValue]);
#warning 苏智注意！
    orgTarget.create_time = [NSDate convertDateToLocalTime:[NSDate date]]; // 注意：这里的时间，当type＝2是文件的时候，要从对应的物理文件读取，该操作可能发生在文件下载完成后补充。
    orgTarget.update_time = [NSDate convertDateToLocalTime:[NSDate date]];
    
    return orgTarget;
}

// 从服务器同步写入一个file
- (Client_file*)syncFile:(NSDictionary *)dictFileValue;
{
    Client_file* orgFile = [self fetchFile:[dictFileValue objectForKey:@"id"]];
    if (orgFile == nil)
    {
        orgFile = (Client_file *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientFile
                                                               inManagedObjectContext:self.objectContext];
        orgFile.file_id = [dictFileValue objectForKey:@"id"];
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

// 从服务器同步写入一个SignFlow
- (Client_sign_flow*)syncSignFlow:(NSDictionary*)dicSignFlow
{
    Client_sign_flow* flow = [self fetchSignFlow:[dicSignFlow objectForKey:@"id"]];
    
    if (flow == nil)
    {
        flow = (Client_sign_flow *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignFlow
                                                                 inManagedObjectContext:self.objectContext];
        flow.sign_flow_id = [dicSignFlow objectForKey:@"id"];
        [self.objectContext insertObject:flow];
    }
    
    // 填写signFlow对象
    // flow.starterAccount = [signFlowDict objectForKey:@"starterAccount"]; 需要增加 starterAccount字段 这个值可以用对应的file中OwnerAccountID
    flow.current_sequence = @([[dicSignFlow objectForKey:@"currentSequence"] integerValue]);
    flow.current_sign_id = [dicSignFlow objectForKey:@"currentSignId"];
    flow.current_sign_status = @([[dicSignFlow objectForKey:@"currentSignStatus"] integerValue]);
    // flow.status = ; 通过事后的综合判断，随后填写
    return flow;
}

// 同步写入一个Sign
- (Client_sign*)syncSign:(NSDictionary*)dicSign
{
    Client_sign *sign = [self fetchSign:[dicSign objectForKey:@"id"]];
    if (sign == nil)
    {
        sign = (Client_sign *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSign
                                                            inManagedObjectContext:self.objectContext];
        sign.sign_id = [dicSign objectForKey:@"id"];
        [self.objectContext insertObject:sign];
    }

    sign.sequence = @([[dicSign objectForKey:@"sequence"] integerValue]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    sign.sign_date = [formatter dateFromString:[dicSign objectForKey:@"signDate"]];
    sign.refuse_date = [formatter dateFromString:[dicSign objectForKey:@"refuseDate"]];
    sign.sign_account_id = [dicSign objectForKey:@"signerAccountID"];
    sign.sign_displayname = [dicSign objectForKey:@"signerName"];
    sign.sign_address = [dicSign objectForKey:@"signerAddress"];
    return sign;
}

// 清除不在使用的文件
- (void)clearUnusedFiles
{
    NSMutableArray *delFiles = [NSMutableArray array];
    for (Client_file *file in self.allFiles)
    {
        if ([file.clientTargets count] == 0)
            [delFiles addObject:file];
    }
    
    for (Client_file *file in delFiles)
    {
        [[NSFileManager defaultManager] removeItemAtPath:file.phsical_filename error:nil];
        [self.objectContext deleteObject:file];
    }
}

// 清除本地所有下载文件
- (void)clearAllLocalFiles
{
    for (Client_file *file in self.allFiles)
    {
        [[NSFileManager defaultManager] removeItemAtPath:file.phsical_filename error:nil];
        file.local_version = @(0);
    }
    [[DownloadManager defaultInstance] resetDownloadFileList];
}

#pragma mark - Search

- (Client_target*)getTargetByID:(NSString*)target_id
{
    return [self fetchTarget:target_id];
}

// 返回指定parent_id的所有文件夹对象
- (NSArray *)foldersWithParentTarget:(NSString *)parent_id
{
    if (parent_id.length == 0)
        return nil;

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

// 返回指定parent_id下的所有文件对象
- (NSArray *)filesWithParentTarget:(NSString *)parent_id
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent_id==%@ AND type==2", parent_id];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"update_time" ascending:NO];
    
    return [self arrayFromCoreData:EntityClientTarget
                         predicate:predicate
                             limit:NSUIntegerMax
                            offset:0
                           orderBy:sort];
}

#pragma mark - Modify

// 修改指定Target的显示名称
- (void)modifyTarget:(NSString *)targetID displayName:(NSString *)displayName
{
    Client_target *target = [self fetchTarget:targetID];
    if (target != nil)
        target.display_name = displayName;
}

// 添加一个目录
- (void)addFolder:(NSString *)name parentID:(NSString *)parentID
{
    Client_target *folder = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget
                                                                           inManagedObjectContext:self.objectContext];
    folder.target_id = [Util generalUUID];
    folder.parent_id = parentID;
    folder.display_name = name;
    folder.type = @(TargetTypeUserFolder);
    folder.record_status = @(1);
    folder.create_time = [NSDate convertDateToLocalTime:[NSDate date]];
    folder.update_time = [NSDate convertDateToLocalTime:[NSDate date]];
    
    [self.objectContext insertObject:folder];
}

// 添加一个文件
- (void)addFile:(FileExtendType)type displayName:(NSString *)displayName path:(NSString *)path parentID:(NSString *)parentID
{
    Client_target *fileTarget = (Client_target *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientTarget
                                                                               inManagedObjectContext:self.objectContext];
    fileTarget.target_id = [Util generalUUID];
    fileTarget.parent_id = parentID;
    fileTarget.display_name = displayName;
    fileTarget.type = @(TargetTypeFile);
    fileTarget.record_status = @(1);
    fileTarget.create_time = [NSDate convertDateToLocalTime:[NSDate date]];
    fileTarget.update_time = [NSDate convertDateToLocalTime:[NSDate date]];
    
    // 生成文件关联对象
    Client_file *file = (Client_file *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientFile inManagedObjectContext:self.objectContext];
    file.file_id = fileTarget.target_id;
    file.file_type = @(type);
    file.phsical_filename = path;
    file.phsical_backup_filename = path;
    file.record_references = @(1);
    file.version = @(1);
#warning message(file.total_size)
    fileTarget.clientFile = file;

    [self.objectContext insertObject:fileTarget];
    [self.objectContext insertObject:file];
}

// 删除目录及子目录（注意，对于文件类型的Target，对应的File结构不必删除
- (void)deleteFolders:(NSString *)targetID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"target_id==%@", targetID];
    NSArray *targets = [self arrayFromCoreData:EntityClientTarget
                                     predicate:predicate
                                         limit:NSUIntegerMax
                                        offset:0 orderBy:nil];
    if (targets.count <= 0)
    {
        NSLog(@"can't find the target with id %@", targetID);
        return;
    }
    
    NSMutableArray *allSubTargets = [[NSMutableArray alloc] init];
    [allSubTargets addObjectsFromArray:targets];
    Client_target *target = targets[0];
    NSArray *subTargets = [self allTagetsUnderID:target.target_id];
    if ([subTargets count])
        [allSubTargets addObjectsFromArray:subTargets];
    
    for (Client_target *target in allSubTargets)
        [self.objectContext deleteObject:target];
}

// 更新指定文件的本地版本为server版本，主要应用于下载完成
- (void)syncLocalVersionToServer:(NSString *)fileID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_id==%@", fileID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientFile
                                          predicate:predicate
                                              limit:NSIntegerMax
                                             offset:0
                                            orderBy:nil];
    
    if (fetchObjects.count > 0)
    {
        Client_file *file = [fetchObjects firstObject];
        file.local_version = file.server_version;
    }
}


#pragma mark - Private function


// 根据TargetID获取对应Target对象
- (Client_target*) fetchTarget:(NSString*) targetID
{
    Client_target *target = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"target_id==%@", targetID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientTarget
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        target = [fetchObjects firstObject];
    
    return target;
}

// 根据文件ID获取文件数据对象
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

// 根据流程ID获取流程数据对象
- (Client_sign_flow*) fetchSignFlow:(NSString*) flowID
{
    Client_sign_flow* flow = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sign_flow_id==%@", flowID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignFlow
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        flow = [fetchObjects firstObject];
    
    return flow;
}


// 根据流程ID获取流程数据对象
- (Client_sign*) fetchSign:(NSString*) signID
{
    Client_sign* sign = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sign_id==%@", signID];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSign
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        sign = [fetchObjects firstObject];
    
    return sign;
}

// 递归查找当前target下的所有子target
- (NSArray *)allTagetsUnderID:(NSString *)targetID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent_id==%@", targetID];
    NSArray *subTargets = [self arrayFromCoreData:EntityClientTarget
                                        predicate:predicate
                                            limit:NSUIntegerMax
                                           offset:0
                                          orderBy:nil];
    if (subTargets.count <= 0)
        return nil;
    
    NSMutableArray *allSubTargets = [NSMutableArray array];
    [allSubTargets addObjectsFromArray:subTargets];
    for (Client_target *target in subTargets)
    {
        NSArray *subTarget = [self allTagetsUnderID:target.target_id];
        if ([subTarget count])
            [allSubTargets addObjectsFromArray:subTarget];
    }
    
    return allSubTargets;
}


@end
