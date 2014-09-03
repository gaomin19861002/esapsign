//
//  DocDetailViewController.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_file.h"
#import "Client_target.h"
#import "SignatureClipListView.h"
#import "SignerFlowInsideView.h"
#import "cassidlib.h"

@interface DocDetailViewController : UIViewController<CASDKDrawDelegate, SignatureClipViewDelegate, SignatureClipListViewDelegate, UIWebViewDelegate>
{
    SignatureClipListView *signsListView;
    SignatureClipView *curDragSignView;

@public
    // 是否正在创建新签名
    BOOL bCreateNewSign;
    
    // 对应的文件数据结构
    Client_target *clientTarget;
    
    // 当前签名的签名包对象
    Client_sign* currentSign;
}

// 背景容器视图
@property (retain, nonatomic) IBOutlet UIView *backgroundView;

// 直接签署UID
@property (strong, nonatomic) IBOutlet UIView *directSignView;

// 用于展示PDF内容的视图
@property (retain, nonatomic) IBOutlet UIWebView *documentDisplayView;

// 用于放置签名工具栏
@property (retain, nonatomic) IBOutlet UIView *operationBgView;

// 用户放置签名流列表
@property (retain, nonatomic) IBOutlet SignerFlowInsideView *signFlowView;

// 提交签名结果
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

/**
 * @abstract Operating buttons' actions
 */
- (IBAction)colorSelected:(id)sender;
- (IBAction)penSelected:(id)sender;

/**
 * Command buttons' actions
 */
- (IBAction)toolClear:(id)sender;
- (IBAction)toolUndo:(id)sender;
- (IBAction)toolSubmit:(id)sender;

/**
 * @abstract 导航取消返回
 */
- (IBAction)cancelButtonClicked:(id)sender;

/**
 * @abstract 完成操作按钮
 */
- (IBAction)submitButtonClicked:(id)sender;

// 文档是否可以编辑
@property (assign, nonatomic) BOOL editable;

@end
