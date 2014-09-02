//
//  DownloadInfo.m
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DownloadInfo.h"
#import "NSObject+DelayBlocks.h"

@implementation DownloadInfo

- (void)setStatus:(DownloadStatus)status {
    _status = status;
    if (![NSThread isMainThread]) {
        DebugLog(@"current thread is no main thread");
    }
    [self performBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadStatusChangedNotification object:nil userInfo:@{DownloadInfoKey: self}];
    } afterDelay:.0f];
}

#pragma -
#pragma mark ASIProcessDelegate Methods
- (void)setProgress:(float)newProgress {
    self.downloadProgress = newProgress;
    if (![NSThread isMainThread]) {
        DebugLog(@"current thread is no main thread");
    }
    [self performBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadProgressUpdateNotification object:nil userInfo:@{DownloadInfoKey: self}];

    } afterDelay:.0f];
}

@end
