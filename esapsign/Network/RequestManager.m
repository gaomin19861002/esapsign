//
//  BaseData.m
//  esapsign
//
//  Created by Suzic on 14-9-2.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "RequestManager.h"
#import "NSObject+Json.h"
#import "NSString+Additions.h"
#import "CAAppDelegate.h"

#define HttpTimeout 30

@interface RequestManager()<ASIHTTPRequestDelegate>

@property(nonatomic, retain) NSMutableArray *allDelegates;

@end

@implementation RequestManager

DefaultInstanceForClass(RequestManager);

- (NSMutableArray *)allDelegates
{
    if (!_allDelegates) {
        _allDelegates = [[NSMutableArray alloc] init];
    }
    
    return _allDelegates;
}

- (void)registerDelegate:(id<RequestManagerDelegate>) delgate
{
    if (delgate) {
        [self.allDelegates addObject:delgate];
    }
}

- (void)unRegisterDelegate:(id<RequestManagerDelegate>) delgate
{
    if (delgate) {
        [self.allDelegates removeObject:delgate];
    }
}

// 异步向服务器发送数据, 并返回发送请求的实例对象
- (ASIFormDataRequest *)asyncPostData:(NSString *)address Parameter:(NSDictionary *)para
{
    NSURL *rURL = [[NSURL alloc] initWithString:address];
    ASIFormDataRequest *asyncRequest = [[ASIFormDataRequest alloc] initWithURL:rURL];
    
    //for (NSString *key in [para allKeys]) {
    //    [asyncRequest addPostValue:[para objectForKey:key] forKey:key];
    //}
    [asyncRequest setPostBody:(NSMutableData *)[para jsonData]];
    
    /*
    int index = 0;
    NSString* value =nil;
    for (NSString *key in [para allKeys]) {
        value = (NSString*)[para objectForKey:key];
        
        if( index == 0 ) {
            address = [NSString stringWithFormat:@"%@?%@=%@",address,key,value];
        } else {
            address = [NSString stringWithFormat:@"%@&%@=%@",address,key,value];
        }
        index ++;
    }
    
    DebugLog(@"request = %@",address);
    */
    
    [asyncRequest setTimeOutSeconds:HttpTimeout];
    [asyncRequest setDelegate:self];
    [asyncRequest startAsynchronous];
    
    return asyncRequest;
}

// 异步向服务器发送文件，并返回发送请求的实例对象
- (ASIFormDataRequest *)asyncPostData:(NSString *)address file:(NSString *)filePath isPDF:(BOOL)isPDF;
{
    if (![filePath length])
    {
        return nil;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        DebugLog(@"upload file not exist");
        return nil;
    }
    
    NSURL *rURL = [[NSURL alloc] initWithString:address];
    ASIFormDataRequest *asyncRequest = [[ASIFormDataRequest alloc] initWithURL:rURL];
    [asyncRequest setRequestMethod:@"POST"];
    [asyncRequest setTimeOutSeconds:HttpTimeout];
    [asyncRequest setDelegate:self];
    
    NSString *boundary = @"---------------------------7de12b3211498";
    
    [asyncRequest addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]];
    
	NSMutableData *bodyData = [NSMutableData data];

    NSString *formHeader = @"-----------------------------7de12b3211498\r\n";
    [bodyData appendData:[formHeader dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *headerTemplate = isPDF ?
        @"Content-Disposition: form-data; name=\"file_upload\"; filename=\"%@\"\r\nContent-Type: application/%@\r\n":
        @"Content-Disposition: form-data; name=\"file_upload\"; filename=\"%@\"\r\nContent-Type: image/%@\r\n";
    NSString *fileName = [filePath fileNameInPath];
    NSString *fileExtends = [[fileName componentsSeparatedByString:@"."] lastObject];
    NSString *header = [NSString stringWithFormat:headerTemplate, fileName, fileExtends];
    [bodyData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];

    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    [bodyData appendData:fileData];
    
    NSString *formfooter = @"-----------------------------7de12b3211498--\r\n";
    [bodyData appendData:[formfooter dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSUInteger len = [fileData length];
//    for (int i = 0; i < len / 1000; i++) {
//        NSString *formHeader = @"-----------------------------7de12b3211498";
//        [bodyData appendData:[formHeader dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        NSString *headerTemplate = @"Content-Disposition: form-data; name=\"file_upload\"; filename=\"%@\"\r\nContent-Type: \"application/PNG%@\"\r\n";
//        NSString *fileName = [filePath fileNameInPath];
//        NSString *fileExtends = [[fileName componentsSeparatedByString:@"."] lastObject];
//        NSString *header = [NSString stringWithFormat:headerTemplate, fileName, fileExtends];
//        [bodyData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
//        [bodyData appendData:[fileData subdataWithRange:NSMakeRange(i * 1000, 1000)]];
//    }
//    
//    if (len % 1000) {
//        NSUInteger subLen = len % 1000;
//        NSString *formHeader = @"-----------------------------7de12b3211498";
//        [bodyData appendData:[formHeader dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        NSString *headerTemplate = @"Content-Disposition: form-data; name=\"file_upload\"; filename=\"%@\"\r\nContent-Type: \"application/%@\"\r\n";
//        NSString *fileName = [filePath fileNameInPath];
//        NSString *fileExtends = [[fileName componentsSeparatedByString:@"."] lastObject];
//        NSString *header = [NSString stringWithFormat:headerTemplate, fileName, fileExtends];
//        [bodyData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
//        [bodyData appendData:[fileData subdataWithRange:NSMakeRange(len - subLen - 1    , subLen)]];
//    }
//    NSString *formHeader = @"-----------------------------7de12b3211498";
//    [bodyData appendData:[formHeader dataUsingEncoding:NSUTF8StringEncoding]];
//    [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    //[asyncRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [bodyData length]]];
    
	[asyncRequest setPostBody:bodyData];
    [asyncRequest startAsynchronous];
    
    return asyncRequest;
}

#pragma mark - HTTP Delegate Methods

- (void)requestStarted:(ASIHTTPRequest *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<RequestManagerDelegate> delegate in self.allDelegates) {
            if ([delegate respondsToSelector:@selector(asynRequestStarted:)]) {
                [delegate asynRequestStarted:request];
            }
        }
    });
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<RequestManagerDelegate> delegate in self.allDelegates) {
            if ([delegate respondsToSelector:@selector(asynRequestFailed:)]) {
                [delegate asynRequestFailed:request];
            }
        }
    });
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *resString = [request responseString];
        DebugLog(@"res= %@", resString);
        
        NSDictionary *resDict = [resString jsonValue];
        NSDictionary *loginDict = [resDict objectForKey:@"login"];
        if (loginDict && [[loginDict objectForKey:@"result"] intValue] != 1)
        {
            // 跳转到登录界面
            CAAppDelegate *delegate = (CAAppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate popLoginView];
            
            return;
        }
        
        // 检查是否需要跳转到签名页面
        //if (loginDict && [[loginDict objectForKey:@"requireSign"] intValue] == 1)
        //{
            // 需要跳转到签名页
        ///    [[NSNotificationCenter defaultCenter] postNotificationName:NeedCreateHandSignNotification object:nil];
        //}
        
        for (id<RequestManagerDelegate> delegate in self.allDelegates) {
            if ([delegate respondsToSelector:@selector(asynRequestFinished:)]) {
                [delegate asynRequestFinished:request];
            }
        }
    });
}

@end
