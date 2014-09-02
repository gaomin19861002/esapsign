/**
 * Copyright (C) 2001-2014, Foxit Corporation.
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation.
 * It isn't allowed to distribute any parts of Foxit PDF SDK to any third parties or general public, unless there 
 * is a license agreement between Foxit Corporation and customers.
 *
 * @file	fs_renderer_apple_r.h
 * @brief	Header file for \ref FSRENDERER_APPLE "Renderer For Apple" module of Foxit PDF SDK.
 * @details	This module is used for a rendering engine(renderer) on Mac. 
 *
 * @note	The APIs listed in this files are under the license control of "Renderer" module in PDF SDK.<br>
 *			Please make sure the license of Renderer module is purchased and apply the license before 
 *			calling APIs in this file. <br> 
 */

#ifndef _FSCRT_RENDERER_APPLE_R_H_
#define _FSCRT_RENDERER_APPLE_R_H_

/** 
 * @defgroup	FSRENDERER_APPLE Renderers For Apple
 * @ingroup		FSRENDERER
 * @brief		Definitions for a rendering engine on Apple.<br>
 *				Definitions and functions in this module are included in fs_renderer_apple_r.h.<br>
 *				Module: Renderer<br>
 *				License Identifier: Renderer/All<br>
 *				Available License Right: Unnecessary
 */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif
	
#import <CoreGraphics/CoreGraphics.h>

#ifndef _FSCRT_DEF_MACRO_APPLEDEVICE_
#define _FSCRT_DEF_MACRO_APPLEDEVICE_
/**
 * @name	Macro Definitions for Apple devices
 */
/**@{*/

/** @brief	Display device, like monitor. */
#define FSCRT_APPLEDEVICE_DISPLAY		1
/** @brief	Raster based printers. */
#define FSCRT_APPLEDEVICE_PRINTER		2

/**@}*/
#endif /* _FSCRT_DEF_MACRO_APPLEDEVICE_ */

/**
 * @brief	Create a renderer on an Apple quartz context.
 *
 * @details	Renderer is a term of graphics engine in Foxit PDF SDK, it provides basic management and drawing operations as a common feature.<br>
 * 			There are two approaches to use renderer: one is to draw on a renderer directly, the other is to output document contents by using a graphics context.<br>
 * 			PDF module provides a rendering context to output page contents. Please refer to function ::FSPDF_RenderContext_Create.
 * 
 * @param[in]	context			Handle to a <b>CGContextRef</b> object which is an iOS/Mac device.
 * @param[in]	deviceClass		Device class. Please refer to macro definitions <b>FSCRT_APPLEDEVICE_XXX</b> and this should be one of these macros.
 * @param[out]	renderer		Pointer to a <b>FSCRT_RENDERER</b> handle that receives a new renderer object.
 *
 * @return 	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if the parameter <i>context</i> or <i>renderer</i> is <b>NULL</b>.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable error occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 * 			::FSCRT_ERRCODE_ERROR if fail to create a renderer with the specified parameter <i>context</i>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @note	Foxit PDF SDK will extend the supports on more platform-based native devices.
 *
 * @attention	<b>Thread Safety</b>: this function is thread-safe.<br>
 *				<b>OOM Information</b>:<br>
 *				OOM handling is only for mobile platforms, not for server or desktop.<br>
 *				<ul>
 *				<li>This function is long-term recoverable.</li>
 *				<li> <i>renderer</i>: this handle is long-term recoverable.</li>
 *				</ul>
 *				Please refer to the document "Robust PDF Applications with Limited Memory" for more details.
 */
FS_RESULT	FSCRT_Renderer_CreateOnCGContext(CGContextRef context, FS_INT32 deviceClass, FSCRT_RENDERER* renderer);


#ifdef __cplusplus
};
#endif

/**@}*/ /* group FSRENDERER_APPLE */

#endif /* _FSCRT_RENDERER_APPLE_R_H_ */
