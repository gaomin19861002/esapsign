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
#import "NSDate+Additions.h"

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
    
    Client_signpic* orgSignpic = [self fetchSignPic:fileId];
    if (orgSignpic == nil)
    {
        orgSignpic = (Client_signpic *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignPic
                                                                      inManagedObjectContext:[DataManager defaultInstance].objectContext];
        orgSignpic.signpic_id = fileId;
        [self.objectContext insertObject:orgSignpic];

        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        if (updateDate != nil && ![updateDate isEqualToString:@""])
            orgSignpic.signpic_updatedate = [dateFormater dateFromString:updateDate];
        else
            orgSignpic.signpic_updatedate = [NSDate convertDateToLocalTime:[NSDate date]];
        NSLog(@"签名图更新时间：%@", [orgSignpic.signpic_updatedate fullDateString]);
        
        // 如果本地没有该签名图，记录其服务器地址，从上面更新下来
        orgSignpic.signpic_serverpath = serverPath;
        NSString *fileName = [serverPath fileNameInPath];
        NSString *localPath = [[FileManagement signsImageCachedFolder] stringByAppendingPathComponent:fileName];
        orgSignpic.signpic_path = localPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:orgSignpic.signpic_path])
    {
        // 如果本地已经有该签名图，不计其服务器地址，避免重复下载
        orgSignpic.signpic_serverpath = nil;
    }
    else
    {
        orgSignpic.signpic_serverpath = serverPath;
    }
    
    return orgSignpic;
}


/**
 *  用户创建一个签名图
 *
 *  @param signFilePath 签名文件路径
 */
- (Client_signpic *)addSignWithPath:(NSString *)signFilePath withID:(NSString*)givenID
{
    Client_signpic *sign = (Client_signpic *)[NSEntityDescription insertNewObjectForEntityForName:EntityClientSignPic
                                                                           inManagedObjectContext:self.objectContext];
    sign.signpic_id = givenID;
    sign.signpic_path = signFilePath;
    sign.signpic_updatedate = [NSDate convertDateToLocalTime:[NSDate date]];
    [self.objectContext insertObject:sign];
    return sign;
}

/*!
 清除本地签名文件
 */
- (void)clearLocalSignPic
{
    for (Client_signpic *signpic in self.allSignPics)
    {
        // 只删除逻辑对象，不删除实际文件
        // [[NSFileManager defaultManager] removeItemAtPath:signFile.signpic_path error:nil];
        [self.objectContext deleteObject:signpic];
    }
}

/*!
 删除一个签名文件信息
 */
-(void)deleteSignPic:(Client_signpic *)signToDel
{
    for (Client_signpic* signpic in self.allSignPics)
    {
        if ([signpic.signpic_id isEqualToString:signToDel.signpic_id])
        {
            [self.objectContext deleteObject:signpic];
            break;
        }
    }
}

/*
 根据签名图ID获取对应签名图对象
 */
- (Client_signpic*) fetchSignPic:(NSString*) signpic_id
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
