//
//  DownloadInfo.h
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DownloadStatus)
{
    DownloadStatusNoStarted = 0,
    DownLoadStatusWaitingDownload = 1,
    DownloadStatusDownloading = 2,
    DownloadStatusFailed = 3,
    DownloadStatusFinished = 4,
    DownloadStatusPaused = 5,
};

@interface DownloadInfo : NSObject

/*!
 下载文件的类型，0, 签名文件， 1, 其它文件
 */
@property(nonatomic, assign) NSInteger fileType;

@property(nonatomic, copy) NSString *serverPath;

@property(nonatomic, copy) NSString *localPath;

@property(nonatomic, copy) NSString *fileID;

@property(nonatomic, assign) DownloadStatus status;

@property(nonatomic, assign) CGFloat downloadProgress;

@end
