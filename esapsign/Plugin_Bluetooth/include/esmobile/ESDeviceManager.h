/*!
 @header ESDeviceManager.h
 @abstract 设备管理器定义
 @see   ESDeviceType
 @copyright Copyright (c) 2014年 excelsecu. All rights reserved.
 @author 陆振文 on 14-3-28
 @version 1.00
 */

#import <Foundation/Foundation.h>
#import "ESDevice.h"


/*!
 @class       ESDeviceManager
 @abstract    设备管理器，负责管理设备的连接，状态处理，分发事件等等
 @discussion  一个设备管理器用来管理多种类型(ESDeviceType)的设备,下面是使用示例：
 
 <br /><br />
 步骤一：
 <br /><br />
 ESDeviceManager *mgr = [ESDeviceManager shareManager];
 <br /><br /><br />
 //为指定类型的设备设置委托<br />
 [mgr setDelegate:delegate forType:kESDeviceAudio];
 <br /><br />
 或者 <br />
 [mgr setDelegate:delegate forType:kESDeviceAudio|kESDeviceBluetooth];<br />
 或者分别设置 <br />
 [mgr setDelegate:delegate1 forType:kESDeviceAudio];<br />
 [mgr setDelegate:delegate2 forType:kESDeviceBluetooth];<br />
 
 <br /><br />
 [mgr start];//启动监听
 <br /><br /><br /><br />
 
 步骤二:
 <br /><br />
 //回调会在主线程调用 <br />
 -(void)onDeviceConnectionStateDidChanged:(id<ESDevice>)device{
 <br /><br />
     // 判断连接状态 <br />
     &nbsp;&nbsp;&nbsp;&nbsp;if ([device isConnected]) {<br />
         // 异步读取mediaId 或者其他操作<br />
         &nbsp;&nbsp;&nbsp;&nbsp;[self performSelectorInBackground:@selector(getDeviceMediaId) withObject:nil];<br />
         // ......<br />
     &nbsp;&nbsp;}<br />
 }<br /><br /><br /><br />
 
 步骤三：<br />
 // 在退出程序的时候记得释放资源，注意：调用此方法之后会把所有资源置空，可以重复步骤一来初始化<br />
 [mgr stop];<br />
 
 
 @see ESDeviceType
 @see ESDeviceConnectionStateDelegate
 @author    陆振文
 @version   1.0
 */
@interface ESDeviceManager : NSObject


/*!
 @method
 @abstract 为指定类型的设备设置委托，这样当指定类型设备连接上就会触发回调，其他类型的设备状态改变不会响应
 
 @param    delegate 设备状态委托
 @param    type     单个类型值或者是组合起来的值，如kESDeviceAudio|kESDeviceBluetooth
 @see       ESDeviceConnectionStateDelegate
 @see       ESDeviceType
 */

-(void)setDelegate:(id<ESDeviceConnectionStateDelegate>) delegate forType:(ESDeviceType)type;


/*!
 @method
 @abstract  获取所有已连接的Device
 @return    所有已连接的设备，无则返回空链表
 */
-(NSArray *) deviceList;
/*!
 @method
 @abstract  获取指定类型的所有已连接的Device
 
 @param     type 设备类型，可以是组合起来的值
 @return    指定类型已连接的设备 无则返回空列表
 */
-(NSArray *) deviceListForType:(ESDeviceType)type;

/*!
 @method
 @abstract  开始监听
 */
-(void) start;

/*!
 @method
 @abstract  停止监听，释放所有资源。一般在退出应用的时候调用此方法
 */
-(void) stop;


+(ESDeviceManager *)shareManager;

/*!
 @method
 @abstract  通过错误码获取错误描述信息
 @param     error  错误码
 */
+(NSString *)errorDescription:(ESError)error;


@end