/**
 * @deprecated	As of release 2.0 version, this header file will not be used. 
 *				This header file will be replaced by fpdf_base.h, fs_base.h and fpdf_document.h .
 *
 * Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
 * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
 * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
 * Without SDK license agreement, you cannot redistribute anything.
 * @file fpdf_emb_docsaver.h
 * @author	Foxit Corporation
 */


#ifndef _FPDF_EMB_DOCSAVER_H_
#define _FPDF_EMB_DOCSAVER_H_

#ifdef __cplusplus
extern "C" {
#endif


/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FILEWRITE in fs_base.h .
 * @brief  Structure for describing the way to access a file (write only).
 */
struct FPDFEMB_FILEWRITE_ACCESS 
{
	/**
	 * @brief Get the current size of the file.
	 *
	 * @param[in] file			A pointer to this file access structure.
	 * @return The file size, in bytes. -1 means error.
	 */
	unsigned int	(*GetSize)(struct FPDFEMB_FILEWRITE_ACCESS* file);

	/**
	 * @brief	Write a data block to the file.
	 *
	 * @param[in] file			A pointer to this file access structure.
	 * @param[in] buffer		A pointer to a buffer containing the data which is to be written into the file.
	 * @param[in] offset		The offset in byte for the block, from the beginning of the file.
	 * @param[in] size			The count of bytes of the block.
	 * @return	::FPDFERR_SUCCESS means success.<br>
	 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
	 */
	FPDFEMB_RESULT	(*WriteBlock)(struct FPDFEMB_FILEWRITE_ACCESS* file, const void* buffer,
									unsigned int offset, unsigned int size);
	/**
	 * @brief	Flush a stream.
	 *
	 * @param[in] file			A pointer to this file access structure.
	 * @return	::FPDFERR_SUCCESS means success.<br>
	 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
	 */
	FPDFEMB_RESULT	(*Flush)(struct FPDFEMB_FILEWRITE_ACCESS* file);

	/**< @brief A user pointer, used by the application. */
	void*			user;		
};

/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for Saving Flags
 * @brief These are used for saving document.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_SAVEAS_INCREMENTAL in fpdf_base.h .
 * @brief Save the document incrementally. 
 */
#define FPDFEMB_SAVEAS_INCREMENTAL		1
/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_SAVEAS_NOORIGINAL in fpdf_base.h .
 * @brief Save the document without the original one. 
 */
#define FPDFEMB_SAVEAS_NOORIGINAL		2
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_SaveAs in fpdf_document.h .
 * @brief Save the modified document to a new file.
 *
 * @param[in] document		A document handle .
 * @param[in] file			A pointer to a file write access structure.
 * @param[in] flag			The saving flags. See macro definitions  <b>FPDFEMB_SAVEAS_XXX</b>.
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. This can be <b>NULL</b> if you
 *							don't want to pause.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartSaveDocumentAs(FPDFEMB_DOCUMENT document, struct FPDFEMB_FILEWRITE_ACCESS* file,
										   int flag, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will not be used .
 * @brief	Continue saving a PDF document to a new file. But now this function is <b>invalid</b>.
 *
 * @param[in] document		Document handle returned by FPDFEMB_StartLoadDocument function
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. This can be NULL if you
 *							don't want to pause.
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 * @note	This function is <b>invalid</b> now.
 */
FPDFEMB_RESULT FPDFEMB_ContinueSaveDocumentAs(FPDFEMB_DOCUMENT document, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_ReloadDocument in fpdf_document.h .
 * @brief	Reload a document after it has been modified .
 *
 * @details The document reloading is a progressive process. It might take a long time to
 *			reload the document. <br>
 *			Actually, this function just parses the document again after it has been modified.
 *
 * @param[in] document		A document handle 
 * @param[in] file			A pointer to file access structure.
 *							This structure must be kept valid before next reloading.
 * @param[in] password		A pointer to a zero-terminated byte string, for the password.
 *							Or <b>NULL</b> for no password.
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. <br>
 *							<b>This should be NULL because of not being supported now.</b>
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartReloadDocument(FPDFEMB_DOCUMENT document, struct FPDFEMB_FILE_ACCESS* file, 
										   const char* password, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will not be used .
 * @brief Continue reloading a PDF document. But now this function is <b>invalid</b>.
 *
 * @param[in] document		A document handle returned by ::FPDFEMB_StartLoadDocument function
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. This can be <b>NULL</b> if you
 *							don't want to pause.
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 * @note	This function is <b>invalid</b> now.
 */
FPDFEMB_RESULT FPDFEMB_ContinueReloadDocument(FPDFEMB_DOCUMENT document, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for Document Permissions
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_PRINT in fpdf_base.h .
 * @brief Set if the user is allowed to print. 
 */
#define FPDFEMB_PERMISSION_PRINT			0x0004
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_MODIFY in fpdf_base.h .
 * @brief Set if the user is allowed to modify. 
 */
#define FPDFEMB_PERMISSION_MODIFY			0x0008
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_EXTRACT in fpdf_base.h .
 * @brief Set if the user is allowed to extract content. 
 */
#define FPDFEMB_PERMISSION_EXTRACT			0x0010
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_ANNOTFORM in fpdf_base.h .
 * @brief Set if the user is allowed to annotate. 
 */
#define FPDFEMB_PERMISSION_ANNOTFORM		0x0020
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_FILLFORM in fpdf_base.h .
 * @brief Set if the user is allowed to modify form field data. 
 */
#define FPDFEMB_PERMISSION_FILLFORM			0x0100
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_EXTRACTACCESS in fpdf_base.h .
 * @brief Set if the user is allowed to extract content. 
 */
#define FPDFEMB_PERMISSION_EXTRACTACCESS	0x0200
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_ASSEMBLE in fpdf_base.h .
 * @brief Set if the user is allowed to organize the document. 
 */
#define FPDFEMB_PERMISSION_ASSEMBLE			0x0400
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_PERMISSION_PRINT_HIGH in fpdf_base.h .
 * @brief Set if the user is allowed to print at highest quality. 
 */
#define FPDFEMB_PERMISSION_PRINT_HIGH		0x0800
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_GetPermissions in fpdf_document.h .
 * @brief Get permission flags specified by a PDF document
 *
 * @param[in] document		A document handle returned by the function ::FPDFEMB_StartLoadDocument.
 *
 * @return The permission flag. See macro definitions <b>FPDFEMB_PERMISSION_xxx</b>.<br>
 *         Document permissions are set bitwise in the return value.<br>
 *			0 means parameter error.
 */
unsigned int FPDFEMB_GetDocumentPermissions(FPDFEMB_DOCUMENT document);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_AddModifyMark in fpdf_document.h .
 * @brief	Add some mark string on the special page.
 *			Only English text string is supported for now.
 *
 * @param[in] document		A document handle returned by the function ::FPDFEMB_StartLoadDocument.
 * @param[in] page			A page handle.
 * @param[in] x				The value of the X position in the PDF page coordination system, in hundredth of points.
 * @param[in] y				The value of the Y position in the PDF page coordination system, in hundredth of points.
 * @param[in] fontsize		The font size which is to be used to write the string, in hundredth of an actual font size.<br>
 *							For example, if you want to set the font size to be 10, you should set the paramter <i>fontsize</i>to be 2000.
 * @param[in] string		The text string which is to be written on the page.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_AddDocumentModifyMark(FPDFEMB_DOCUMENT document, FPDFEMB_PAGE page, 
											 int x, int y, int fontsize, char* string);

#ifdef __cplusplus
}
#endif

#endif // _FPDF_EMB_DOCSAVER_H_