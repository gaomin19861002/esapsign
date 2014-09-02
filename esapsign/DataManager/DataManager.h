//
//  DataManager.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Client_sign_flow.h"
#import "Client_target.h"
#import "Client_file.h"
#import "Client_user.h"
#import "Client_signfile.h"
#import "Client_content.h"
#import "Client_sign.h"
#import "Client_account.h"
#import "User.h"

#define DBFileName  @"clientInfo.data"

/*!
 定义EntityName
 */
#define EntityClientTarget      @"Client_target"
#define EntityClientFile        @"Client_file"
#define EntityClientSignFlow    @"Client_sign_flow"
#define EntityClientUser        @"Client_user"
#define EntityClientSignfile    @"Client_signfile"
#define EntityClientContent     @"Client_content"
#define EntityClientSign        @"Client_sign"
#define EntityClientAccount     @"Client_account"

/*!
 数据库管理类
 */

@interface DataManager : NSObject

@property(nonatomic, retain) NSManagedObjectContext *objectContext;
@property(nonatomic, retain) NSManagedObjectModel *objectModel;
@property(nonatomic, retain) NSPersistentStoreCoordinator *storeCoordinator;

/*!
 所有的target对象
 */
@property(nonatomic, retain) NSMutableArray *allTargets;

/*!
 所有的file对象
 */
@property(nonatomic, retain) NSMutableArray *allFiles;

@property(nonatomic, retain) NSMutableArray *allUsers;

@property(nonatomic, retain) NSMutableArray *allSignFiles;

/*!
 用户目录路径
 */
@property(nonatomic, copy) NSString *userPath;

/*!
 返回指定parent_id的所有文件夹
 @param parent_id 父id
 @return 所有的文件夹target
 */
- (NSArray *)foldersWithParentTarget:(NSString *)parent_id;

/*!
 返回指定parent_id下的所有文件
 @param parent_id 父id
 @return 所有的文件target
 */
- (NSArray *)filesWithParentTarget:(NSString *)parent_id;

DefaultInstanceForClassHeader(DataManager);
//ReleaseInstanceForClassHeader;

- (void)saveContext;

/*!
 修改指定Target的显示名称
 */
- (void)modifyTarget:(NSString *)targetID displayName:(NSString *)displayName;

/*!
 返回所有通讯录成员
 */
- (NSMutableArray *)allClientUsers;

/*!
 添加一个通讯录用户
 @param userName 用户名称
 @return 当前用户对象
 */
- (Client_user *)addContactUser:(NSString *)firstName lastName:(NSString *)lastName;

/*!
 添加一条通讯录用户条目
 @param user 指定的用户对象
 @param contextType 条目类型
 @param contextValue 条目的值
 */
- (void)addContent:(Client_user *)user
      contentTitle:(NSString *)title
       contentType:(UserContentType)contentType
      contentValue:(NSString *)contentVlaue
             major:(BOOL)major;


/*!
 生成一条新的条目信息
 @param user 指定的用户对象
 @param contextType 条目类型
 @param contextValue 条目的值
 */
- (Client_content *)insertContentWithUser:(Client_user *)user
                             contentTitle:(NSString *)title
                              contentType:(UserContentType)contentType
                             contentValue:(NSString *)contentVlaue
                                    major:(BOOL)major;

/**
 *  修改指定通讯录成员名称
 *
 *  @param userID    用户id
 *  @param displayName 新的昵称
 */
- (void)modifyUser:(NSString *)userID withFirstName:(NSString *)firstName familyName:(NSString *)familyName;

/*!
 添加一个目录
 */
- (void)addFolder:(NSString *)name parentID:(NSString *)parentID;

/*!
 同步写入一个target
 */
- (Client_target*)syncTarget:(NSDictionary *)dictTargetValue;

/*!
 同步写入一个file
 */
- (Client_file*)syncFile:(NSDictionary *)dictFileValue;

/*!
 重置所有Target，一般同步时，从服务器更新获取全部Target列表需要先做此操作。
 */
- (void)resetTarget;

/*!
 删除目录及子目录
 */
- (void)deleteFolders:(NSString *)clientID;

/*!
 添加一个文件
 */
- (void)addFile:(FileExtendType)type
    displayName:(NSString *)displayName
           path:(NSString *)path
       parentID:(NSString *)parentID;

/*!
 更新指定文件的本地版本为server版本，主要应用于下载完成
 @param fileID 文件id
 */
- (void)syncLocalVersionToServer:(NSString *)fileID;

/**
 *  返回所有签名文件(By Yi Minwen)
 *
 *  @return
 */
- (NSMutableArray *)allDefaultSignFiles;

/**
 *  添加一个签名(By Yi Minwen)
 *
 *  @param signFilePath 签名文件路径
 */
- (Client_signfile *)addSignWithPath:(NSString *)signFilePath withID:(NSString*)givenID;

/*!
 添加一个签名文件信息
 */
- (Client_signfile* )syncSignFileInfo:(NSString *)fileId serverPath:(NSString *)serverPath;

/*!
 *  @abstract   从服务器同步添加一个签名文件信息
 *  @param dict
 */
- (Client_signfile *) syncSignFileWithDict:(NSDictionary *) dict;

/*!
 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 */
- (Client_user *)syncSignUser:(NSString *)address displayName:(NSString *)displayName;

/*!
 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 */
- (Client_user *)syncSignUser:(NSString *)address displayName:(NSString *)displayName userid:(NSString *) userid;

/*!
 *  @abstract 同步一个签名信息，如果不存在则添加，如果存在，则更新签名表中的displayName
 *  @param  contentType:条目类型（0：email，1：电话号码，2：文字信息）
 *  @return Client_user对象，如果没找到，则返回nil。
 */
- (Client_user *) syncUser:(NSString *) contentType andValue:(NSString *) contentValue;

/*!
 *  @abstract 根据id找对应的用户
 *  @param  userid NSString对象 用户的id
 *  @return Client_user对象
 */
- (Client_user *) findUserWithId:(NSString *) userid;

/*!
 *  @abstract 根据signerAddress找对应的用户
 *  @param  address NSString对象 用户的签约地址（目前为只支持邮件，以后还会支持电话短信）
 *  @return Client_user对象
 */
- (Client_user *) findUserWithAddress:(NSString *) address;

/*!
 *  @abstract 创建一个用户，并添加到数据库中
 *  @param
 *  @return Client_user对象
 */
- (Client_user *) createUserWithDictionary:(NSDictionary *) dict;

/*!
 *  @abstract 创建并添加一个ClientContent
 *  @param user Client_user对象，用于关联。 dict Dictionary对象，用于设置值Client_content的值。
 *  @return Client_user对象
 */
- (Client_content *) addContentWithUser:(Client_user *) user content:(NSDictionary *) dict;
/*!
 *  @abstract 清除Client_user的所有联系方式
 *  @param user 要清除联系方式的Client_user对象
 *  @return Client_user对象
 */
- (void) clearAllContent:(Client_user *) user;

/**
 *  删除签名(By Yi Minwen)
 *
 *  @param signToDel 签名文件
 */
-(void)deleteSignFile:(Client_signfile *)signToDel;

-(Client_user *)addContactWithName:(NSString *)contactName;

/*!
 获取5个常用联系人
 */
- (NSArray *)lastestConstacts;

/*!
 添加一个用户到指定文件的签名流程中
 */
- (Client_sign *)addFileSignFlow:(Client_file *)file
                     displayName:(NSString *)displayName
                         address:(NSString *)address;

- (BOOL)removeClientSign:(Client_sign *)sign
          fromClientFile:(Client_file *)file;

/*!
 返回指定地址信息的User
 */
- (Client_user *)clientUserWithAddress:(NSString *)address;

/*!
 清除已有的target对象
 */
- (void)clearAllTargets;

/*!
 清除不在使用的文件
 */
- (void)clearUnusedFiles;

/*!
 清除本地所有下载文件
 */
- (void)clearAllLocalFiles;

/*!
 清除本地签名文件
 */
- (void)clearLocalSignFile;

/*!
 清除所有的签流程
 */
- (void)clearAllSignFlow;

/*!
 清除所有的签名人信息
 */
- (void)clearAllSign;

#pragma mark - Clear Cache

/**
 *  @abstract 清空缓存文件
 */
- (void) clearnCaches;

#pragma mark - Client_account Methods

/**
 *  @abstract 根据用户名（登陆账号）匹配用户
 *  @param accountId  NSString 用户登陆的账号。
 */
- (Client_account *) queryAccountByAccountId:(NSString *) accountId;

/**
 *  @abstract 创建一个新的用户信息
 *  @param user User
 */
- (Client_account *) createAccountWithUser:(User *) user;

#pragma mark - ContactDetail

/**
 *  获取与联系人所有相关签名文档(By Yi Minwen)
 *
 *  @param user 相关联系人
 */
-(NSMutableArray *)allTargetsWithClientUser:(Client_user *)user;

/**
 *  删除所有联系人(By gaomin)
 */
-(void)deleteAllClientUsers;

/**
 *  删除联系人(By Yi Minwen)
 *
 *  @param user 相关联系人
 */
-(void)deleteClientUser:(Client_user *)user;

/**
 *  更新联系人条目信息(By Yi Minwen)
 *
 *  @param user 相关联系人
 *  @param userContents 相关条目信息
 */
-(void)updateClientUser:(Client_user *)user WithContents:(NSArray *)userContents;

-(void)removeContents:(NSArray *)userContentsToDel inClientUser:(Client_user *)user;


#pragma mark - MiniDocList

/**
 *  判定是否有对应签名流程(By Yi Minwen)
 *
 *  @param file 当前文件
 */
-(BOOL)hasSignFlowWithClientFile:(Client_file *)file;

#pragma mark - DocDetail

/*!
 保存签名
 @param signFlow 当前signflow
 @param signStatus 签名状态
 */
-(Client_sign* )finishSignFlow:(Client_sign_flow *)signFlow withStatus:(NSNumber *)signStatus;

/*!
 *  清空签名的signdate
 *  @param signFlow 当前signflow
 */
- (Client_sign *) resetSignDate:(Client_sign_flow *) signFlow;

/*!
 是否签名流程已走完
 @param file 签名文件
 @return
 */
- (BOOL)isClientFileFinishedSign:(Client_file *)file;

/*!
 是否当前target具备编辑条件
 目前只有收件箱下的可编辑，其他都不可编辑
 @param target 当前target
 @return 返回可编辑状态
 */
- (BOOL)isClientTargetEditable:(Client_target *)target;

@end
