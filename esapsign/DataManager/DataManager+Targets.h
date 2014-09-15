//
//  DataManager+Targets.h
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (Targets)

// 清除已有的target对象
- (void)clearAllTargets;

// 清除所有的签名流程
- (void)clearAllSignFlow;

// 清除所有的签名人信息
- (void)clearAllSign;

// 同步写入一个target
- (Client_target*)syncTarget:(NSDictionary *)dictTargetValue;

// 同步写入一个file
- (Client_file*)syncFile:(NSDictionary *)dictFileValue;

// 同步写入一个SignFlow
- (Client_sign_flow*)syncSignFlow:(NSDictionary*)dicSignFlow;

// 同步写入一个Sign
- (Client_sign*)syncSign:(NSDictionary*)dicSign;

// 返回指定parent_id的所有文件夹
- (NSArray *)foldersWithParentTarget:(NSString *)parent_id;

// 返回指定parent_id下的所有文件
- (NSArray *)filesWithParentTarget:(NSString *)parent_id;

// 修改指定Target的显示名称
- (void)modifyTarget:(NSString *)targetID displayName:(NSString *)displayName;

// 用户添加一个目录
- (void)addFolder:(NSString *)name parentID:(NSString *)parentID;

// 用户添加一个文件
- (void)addFile:(FileExtendType)type
    displayName:(NSString *)displayName
           path:(NSString *)path
       parentID:(NSString *)parentID;

// 删除目录及子目录
- (void)deleteFolders:(NSString *)clientID;

// 更新指定文件的本地版本为server版本，主要应用于下载完成
- (void)syncLocalVersionToServer:(NSString *)fileID;

// 清除不在使用的文件
- (void)clearUnusedFiles;

// 清除本地所有下载文件
- (void)clearAllLocalFiles;

@end
