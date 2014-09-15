//
//  DataManager+SignPic.m
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager+SignPic.h"
#import "FileManagement.h"
#import "NSString+Additions.h"

@implementation DataManager (SignPic)

/*!
 *  @abstract   从服务器同步添加一个签名文件信息
 *  @param dict
 */
- (Client_signpic *) syncSignPicWithDict:(NSDictionary *) dict
{
    NSString *fileId = [dict objectForKey:@"id"];
    NSString *serverPath = [dict objectForKey:@"picUrl"];
    NSString *updateDate = [dict objectForKey:@"updateDate"];
    
    Client_signpic* orgSignfile = [self fetchSignFile:fileId];
    if (orgSignfile == nil)
    {
        orgSignfile = (Client_signpic *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignPic
                                                                      inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgSignfile.signpic_id = fileId;
        //[self.allSignFiles addObject:orgSignfile];
        [self.objectContext insertObject:orgSignfile];
        
        if (updateDate != nil && ![updateDate isEqualToString:@""])
        {
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
            orgSignfile.signpic_updatedate = [dateFormater dateFromString:updateDate];
        }
        else
        {
            orgSignfile.signpic_updatedate = nil;
        }
        
        
        // 如果本地没有该签名图，记录其服务器地址，从上面更新下来
        orgSignfile.signpic_serverpath = serverPath;
        NSString *fileName = [serverPath fileNameInPath];
        NSString *localPath = [[FileManagement signsImageCachedFolder] stringByAppendingPathComponent:fileName];
        orgSignfile.signpic_path = localPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:orgSignfile.signpic_path])
    {
        // 如果本地已经有该签名图，不计其服务器地址，避免重复下载
        orgSignfile.signpic_serverpath = nil;
    }
    else
    {
        orgSignfile.signpic_serverpath = serverPath;
    }
    
    return orgSignfile;
}


/**
 *  用户创建一个签名图
 *
 *  @param signFilePath 签名文件路径
 */
- (Client_signpic *)addSignWithPath:(NSString *)signFilePath withID:(NSString*)givenID
{
    Client_signpic *sign = (Client_signpic *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignPic inManagedObjectContext:self.objectContext];
    sign.signpic_id = givenID;
    sign.signpic_path = signFilePath;
    [self.allSignPics addObject:sign];
    [self.objectContext insertObject:sign];
    return sign;
}

- (NSMutableArray *)allDefaultSignPics
{
    return self.allSignPics;
}

/*!
 清除本地签名文件
 */
- (void)clearLocalSignFile
{
    for (Client_signpic *signFile in self.allSignPics)
    {
        [[NSFileManager defaultManager] removeItemAtPath:signFile.signpic_path error:nil];
        [self.objectContext deleteObject:signFile];
    }
    
    self.allSignPics = nil;
}

/*!
 删除一个签名文件信息
 */
-(void)deleteSignFile:(Client_signpic *)signToDel
{
    for (int i = self.allSignPics.count - 1; i>= 0; i--) {
        Client_signpic *item = [self.allSignPics objectAtIndex:i];
        if ([item.signpic_id isEqualToString:signToDel.signpic_id]) {
            [self.objectContext deleteObject:item];
            [self.allSignPics removeObjectAtIndex:i];
            break;
        }
    }
}

/*
 根据签名图ID获取对应签名图对象
 */
- (Client_signpic*) fetchSignFile:(NSString*) signpic_id
{
    Client_signpic *signpic = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"signpic_id==%@", signpic_id];
    NSArray *fetchObjects = [self arrayFromCoreData:EntityClientSignPic
                                          predicate:predicate
                                              limit:NSUIntegerMax
                                             offset:0
                                            orderBy:nil];
    if ([fetchObjects count])
        signpic = [fetchObjects firstObject];
    
    return signpic;
}

@end
