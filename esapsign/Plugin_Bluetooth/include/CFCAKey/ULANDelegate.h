//
//  CFISTBTKeyDelegate.h
//  BLEKeyDemo
//
//  Created by LiChuang on 8/26/13.
//  Copyright (c) 2013 cfist. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CFISTCertificate;

//error type
#define CFIST_OK         0
#define CFIST_ERROR_INVALID_PARAMETER           -1
#define CFIST_ERROR_INVALID_PIN                 -2
#define CFIST_ERROR_KEY_OKBUTTON_SIGN_TIMEOUT   -3
#define CFIST_ERROR_KEY_OKBUTTON_PIN_TIMEOUT    -4
#define CFIST_ERROR_KEY_RESPONSE_TIMEOUT    -5
#define CFIST_ERROR_BLE_CONNECTION          -6
#define CFIST_ERROR_BLE_COMMUNICATION       -7
#define CFIST_ERROR_INTERNAL_RUNTIME        -8
#define CFIST_ERROR_KEY_UNEXPECTED_RETURN   -9
#define CFIST_ERROR_KEY_BUSY                -10
#define CFIST_ERROR_UNKNOW                  -99


@interface CFISTError : NSObject

+(CFISTError*)errorWith:(int)errorCode state:(int)state errorMsg:(NSString*)errorMsg;
+(CFISTError*)errorWith:(int)errorCode state:(int)state underlyErrorData:(NSData*)underlyErrorData errorMsg:(NSString*)errorMsg;

@property (nonatomic) int errorCode;
//if errorType is CFIST_ERROR_INVALID_PIN,the key will be locked after try another pinCanRetries times;
@property (nonatomic) int pinCanRetries;
//if  errorType is CFIST_ERROR_KEY_UNEXPECTED_RETURN,underlyErrorData is underly errorcode
@property (nonatomic,strong) NSData* underlyErrorData;

@property (nonatomic) int currentStatus;
@property (nonatomic,strong) NSString* errorMessage;

-(NSString*)toString;
@end


@protocol ULANDelegate

/**
 *  called when CFIST BlueTooth Key connected,
 *
 *  @param errCode : nil is ok
 */
-(void) didConnected:(CFISTError*)err;

/**
 *  called when Key disConnected,
 *
 *  @param errCode :nil is ok
 */
-(void) didDisConnected:(CFISTError*)err ;


/**
 *
 *  @param errCode   : nil is ok
 *  @param signature :the signature by the key
 */
-(void) didSigned:(CFISTError*)err result:(NSString *)signature;

//
-(void) didCertFetched:(CFISTError*)err  cert:(CFISTCertificate *)cert;


@end
