//
//  DataManager+SignPic.h
//  esapsign
//
//  Created by 苏智 on 14-9-15.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (SignPic)

// 从服务器同步添加一个签名文件信息
- (Client_signpic *)syncSignPicWithDict:(NSDictionary *) dict;

// 返回所有签名文件
- (NSMutableArray *)allDefaultSignPics;

// 添加一个签名图片
- (Client_signpic *)addSignWithPath:(NSString *)signFilePath withID:(NSString*)givenID;

// 删除签名(By Yi Minwen)
- (void)deleteSignFile:(Client_signpic *)signToDel;

// 清除本地签名文件
- (void)clearLocalSignFile;

@end
