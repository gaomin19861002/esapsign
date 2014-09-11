//
//  Client_file.m
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "Client_file.h"
#import "Client_sign_flow.h"
#import "Client_target.h"
#import "Client_sign.h"
#import "DataManager.h"
#import "DownloadManager.h"

@interface Client_file()

/*!
 返回指定id的签名流对象
 */
- (Client_sign_flow *)signFlowWithID:(NSString *)flowID;

@end


@implementation Client_file

@dynamic download_size;
@dynamic file_id;
@dynamic file_type;
@dynamic local_version;
@dynamic locker_account_id;
@dynamic owner_account_id;
@dynamic phsical_backup_filename;
@dynamic phsical_filename;
@dynamic record_references;
@dynamic server_version;
@dynamic sign_flow_id;
@dynamic sign_status;
@dynamic store_type;
@dynamic total_size;
@dynamic trans_filename;
@dynamic upload_size;
@dynamic version;
@dynamic version_guid;
@dynamic clientTarget;
@dynamic currentSignflow;
@dynamic clientTargets;

/*!
 添加一个用户到签名流程
 */
- (Client_sign *)addUserToSignFlow:(NSString *)userName address:(NSString *)address {
    return [[DataManager defaultInstance] addFileSignFlow:self displayName:userName address:address];
}

- (BOOL)removeClientSign:(Client_sign *)sign {
    return [[DataManager defaultInstance] removeClientSign:sign
                                            fromClientFile:self];
}

- (FileStatus)fileStatus {
    FileStatus status = FileStatusFinished;
    int serverVersion = [self.server_version intValue];
    int localVersion = [self.local_version intValue];
    if (serverVersion == localVersion) {
        status = FileStatusFinished;
    } else if (serverVersion > localVersion) {
        DownloadStatus dstatus =[[DownloadManager defaultInstance] downloadingWithFile:self.file_id];
        
        if (dstatus == DownloadStatusDownloading) {
            status = FileStatusDownloading;
        } else if (dstatus == DownloadStatusNoStarted){
            status = FileStatusNotStarted;
        } else if (dstatus == DownLoadStatusWaitingDownload) {
            status = FileStatusWaitingDownload;
        } else if (dstatus == DownloadStatusPaused) {
            status = FileStatusPauseDownload;
        } else if (dstatus == DownloadStatusFailed) {
            status = FileStatusWaitingDownload;
        }
    } else if (serverVersion < localVersion) {
#warning TODO Upload Status
    }
    
    return status;
}

#pragma -
#pragma mark Private Methods
/*!
 返回指定id的签名流对象
 */
- (Client_sign_flow *)signFlowWithID:(NSString *)flowID {
    
    
    return nil;
}

@end
