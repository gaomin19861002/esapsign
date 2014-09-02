/**
 * @deprecated	As of release 2.0 version, this header file will not be used. 
 *				This header file will be replaced by fpdf_base.h and fpdf_annot.h .
 *
 * Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
 * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
 * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
 * Without SDK license agreement, you cannot redistribute anything.
 * @file fpdf_emb_annot.h
 * @author	Foxit Corporation
 */

#ifndef _FPDF_EMB_ANNOT_H_
#define _FPDF_EMB_ANNOT_H_

#ifdef __cplusplus
extern "C" {
#endif


/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions of Annotation Types
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_UNKNOWN in fpdf_base.h.
 * @brief No or unsupported annotation. 
 */
#define FPDFEMB_ANNOT_UNKNOWN				0
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_NOTE in fpdf_base.h.
 * @brief Note annotation. 
 */
#define FPDFEMB_ANNOT_NOTE					0x0001
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_HIGHLIGHT in fpdf_base.h.
 * @brief Highlight annotation. 
 */
#define FPDFEMB_ANNOT_HIGHLIGHT				0x0002
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_PENCIL in fpdf_base.h.
 * @brief Pencil annotation. 
 */
#define FPDFEMB_ANNOT_PENCIL				0x0004
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_STAMP in fpdf_base.h.
 * @brief Stamp annotation. 
 */		
#define FPDFEMB_ANNOT_STAMP					0x0008
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTTYPE_FILEATTACHMENT in fpdf_base.h.
 * @brief File attachment annotation.
 */				
#define	FPDFEMB_ANNOT_FILEATTACHMENT		0x0010
/**@}*/


/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions of Information Flags for Annotation.
 */
/**@{*/
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_TYPE in fpdf_base.h.
 * @brief The type of annotation. 
 */
#define FPDFEMB_ANNOTINFO_TYPE				1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_AUTHOR in fpdf_base.h.
 * @brief The author of annotation. 
 */
#define FPDFEMB_ANNOTINFO_AUTHOR			2
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_RECT in fpdf_base.h.
 * @brief The rectangle of annotation. 
 */
#define FPDFEMB_ANNOTINFO_RECT				3
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_CONTENTS in fpdf_base.h.
 * @brief The contents of note annotation. 
 */
#define FPDFEMB_ANNOTINFO_CONTENTS			4
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_COLOR in fpdf_base.h.
 * @brief The color of annotation. 
 */
#define FPDFEMB_ANNOTINFO_COLOR				5
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_OPACITY in fpdf_base.h.
 * @brief The opacity of annotation. 
 */
#define FPDFEMB_ANNOTINFO_OPACITY			6
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOTINFO_LINEWIDTH in fpdf_base.h.
 * @brief The line width of pencil annotation. 
 */
#define FPDFEMB_ANNOTINFO_LINEWIDTH			7
/**@}*/


/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_NOTEINFO in fpdf_base.h .
 * @brief Data structure for a note annotation. 
 */
struct FPDFEMB_ANNOT_NOTEINFO
{
	unsigned int			size;			/**< @brief The size of the structure. */
	FPDFEMB_WCHAR			author[64];		/**< @brief The author of the annotation. */
	unsigned int			color;			/**< @brief The color of the annotation. */
	int						opacity;		/**< @brief The opacity of the annotation. */
	int						icon;			/**< @brief This is reserved. */
	struct FPDFEMB_RECT		rect;			/**< @brief The rectangle of the annotation. */
	FPDFEMB_WCHAR*			contents;		/**< @brief Contents of the annotation. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_QUAD in fpdf_base.h .
 * @brief Data structure for a quadrilateral of annotation. 
 */
struct FPDFEMB_ANNOT_QUAD
{	
	/**
	 * @name The text is oriented with respect to the edge connecting points (x1, y1) and (x2, y2).
	 */
	/**@{*/
	int						x1;				/**< @brief The value of x-coordinate of the first vertex. */
	int						y1;				/**< @brief The value of y-coordinate of the first vertex. */
	int						x2;				/**< @brief The value of x-coordinate of the second vertex. */
	int						y2;				/**< @brief The value of y-coordinate of the second vertex. */
	int						x3;				/**< @brief The value of x-coordinate of the third vertex. */
	int						y3;				/**< @brief The value of y-coordinate of the third vertex. */
	int						x4;				/**< @brief The value of x-coordinate of the fourth vertex. */
	int						y4;				/**< @brief The value of y-coordinate of the fourth vertex. */
	/**@}*/
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_HIGHLIGHTINFO in fpdf_base.h .
 * @brief Data structure for a highlight annotation. 
 */
struct FPDFEMB_ANNOT_HIGHLIGHTINFO
{
	unsigned int				size;			/**< @brief The size of the structure. */
	FPDFEMB_WCHAR				author[64];		/**< @brief The author of the annotation. */
	unsigned int				color;			/**< @brief The color of the annotation. */
	int							opacity;		/**< @brief The opacity of the annotation, from 0 to 100 */
	int							quad_count;		/**< @brief The quadrilateral count of the highlight annotation. */
	struct FPDFEMB_ANNOT_QUAD*	quads;			/**< @brief Quadrilaterals of the highlight annotation. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_LINE in fpdf_base.h .
 * @brief Data structure for line of annotation. 
*/
struct FPDFEMB_ANNOT_LINE
{
	int							point_count;	/**< @brief The point count of the line in annotation. */
	struct FPDFEMB_POINT*		points;			/**< @brief Points of the line in annotation. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_PENCILINFO in fpdf_base.h .
 * @brief Data structure for a pencil annotation.
 */
struct FPDFEMB_ANNOT_PENCILINFO
{
	unsigned int				size;			/**< @brief The size of the structure. */
	FPDFEMB_WCHAR				author[64];		/**< @brief The author of the annotation. */
	unsigned int				color;			/**< @brief The color of the annotation. */
	int							opacity;		/**< @brief The opacity of the annotation. */
	int							busebezier;		/**< @brief Whether to use the bezier curve to connect two points or not. */
	FPDFEMB_BOOL				boptimize;		/**< @brief Whether to optimize to decrease points on the line or not. */
	int							reserved1;		/**< @brief This is reserved, and it must be 0. */
	int							line_width;		/**< @brief The line width of the pencil annotation. */
	int							line_count;		/**< @brief The line count of the pencil annotation. */
	struct FPDFEMB_ANNOT_LINE*	lines;			/**< @brief Lines of the pencil annotation. */
};

/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for Image Types
 * @brief Used in the data structure for a stamp annotation.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_IMAGETYPE_BMP in fpdf_base.h .
 * @brief The type of the image is BMP.
 */
#define FPDFEMB_IMAGETYPE_BMP			1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_IMAGETYPE_JPG in fpdf_base.h .
 * @brief The type of the image is JPG.
 */
#define FPDFEMB_IMAGETYPE_JPG			2
/**@}*/

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_STAMPINFO in fpdf_base.h .
 * @brief Data structure for a stamp annotation.
 */
struct FPDFEMB_ANNOT_STAMPINFO
{
	unsigned int			size;			/**< @brief The size of the structure. */
	FPDFEMB_WCHAR			author[64];		/**< @brief The author of the annotation. */
	unsigned int			color;			/**< @brief The color of the annotation. */
	int						opacity;		/**< @brief The opacity of the annotation. */
	struct FPDFEMB_RECT		rect;			/**< @brief The rectangle of the annotation. */
	FPDFEMB_WCHAR			name[32];		/**< @brief The subject of the annotation. */
	int						imgtype;		/**< @brief The image type of the image data. */
	int						imgdatasize;	/**< @brief The image data buffer size. */
	unsigned char*			imgdata;;		/**< @brief The image data buffer. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_ANNOT_FILEATTACHMENTINFO in fpdf_base.h .
 * @brief Data structure for a file attachment annotation.
 */
struct FPDFEMB_ANNOT_FILEATTACHMENTINFO
{
	unsigned int			size;			/**< @brief The size of the structure. */
	FPDFEMB_WCHAR			author[64];		/**< @brief The author of the annotation. */
	unsigned int			color;			/**< @brief The color of the annotation. */
	int						opacity;		/**< @brief The opacity of the annotation. */
	int						icon;			/**< @brief This is reserved, and it must be 0. */
	struct FPDFEMB_RECT		rect;			/**< @brief The rectangle of the annotation. */
	FPDFEMB_WCHAR			filename[256];	/**< @brief The file name. */
	int						file_size;		/**< @brief The file data buffer size. */
	void*					file_data;		/**< @brief The file data buffer. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetCount in fpdf_annot.h .
 * @brief Get number of annotations in the page.
 *
 * @details This function must be called before any other annotation related function can
 *			be called for the page.
 *
 * @param[in] page			A page handle
 * @param[out] count		Used to received the count of annotations.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Annot_GetCount(FPDFEMB_PAGE page, int* count);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetAtPos in fpdf_annot.h .
 * @brief Get the index of the annotation which is the nearest one to a certain position on the page.
 *
 * @details	If there is no nearest annotation, the parameter <i>index</i> will be -1.
 *
 * @param[in] page			A page handle
 * @param[in] x				The value of X position in the PDF page coordination system, in hundredth of points.
 * @param[in] y				The value of Y position in the PDF page coordination system, in hundredth of points.
 * @param[out] index		A pointer to an integer used to receive the zero-based annotation index.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Annot_GetIndexAtPos(FPDFEMB_PAGE page, int x, int y, int* index);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetInfo in fpdf_annot.h .
 * @brief Get the information of the annotation.
 *
 * @details	The application must call ::FPDFEMB_Annot_GetCount first before it can call this function
 *			for any particular annotation.
 *			If the parameter <i>buffer</i> is <b>NULL</b>, then the parameter <i>bufsize</i> will receive
 *			the count of bytes required to store the annotation information.
 *			If the paramter <i>bufsize</i>(the size of <i>buffer</i>) is smaller than the required size, then this function
 *			will not copy any data, and return the error code ::FPDFERR_PARAM. And the required buffer size will 
 *			also be put into <i>bufsize</i>.<br>
 *			The data type of <i>buffer</i> depends on the parameter <i>infotype</i>,
 *			and different types are used:<br>
 *			<ul>
 *			<li>::FPDFEMB_ANNOTINFO_TYPE:		int</li>
 *			<li>::FPDFEMB_ANNOTINFO_AUTHOR:		::FPDFEMB_WCHAR</li>
 *			<li>::FPDFEMB_ANNOTINFO_RECT:		::FPDFEMB_RECT</li>
 *			<li>::FPDFEMB_ANNOTINFO_CONTENTS:	::FPDFEMB_WCHAR</li>
 *			<li>::FPDFEMB_ANNOTINFO_COLOR:		unsigned int</li>
 *			<li>::FPDFEMB_ANNOTINFO_OPACITY:	int</li>
 *			<li>::FPDFEMB_ANNOTINFO_LINEWIDTH:	int</li>
 *			</ul>
 *			When the data type is ::FPDFEMB_WCHAR, the output will be in Unicode, using UTF-16LE format. 
 *			It's terminated by two consecutive zero bytes.
 *
 * @param[in] page			A page handle
 * @param[in] index			A zero-based index used to specify the annotation.
 * @param[in] infotype		The type of the information. See the macro definitions <b>FPDFEMB_ANNOTINFO_XXX</b>.
 * @param[out] buffer		A buffer allocated by the application, or <b>NULL</b>. 
 *							If it has enough or larger size, it will be used to receive the information of the annotation.<br>
 *							Otherwise <i>buffer</i> will get nothing, and should be allocated enough size by using <i>bufsize</i> returned by this function.
 * @param[in,out] bufsize	A pointer to a number which indicates the size(count of bytes) of <i>buffer</i>
 *							 before this function is called. Then after the function returns, this paremeter will store
 *							the actual count of bytes of the annotation's information.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note	This function supports the following annotation types:<br>
 *			fileattachment, stamp, pencil, highlight, note.
 */
FPDFEMB_RESULT FPDFEMB_Annot_GetInfo(FPDFEMB_PAGE page, int index, int infotype, void* buffer, int* bufsize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_SetInfo in fpdf_annot.h .
 * @brief	Set the information of the specified annotation.
 * @param[in] page			A page handle
 * @param[in] index			A zero-based index of the annotation.
 * @param[in] infotype		The type of the information. See macro definitions <b>FPDFEMB_ANNOTINFO_XXX</b>.
 * @param[in] buffer		A buffer allocated by the application and used to set the information. <br>
 *							The data type of <i>buffer</i> depends on the parameter <i>infotype</i>.<br>
 *							See comments of ::FPDFEMB_Annot_GetInfo function upon.
 * @param[in] bufsize		The size(count of bytes) of <i>buffer</i>.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note	This function supports the following annotation types:<br>
 *			fileattachment, stamp, pencil, highlight, note.
 */
FPDFEMB_RESULT FPDFEMB_Annot_SetInfo(FPDFEMB_PAGE page, int index, int infotype, void* buffer, int bufsize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_Add in fpdf_annot.h .
 * @brief	Add an annotation to the page
 * @details	The data type of the parameter <i>data</i> depends on the parameter <i>annottype</i>,
 *			and different types are used:<br>
 *			Format:  Annot Type : Data type 
 *			<ul>
 *			<li>::FPDFEMB_ANNOT_NOTE:			::FPDFEMB_ANNOT_NOTEINFO</li>
 *			<li>::FPDFEMB_ANNOT_HIGHLIGHT:		::FPDFEMB_ANNOT_HIGHLIGHTINFO</li>
 *			<li>::FPDFEMB_ANNOT_PENCIL:			::FPDFEMB_ANNOT_PENCILINFO</li>
 *			<li>::FPDFEMB_ANNOT_STAMP:			::FPDFEMB_ANNOT_STAMPINFO</li>
 *			<li>::FPDFEMB_ANNOT_FILEATTACHMENT: ::FPDFEMB_ANNOT_FILEATTACHMENTINFO</li>
 *			</ul>
 * @param[in] page			A page handle.
 * @param[in] annottype		The type of the annotation which is to be added to the page. See macro definitions <b>FPDFEMB_ANNOT_xxx</b>.
 * @param[in] data			The data struct of the annotation.
 * @param[in] datasize		The data size (count of bytes). This value should be above 0.
 * @param[out] index		A pointer to an integer used to receive the zero-based index of the added annotation.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note	This function supports the following annotation types:<br>
 *			fileattachment, stamp, pencil, highlight, note.
 */
FPDFEMB_RESULT FPDFEMB_Annot_Add(FPDFEMB_PAGE page, int annottype, void* data, int datasize, int* index);

/**	
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_Delete in fpdf_annot.h .
 * @brief	Delete the specified annotation off page
 *
 * @param[in] page			A page handle.
 * @param[in] index			The zero-based index of the annotation which is to be deleted.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Annot_Delete(FPDFEMB_PAGE page, int index);

#ifdef __cplusplus
}
#endif

#endif	// #ifndef _FPDF_EMB_ANNOT_H_
