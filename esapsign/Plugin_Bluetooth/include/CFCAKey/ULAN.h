//
//  ULAN.h
//  ULANToolKit
//
//  Created by LiChuang on 9/23/13.
//  Copyright (c) 2013 cfist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ULANDelegate.h"

#define CERT_TYPE_SM2_CFIST         @"SM2"
#define CERT_TYPE_RSA1024_CFIST     @"RSA1024"
#define CERT_TYPE_RSA2048_CFIST     @"RSA2048"

#define HASH_ALGORITHM_SHA1         @"SHA1"
#define HASH_ALGORITHM_SHA256       @"SHA256"
#define HASH_ALGORITHM_MD5          @"MD5"
#define HASH_ALGORITHM_SM3          @"SM3"

#define SIGN_TYPE_PKCS1                  @"PKCS1"
#define SIGN_TYPE_PKCS7_DETACHED         @"PKCS7_DETACHED"
#define SIGN_TYPE_PKCS7_ATTACHED         @"PKCS7_ATTACHED"


#define CFIST_LOG_LEVEL_PRINT  0
#define CFIST_LOG_LEVEL_RAM    1
#define CFIST_LOG_LEVEL_FILE   2

@interface CFISTCertificate : NSObject
-(id)initWith:(NSData*)certData errMsg:(NSString **)errMsg;

@property (readonly) NSData      *certEncode;
@property (readonly) NSString    *serialNumber;
@property (readonly) NSString    *issuerDN;
@property (readonly) NSDate      *notBefore;
@property (readonly) NSDate      *notAfter;
@property (readonly) NSString    *subjectDN;

@end


@interface ULAN : NSObject

//cert in connected ULAN key, it will be nil until fetchCert() be called
@property (strong,readonly) CFISTCertificate      *cert;

/**
 *  get the instance of CFISTBluetoothKey,which implements singleton mode
 *
 *  @param delegator     the delegator that implements callback
 *
 *  @return  instance of CFISTBluetoothKey
 */
+ (ULAN *)sharedBluetoothKey :(id<ULANDelegate> )delegator;


/**
 *
 *  @return is connected with the CFIST bluetooth key
 */
-(BOOL) isConnected;


/**
 *  scan and try to connect the CFIST bluetooth key
 */
-(void) connectKey:(NSString *)keyID;

/**
 *  disconnection initiative, such when the user cancel the operation
 */
-(void) disConnect;

/**
 *   sign data
 *
 *  @param dataToSign data to sign
 *  @param pin        pinCode
 *  @param certType   sm2,rsa1024,rsa2048
 *  @param hashAlgorithm   SM3,SHA1,SHA256
 *  @param signType   PKCS1,PKCS7_DETACHED,PKCS7_ATTACHED
 *  @param isExternalHash if YES:dataToSign is hash and signType can't be PKCS7_ATTACHED
 *  @return ok 0 ,fail errcode
 */
-(void) sign:(NSData *)dataToSign
         pin:(NSString *)pin
    signType:(NSString *)signType
hashAlgorithm:(NSString *)hashAlgorithm
    certType:(NSString *)certType
isExternalHash:(BOOL)isExternalHash;

/**
 *  fetch certifate from ulan key
 */
-(void) fetchCert:(NSString *)certType;

/**
 *  set logging level
 *
 *  @param logLevel 0:just print,1 log:to ram,2:log to file.
 */
+(void) setLogLevel:(int) logLevel;

/**
 *
 *  @return recent logging,include .log file's data
 */
+(NSString*) getRecentLog;


+ (NSString *)getVersion;

@end



