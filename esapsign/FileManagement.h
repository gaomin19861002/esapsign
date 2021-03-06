//
//  FileManagement.h
//  esapsign
//
//  Created by 苏智 on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManagement : NSObject

// cache目录
+ (NSString *)getCachesDirectory;

// document目录
+ (NSString *)getDocumentDirectory;

// 删除一个文件
+ (BOOL)removeFile:(NSString *)strFilePath;

// 删除一个文件夹
+ (BOOL)removeFolder:(NSString *)strFolderName;

// 拷贝资源目录文件到caches目录
+ (BOOL)copyResourceFileToCachesDirectory:(NSString *)strFileName;

// 拷贝资源目录文件到caches目录
+ (BOOL)copyResourceFileToDocumentDirectory:(NSString *)strFileName;

// 拷贝资源目录下子目录到caches目录
// 保持子目录结构一致
+ (BOOL)copyResourceSubDirToCachesDirectory:(NSString *)subPath;

@end

@interface FileManagement (Additions)

+ (NSString *)signsImageCachedFolder;

@end