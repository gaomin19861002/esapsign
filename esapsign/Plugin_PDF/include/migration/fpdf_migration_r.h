/**
 * Copyright (C) 2001-2014, Foxit Corporation.
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation.
 * You cannot distribute any part of Foxit PDF SDK to any third party or general public, 
 * unless there is a separate license agreement with Foxit Corporation which explicitly grants you such rights.
 *
 * @file	fpdf_migration_r.h
 * @brief	Header file for \ref FPDFMIGRATION "PDF Migration" module of Foxit PDF SDK.
 * @details	This header file provides migration access to different Foxit PDF SDKs.<br>
 *			It contains:<br>
 *			<ul>
 *			<li>1. Different Foxit SDK PDF Document object migration. </li>
 *			<li>2. Different Foxit SDK PDF Page object migration. </li>
 *			</ul>
 *
  * @note	The APIs listed in this file are under the license control of "PDF Migration" module in PDF SDK.<br>
 *			Please make sure the license of PDF Migration module is purchased and apply the license before 
 *			calling APIs in this file. <br>
 */
#ifndef _FPDF_MIGRATION_R_H_
#define _FPDF_MIGRATION_R_H_

/** 
 * @defgroup	FPDFMIGRATION PDF Migration
 * @brief		Definitions for migration access to different Foxit PDF SDKs.<br>
 *				Definitions and functions in this module are included in fpdf_migration_r.h.<br>
 *				Module: PDFMigration<br>
 *				License Identifier: Migration/All<br>
 *				Available License Right: Reading
 * @details		This module contains following features:<br>
 *				<ul>
 *				<li>1. Support DLL SDK and SDK4.0 documents and pages migration.</li>
 *				<li>2. Support EMB2.0 SDK and SDK4.0 documents and pages migration.</li>
 *				<li>3. Support EMB1.0 SDK and SDK4.0 documents and pages migration.</li>
 *				</ul>
 */
/**@{*/

#ifdef __cplusplus
extern "C" {
#endif

/** @brief	Handle type to a DLL PDF document. */
typedef void*	FSCRT_DLLDOCUMENT;
/** @brief	Handle type to a DLL PDF page. */
typedef void*	FSCRT_DLLPAGE;
/** @brief	Handle type to a EMB2.0 PDF document. */
typedef void*	FSCRT_EMB2DOCUMENT;
/** @brief	Handle type to a EMB2.0 PDF page. */
typedef void*	FSCRT_EMB2PAGE;
/** @brief	Handle type to a EMB1.0 PDF document. */
typedef void*	FSCRT_EMB1DOCUMENT;
/** @brief	Handle type to a EMB1.0 PDF page. */
typedef void*	FSCRT_EMB1PAGE;

/**
 * @brief	Create a migration SDK4.0 PDF document object based on DLL PDF document object.
 *
 * @param[in]	srcDoc	Handle to a <b>FSCRT_DLLDOCUMENT</b> object indicating a DLL PDF document.
 * @param[out]	destDoc	Pointer to a <b>FSCRT_DOCUMENT</b> handle that receives a migration SDK4.0 PDF document.
 *						If there are any errors, it will be <b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcDoc</i> or <i>destDoc</i> is a <b>NULL</b> pointer.<br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable errors.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_DLLToSDK_CreateDoc(FSCRT_DLLDOCUMENT srcDoc, FSCRT_DOCUMENT* destDoc);

/**
 * @brief	Release a migration SDK4.0 PDF document.
 *
 * @param[in]	doc		Handle to a <b>FSCRT_DOCUMENT</b> object which is a migration SDK4.0 PDF document.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS for success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>doc</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_DLLToSDK_ReleaseDoc(FSCRT_DOCUMENT doc);

/**
 * @brief	Create a migration SDK4.0 PDF page object from DLL PDF page object.
 *
 * @param[in]	srcPage		Handle to a <b>FSCRT_DLLPAGE</b> object which is a DLL PDF page object.
 * @param[out]	destPage	Pointer to a <b>FSCRT_PAGE</b> handle that receives a migration SDK4.0 PDF page object.
 *							If there are any errors, it will be <b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcPage</i> or <i>destPage</i> is <b>NULL</b> <br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable error occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @note	If applications don't call function ::FSPDF_DLLToSDK_CreateDoc to create a document , only call this function 
 *			to create a page, applications shall call function ::FSPDF_DLLToSDK_ReleaseDoc to release 
 *			the document got by the function ::FSCRT_Page_GetDocument.
 *
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_DLLToSDK_CreatePage(FSCRT_DLLPAGE srcPage, FSCRT_PAGE* destPage);

/**
 * @brief	Release a migration SDK4.0 PDF page.
 *
 * @param[in]	page	Handle to a <b>FSCRT_PAGE</b> object which is a migration SDK4.0 PDF page object.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>page</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_DLLToSDK_ReleasePage(FSCRT_PAGE page);

/**
 * @brief	Create a migration SDK4.0 PDF document based on EMB2.0 PDF document.
 *
 * @param[in]	srcDoc	Handle to a <b>FSCRT_EMB2DOCUMENT</b> object which is an EMB2.0 PDF document.
 * @param[out]	destDoc	Pointer to a <b>FSCRT_DOCUMENT</b> handle that receives a migration SDK4.0 PDF document.
 *						If there are any errors, it will be <b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcDoc</i> or <i>destDoc</i> is <b>NULL</b>.<br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable error occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_EMB2ToSDK_CreateDoc(FSCRT_EMB2DOCUMENT srcDoc, FSCRT_DOCUMENT* destDoc);

/**
 * @brief	Release a migration SDK4.0 PDF document.
 *
 * @param[in]	doc		Handle to a <b>FSCRT_DOCUMENT</b> object which is a migration SDK4.0 PDF document.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>doc</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_EMB2ToSDK_ReleaseDoc(FSCRT_DOCUMENT doc);

/**
 * @brief	Create a migration SDK4.0 PDF page based on EMB2.0 PDF page.
 *
 * @param[in]	srcPage		Handle to a <b>FSCRT_EMB2PAGE</b> which is a EMB2.0 PDF page.
 * @param[out]	destPage	Pointer to a <b>FSCRT_PAGE</b> handle that receives a migration SDK4.0 PDF page.
 *							If there are any errors, it will be set<b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if succeeds.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcPage</i> or <i>destPage</i> is <b>NULL</b>.<br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable errors occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @note	If applications haven't called the function ::FSPDF_EMB2ToSDK_CreateDoc to create a document, and only calling this function 
 *			to create a page, applications shall call the function ::FSPDF_EMB2ToSDK_ReleaseDoc to release 
 *			the document returned from the function ::FSCRT_Page_GetDocument.
 *
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_EMB2ToSDK_CreatePage(FSCRT_EMB2PAGE srcPage, FSCRT_PAGE* destPage);

/**
 * @brief	Release a migration SDK4.0 PDF page.
 *
 * @param[in]	page	Handle to a <b>FSCRT_PAGE</b> object which is a migration SDK4.0 PDF page.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>page</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_EMB2ToSDK_ReleasePage(FSCRT_PAGE page);

/**
 * @brief	Create a migration SDK4.0 PDF document based on EMB1.0 PDF document.
 *
 * @param[in]	srcDoc	Handle to a <b>FSCRT_EMB1DOCUMENT</b> object which is a EMB1.0 PDF document.
 * @param[out]	destDoc	Pointer to a <b>FSCRT_DOCUMENT</b> handle that receives the migration SDK4.0 PDF document.
 *						If there are any errors, it will be set<b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcDoc</i> or <i>destDoc</i> is <b>NULL</b>.<br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable error occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_EMB1ToSDK_CreateDoc(FSCRT_EMB1DOCUMENT srcDoc, FSCRT_DOCUMENT* destDoc);

/**
 * @brief	Release a migration SDK4.0 PDF document.
 *
 * @param[in]	doc		Handle to a <b>FSCRT_DOCUMENT</b> object which is a migration SDK4.0 PDF document.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>doc</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_EMB1ToSDK_ReleaseDoc(FSCRT_DOCUMENT doc);

/**
 * @brief	Create a migration SDK4.0 PDF page based on EMB1.0 PDF page.
 *
 * @param[in]	srcPage		Handle to a <b>FSCRT_EMB1PAGE</b> object which is a EMB1.0 PDF page.
 * @param[out]	destPage	Pointer to a <b>FSCRT_PAGE</b> handle that receives the SDK4.0 PDF page.
 *							If there are any errors, it will be set<b>NULL</b>.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>srcPage</i> or <i>destPage</i> is <b>NULL</b>.<br>
 *			::FSCRT_ERRCODE_INVALIDMODULE if a PDF module is not initialized.<br>
 * 			::FSCRT_ERRCODE_UNRECOVERABLE if an unrecoverable error occurs.<br>
 * 			::FSCRT_ERRCODE_OUTOFMEMORY if there is not enough memory or invalid memory access.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @note	If applications haven't called the function ::FSPDF_EMB1ToSDK_CreateDoc to create a document, only calling this function 
 *			to	create a page, applications shall the ::FSPDF_EMB1ToSDK_ReleaseDoc function to release 
 *			the document returned from the function ::FSCRT_Page_GetDocument.
 *
 * @attention	<b>Thread Safety</b>: this function is thread safe.
 */
FS_RESULT FSPDF_EMB1ToSDK_CreatePage(FSCRT_EMB1PAGE srcPage, FSCRT_PAGE* destPage);

/**
 * @brief	Release a migration SDK4.0 PDF page.
 *
 * @param[in]	page	Handle to a <b>FSCRT_PAGE</b> object which is a migration SDK4.0 PDF page.
 *
 * @return	::FSCRT_ERRCODE_SUCCESS if success.<br>
 *			::FSCRT_ERRCODE_PARAM if a parameter <i>page</i> is <b>NULL</b>.<br>
 *			For more error codes, please refer to macro definitions <b>FSCRT_ERRCODE_XXX</b>.
 * 
 * @attention	<b>Thread Safety</b>: this function is not thread safe. Applications need to make sure thread safety
 *				 when the same objects are accessed during multi-thread environment.
 */
FS_RESULT FSPDF_EMB1ToSDK_ReleasePage(FSCRT_PAGE page);

#ifdef __cplusplus
};
#endif

/**@}*/ /* group FPDFMIGRATION */

#endif //_FPDF_MIGRATION_R_H_

