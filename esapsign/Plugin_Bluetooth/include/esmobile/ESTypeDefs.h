/*!
 @header  ESTypeDefs
 @abstract  类型定义
 @author    陆振文 on 14-4-2.
 @version   1.0
 */

#ifndef EsMobileInterface_ESTypeDefs_h
#define EsMobileInterface_ESTypeDefs_h



/*!
 @enum
 @abstract  客户类型
 
 @author    陆振文
 @version   1.0
 
 @constant  kESCustomerStandard      标准客户
 @constant  kESCustomerICBC          工行
 @constant  kESCustomerALIPAY
 @constant  kESCustomerCCB           建行
 */
typedef enum ESCustomer{
    kESCustomerStandard,
    kESCustomerICBC,
    kESCustomerALIPAY,
    kESCustomerCCB
}ESCustomer;


//详见 EsDriver.h
//#define AUDIO_PROTOCAL      5
//#define IDOCK_PROTOCAL      6
//#define BT_PROTOCAL         7

/*!
 @enum      ESDeviceType
 @abstract  Device类型
 
 @author    陆振文
 @version   1.0
 
 @constant  kESDeviceAudio      音频Device
 @constant  kESDeviceBluetooth  蓝牙Device
 */
typedef enum ESDeviceType{
    kESDeviceAudio     = 0x01,
    kESDeviceBluetooth = 0x02,
    kESDeviceIDock     = 0x04
}ESDeviceType;




//详见 EsCommon.h
//// 哈希算法ID
//#define	ES_HASH_ALG_MD5		 0x80000001
//#define	ES_HASH_ALG_SHA1	 0x80000002
//#define	ES_HASH_ALG_SHA256	 0x80000003
//#define	ES_HASH_ALG_SHA384   0x80000004
//#define	ES_HASH_ALG_SHA512   0x80000005
//#define	ES_HASH_ALG_SM3		 0x80000006
//#define	ES_HASH_ALG_MD5SHA1	 0x80000007
//
//// 对称算法ID
//#define ES_SYMM_ALG_DES		    0x0001
//#define ES_SYMM_ALG_3DES112	    0x0002
//#define ES_SYMM_ALG_3DES168		0x0004
//#define ES_SYMM_ALG_AES128		    0x0008
//#define ES_SYMM_ALG_AES192		    0x0010
//#define ES_SYMM_ALG_AES256		    0x0020
//#define ES_SYMM_ALG_SSF33		    0x0100
//#define ES_SYMM_ALG_SM1			0x0200
//#define ES_SYMM_ALG_SM4		    0x0400

/*!
 @enum
 @abstract  算法ID
 
 @author    陆振文
 @version   1.0
 
 @constant kESAlgorithmHashMD5
 @constant kESAlgorithmHashSHA1
 @constant kESAlgorithmHashSHA256
 @constant kESAlgorithmHashSHA384
 @constant kESAlgorithmHashSHA512
 @constant kESAlgorithmHashSM3
 @constant kESAlgorithmHashMD5SHA1
 
 // 对称算法
 @constant kESAlgorithmSymmDES
 @constant kESAlgorithmSymm3DES112
 @constant kESAlgorithmSymm3DES168
 @constant kESAlgorithmSymmAES128
 @constant kESAlgorithmSymmAES192
 @constant kESAlgorithmSymmAES256
 @constant kESAlgorithmSSF33
 @constant kESAlgorithmSM1
 @constant kESAlgorithmSM4
 */

typedef enum ESAlgorithm{
    // HASH算法
    kESAlgorithmHashMD5     = 0x80000001,
    kESAlgorithmHashSHA1    = 0x80000002,
    kESAlgorithmHashSHA256  = 0x80000003,
    kESAlgorithmHashSHA384  = 0x80000004,
    kESAlgorithmHashSHA512  = 0x80000005,
    kESAlgorithmHashSM3     = 0x80000006,
    kESAlgorithmHashMD5SHA1 = 0x80000007,
    
    // 对称算法
    kESAlgorithmSymmDES     = 0x0001,
    kESAlgorithmSymm3DES112 = 0x0002,
    kESAlgorithmSymm3DES168 = 0x0004,
    kESAlgorithmSymmAES128  = 0x0008,
    kESAlgorithmSymmAES192  = 0x0010,
    kESAlgorithmSymmAES256  = 0x0020,
    kESAlgorithmSSF33       = 0x0100,
    kESAlgorithmSM1         = 0x0200,
    kESAlgorithmSM4         = 0x0400
}ESAlgorithm;


//详见 OperateError.h
/*!
 @enum
 @abstract  错误码
 
 @constant  kESErrorNoError                              无错误
 @constant  kESErrorNotConnectedAnyDevice                未连接任何设备
 
 @constant  kESErrorCOSInvalidFileType                   文件类型不匹配
 @constant  kESErrorCOSAccessDenied                      安全状态不满足
 @constant  kESErrorCOSInvalidRandom	                 随机数不可用或者引用数据无效
 @constant  kESErrorCOSConditionNotSatisfied             使用条件不满足
 @constant  kESErrorCOSFileNotSelected	                 没有当前文件
 @constant  kESErrorCOSNotProtectedMessage		         缺少安全报文数据对象
 @constant  kESErrorCOSInvalidProtectedMessage           安全报文项不正确
 @constant  kESErrorCOSInvalidAPDUParam			         数据域参数错误(全部错误)
 @constant  kESErrorCOSFunctionUnsupported		         功能不支持
 @constant  kESErrorCOSFileNotFound			             没有找到文件
 @constant  kESErrorCOSRecordNotFound		             没有找到记录
 @constant  kESErrorCOSNoSpace				             缺少剩余空间
 @constant  kESErrorCOSInvalidTLVData		             TLV数据对象不一致
 @constant  kESErrorCOSInvalidP1P2Param			         P1P2参数不正确
 @constant  kESErrorCOSReferencedDataNotFound	         没有找到引用数据
 @constant  kESErrorCOSOutOfBounds				         偏移超出范围
 @constant  kESErrorCOSInvalidINS				         不正确的INS
 @constant  kESErrorCOSInvalidCLA				         不正确的CLA
 @constant  kESErrorCOSPartitionInvalidAPDUParam         数据域参数错误(部分错误)
 
 @constant  kESErrorCOSDeviceRequireInitialize	         设备没有初始化
 @constant  kESErrorCOSDeviceTimeout			         通讯超时或者通讯数据格式错误
 @constant  kESErrorCOSKeyIDNotFound		             没有找到密钥记录
 @constant  kESErrorCOSUserCancelled			         用户取消
 @constant  kESErrorCOSButtonTimeout			         按键超时
 @constant  kESErrorCOSButtonWrong			             按键错误
 @constant  kESErrorCOSHandshakeFail		             建立握手失败
 @constant  kESErrorCOSPasswordRetry15		             密码重试次数15次
 @constant  kESErrorCOSPasswordRetry14		             密码重试次数14次
 @constant  kESErrorCOSPasswordRetry13		             密码重试次数13次
 @constant  kESErrorCOSPasswordRetry12		             密码重试次数12次
 @constant  kESErrorCOSPasswordRetry11		             密码重试次数11次
 @constant  kESErrorCOSPasswordRetry10		             密码重试次数10次
 @constant  kESErrorCOSPasswordRetry9		             密码重试次数9次
 @constant  kESErrorCOSPasswordRetry8		             密码重试次数8次
 @constant  kESErrorCOSPasswordRetry7		             密码重试次数7次
 @constant  kESErrorCOSPasswordRetry6		             密码重试次数6次
 @constant  kESErrorCOSPasswordRetry5		             密码重试次数5次
 @constant  kESErrorCOSPasswordRetry4		             密码重试次数4次
 @constant  kESErrorCOSPasswordRetry3		             密码重试次数3次
 @constant  kESErrorCOSPasswordRetry2		             密码重试次数2次
 @constant  kESErrorCOSPasswordRetry1		             密码重试次数1次
 @constant  kESErrorCOSPasswordRetry0		             密码重试次数1次
 @constant  kESErrorCOSPINLocked			             密钥已经被锁定
 @constant  kESErrorCOSLowEnergy			             低电量
 
 
 @constant  kESErrorSlotNotInitialize                   未初始化中间件
 
 @constant  kESErrorSlotInvalidParam		             无效参数
 @constant  kESErrorSlotInvalidHandle		             无效句柄
 @constant  kESErrorSlotCancel				             软件层取消按键操作
 @constant  kESErrorSlotOperationTimeout		         操作因超时而被取消
 @constant  kESErrorSlotMemoryNotEnough                  缓冲区不足，包括申请失败，出参Buffer长度不足
 @constant  kESErrorSlotPINCacheNotExist                 没有PIN缓存
 @constant  kESErrorSlotInvalidXMLFormat		         二代签名数据格式错误
 @constant  kESErrorSlotInfoNotFound		             所需信息(文件，指针，容器，证书、公私钥等等)不存在
 @constant  kESErrorSlotInfoFull			             所需信息(文件，指针，容器，证书、公私钥等等)已用满，无法创建
 @constant  kESErrorSlotInfoExists			             所需信息(文件，指针，容器，证书、公私钥等等)已存在，无需创建
 @constant  kESErrorSlotInvalidInfo			             所需信息(文件，指针，容器，证书、公私钥等等)错误
 @constant  kESErrorSlotInfoAccessError			         所需信息(文件，指针，容器，证书、公私钥等等)访问错误（如越界、被破坏、内部生成校验错误等等）
 @constant  kESErrorSlotAPDUModeDecryptError	         使用APDU级线路保护解密失败
 @constant  kESErrorSlotGetHashValueFail		         获取哈希值失败
 @constant  kESErrorSlotOSError				             系统调用错误（如windows调用android）
 @constant  kESErrorSlotUnsupportedStruct	             不支持的中间件结构
 @constant  kESErrorSlotPublicKeyNotExist	             公钥不存在
 @constant  kESErrorSlotCertificateNotExist		         证书不存在
 
 
 @constant  kESErrorDeviceRequireActive                  设备需要激活
 
 @constant  kESErrorAudioDriverInitializeFail	         音频驱动初始化失败
 @constant  kESErrorAudioDriverCommunicationFail         音频驱动通讯错误
 @constant  kESErrorAudioDriverInvalidDataFormat         音频协议数据包错误(不符合协议规定)
 @constant  kESErrorAudioDriverInvalidParam		         音频驱动参数错误
 @constant  kESErrorAudioDriverUnsupportedIOCtl	         音频驱动控制码不支持
 @constant  kESErrorAudioDriverNotReady		             音频通道未就绪（如没插入耳机线）
 @constant  kESErrorAudioDriverProtocolNotSupported          音频协议版本不支持/不兼容
 @constant  kESErrorAudioDriverCancel			         指令取消、因驱动未初始化直接返回
 @constant  kESErrorAudioDriverRouteDidChanged	         音频路由改变
 @constant  kESErrorAudioDriverConfigFail		         音频通信配置失败
 @constant  kESErrorAudioDriverBusy			             音频固件/Key设备忙
 @constant  kESErrorAudioDriverV2ProtocolFound	         检测到V2版通信协议（错误码只在驱动内使用）
 
 @constant  kESErrorBluetoothInitializeFail		         蓝牙驱动初始化失败
 @constant  kESErrorBluetoothCommunicationError	         蓝牙驱动通讯错误/蓝牙断开
 @constant  kESErrorBluetoothInvalidDataFormat	         蓝牙协议数据包错误(不符合协议规定)
 @constant  kESErrorBluetoothDisconnected		         蓝牙断开连接
 
 @constant  kESErrorOTGConnectionError			         OTG通讯失败
 */
typedef enum ESError{
    
    
    kESErrorNoError                     = 0x00000000,  	// 成功
    kESErrorNotConnectedAnyDevice       = 0xC045000F,   //未连接任何设备
    
    
    // COS错误码
    kESErrorCOSInvalidFileType          = 0xE0616981,		// 文件类型不匹配
    kESErrorCOSAccessDenied             = 0xE0616982,		// 安全状态不满足
    kESErrorCOSInvalidRandom	        = 0xE0616984,		// 随机数不可用或者引用数据无效
    kESErrorCOSConditionNotSatisfied    = 0xE0616985,		// 使用条件不满足
    kESErrorCOSFileNotSelected	        = 0xE0616986,	// 没有当前文件
    kESErrorCOSNotProtectedMessage		= 0xE0616987,		// 缺少安全报文数据对象
    kESErrorCOSInvalidProtectedMessage  = 0xE0616988,		// 安全报文项不正确
    kESErrorCOSInvalidAPDUParam			= 0xE0616A80,		// 数据域参数错误(全部错误)
    kESErrorCOSFunctionUnsupported		= 0xE0616A81,		// 功能不支持
    kESErrorCOSFileNotFound			    = 0xE0616A82,		// 没有找到文件
    kESErrorCOSRecordNotFound		    = 0xE0616A83,		// 没有找到记录
    kESErrorCOSNoSpace				    = 0xE0616A84,		// 缺少剩余空间
    kESErrorCOSInvalidTLVData		    = 0xE0616A85,		// TLV数据对象不一致
    kESErrorCOSInvalidP1P2Param			= 0xE0616A86,		// P1P2参数不正确
    kESErrorCOSReferencedDataNotFound	= 0xE0616A88,		// 没有找到引用数据
    kESErrorCOSOutOfBounds				= 0xE0616B00,		// 偏移超出范围
    kESErrorCOSInvalidINS				= 0xE0616D00,		// 不正确的INS
    kESErrorCOSInvalidCLA				= 0xE0616E00,		// 不正确的CLA
    kESErrorCOSPartitionInvalidAPDUParam= 0xE0616FEB,		// 数据域参数错误(部分错误)
    
    kESErrorCOSDeviceRequireInitialize	= 0xE0616FF0,		// 设备没有初始化
    kESErrorCOSDeviceTimeout			= 0xE0616FFB,		// 通讯超时或者通讯数据格式错误
    kESErrorCOSKeyIDNotFound		    = 0xE0619403,		// 没有找到密钥记录
    kESErrorCOSUserCancelled			= 0xE0616FF8,		// 用户取消
    kESErrorCOSButtonTimeout			= 0xE0616FF9,		// 按键超时
    kESErrorCOSButtonWrong			    = 0xE0616FFE,		// 按键错误
    kESErrorCOSHandshakeFail		    = 0xE0616FFF,		// 建立握手失败
    kESErrorCOSPasswordRetry15		    = 0xE06163CF,		// 密码重试次数15次
    kESErrorCOSPasswordRetry14		    = 0xE06163CE,		// 密码重试次数14次
    kESErrorCOSPasswordRetry13		    = 0xE06163CD,		// 密码重试次数13次
    kESErrorCOSPasswordRetry12		    = 0xE06163CC,		// 密码重试次数12次
    kESErrorCOSPasswordRetry11		    = 0xE06163CB,		// 密码重试次数11次
    kESErrorCOSPasswordRetry10		    = 0xE06163CA,		// 密码重试次数10次
    kESErrorCOSPasswordRetry9		    = 0xE06163C9,		// 密码重试次数9次
    kESErrorCOSPasswordRetry8		    = 0xE06163C8,		// 密码重试次数8次
    kESErrorCOSPasswordRetry7		    = 0xE06163C7,		// 密码重试次数7次
    kESErrorCOSPasswordRetry6		    = 0xE06163C6,		// 密码重试次数6次
    kESErrorCOSPasswordRetry5		    = 0xE06163C5,		// 密码重试次数5次
    kESErrorCOSPasswordRetry4		    = 0xE06163C4,		// 密码重试次数4次
    kESErrorCOSPasswordRetry3		    = 0xE06163C3,		// 密码重试次数3次
    kESErrorCOSPasswordRetry2		    = 0xE06163C2,		// 密码重试次数2次
    kESErrorCOSPasswordRetry1		    = 0xE06163C1,		// 密码重试次数1次
    kESErrorCOSPasswordRetry0		    = 0xE06163C0,		// 密码重试次数1次
    kESErrorCOSPINLocked			    = 0xE0616983,		// 密钥已经被锁定
    kESErrorCOSLowEnergy			    = 0xE0616FD0,		// 低电量
    
    
    // SlotAPI错误码
    kESErrorSlotNotInitialize           = -1,//未初始化中间件
    
    kESErrorSlotInvalidParam		    = 0xE0603004,		// 无效参数
    kESErrorSlotInvalidHandle		    = 0xE0603005,		// 无效句柄
    kESErrorSlotCancel				    = 0xE0603007,      // 软件层取消按键操作
    kESErrorSlotOperationTimeout		= 0xE0603008,      // 操作因超时而被取消
    kESErrorSlotMemoryNotEnough         = 0xE060300C,		// 缓冲区不足，包括申请失败，出参Buffer长度不足
    kESErrorSlotPINCacheNotExist        = 0xE060300D,		// 没有PIN缓存
    kESErrorSlotInvalidXMLFormat		= 0xE060300E,		// 二代签名数据格式错误
    kESErrorSlotInfoNotFound		    = 0xE0603011,		// 所需信息(文件，指针，容器，证书、公私钥等等)不存在
    kESErrorSlotInfoFull			    = 0xE0603012,// 所需信息(文件，指针，容器，证书、公私钥等等)已用满，无法创建
    kESErrorSlotInfoExists			    = 0xE0603013,// 所需信息(文件，指针，容器，证书、公私钥等等)已存在，无需创建
    kESErrorSlotInvalidInfo			    = 0xE0603014, // 所需信息(文件，指针，容器，证书、公私钥等等)错误
    kESErrorSlotInfoAccessError			= 0xE0603015,// 所需信息(文件，指针，容器，证书、公私钥等等)访问错误（如越界、被破坏、内部生成校验错误等等）
    kESErrorSlotAPDUModeDecryptError	= 0xE0603016,		// 使用APDU级线路保护解密失败
    kESErrorSlotGetHashValueFail		= 0xE0603017,		// 获取哈希值失败
    kESErrorSlotOSError				    = 0xE0603018,		// 系统调用错误（如windows调用android）
    kESErrorSlotUnsupportedStruct	    = 0xE0603019,		// 不支持的中间件结构
    kESErrorSlotPublicKeyNotExist	    = 0xE0603020,		// 公钥不存在
    kESErrorSlotCertificateNotExist		= 0xE0603021,		// 证书不存在
    
    
    kESErrorDeviceRequireActive         = 0x60606003, // 设备需要激活
    
    // 音频驱动错误码
    kESErrorAudioDriverInitializeFail	= 0xE0601500,		// 音频驱动初始化失败
    kESErrorAudioDriverCommunicationFail= 0xE0601501,		// 音频驱动通讯错误
    kESErrorAudioDriverInvalidDataFormat= 0xE0601502,		// 音频协议数据包错误(不符合协议规定)
    kESErrorAudioDriverInvalidParam		= 0xE0601503,		// 音频驱动参数错误
    kESErrorAudioDriverUnsupportedIOCtl	= 0xE0601504,		// 音频驱动控制码不支持
    kESErrorAudioDriverNotReady		    = 0xE0601505,		// 音频通道未就绪（如没插入耳机线）
    kESErrorAudioDriverProtocolNotSupported =0xE0601506,		// 音频协议版本不支持/不兼容
    kESErrorAudioDriverCancel			= 0xE0601507,		// 指令取消、因驱动未初始化直接返回
    kESErrorAudioDriverRouteDidChanged	= 0xE0601508,		// 音频路由改变
    kESErrorAudioDriverConfigFail		= 0xE0601509,		// 音频通信配置失败
    kESErrorAudioDriverBusy			    = 0xE060150A,		// 音频固件/Key设备忙
    kESErrorAudioDriverV2ProtocolFound	= 0xE060150B,		// 检测到V2版通信协议（错误码只在驱动内使用）
    
    // 蓝牙驱动错误码
    kESErrorBluetoothInitializeFail		= 0xE0601700,		// 蓝牙驱动初始化失败
    kESErrorBluetoothCommunicationError	= 0xE0601701,		// 蓝牙驱动通讯错误/蓝牙断开
    kESErrorBluetoothInvalidDataFormat	= 0xE0601702,		// 蓝牙协议数据包错误(不符合协议规定)
    kESErrorBluetoothDisconnected		= 0xE0601703,		// 蓝牙断开连接
    
    // OTG驱动错误码
    kESErrorOTGConnectionError			= 0xE0601801		// OTG通讯失败
}ESError;


/*!
 @enum
 @abstract  PIN类型
 @constant  kESPinUser 用户PIN
 @constant  kESPinAdmin 管理员PIN
 */
typedef enum ESPinType{
    kESPinUser = 0x01,
    kESPinAdmin= 0x02
}ESPinType;

/*!
 @enum
 @abstract  密钥类型，可以同时指定多种类型  kESKeyPairExchange|kESKeyPairSignature
 
 @constant  kESKeyPairAll      所有密钥对
 @constant  kESKeyPairExchange  交换密钥类型
 @constant  kESKeyPairSignature  签名密钥类型
 @constant  kESKeyPairTemporary   临时密钥
 */
typedef enum ESKeyPairType{
    kESKeyPairAll          = 0x0007,
    kESKeyPairExchange     = 0x0001,
    kESKeyPairSignature    = 0x0002,
    kESKeyPairTemporary    = 0x0004
}ESKeyPairType;

#endif
