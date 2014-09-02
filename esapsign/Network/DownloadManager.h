//
//  DownloadManager.h
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadInfo.h"

#define DownloadCountKey    @"DownloadCount"

@interface DownloadManager : NSObject

DefaultInstanceForClassHeader(DownloadManager);

@property(nonatomic, assign) NSInteger downloadCount;

/*!
 重置文件下载列表
 */
- (void)resetDownloadFileList;

- (void)startDownload;

- (void)clearDownload;

/*!
 文件是否正在下载
 @param fileID 文件id 
 @return 下载状态
 */
- (DownloadStatus)downloadingWithFile:(NSString *)fileID;

- (BOOL)pauseDownloadingWithFile:(NSString *)fileID;

- (void)startDownloadingWithFile:(NSString *)fileID;

- (void)cancelDownloadingWithFile:(NSString *)fileID;

@end
