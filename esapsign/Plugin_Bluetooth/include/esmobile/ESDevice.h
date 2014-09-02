/*!
 @header ESDevice.h
 @abstract 文鼎创iOS中间件标准接口
 @author 陆振文 on 14-3-28
 @copyright Copyright (c) 2014年 excelsecu. All rights reserved.
 @version 1.00
 */

#import <Foundation/Foundation.h>
#import "ESTypeDefs.h"

/*!
 @enum
 @abstract     描述device的链接状态
 @discussion   该状态在ESDevice 委托中使用，用来判断device的连接状态
 
 @constant     kESDeviceStateConnected device已连接
 @constant     kESDeviceStateDisconnected device断开连接
 @constant     kESDeviceStateConnecting device正在链接
 
 @author       陆振文
 @version      1.0
 */
enum ESDeviceConnectionState{
    kESDeviceStateConnected,
    kESDeviceStateDisconnected,
    kESDeviceStateConnecting
};

typedef enum ESDeviceConnectionState  ESDeviceConnectionState;



/*!
 @protocol
 @abstract  device操作的上层接口，一个device代表一个连接上的U盾
 @discussion
 @author       陆振文
 @version      1.0
 */
@protocol ESDevice <NSObject>

@required


/*!
 @method
 @abstract    获取当前状态
 @return      当前状态
 */
-(ESDeviceConnectionState) state;


/*!
 @method
 @abstract    获取deviceId
 @return      deviceId
 */
-(NSInteger) deviceId;

///*!
// @method
// @abstract    连接device
// @return      YES如果链接成功，否则NO
// */
//-(BOOL) connect;

/*!
 @method
 @abstract 获取设备类型
 @return   设备类型
 @see  ESDeviceType
 */
-(ESDeviceType)type;


/*!
 @method
 @abstract    断开device连接
 @return      YES如果断开成功，否则NO
 */
-(BOOL) disconnect;

/*!
 @method
 @abstract    device是否已连接
 @return      YES如果已连接，否则返回NO
 */
-(BOOL) isConnected;

/*!
 @method
 @abstract    获取最后一次操作的错误码
 @return      最后一次操作的错误码
 */
-(ESError) lastErrorCode;


/*!
 @method
 @abstract    获取最后一次操作的错误描述信息
 @return      最后一次操作的错误描述信息，无错误返回nil
 */
-(NSString *) lastErrorMessage;

/*!
 @method
 @abstract    修改用户PIN 需要用户点击Key上的&lt;确定&gt;按钮
 
 @param       pinType    pin类型
 @param       newPin     新的PIN
 @param       oldPin     原来的PIN
 @return      YES如果修改成功，否则NO 可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(BOOL) changePin:(ESPinType)pinType oldPin:(NSString *)oldPin newPin:(NSString *) newPin;

/*!
 @method
 @abstract    获取密钥列表，可能列表为空
 
 @param       keyPairType     密钥算法标示
 @return      NSNumber数组：如果获取成功，否则nil； 可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSArray *) keyPairList:(ESKeyPairType) keyPairType;

/*!
 @method
 @abstract    读取序列号
 
 @return      成功则返回序列号，失败则返回nil;可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSString *) mediaId;

/*!
 @method
 @abstract    获取用户PIN重试次数
 
 @return      成功则返回重试次数，失败则返回-1，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSInteger) pinRetryCount;

/*!
 @method
 @abstract    获取用户PIN相关信息
 
 @param       pinType  pin类型
 @param       mPinRetry  剩余重试次数
 @param       mMaxRetry  最多重试次数
 @return      成功则返回YES，失败则返回NO，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(BOOL) getPinInfo:(ESPinType) pinType pinRetry:(NSInteger *)mPinRetry maxRetry:(NSInteger *)mMaxRetry hasModifiedBefore:(BOOL *)hasModified;

/*!
 @method
 @abstract    读取证书 有可能当前密钥对所在位置没有证书
 @param       keyPairIndex  密钥索引
 @return      成功则返回证书数据，失败则返回nil，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSData *) readCertificate:(NSInteger) keyPairIndex;

/*!
 @method
 @abstract    设置字符编码
 @param       charset  字符编码，如@“UTF-8”、@“GBK” etc
 */
-(BOOL)	setCharset:(NSString *)charset;


/*!
 @method
 @abstract    对Hash值进行签名
 @param       keyPairIndex
 @param       hashAlgId
 @param       hashValue
 @return      签名数据，失败则返回nil，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSData *) signHashValue:(NSInteger) keyPairIndex algorithm:(ESAlgorithm)hashAlgId  hashValue:(NSData *)hashValue;

/*!
 @method
 @abstract    对Hash值进行签名
 @param       keyPairIndex   密钥对下标
 @param       hashAlgId      算法
 @param       string      哈希字符串
 @param       encoding  字符编码
 @return      签名数据，失败则返回nil，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSData *) signHashValue:(NSInteger) keyPairIndex algorithm:(ESAlgorithm)hashAlgId  hashSting:(NSString *)string stringEncoding:(NSStringEncoding)encoding;

/*!
 @method
 @abstract    签名报文 由Key对报文进行Hash
 @param       keyPairIndex    密钥对下标
 @param       hashAlgId       算法
 @param       message         报文
 @param       encoding  字符编码
 @return      签名数据，失败则返回nil，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(NSData *) signMessage:(NSInteger) keyPairIndex algorithm:(ESAlgorithm)hashAlgId message:(NSString *)message stringEncoding:(NSStringEncoding)encoding;

/*!
 @method
 @abstract    签名数据 由Key对数据进行Hash
 @param       keyPairIndex
 @param       hashAlgId
 @param       data
 @return      签名数据，失败则返回nil，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */

-(NSData *) signMessage:(NSInteger) keyPairIndex algorithm:(ESAlgorithm)hashAlgId data:(NSData *)data;

/*!
 @method
 @abstract    认证用户PIN 在PinRetry &lt;= N 的情况下，需要用户点击Key上的&lt;确认&gt;按钮 N为可配置参数
 @param       pinType  pin类型
 @param       pin
 @return      YES校验成功，否则返回NO，可以通过 lastErrorCode|lastErrorMessage 方法获取错误信息
 */
-(BOOL)	verifyPin:(ESPinType)pinType pin:(NSString *) pin;


/*!
 @method
 @abstract 非对称算法解密
 
 @param    keyPairIndex 密钥对下标
 @param    encryptedData 密文数据
 @return   解密后的数据
 */
-(NSData *)	asymDecrypt:(NSInteger) keyPairIndex data:(NSData *)encryptedData;

/*!
 @method
 @abstract 非对称算法加密
 
 @param    keyPairIndex 密钥对下标
 @param    data 明文数据
 @return   加密后的数据
 */
-(NSData *)	asymEncrypt:(NSInteger) keyPairIndex data:(NSData *)data;

@end




/*!
 @protocol
 @abstract     device链接状态委托
 @discussion   该委托在 ESDeviceManager 中使用
 
 @author       陆振文
 @version      1.0
 @see          ESDeviceManager
 */
@protocol ESDeviceConnectionStateDelegate <NSObject>

@required
/*!
 @method
 
 @abstract     device连接委托,委托方法在UI线程中调用
 @param        device  每次事件触发都会返回一个Device接口，可通过 (ESDeviceConnectionState)[device state]来获取设备的链接状态，或者通过[device isConnected]来判断是否连上
 
 @author       陆振文
 @version      1.0
 */
-(void) onDeviceConnectionStateDidChanged:(id<ESDevice>)device;

@end

