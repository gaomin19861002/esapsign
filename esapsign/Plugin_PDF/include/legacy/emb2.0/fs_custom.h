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
 * @file	fs_custom_r.h
 * @brief	Header file for custom interfaces of Foxit PDF SDK.
 * @details	This header file defines basic data types and functions. Other modules all depend on this base one.<br>
 *			It contains:<br>
 *			<ul>
 *			<li>1. Font supports: font mapper, creation and properties access. </li>
 *			</ul>
 *
 * @note	If you want to purchase Foxit PDF SDK license and use ANY of the following functions, please request for enabling Base module explicitly.
 */
#ifndef _FS_CUSTOM_H_
#define _FS_CUSTOM_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _FS_DEF_FONTMAPPEREX2_
#define _FS_DEF_FONTMAPPEREX2_

/**
 * @brief Defines interface for system font mapper.
 */
typedef struct _FS_FONT_DATA_MAPPER2_
{
	/** @brief The size of the data structure. It must be set to <I>sizeof</I>(::FS_FONT_DATA_MAPPER). */
	FS_DWORD	lStructSize;

	/** @brief A user pointer, used by the application. */
	FS_LPVOID	clientData;	

	/**
	 * @brief Find font Data for a particular PDF font
	 *
	 * @param[in] clientData	The user-supplied data.
	 * @param[in] name			The font name.
	 * @param[in] charset		Charset ID. See macro definitions <b>FS_CHARSET_XXX</b>.
	 * @param[in] flags			Font flags. See macro definitions <b>FS_FONT_XXX</b>. 
	 * @param[in] weight		Weight of the font. Range from 100 to 900. 400 is normal,
	 * 							700 is bold.
	 * @param[out] fontdata		Pointer to the external data.
	 * @param[out] fontsize     Number of bytes in the external data.
 	 * @param[out] face_index	Receiving an zero-based index value for the font face, if the 
	 * 							mapped font file is a "collection" (meaning a number of faces 
	 *							are stored in the same file). If the font file is not a 
	 *							collection, the index value should be zero.
	 * @param[out] font_scale	The font scale.
	 *
	 * @return	Non-zero for a substitution font has be specified.
	 *			Zero if the mapper doesn't map the font, or something is wrong.
	 */
	FS_BOOL		(*MapFont)(FS_LPVOID clientData, FS_LPCSTR name, FS_INT32 charset,
						   FS_DWORD flags, FS_INT32 weight,
						   FS_LPSTR* fontdata, FS_INT32* fontsize, FS_INT32* face_index, FS_FLOAT* face_scale);

} FS_FONT_DATA_MAPPER2;
#endif

FS_RESULT FS_Font_SetFontDataMapper2(FS_FONT_DATA_MAPPER2* mapper);

#ifdef __cplusplus
};
#endif

#endif /* _FS_CUSTOM_H_ */
/**@}*/
