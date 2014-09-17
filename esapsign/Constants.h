//
//  Constants.h
//  PdfEditor
//
//  Created by Liuxiaowei on 14-3-30.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#ifndef CONSTANTS_H_
#define CONSTANTS_H_

#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)

#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)

/*!
 定义签名流程中包含的签名人最大值
 */
#define MaxSignMembers  6

/*!文档管理页面的更新通知 */
#define DocViewUpdateNotification           @"DocViewUpdateNotification"

/**  通讯录成员删除通知 */
#define ContactUpdateNotification           @"ContactUpdateNotification"

/**  通讯录成员删除通知 */
#define ContactDeleteNotification           @"ContactDeleteNotification"

/*! 通信录导入成功通知 */
#define ContactImportSucceedNotification    @"ContactImportSucceedNotification"

/*! 定义同步更新完成通知 */
#define SyncUpdateFinishedNotification      @"UpdateFinishedNotificatioin"

/*! 定义动作提交成功通知 */
#define ActionSubmitSucceedNotification     @"ActionSubmitSucceedNotification"

/* 清空缓存后完成的通知 */
#define ClearCacheFinishedNotification      @"ClearCacheFinishedNotification"

/*! 定义下载进度通知 */
#define DownloadProgressUpdateNotification  @"DownloadProgressUpdate"

/*! 下载完成通知 */
#define DownloadStatusChangedNotification   @"DownloadStatusChanged"

/*! 下载完签名文件，发出更新通知 */
#define SignPicUpdateCompleteNotification   @"SignPicUpdateCompleteNotification"

//-------------------------------------------------------------------------------------------------------------------------------------------------------------/

/*!定义拿到文件签名锁的超时时间 */
#define SignLockTimeOut 5*1000*60*6

/*! 用户注册的网址 */
#define REGISTERWEBURL @"http://www.e-contract.cn/user/register.html"

/*! 需要创建手写签名的通知 */
#define NeedCreateHandSignNotification @"NeedCreateHandSignNotification"

/*!
 定义签名流程签署状态标签
 */
typedef NS_ENUM(NSInteger, SignProgressStatus)
{
    SignProgressFail = 0,
    SignProgressOK = 1,
    SignProgressInProgress = 2
};

/*!
 定义文件类型
 */
typedef NS_ENUM(NSInteger, FileExtendType) {
    FileExtendTypeUnknown = 0,
    FileExtendTypePdf = 1,
    FileExtendTypeTxt = 2,
    FileExtendTypeImage = 3
};

/*!
 定义文件状态
 */
typedef NS_ENUM(NSInteger, FileDownloadStatus) {
    FileStatusFinished = 0,
    FileStatusNotStarted = 1,
    FileStatusWaitingDownload = 2,
    FileStatusDownloading = 3,
    FileStatusPauseDownload = 4,
    FileStatusWaitingUpload = 5,
    FileStatusUploading = 6,
    FileStatusPauseUpload = 7
};

/*!
 定义target类型
 */
typedef NS_ENUM(NSInteger, TargetType) {
    TargetTypeSystemFolder = 0,
    TargetTypeUserFolder = 1,
    TargetTypeFile = 2,
};

/*!
 定义用户信息的标签类型
 */
typedef enum
{
    UserContentTypeEmail = 0,
    UserContentTypePhone = 1,
    UserContentTypeAddress = 2
} UserContentType;

/*
 使用颜色的宏
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/*!
 定义用户按字母排序
 */
#define ALPHA @"常_abcdefghijklmnopqrstuvwxyz"

/*!
 定义通讯录导入提醒的key
 */
#define ContactImportDisabledAskedKey @"ContactImportDisabledAsked"

/*!
 定义登录用户的key
 */
#define LoginUser @"LoginUser"

/*!
 下载信息key
 */
#define DownloadInfoKey @"downloadInfo"


#define SignFailMessage @"由于网络原因，签名失败！"

#if !__has_feature(objc_arc)
// Safe releases
#define InvalidateTimer(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }

//iOS 4 and above. to avoid retain cycles
#define BlockWeakObject(obj, wobj)  __block __typeof__((__typeof__(obj))obj) wobj = obj
#define BlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = [[obj retain] autorelease]
#else // !__has_feature(objc_arc)
// Safe releases
#define InvalidateTimer(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

//iOS 4 and above. to avoid retain cycles
#define BlockWeakObject(obj, wobj)  __weak __typeof__((__typeof__(obj))obj) wobj = obj
#define BlockStrongObject(obj, sobj) __typeof__((__typeof__(obj))obj) sobj = obj
#endif // !__has_feature(objc_arc)

#endif
