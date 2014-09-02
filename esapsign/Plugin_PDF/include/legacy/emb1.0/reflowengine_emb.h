/**
 * @deprecated	As of release 2.0 version, this header file will not be used. 
 *				This header file will be replaced by fpdf_base.h and fpdf_reflow.h .
 *
 * Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
 * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
 * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
 * Without SDK license agreement, you cannot redistribute anything.
 * @file reflowengine_emb.h
 * @author	Foxit Corporation
 */

#ifndef _FREFLOWEMB_H_
#define _FREFLOWEMB_H_

#ifndef _FPDFEMB_H_
#include "fpdfemb.h"
#endif

/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for Parser Flags
 */
/**@{*/
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PARSER_IMAGE in fpdf_base.h.
 * @brief Whether Parse image.
 */
#define RFEMB_PARSER_IMAGE		0x1 
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PARSER_PAGEMODE in fpdf_base.h.
 * @brief Whether slice image or text for page.
 */ 
#define RFEMB_PARSER_PAGEMODE	0x4 
/**@}*/

#ifdef __cplusplus
extern "C" {
#endif

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_REFLOWPAGE</b> in fpdf_base.h.
 * @brief Reflow page data structure.
 */
typedef void* RFEMB_ReflowedPage;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_AllocPage in fpdf_reflow.h .
 * @brief Alloc a reflow page.
 *
 * @return An allocated reflow page. <br>
 *			<b>NULL</b> means out of memory or the license of the SDK is invalid.
 */
RFEMB_ReflowedPage RFEMB_AllocReflowedPage();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_DestroyPage in fpdf_reflow.h .
 * @brief Destroy a reflow page
 *
 * @param[in] Page					A reflow page handle
 * @return None.
 */
void RFEMB_DestroyReflowedPage(RFEMB_ReflowedPage Page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_GetPageSize in fpdf_reflow.h .
 * @brief Get the width and height of a reflow page.
 *
 * @param[in] page					A reflow page handle.
 * @param[out] width				The width of the page.
 * @param[out] height				The height of the page.
 * 
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 * 
 */
FPDFEMB_RESULT RFEMB_GetRFPageSize(RFEMB_ReflowedPage page, int* width, int* height);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief The pointer to reflow page object structure.
 */
typedef void* RFEMB_PageObjects;

/** 
 * @deprecated As of release 2.0, this will not be used.
 * @brief The pointer to reflow parser data structure.
 */
typedef void* RFEMB_Parser;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_StartParse in fpdf_reflow.h .
 * @brief Start parsing a loaded PDF page into a reflowed page
 *
 * @details Page Reflowing is a progressive process. It might take a long time to reflow
 *			a page. If the parameter <i>pause</i> parameter is provided, this function may return
 *			::FPDFERR_TOBECONTINUED any time during reflowing.<br>
 *			When ::FPDFERR_TOBECONTINUED is returned, the reflowing is not finished. The
 *			application must call ::RFEMB_ContinueParse to continue reflowing.
 *
 * @param[in] page					A reflow page handle returned by ::RFEMB_AllocReflowedPage function.
 * @param[in] pdfPage				A PDF page handle.
 * @param[in] width					The desired page width, in hundredth of points. This value should be over 20.
 * @param[in] fitPageHeight			The desired page height, in hundredth of points.
 * @param[in] pause					Pointer to a structure that can pause the rendering process.
 *									Can be NULL if no pausing is needed.
 *									If provided, this pointer has to be valid during the whole reflowing.
 * @param[in] flags					The parser flag. See macro definitions <b>RFEMB_PARSER_XXX</b>.
 *
 * 
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 * 
 */
FPDFEMB_RESULT RFEMB_StartParse(RFEMB_ReflowedPage page, FPDFEMB_PAGE pdfPage, 
 								  float width, float fitPageHeight, FPDFEMB_PAUSE* pause, int flags);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_ContinueParse in fpdf_reflow.h .
 * @brief Continue reflowing a PDF page
 *
 * @param[in] page					A reflow page handle returned by ::RFEMB_AllocReflowedPage function.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_ContinueParse(RFEMB_ReflowedPage page);



/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_SetDitherBits in fpdf_reflow.h .
 * @brief Set dither bits for rendering.
 *
 * @param[in] page					A reflow page handle. The page has to be parsed first.
 * @param[in] DitherBits			Default value: 2.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_SetDitherBits(RFEMB_ReflowedPage page, int DitherBits);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_StartRender in fpdf_reflow.h .
 * @brief Start rendering of a reflowed page.
 *
 * @details Rendering is a progressive process. This function starts the rendering process,
 *			and may return before the rendering is finished, if a pause structure is provided.<br>
 *			Application should call ::RFEMB_ContinueParse repeatedly to finish the rendering 
 *			when the return value is ::FPDFERR_TOBECONTINUED.<br>
 *			There can be only one rendering procedure for a page at any time. And the rendering
 *			can be started over and over again for the same page. If a page rendering is already
 *			active, starting another one will cancel the previous rendering.<br>
 *			Rendering of a page doesn't draw the page background, therefore, you usually need
 *			to draw the background in the DIB yourself.
 *
 * @param[in] dib					A DIB handle, as the rendering device.
 * @param[in] page					A reflow page handle. The page has to be parsed first.
 * @param[in] start_x				The left pixel position of the display area in the device coordination
 * @param[in] start_y				The top pixel position of the display area in the device coordination
 * @param[in] size_x				The horizontal size (in pixels) for displaying the page
 * @param[in] size_y				The vertical size (in pixels) for displaying the page
 * @param[in] rotate				The page orientation: 
 *									<ul>
 *									<li>0:	Normal</li>
 *									<li>1:	Rotate 90 degrees clockwise</li>
 *									<li>2:	Rotate 180 degrees</li>
 *									<li>3:	Rotate 90 degrees counter-clockwise</li>
 *									</ul>
 * @param[in] pause					A pointer to a structure that can pause the rendering process.
 * 									Thsi can be <b>NULL</b> if no pausing is needed.
 *									If provided, this pointer has to be valid during the whole rendering.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_StartRender(FPDFEMB_BITMAP dib, RFEMB_ReflowedPage page,
								 int start_x, int start_y, int size_x, int size_y, int rotate, FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_ContinueRender in fpdf_reflow.h .
 * @brief Continue rendering a reflowed page.
 *
 * @param[in] page					A handle returned by ::RFEMB_StartRender function
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_ContinueRender(RFEMB_ReflowedPage page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_MATRIX in fs_base.h.
 * @brief The transformation matrix.
 */
typedef void* RFEMB_Matrix;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_GetMatrix in fpdf_reflow.h .
 * @brief Allocate a matrix.
 *
 * @param[in] page					Page handle. The page has to be parsed first.
 * @param[in] start_x				Left pixel position of the display area in the device coordination
 * @param[in] start_y				Top pixel position of the display area in the device coordination
 * @param[in] size_x				Horizontal size (in pixels) for displaying the page
 * @param[in] size_y				Vertical size (in pixels) for displaying the page
 * @param[in] rotate				The page orientation: 
 *									<ul>
 *									<li>0:	Normal</li>
 *									<li>1:	Rotate 90 degrees clockwise</li>
 *									<li>2:	Rotate 180 degrees</li>
 *									<li>3:	Rotate 90 degrees counter-clockwise</li>
 *									</ul>
 * @return The matrix handle.<br><b>NULL</b> means out of memory or parameters error.
*/
RFEMB_Matrix RFEMB_AllocMatrix(RFEMB_ReflowedPage page, int start_x, int start_y, int size_x, int size_y, int rotate);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Destroy a matrix.
 * @param[in] matrix				Matrix handle. 
*/
void RFEMB_DestroyMatrix(RFEMB_Matrix matrix);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_GetFocusData in fpdf_reflow.h .
 * @brief Get data pointing to current reading position
 *
 * @details This function retrieves data pointing to given reading position.
 *			Application can convert it to the physical position by calling ::RFEMB_Focus_GetPosition.
 * @param[in] page					Handle to the page
 * @param[in] matrix				Handle to the matrix form ::RFEMB_AllocMatrix
 * @param[in] x					Destination x position
 * @param[in] y					Destination y position
 * @param[out] buffer				Application allocated buffer receiving the destination data
 *									If this parameter is NULL, then data won't be retrieved.
 * @param[in,out] bufsize			Pointer to an integer receiving data block size for the destination.
 *								If <i>buffer</i> is <b>NULL</b>, this will get the actual size of the destination data.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_Focus_GetData(RFEMB_ReflowedPage page, RFEMB_Matrix matrix, int x, int y, void* buffer, int* bufsize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Reflow_GetFocusPosition in fpdf_reflow.h .
 * @brief Get a point pointing to the current reading position
 *
 * @details This function Get a point from data retrieved from ::RFEMB_Focus_GetData.
 *
 * @param[in] page					Handle to the page
 * @param[in] matrix				Handle to the matrix from ::RFEMB_AllocMatrix
 * @param[in] data					Data from ::RFEMB_Focus_GetData 
 * @param[in] size					Data size	
 * @param[out] x					Destination x position
 * @param[out] y					Destination y position
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT RFEMB_Focus_GetPosition(RFEMB_ReflowedPage page, RFEMB_Matrix matrix, 
										   void* data, int size, int* x, int* y);

#ifdef __cplusplus
};
#endif

#endif




 
