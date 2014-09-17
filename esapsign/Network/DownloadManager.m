//
//  DownloadManager.m
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DownloadManager.h"
#import "DataManager.h"
#import "DataManager+SignPic.h"
#import "DataManager+Targets.h"
#import "Client_signpic.h"
#import "DownloadInfo.h"
#import "ASINetworkQueue.h"
#import "NSString+Additions.h"
#import "ASIHTTPRequest.h"
#import "SyncManager.h"
#import "NSObject+DelayBlocks.h"
#import "CAAppDelegate.h"

#define MaxDownloadCount    1

@interface DownloadManager()<ASIHTTPRequestDelegate, ASIProgressDelegate>

@property(nonatomic, retain) NSMutableArray *downloadFiles;
@property(nonatomic, retain) ASINetworkQueue *workQueue;

- (DownloadInfo *)firstWaitingFile;

- (void)modifyQueueDownloadInfo:(DownloadInfo *)info;
- (void)removeQueueDownloadInfo:(DownloadInfo *)info;

@property(nonatomic, assign) NSInteger allSignCount;

@end

@implementation DownloadManager

DefaultInstanceForClass(DownloadManager);

- (id)init
{
    if (self = [super init])
    {
        NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
        if (![nd valueForKey:DownloadCountKey])
            self.downloadCount = 5;
        else
            self.downloadCount = [[nd valueForKey:DownloadCountKey] integerValue];
        //[self resetDownloadFileList];
    }
    
    return self;
}

- (NSMutableArray *)downloadFiles
{
    if (!_downloadFiles)
        _downloadFiles = [[NSMutableArray alloc] init];
    return _downloadFiles;
}

- (ASINetworkQueue *)workQueue
{
    if (!_workQueue)
    {
        _workQueue = [[ASINetworkQueue alloc] init];
        [_workQueue setDelegate:self];
        [_workQueue setDownloadProgressDelegate:self];
        [_workQueue setShowAccurateProgress:YES];
        [_workQueue setRequestDidFailSelector:@selector(downloadFail:)];
        [_workQueue setRequestDidFinishSelector:@selector(downloadFinished:)];
        [_workQueue go];
    }
    return _workQueue;
}

// 重置文件下载列表
- (void)resetDownloadFileList
{
    self.downloadFiles = nil;
    self.allSignCount = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 查找所有未下载的签名图片
    NSArray *signFiles = [[DataManager defaultInstance] allSignPics];
    for (Client_signpic *signFile in signFiles)
    {
        if ([signFile.signpic_serverpath length])
        {
            if (![fileManager fileExistsAtPath:signFile.signpic_path])
            {
                self.allSignCount ++;
                // 添加到下载列表中
                DownloadInfo *info = [[DownloadInfo alloc] init];
                info.serverPath = signFile.signpic_serverpath;
                info.localPath = signFile.signpic_path;
                info.status = DownLoadStatusWaitingDownload;
                info.fileID = signFile.signpic_id;
                info.fileType = 0;
                [self.downloadFiles addObject:info];
            }
        }
    }
    
    NSArray *files = [[DataManager defaultInstance] allFiles];
    for (Client_file* file in files)
    {
        BOOL needDownload = NO;
        if (![fileManager fileExistsAtPath:file.phsical_filename])
        {
            needDownload = YES;
            // 为了显示正确的状态，将本地版本置为0
            file.local_version = @(0);
        }
        else if ([file.local_version intValue] < [file.server_version intValue])
        {
            // 如果本地版本小于服务器版本，则进行下载
            needDownload = YES;
        }
        
        if (needDownload)
        {
            // 添加到下载列表中
            DownloadInfo *info = [[DownloadInfo alloc] init];
            info.serverPath = [NSString stringWithFormat:@"%@%@", APIBaseDownload, file.file_id];
            info.localPath = file.phsical_filename;
            info.status = DownloadStatusNoStarted;
            info.fileID = file.file_id;
            info.fileType = 1;
            [self.downloadFiles addObject:info];
        }
    }
}

- (void)startDownload
{
    if (![self.downloadFiles count] || [CAAppDelegate sharedDelegate].offlineMode)
    {
        DebugLog(@"no files need to download");
        // [[NSNotificationCenter defaultCenter] postNotificationName:DownloadSignFileUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SignPicUpdateCompleteNotification object:nil];
        return;
    }
    
    if (self.workQueue.operationCount >= self.downloadCount) {
        DebugLog(@"download queue have max count, can't start new");
        return;
    }
    
    DownloadInfo *info = [self firstWaitingFile];
    if (info)
    {
        ASIHTTPRequest *downRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:info.serverPath]];
        [downRequest setDownloadDestinationPath:info.localPath];
        NSString *fileName = [info.localPath fileNameInPath];
        NSString *tempPath = [NSString stringWithFormat:@"%@/%@.download",[DataManager defaultInstance].userPath, fileName];
        [downRequest setTemporaryFileDownloadPath:tempPath];
        [downRequest setAllowResumeForFileDownloads:YES];
        [downRequest setDelegate:self];
        [downRequest setDownloadProgressDelegate:info];
        // [downRequest setTimeOutSeconds:5];
        [downRequest setShouldContinueWhenAppEntersBackground:YES];
        [downRequest setUserInfo:@{DownloadInfoKey: info}];
        [self.workQueue addOperation:downRequest];
        info.status = DownloadStatusDownloading;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SignPicUpdateCompleteNotification object:nil];
    }
    
    if (self.workQueue.requestsCount < self.downloadCount && [self firstWaitingFile])
    {
        [self performBlock:^{
            [self startDownload];
        } afterDelay:.1f];
    }
}

- (void)clearDownload
{
    self.downloadFiles = nil;
    for (ASIHTTPRequest *downRequest in self.workQueue.operations)
    {
        [downRequest clearDelegatesAndCancel];
        [[NSFileManager defaultManager] removeItemAtPath:downRequest.temporaryFileDownloadPath error:nil];
    }
    self.workQueue = nil;
}

// 文件是否正在下载
- (DownloadStatus)downloadingWithFile:(NSString *)fileID
{
    DownloadStatus status = DownloadStatusNoStarted;
    for (DownloadInfo *info in self.downloadFiles)
    {
        if ([info.fileID isEqualToString:fileID]) {
            status = info.status;
        }
    }
    return status;
}

- (BOOL)pauseDownloadingWithFile:(NSString *)fileID
{
    BOOL pause = NO;
    ASIHTTPRequest *pauseRequest = nil;
    for (ASIHTTPRequest *downRequest in self.workQueue.operations)
    {
        DownloadInfo *info = [downRequest.userInfo objectForKey:DownloadInfoKey];
        if ([info.fileID isEqualToString:fileID])
            pauseRequest = downRequest;
    }
    
    if (pauseRequest)
    {
        [pauseRequest clearDelegatesAndCancel];

        pause = YES;
        DownloadInfo *downInfo = nil;
        for (DownloadInfo *info in self.downloadFiles)
        {
            if ([info.fileID isEqualToString:fileID])
                downInfo = info;
        }
        
        if (downInfo)
        {
            downInfo.status = DownloadStatusPaused;
            [self.downloadFiles removeObject:downInfo];
            
            // 将该信息添加到下载队列的末尾
            [self.downloadFiles addObject:downInfo];
            
            // 开启下一个文件的下载
            [self performBlock:^{
                [self startDownload];
            } afterDelay:.5f];

        }
    }
    
    return pause;
}

- (void)startDownloadingWithFile:(NSString *)fileID
{
    DownloadInfo *startInfo = nil;
    for (DownloadInfo *info in self.downloadFiles)
    {
        if ([info.fileID isEqualToString:fileID])
            startInfo = info;
    }
    
    if (startInfo)
    {
        // 先将下载信息从队列中移除
        [self.downloadFiles removeObject:startInfo];
        
        startInfo.status = DownLoadStatusWaitingDownload;
        
        // 查找未开始下载的文件, 将要下载的文件添加到队列未开始的最前面
        DownloadInfo *noStartInfo = [self firstWaitingFile];
        if (!noStartInfo) {
            if (!self.downloadFiles) {
                self.downloadFiles = [NSMutableArray array];
                [self.downloadFiles addObject:startInfo];
            } else {
                [self.downloadFiles insertObject:startInfo
                                         atIndex:0];
            }
            
        } else {
            int index = [self.downloadFiles indexOfObject:noStartInfo];
            [self.downloadFiles insertObject:startInfo atIndex:index];
        }
        
        // 开启下一个文件的下载
        [self performBlock:^{
            [self startDownload];
        } afterDelay:.5f];
    }
}

- (void)cancelDownloadingWithFile:(NSString *)fileID
{
    DownloadInfo *startInfo = nil;
    for (DownloadInfo *info in self.downloadFiles)
    {
        if ([info.fileID isEqualToString:fileID])
            startInfo = info;
    }
    
    if (startInfo)
    {
        // 先将下载信息从队列中移除
        [self.downloadFiles removeObject:startInfo];
        
        startInfo.status = DownloadStatusNoStarted;
        
        // 将取消下载的文件添加到队列的最后面
        if (!self.downloadFiles)
            self.downloadFiles = [NSMutableArray array];
        
        [self.downloadFiles addObject:startInfo];
    }
}

- (DownloadInfo *)firstWaitingFile
{
    if (![self.downloadFiles count])
        return nil;
    
    for (DownloadInfo *info in self.downloadFiles)
    {
        if (info.status == DownLoadStatusWaitingDownload)
            return info;
    }
    return nil;
}

- (void)downloadFail:(ASIHTTPRequest *)httpRequest
{
    // 修改上一次下载的结果
    DownloadInfo *info = [[httpRequest userInfo] valueForKey:DownloadInfoKey];
    if (info)
    {
        if (info.fileType == 0)
        {
            // 全部签名下载完成
            [self performBlock:^{ [[NSNotificationCenter defaultCenter] postNotificationName:SignPicUpdateCompleteNotification object:nil]; } afterDelay:.0f];
        }
        
        if (![NSThread isMainThread])
        {
            DebugLog(@"current thread is no main thread");
        }
        info.status = DownloadStatusFailed;
        [self modifyQueueDownloadInfo:info];
        [self performBlock:^{
            [self startDownload];
        } afterDelay:.1f];
    }
}

// 下载一个文件完成通知方法
- (void)downloadFinished:(ASIHTTPRequest *)httpRequest
{
    DownloadInfo *info = [[httpRequest userInfo] valueForKey:DownloadInfoKey];
    if (info)
    {
        if (![NSThread isMainThread])
        {
            DebugLog(@"current thread is no main thread");
        }
        
        info.status = DownloadStatusFinished;
        [self modifyQueueDownloadInfo:info];
        [[DataManager defaultInstance] syncLocalVersionToServer:info.fileID];
        
        [self performBlock:^{ [self startDownload]; } afterDelay:.1f];
    }
}

- (void)modifyQueueDownloadInfo:(DownloadInfo *)info
{
    for (DownloadInfo *downloadinfo in self.downloadFiles)
    {
        if ([downloadinfo.fileID isEqualToString:info.fileID])
            downloadinfo.status = info.status;
    }
}

- (void)removeQueueDownloadInfo:(DownloadInfo *)info
{
    DownloadInfo *removeInfo = nil;
    for (DownloadInfo *downloadinfo in self.downloadFiles)
    {
        if ([downloadinfo.fileID isEqualToString:info.fileID])
            removeInfo = downloadinfo;
    }
    
    if (removeInfo)
    {
        [self.downloadFiles removeObject:removeInfo];
    }
}


@end
