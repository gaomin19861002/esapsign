//
//  ClientContentInEdit.h
//  PdfEditor
//
//  Created by Yi Minwen on 14-6-22.
//  Copyright (c) 2014年 MinwenYi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Client_content;

@interface ClientContentInEdit : NSObject

@property (nonatomic, copy) NSString *content_id;
@property (nonatomic, assign) NSInteger contentType;
@property (nonatomic, copy) NSString *contentValue;
@property (nonatomic, assign) NSInteger major;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *account_id;

/*!
 条目类型名称
 */
@property(nonatomic, copy) NSString *contentTypeName;

- (id)initWithClientContent:(Client_content *)item;

- (id)initWithContentTitle:(NSString *)title
               contentType:(UserContentType)contentType
              contentValue:(NSString *)contentVlaue
                     major:(BOOL)major;

/*!
 从Client_content 初始化 ClientContentInEdit
 */
+ (NSMutableArray *)contentsInEditFromArray:(NSArray *)arrContents;

@end