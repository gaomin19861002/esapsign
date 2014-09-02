/** Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
  * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
  * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
  * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
  * Without SDK license agreement, you cannot redistribute anything.
  * Functions in this header file, require "FPDFANNOT" module to be enabled in your SDK license.
  * @file	fpdf_annot.h
  * @author	Foxit Corporation
  * @brief	Header file for the Annotation module.<br>
  *			The annot module offers methods to do some operations on annotations.
  *			Following the specification of PDF, users can retrieve the annotation in the current position 
  *			as well as add, delete or modify annotations by using these methods.
  *			This module currently supports annotations defined in macro <b>FPDF_ANNOTTYPE_XXX</b>.
  * @note	If you want to purchase Foxit PDF SDK license and use ANY of the following functions, please
  *			request for enabling Annotation module explicitly. 
  * @version 2.1
  */

/** 
 * @addtogroup FPDFANNOT Annotation
 * @brief Methods in this module are included in fpdf_annot.h
 */
/**@{*/

#ifndef _FPDF_ANNOT_H_
#define _FPDF_ANNOT_H_

#ifndef _FS_BASE_H_
#include "fs_base.h"
#endif

#ifndef _FPDF_BASE_H_
#include "fpdf_base.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief	Get the count of hyperlinks inside a page.
 *
 * @param[in] page			A page handle.
 * @param[out] link_count	Pointer to an integer that receives the count of links.
 *
 * @return	::FS_ERR_SUCCESS means get the count successfully.<br>
 *			 For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports link annotation.
 */
FS_RESULT FPDF_Annot_GetLinkCount(FPDF_PAGE page, FS_INT32* link_count);

/**
 * @brief	Get the specified hyperlink handler.
 *
 * @param[in] page			A page handle
 * @param[in] link_index	A zero-based index used to specify the link.
 * @param[out] link_annot	Pointer to a annot handle that receives the handle of the first action.
 *
 * @return	::FS_ERR_SUCCESS means get the handler successfully.<br>
 *			 For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports link annotation.
 */
FS_RESULT FPDF_Annot_GetLink(FPDF_PAGE page, FS_INT32 link_index, FPDF_ANNOT* link_annot);

/**
 * @brief	Get action(s) associated with the specified hyperlink.
 *
 * @param[in] page			A page handle
 * @param[in] link_annot	The handler of the specified hyperlink.
 * @param[out] action		Pointer to a <b>FPDF_ACTION</b> structure that receives the handle of the first action.
 *
 * @return	::FS_ERR_SUCCESS means get the action(s) successfully.<br>
 *			 For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports link annotation.
 */
FS_RESULT FPDF_Annot_GetLinkAction(FPDF_PAGE page, FPDF_ANNOT link_annot, FPDF_ACTION* action);

/**
 * @brief	Get the count of areas(quadrilaterals) for the specified link.
 *
 * @param[in] page			A page handle.
 * @param[in] link_annot	A zero-based index used to specify the link.
 * @param[out] count		Pointer to an integer that receives the count of quadrilaterals.
 *
 * @return	::FS_ERR_SUCCESS means get the count successfully. <br>
 *			 For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports link annotation.
 */
FS_RESULT FPDF_Annot_GetLinkAreaCount(FPDF_PAGE page, FPDF_ANNOT link_annot, FS_INT32* count);

/**
 * @brief	Get a particular quadrilateral for a link.
 *
 * @details	The result in "points" array are the X/Y coordinations for the four vertices
 *			of the quadrilateral. Vertices are in the following order: lower left, lower
 *			right, upper right, upper left.
 *
 * @param[in] page			A page handle.
 * @param[in] link_annot	A Zero-based index used to specify for the link.
 * @param[in] area_index	A Zero-based index used to specify the quadrilateral.
 * @param[out] points		Pointer to an array, which consists 4 points, that receives coordinations.
 *
 * @return	::FS_ERR_SUCCESS means get the particular quadrilateral successfully.<br>
 *			 For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports link annotation.
 */
FS_RESULT FPDF_Annot_GetLinkArea(FPDF_PAGE page, FPDF_ANNOT link_annot, FS_INT32 area_index, FS_POINTF* points);

/**
 * @brief	Get the count of annotations in the page.
 *
 * @param[in] page			A page handle.
 * @param[out] count		Pointer to an integer that receives the count of annotations.
 *
 * @return	::FS_ERR_SUCCESS means get the count successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports annotations defined in macro <b>FPDF_ANNOTTYPE_XXX</b>, except link annotation.
 */
FS_RESULT FPDF_Annot_GetCount(FPDF_PAGE page, FS_INT32* count);

/**
 * @brief	Get the handler of the annotation by the index.
 *
 * @param[in] page			A page handle.
 * @param[in] annot_index	The zero-based annotation index.
 * @param[out] annot		The annotation handler.
 *
 * @return	::FS_ERR_SUCCESS means get the index successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 */
FS_RESULT FPDF_Annot_Get(FPDF_PAGE page, FS_INT32 annot_index, FPDF_ANNOT* annot);

/**
 * @brief	Get the handler of the annotation which is the nearest one to a certain position on the page.
 *
 * @details	When the point is inside an annotation, this annotation is the nearest one to the point.
 *			Otherwise this annotation cannot be the nearest one to the point.<br>
 *			If there is no nearest annotation, the parameter <i>annot</i> will be -1.<br>
 *			Application can call function ::FPDF_Annot_SetPositionAccuracy first to set the tolerance value.
 *
 * @param[in] page			A page handle
 * @param[in] x				The value of X position in the PDF page coordination system.
 * @param[in] y				The value of Y position in the PDF page coordination system.
 * @param[out] annot		Pointer to the annotation handler.
 *
 * @return	::FS_ERR_SUCCESS means get the index successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 */
FS_RESULT FPDF_Annot_GetAtPos(FPDF_PAGE page, FS_FLOAT x, FS_FLOAT y, FPDF_ANNOT* annot);

/**
 * @brief	Get the handler of the annotation which is the nearest one to a certain position on the page, in device coordinates.
 *
 * @details	Only when the point is inside an annotation, this annotation is just the nearest one to this point.
 *			If there is no nearest annotation, the parameter <i>annot</i> will be <b>NULL</b>.<br>
 *			Application can call function ::FPDF_Annot_SetPositionAccuracy first to set the tolerance value.
 *
 * @param[in] page			A page handle.
 * @param[in] matrix		Page transformation matrix, returned by ::FPDF_Page_GetMatrix.
 * @param[in] x				The value of X position in the device coordinates.
 * @param[in] y				The value of Y position in the device coordinates.
 * @param[out] annot		Pointer to an annotation handler, which is the nearest one to specific point. <b>NULL</b> means no nearest annotation.
 *
 * @return	::FS_ERR_SUCCESS means get the index successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1.
 */
FS_RESULT FPDF_Annot_GetAtDevicePos(FPDF_PAGE page, const FS_MATRIX* matrix, FS_INT32 x, FS_INT32 y, FPDF_ANNOT* annot);

/**	
 * @brief	Set the accuracy to specify the tolerance value, which will affect on points used in function ::FPDF_Annot_GetAtPos or ::FPDF_Annot_GetAtDevicePos
 *
 * @param[in]  accuracy			The position accuracy for getting an annotation from a given position. Valid value: from 0.0f to 30.0f.
 *
 * @return	::FS_ERR_SUCCESS means successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	Available since version 2.1.<br>
 *			Only support "Square", "Circle, "Line", "Ink" annotations.
 */
FS_RESULT	FPDF_Annot_SetPositionAccuracy(FS_FLOAT accuracy);

/**
 * @brief	Get the index of the annotation by the annotation handler.
 *
 * @param[in] page			A page handle.
 * @param[in] annot			The annotation handler.
 * @param[out] index		Pointer to an integer that receives the zero-based annotation index.
 *
 * @return	::FS_ERR_SUCCESS means get the index successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 */
FS_RESULT FPDF_Annot_GetIndex(FPDF_PAGE page, FPDF_ANNOT annot, FS_INT32* index);

/**
 * @brief	Get the information of the specified annotation.
 *
 * @details	The application must call ::FPDF_Annot_GetCount first before it can call this function
 *			for any specified annotation.<br>
 *			If the parameter <i>buffer</i> is <b>NULL</b>, then the parameter <i>bufsize</i> will receive
 *			the count of bytes required to store the information of the specified annotation.<br>
 *			If the parameter <i>bufsize</i>(the size of <i>buffer</i>) is smaller than the required size, then this function
 *			will not copy any data, and return the error code ::FS_ERR_PARAM. And the required buffer size will 
 *			also be put into <i>bufsize</i>.<br>
 *			The data type of <i>buffer</i> depends on the parameter <i>infotype</i>,
 *			and different types are used:
 *			<ul>
 *			<li>::FPDF_ANNOTINFO_TYPE:			::FS_INT32</li>
 *			<li>::FPDF_ANNOTINFO_AUTHOR:		::FS_WCHAR</li>
 *			<li>::FPDF_ANNOTINFO_RECT:			::FS_RECT</li>
 *			<li>::FPDF_ANNOTINFO_CONTENTS:		::FS_WCHAR</li>
 *			<li>::FPDF_ANNOTINFO_COLOR:			::FS_DWORD</li>
 *			<li>::FPDF_ANNOTINFO_OPACITY:		::FS_INT32</li>
 *			<li>::FPDF_ANNOTINFO_LINEWIDTH:		::FS_INT32</li>
 *			<li>::FPDF_ANNOTINFO_FILEDATA:		::FS_LPVOID. Available since version 2.1.</li>, 
 *			<li>::FPDF_ANNOTINFO_MODTIME:		::FS_SYSTEMTIME. Available since version 2.1.</li>
 *			</ul>
 *			When the data type is ::FS_WCHAR, the output buffer will be in Unicode, using UTF-16LE format. 
 *			It's terminated by two consecutive zero bytes.
 *
 * @param[in] page			A page handle
 * @param[in] annot			The annotation handler.
 * @param[in] infotype		The type of the information. See the macro definitions <b>FPDF_ANNOTINFO_XXX</b>.
 *							The opacity information should be got with the type ::FPDF_ANNOTINFO_OPACITY, not ::FPDF_ANNOTINFO_COLOR.<br>
 * @param[out] buffer		A buffer allocated by the application, or <b>NULL</b>. 
 *							If it has enough or larger size, it will be used to receive the information of the annotation.<br>
 *							Otherwise <i>buffer</i> will get nothing, and should be allocated enough size by using <i>bufsize</i> returned by this function.
 * @param[in,out] bufsize	Pointer to a number which indicates the size(count of bytes) of <i>buffer</i> 
 *							before this function is called. Then after the function returns, this parameter will store
 *							the actual count of bytes of the annotation's information.
 *
 * @return	::FS_ERR_SUCCESS means get the information successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports annotations defined in macro <b>FPDF_ANNOTTYPE_XXX</b>, except link annotation.
 */
FS_RESULT FPDF_Annot_GetInfo(FPDF_PAGE page, FPDF_ANNOT annot, FS_INT32 infotype, FS_LPVOID buffer, FS_LPDWORD bufsize);

/**
 * @brief	Set the information of the specified annotation.
 *
 * @param[in] page			A page handle
 * @param[in] annot			The annotation handler.
 * @param[in] infotype		The type of the information. See macro definitions <b>FPDF_ANNOTINFO_XXX</b>.
 *							The opacity information should be set with the type ::FPDF_ANNOTINFO_OPACITY, not ::FPDF_ANNOTINFO_COLOR.<br>
 * @param[in] buffer		A buffer allocated by the application and used to set the information. <br>
 *							The data type of <i>buffer</i> depends on the parameter <i>infotype</i>.<br>
 *							See the comment of ::FPDF_Annot_GetInfo for more information.
 * @param[in] bufsize		The size(count of bytes) of <i>buffer</i>.
 *
 * @return	::FS_ERR_SUCCESS means set the information successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports annotations defined in macro <b>FPDF_ANNOTTYPE_XXX</b>, except link annotation.<br>
 *			To pencil annotations, the <i>infotype</i> can use ::FPDF_ANNOTINFO_LINEWIDTH instead of ::FPDF_ANNOTINFO_RECT.<br>
 *			To other annotations, the <i>infortype</i> cannot use ::FPDF_ANNOTINFO_LINEWIDTH.
 */
FS_RESULT FPDF_Annot_SetInfo(FPDF_PAGE page, FPDF_ANNOT annot, FS_INT32 infotype, FS_LPVOID buffer, FS_DWORD bufsize);

/**
 * @brief Get rectangle of an annotation in device coordinations.
 *
 * @details For the rectangle conversion, the result rectangle is always "normalized", which is meaning for
 *			device coordinations: left is always smaller than right, and top is always smaller than bottom.
 *
 * @param[in] page			A page handle returned by ::FPDF_Page_Load.
 * @param[in] annot			The annotation handler.
 * @param[in] matrix		Page transformation matrix returned by ::FPDF_Page_GetMatrix.
 * @param[out] annotRect	Used to receive the rectangle.
 *
 * @return	::FS_ERR_SUCCESS means set the information successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1.<br>
 *		 This is a useful function to get the device rectangle of an annotation 
 *		 when the rendering flag ::FPDF_RENDER_NOTTRANSFORMICON is used to render annotation.
 */
FS_RESULT FPDF_Annot_GetDeviceRect(FPDF_PAGE page, FPDF_ANNOT annot, const FS_MATRIX* matrix, FS_RECT* annotRect);


/**
 * @brief	Get color of annotation.
 *
 * @param[in] page			A page handle.
 * @param[in] annot			The annotation handler.
 * @param[in] fillColor		Used to decide which type of color is to be got. 
 *							<b>TRUE</b> means fill color, and <b>FALSE</b> means border color.
 * @param[out] color		Used to receive color value. Format: 0xAARRGGBB, and alpha component is ignored.
 *
 * @return	::FS_ERR_SUCCESS if get color successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	Available since version 2.1.<br>
 *			Some types of annotations need additional filling color, such as Line, Square, Circle, Polygon, etc.
 */
FS_RESULT FPDF_Annot_GetColor(FPDF_PAGE page, FPDF_ANNOT annot, FS_BOOL fillColor, FS_ARGB* color);

/**
 * @brief	Set annotation color.
 *
 * @param[in] page			A page handle.
 * @param[in] annot			The annotation handler.
 * @param[in] color			New color value. Format: 0xAARRGGBB, and alpha component is ignored.
 * @param[in] fillColor		Used to decide which type of color is to be set. 
 *							<b>TRUE</b> means fill color, and <b>FALSE</b> means border color.
 * @param[in] reset			Used to decide whether to reset annotation's appearance automatically or not.
 *							<b>TRUE</b> means this function will call function ::FPDF_Annot_ResetAppearance automatically.
 *
 * @return	::FS_ERR_SUCCESS if set color successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	Available since version 2.1.<br>
 *			Some types of annotations need additional filling color, such as Line, Square, Circle, Polygon, etc.
 */
FS_RESULT FPDF_Annot_SetColor(FPDF_PAGE page, FPDF_ANNOT annot, FS_ARGB color, FS_BOOL fillColor, FS_BOOL reset);

/**
 * @brief	Add an annotation to the page
 *
 * @details	The data type of the parameter <i>data</i> depends on the parameter <i>annottype</i>,
 *			and different types are used:<br>
 *			Format:  Annotation Type - Data type 
 *			<ul>
 *			<li>::FPDF_ANNOTTYPE_NOTE			-	::FPDF_ANNOT_NOTEINFO</li>
 *			<li>::FPDF_ANNOTTYPE_HIGHLIGHT		-	::FPDF_ANNOT_HIGHLIGHTINFO</li>
 *			<li>::FPDF_ANNOTTYPE_PENCIL			-	::FPDF_ANNOT_PENCILINFO</li>
 *			<li>::FPDF_ANNOTTYPE_STAMP			-	::FPDF_ANNOT_STAMPINFO</li>
 *			<li>::FPDF_ANNOTTYPE_FILEATTACHMENT -	::FPDF_ANNOT_FILEATTACHMENTINFO</li>
 *			<li>::FPDF_ANNOTTYPE_LINK			-	::FPDF_ANNOT_LINKINFO</li>	
 *			<li>::FPDF_ANNOTTYPE_SQUARE			-	::FPDF_ANNOT_RECTANGLEINFO. Available since version 2.1.</li>
 *			<li>::FPDF_ANNOTTYPE_CIRCLE			-	::FPDF_ANNOT_RECTANGLEINFO. Available since version 2.1.</li>
 *			<li>::FPDF_ANNOTTYPE_LINE			-	::FPDF_ANNOT_LINEINFO. Available since version 2.1.</li>
 *			<li>::FPDF_ANNOTTYPE_UNDERLINE		-	::FPDF_ANNOT_HIGHLIGHTINFO. Available since version 2.1.</li>
 *			<li>::FPDF_ANNOTTYPE_STRIKEOUT		-	::FPDF_ANNOT_HIGHLIGHTINFO. Available since version 2.1.</li>
 *			<li>::FPDF_ANNOTTYPE_FREETEXT		-	::FPDF_ANNOT_FREETEXTINFO. Available since version 2.1.</li>
 *			</ul>
 *
 * @param[in] page			A page handle.
 * @param[in] annottype		The type of the annotation which is to be added to the page. See macro definitions <b>FPDF_ANNOTTYPE_XXX</b>.
 * @param[in] data			The data struct of the annotation.
 * @param[in] datasize		The data size (count of bytes). This value should be above 0.
 * @param[out] annot		The annotation handler.
 *
 * @return	::FS_ERR_SUCCESS means add successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	This function only supports annotations defined in macro <b>FPDF_ANNOTTYPE_XXX</b>, except link annotation.<br>
 *			ATTENTION: If the type of the annotations to be added is "Link", 
 *			this function doesn't support dest_type ::FPDF_DEST_DOC now.
 */
FS_RESULT FPDF_Annot_Add(FPDF_PAGE page, FS_INT32 annottype, FS_LPVOID data, FS_DWORD datasize, FPDF_ANNOT* annot);

/** @name Macro Definition for annotation state model. Available since version 2.1.*/
/**@{*/
/** @brief State model: Marked */
#define FPDF_STATEMODEL_Marked	0
/** @brief State model: Review */
#define FPDF_STATEMODEL_Review	1
/**@}*/

/** 
 * @name Macro Definition for annotation state. Available since version 2.1.
 * @note These are meaningful when state model is ::FPDF_STATEMODEL_Marked.
 */
/**@{*/
/** @brief Marked State: Marked */
#define FPDF_STATE_MARKED_Marked 0
/** @brief Marked State: Unmarked */
#define FPDF_STATE_MARKED_Unmarked 1
/**@}*/

/** 
 * @name Macro Definition for annotation state. Available since version 2.1.
 * @note These are meaningful when state model is ::FPDF_STATEMODEL_Review.
 */
/**@{*/
/** @brief Review State: Accepted */
#define FPDF_STATE_REVIEW_Accepted	0
/** @brief Review State: Rejected */
#define FPDF_STATE_REVIEW_Rejected	1
/** @brief Review State: Cancelled */
#define FPDF_STATE_REVIEW_Cancelled	2
/** @brief Review State: Completed */
#define FPDF_STATE_REVIEW_Completed	3
/** @brief Review State: None */
#define FPDF_STATE_REVIEW_None		4
/**@}*/

/**	
 * @brief	Set the state (review or marked) of the annotation.
 *
 * @param[in] page				A page handle.
 * @param[in] annot				The annotation handler.
 * @param[in] nStateModel		The state model used to set to annotation. See macro definitions <b>FPDF_STATEMODEL_XXX</b>.
 * @param[in] nState			The state used to set to annotation. See macro definitions <b>FPDF_STATE_XXX_XXX</b>.
 *
 * @return	::FS_ERR_SUCCESS means delete successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1.
 */
FS_RESULT FPDF_Annot_SetState(FPDF_PAGE page, FPDF_ANNOT annot, FS_INT32 nStateModel, FS_INT32 nState);

/**	
 * @brief	Get the state (review or marked) of the annotation.
 *
 * @param[in] page				A page handle.
 * @param[in] annot				The annotation handler.
 * @param[out] nStateModel		Used to receive the state model. See macro definitions <b>FPDF_STATEMODEL_XXX</b>.
 * @param[out] nState			Used to receive the state. See macro definitions <b>FPDF_STATE_XXX_XXX</b>.
 *
 * @return	::FS_ERR_SUCCESS means delete successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1.
 */
FS_RESULT FPDF_Annot_GetState(FPDF_PAGE page, FPDF_ANNOT annot, FS_INT32* nStateModel, FS_INT32* nState);

/**	
 * @brief	Get the value of key "IT" in an annotation dictionary.
 *
 * @param[in] page				A page handle.
 * @param[in]  annot			The annotation handler.
 * @param[out] intent			Used to receive a name describing the intent of the annotation.<br>
 *								When FS_BSTR::len of <i>intent</i> is less than actual size, this function will set actual size to FS_BSTR::len of <i>intent</i> and return ::FS_ERR_SUCCESS.<br>
 *								Then application should allocate FS_BSTR::str with FS_BSTR::len of <i>intent</i>, and call this function again to get the intent name.
 *
 * @return	::FS_ERR_SUCCESS means successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 * 
 * @note	Available since version 2.1.
 */
FS_RESULT FPDF_Annot_GetIntent(FPDF_PAGE page, FPDF_ANNOT annot, FS_BSTR* intent); 

/**	
 * @brief	Delete the specified annotation of the page
 *
 * @param[in] page			A page handle.
 * @param[in] annot			The annotation handler.
 *
 * @return	::FS_ERR_SUCCESS means delete successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 */
FS_RESULT FPDF_Annot_Delete(FPDF_PAGE page, FPDF_ANNOT annot);

/**	
 * @brief	Regenerate the appearance of an annotation.
 *
 * @param[in] page			A page handle.
 * @param[in] annot			The annotation handler.
 *
 * @return	::FS_ERR_SUCCESS means successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	Available since version 2.1.<br>
 *			When any information which has effect on an annotation's appearance is changed, 
 *			the appearance of this annotation is required to be regenerated. 
 * 
 */
FS_RESULT FPDF_Annot_ResetAppearance(FPDF_PAGE page, FPDF_ANNOT annot);

/**
 * @brief	Move annotation to new position.
 *
 * @param[in] page			A Page handle.
 * @param[in] annot			The annotation handle.
 * @param[in] newRect		A rectangle that specifies new position, which the annotation will move to.
 * @param[in] updateAnnot	Used to decide whether to update annotation data according to the new position or not.
 *							<b>TRUE</b> means to update, while <b>FALSE</b> means not to update.
 *
 * @return	::FS_ERR_SUCCESS means successfully.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note	Available since version 2.1.<br>
 *			To some types of annotations, if change their rectangle areas, its data need to be synchronized.<br>
 *			For example, if move a polygon annotation, all its vertices should be changed.
 *
 */
FS_RESULT FPDF_Annot_Move(FPDF_PAGE page, FPDF_ANNOT annot, FS_RECTF newRect, FS_BOOL updateAnnot);

#ifndef _FPDFQUICKDATA_
#define _FPDFQUICKDATA_
/**
 * @brief Structure for data used for accelerating the render for annotation(s). Available since version 2.1. 
 */
typedef struct _FPDF_ANNOT_QUICKDATA_
{
	/** 
	 * @brief	Action type, and valid values are:
	 *			0 means to only render anontations in FPDF_ANNOT_QUICKDATA::annots; 
	 *			1 means to render all annotations;
	 *			2 means not render annotations in FPDF_ANNOT_QUICKDATA::annots.
	 */ 
	int action;					
	int annots_count;			/**< @brief The number of annotations. */
	FPDF_ANNOT* annots;			/**< @brief Pointer to an annotation array. */
	FS_RECTF clip;				/**< @brief Clip rectangle, in device coordinations. */
	int flag;					/**< @brief (Reserved)Rendering flag for annotation. See macros definitions <b>FPDF_RENDER_XXX</b>. */
}FPDF_ANNOT_QUICKDATA;
#endif

/**
 * @brief Accelerate the render for specific annotation(s).
 *
 * @details	When add or delete an annotation, this function can be called to get faster render speed.
 *			Parameter <i>dib</i> is the one which has been used in function ::FPDFEMB_RenderPage_Start.
 *
 * @param[in,out] dib		DIB handle, as the rendering device. This is the one used in function ::FPDFEMB_RenderPage_Start.
 * @param[in] page			Page handle. The page should be parsed first.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation:<br>
 *							<ul>
 *							<li>0: normal</li>
 *							<li>1: rotated 90 degrees clockwise</li>
 *							<li>2: rotated 180 degrees</li>
 *							<li>3: rotated 90 degrees counter-clockwise</li>
 *							</ul>
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 * 							This can be <b>NULL</b> if no pausing is needed.
 * @param[in] data			Data used for accelerating the render.
 *
 * @return	::FS_ERR_SUCCESS means rendering successfully finished.<br>
 *			::FS_ERR_TOBECONTINUED means rendering has been started but not finished, and function ::FPDF_Annot_ContinueRender needs to be called.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1. 
*/
FS_RESULT FPDF_Annot_StartRender(FS_BITMAP dib, FPDF_PAGE page, 
								 int start_x, int start_y, int size_x, int size_y, int rotate, 
								 FS_PAUSE* pause, FPDF_ANNOT_QUICKDATA data);

/**
 * @brief Continue accelerating the render for annotation(s).
 *			
 * @param[in] page			Page handle. 
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 * 							This can be <b>NULL</b> if no pausing is needed.
 *
 * @return	::FS_ERR_SUCCESS means rendering is finished successfully.<br>
 *			::FS_ERR_TOBECONTINUED means rendering hasn't finished and function ::FPDF_Annot_ContinueRender needs to be called.<br>
 *			For more definitions please see macro definitions <b>FS_ERR_XXX</b>.
 *
 * @note Available since version 2.1. 
 */
FS_RESULT FPDF_Annot_ContinueRender(FPDF_PAGE page,  FS_PAUSE* pause);

#ifdef __cplusplus
};
#endif

#endif
// _FPDF_ANNOT_H_
/**@}*/

