/**
 * @deprecated	As of release 2.0 version, this header file will not be used. 
 *				This header file will be replaced by fs_base.h, fpdf_base.h and fpdf_text.h .
 *
 * Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
 * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
 * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
 * Without SDK license agreement, you cannot redistribute anything.
 * @file fpdftextemb.h
 * @author	Foxit Corporation
 */


#ifdef __cplusplus
extern "C" {
#endif

/** 
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for External Error codes of Text Module
 */
/**@{*/
/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_UNPARSEDPAGE in fs_base.h.
 * @brief Returned when ::FPDFEMB_PAGE has not been parsed by ::FPDFEMB_StartParse. 
 */
#define FPDFERR_UNPARSEDPAGE 10
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_NOTEXTONPAGE in fs_base.h.
 * @brief Returned when there is no text information in the PDF page. 
 */
#define FPDFERR_NOTEXTONPAGE 11
/**@}*/

/********************************************************************************************
****
****		Initializition of Text Functionality
****
*********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_TEXTPAGE</b> in fpdf_base.h.
 * @brief Handler type for detailed text information in a page 
 */
typedef void* FPDFEMB_TEXTPAGE;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_LoadPage in fpdf_text.h .
 * @brief Prepare information about all characters in a page.
 *
 * @param[in]  page			Handle to the page that is returned by ::FPDFEMB_LoadPage. 
 * @param[out] textPage		Receives a handle to the text page information structure. If
 *							an error occurs, textPage is set to NULL.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note The application must call ::FPDFEMB_Text_CloseTextPage to release the text page information. 
 */
FPDFEMB_RESULT FPDFEMB_Text_LoadPage(FPDFEMB_PAGE page, FPDFEMB_TEXTPAGE* textPage);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_CloseTextPage in fpdf_text.h .
 * @brief Release all resources allocated for a text page information structure.   
 *			
 * @param[in] textPage	A handle to the text page information structure that is 
 *                      returned ::FPDFEMB_Text_LoadPage.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_CloseTextPage(FPDFEMB_TEXTPAGE textPage);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_CountChars in fpdf_text.h .
 * @brief Get the number of characters in a page. 
 *
 * @details Generated characters such as additonal space and new line characters are also counted.
 * Characters in a page form a "stream", inside the stream, each character has an index. 
 * Index parameters are used in most of the FPDFEMB_Text functions. The first character in 
 * the page has an index value of zero.
 *			
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[out] count		Receives the number of characters in the page. If an error 
 *							occurs, count is set to -1.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_CountChars(FPDFEMB_TEXTPAGE textPage, int* count);

/********************************************************************************************
****
****		Detailed Character Information
****
*********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_BOOL in fs_base.h.
 * @brief type definition for checking character generation status 
 */
typedef int	  FPDFEMB_BOOL;

/** 
 * @deprecated As of release 2.0, these macro definitions will not be used.
 * @name Macro Definitions for Text Direction Flags
 * @note These are used by ::FPDFEMB_Text_GetCharIndexByDirection
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_TEXT_LEFT in fpdf_base.h.
 * @brief Left direction.
 */
#define FPDFEMB_TEXT_LEFT	-1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_TEXT_RIGHT in fpdf_base.h.
 * @brief Right direction.
 */
#define FPDFEMB_TEXT_RIGHT	 1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_TEXT_UP in fpdf_base.h.
 * @brief Up direction.
 */
#define FPDFEMB_TEXT_UP		-2
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_TEXT_DOWN in fpdf_base.h.
 * @brief Down direction.
 */
#define FPDFEMB_TEXT_DOWN	 2
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetUnicode in fpdf_text.h .
 * @brief Get Unicode of a character in a page.   
 *			
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] unicode		Receives the Unicode representation of the character specified by index.
 *							If a character is not encoded in Unicode (the Foxit engine will not 
 *							convert it to unicode), unicode will be set to 0.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetUnicode(FPDFEMB_TEXTPAGE textPage, int index, unsigned int* unicode);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_IsGenerated in fpdf_text.h .
 * @brief Indicates whether a character is a generated character.   
 *			
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] isGenChar	Set to TRUE to indicate the character is a generated character, FALSE 
 *							indicates it is an actual character in the PDF page.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_IsGenerated(FPDFEMB_TEXTPAGE textPage, int index, FPDFEMB_BOOL* isGenChar);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetFontSize in fpdf_text.h .
 * @brief Get the font size of a character.   
 *			
 * @param[in]  textPage		A handle to the text page information structure that is 
 *                          returned by ::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] fontSize		Receives the font size of the character specified by index. The size is 
 *                          measured in points (about 1/72 inch). This is the typographic size 
 *							of the font referred to as "em size".
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetFontSize(FPDFEMB_TEXTPAGE textPage, int index, double* fontSize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetOrigin in fpdf_text.h .
 * @brief Get origin position of a particular character. 
 *		
 * @details The X and Y positions are measured in PDF "user space".
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] origin		A pointer to an ::FPDFEMB_POINT structure that receives the X and Y position 
 *							of the character origin.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetOrigin(FPDFEMB_TEXTPAGE textPage, int index, FPDFEMB_POINT* origin);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetCharBox in fpdf_text.h .
 * @brief Get bounding box of a particular character.
 *
 * @details All positions are measured in PDF "user space".
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] rect			A pointer to an ::FPDFEMB_RECT that receives the the 4 positions (left, right, 
 *							bottom, top)of the the character box.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetCharBox(FPDFEMB_TEXTPAGE textPage, int index, FPDFEMB_RECT* rect);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetMatrix in fpdf_text.h .
 * @brief Get the matrix of a particular character. 
 *
 * @details A matrix defines the transformation of coordinates from one space to another. 
 * In PDF, a matrix is defined by the following equations: 
 * <ul>
 * <li>x' = a * x + c * y + e; </li>
 * <li>y' = b * x + d * y + f; </li>
 * </ul>
 * ::FPDFEMB_Text_GetMatrix is used to get a,b,c,d coefficients of the transformation from 
 * "text space" to "user space". The e and f coefficients are origin position, which can be
 * obtained by calling ::FPDFEMB_Text_GetOrigin.
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] a			Receives coefficient "a" of the matrix. 
 * @param[out] b			Receives coefficient "b" of the matrix. 
 * @param[out] c			Receives coefficient "c" of the matrix. 
 * @param[out] d			Receives coefficient "d" of the matrix. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetMatrix(FPDFEMB_TEXTPAGE textPage, int index, double* a, double* b, 
																			double* c, double* d);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetCharIndexAtPos in fpdf_text.h .
 * @brief Get the index of a character at or nearby a specified position on the page.
 *
 * @param[in]  textPage		A handle to the text page information structure that is 
 *                          returned by ::FPDFEMB_Text_LoadPage.
 * @param[in]  x			X position in PDF "user space". 
 * @param[in]  y			Y position in PDF "user space". 
 * @param[in]  xTolerance	x-axis tolerance value for character hit detection, in point units. This should not be a negative.
 * @param[in]  yTolerance	y-axis tolerance value for character hit detection, in point units. This should not be a negative.
 * @param[out] charIndex	The zero-based index of the character at, or nearby the point (x,y). 
 *							If there is no character at or nearby the point, return value will 
 *							be -1. If an error occurs, -3 will be returned. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetCharIndexAtPos(FPDFEMB_TEXTPAGE textPage, double x ,double y, 
											  double xTolerance, double yTolerance, int* charIndex);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetCharIndexByDirection in fpdf_text.h .
 * @brief Move the character at "index" in the specified "direction" and return the new 
 *        character index.
 *
 * @param[in]  textPage		A handle to the text page information structure that is 
 *							returned by ::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index for the current character.
 * @param[in]  direction	A number indicating the moving direction. Can be one of the following: 
 *							<ul>
 *								<li>FPDFEMB_TEXT_LEFT</li>
 *								<li>FPDFEMB_TEXT_UP</li>  
 *								<li>FPDFEMB_TEXT_RIGHT</li>   
 *								<li>FPDFEMB_TEXT_DOWN</li> 
 *							</ul>
 * @param[out] charIndex	Zero-base character index for the new position. -1 if the beginning 
 *							of the page reached; -2 if the end of the page is reached. -3 for failures.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetCharIndexByDirection(FPDFEMB_TEXTPAGE textPage, int index, 
													int direction, int* charIndex);

/********************************************************************************************
****
****		Detailed Font Information
****
*********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FS_FONT</b> in fpdf_base.h.
 * @brief Font information handler type 
 */
typedef void* FPDFEMB_FONT;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetFont in fpdf_text.h .
 * @brief Get font of a particular character.
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index of the character.
 * @param[out] font			Receives a handle to the font used by the character specified by index. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetFont(FPDFEMB_TEXTPAGE textPage, int index, FPDFEMB_FONT* font);

/**
 * @brief Get font ascent (in 1/1000 em).
 *
 * @param[in]  font		Handle to a font returned by ::FPDFEMB_Text_LoadPage.
 * @param[out] ascent	Receives the accent (typically the above-baseline height of letter "h"),
 *						measured in 1/1000 of em size. If a character uses a font size (em size) 
 *						of 10 points, and it has an ascent value of 500 (meaning half of the em), 
 *                      then the ascent height will be 5 points (5/72 inch). 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Font_GetAscent(FPDFEMB_FONT font, int* ascent);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetFontDescent in fpdf_text.h .
 * @brief Get font descent (in 1/1000 em).
 *
 * @param[in]  font		Handle to a font returned by ::FPDFEMB_Text_LoadPage.
 * @param[out] descent	Receives the descent (typically the under-baseline height of letter "g"), 
 *						measured in 1/1000 of em size. Most fonts have a negative descent value.   
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Font_GetDescent(FPDFEMB_FONT font, int* descent);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetFontName in fpdf_text.h .
 * @brief Get the name of a font.
 *    
 * @param[in]	   font		Handle to a font returned by ::FPDFEMB_Text_LoadPage.
 * @param[out]     buffer	A buffer (allocated by the application) that receives the text.
 * @param[in,out]  buflen	If "buffer" is NULL, number of bytes needed,
 *							including the null terminator.
 *							Otherwise, number of bytes copied.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Font_GetName(FPDFEMB_FONT font, const char* buffer, int* buflen);

/********************************************************************************************
****
****		Detailed String Information
****
*********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetText in fpdf_text.h .
 * @brief Extract Unicode text string from the page.  
 *
 * @details This function ignores characters without Unicode information. 
 *
 * @param[in]      textPage		A handle to the text page information structure that is returned by 
 *								::FPDFEMB_Text_LoadPage.
 * @param[in]      start		Index for the start character. 
 * @param[in]      count		Number of characters to be extracted. 
 * @param[out]     buffer		A Unicode buffer (allocated by the application) that receives the text.
 * @param[in,out]  buflen		If "buffer" is NULL, number of characters (not bytes) needed,
 *								including the Unicode string terminator.
 *								Otherwise, number of characters (not bytes) copied.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note When <i>count</i> = -1 or the result of (<i>start</i> + <i>count</i>)is larger than the whole count of characters in the input text page, 
 *		 it means this function will get all charaters in the text page from the index <i>start</i> 
 *		 and set <i>rectCount</i> to be the count of charaters it actually got.<br>
 */
FPDFEMB_RESULT FPDFEMB_Text_GetText(FPDFEMB_TEXTPAGE textPage, int start, int count, 
									FPDFEMB_WCHAR* buffer, int* buflen);

/** 
 * @brief Count number of rectangular areas occupied by a segment of texts.  
 *
 * @details This function, along with ::FPDFEMB_Text_GetRect, can be used to detect the position 
 * of the text segment on a page. When highlighting text, it is the area corresponding to 
 * the text segment that is colored in. It will automatically merge small character 
 * boxes into bigger ones if those characters are on the same line and use same font settings. 
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  start		Index for the start character. 
 * @param[in]  count		Number of characters to be extracted.  -1 means to count all the rectangles in the page.
 * @param[out] rectCount		Number of rectangles. Zero for error. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note The value of the parameter <i>count</i> should be greater than or equal to -1.
 */
FPDFEMB_RESULT FPDFEMB_Text_CountRects(FPDFEMB_TEXTPAGE textPage, int start, int count, int* rectCount);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetRect in fpdf_text.h .
 * @brief Get a rectangular area from the result generated by ::FPDFEMB_Text_CountRects.   
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index for the rectangle.
 * @param[out] rect			A pointer to a ::FPDFEMB_RECT that receives the the 4 rectangle boundaries
 *							(left, top, right, bottom). 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note Assume that <i>nCount</i> is the result generated by ::FPDFEMB_Text_CountRects.<br>
 *		 The range of <i>index</i> should be 0 to (<i>nCount</i> - 1), including 0 and (<i>nCount</i> - 1).
 */
FPDFEMB_RESULT FPDFEMB_Text_GetRect(FPDFEMB_TEXTPAGE textPage, int index, FPDFEMB_RECT* rect);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetBoundedText in fpdf_text.h .
 * @brief Extract Unicode text within a rectangular boundary on the page.   
 *    
 * @param[in]      textPage	A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]      rect		::FPDFEMB_RECT that specifies the 4 rectangle boundaries
 *							(left, top, right, bottom).   
 * @param[out]     buffer	A Unicode buffer (allocated by the application) that receives the text.
 * @param[in,out]  buflen	If "buffer" is NULL, number of characters (not bytes) needed,
 *							including the Unicode string terminator.
 *							Otherwise, number of characters (not bytes) copied.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetBoundedText(FPDFEMB_TEXTPAGE textPage, FPDFEMB_RECT rect, 
										   FPDFEMB_WCHAR* buffer, int* buflen);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_CountBoundedSegments in fpdf_text.h .
 * @brief Get number of text segments within a rectangular boundary on the page. 
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  rect			A specified rectangle, in which the count of segments will be got. 
 * @param[out] count		Number of segments.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_CountBoundedSegments(FPDFEMB_TEXTPAGE textPage, FPDFEMB_RECT rect, int* count);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetBoundedSegment in fpdf_text.h .
 * @brief Get a particular segment. The total number of segments is returned by 
 *		  ::FPDFEMB_Text_CountBoundedSegments. 
 *
 * @param[in]  textPage		A handle to the text page information structure that is returned by 
 *							::FPDFEMB_Text_LoadPage.
 * @param[in]  index		Zero-based index for the segment.
 * @param[out] start		Pointer to an integer receiving the start character index for the segment.
 * @param[out] count		Pointer to an integer receiving number of characters in the segment. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note Assume that <i>nCount</i> is the result generated by ::FPDFEMB_Text_CountBoundedSegments.<br>
 *		 The range of <i>index</i> should be 0 to (<i>nCount</i> - 1), including 0 and (<i>nCount</i> - 1).
*/
FPDFEMB_RESULT FPDFEMB_Text_GetBoundedSegment(FPDFEMB_TEXTPAGE textPage, int index, int* start, int* count);

/********************************************************************************************
****
****		PDF Page Search Handler
****
*********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_SCHHANDLE</b> in fpdf_base.h.
 * @brief Search information handle type
 */
typedef void* FPDFEMB_SCHHANDLE;

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_FindStart in fpdf_text.h .
 * @brief Start a search. 
 *
 * @param[in]  textPage			A handle to the text page information structure that is returned by 
 *								::FPDFEMB_Text_LoadPage.
 * @param[in]  findWhat			A unicode match pattern. <br>
 *								If this parameter is <b>NULL</b> or the content to be find is <b>NULL</b>,
 *								the function will return ::FPDFERR_PARAM and set <i>searchHandle</i> to <b>NULL</b>.
 * @param[in]  flags			Indicate the find options.  Can be one of the following: 
 *								<ul>
 *									<li>FPDFEMB_MATCHCASE</li>
 *									<li>FPDFEMB_MATCHWHOLEWORD</li>	
 *								</ul>
 * @param[in]  startIndex		A zero-based index specifying the character from which the search will start. -1 means the end of the page.  
 * @param[out] searchHandle		A handle for the search context. ::FPDFEMB_Text_FindClose must be 
 *								called to release this handle. 		
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 * @note Assume that <i>count</i> means the count of charaters in the page. So the range of the parameter <i>startIndex</i> is from 0 to (<i>count</i> - 1).
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_FindStart(FPDFEMB_TEXTPAGE textPage, FPDFEMB_WCHAR* findWhat, unsigned long flags,
									  int startIndex, FPDFEMB_SCHHANDLE* searchHandle);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_FindNext in fpdf_text.h .
 * @brief Search in the direction from page start to end. 
 *
 * @param[in]  handle	A search context handle returned by ::FPDFEMB_Text_FindStart. 
 * @param[out] isMatch	Indicates whether a match is found.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_FindNext(FPDFEMB_SCHHANDLE handle, FPDFEMB_BOOL* isMatch);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_FindPrev in fpdf_text.h .
 * @brief Search in the direction from page end to start. 
 *
 * @param[in]  handle	A search context handle returned by ::FPDFEMB_Text_FindStart. 
 * @param[out] isMatch	Indicates whether a match is found.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_FindPrev(FPDFEMB_SCHHANDLE handle, FPDFEMB_BOOL* isMatch);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetSchResultIndex in fpdf_text.h .
 * @brief Get the starting character index of the search result. 
 *
 * @param[in]  handle	A search context handle returned by ::FPDFEMB_Text_FindStart. 
 * @param[out] index	Index for the starting character. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetSchResultIndex(FPDFEMB_SCHHANDLE handle, int* index);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_GetSchCount in fpdf_text.h .
 * @brief Get the number of matched characters in the search result.  
 *
 * @param[in]  handle	A search context handle returned by ::FPDFEMB_Text_FindStart. 
 * @param[out] count	Number of matched characters. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_GetSchCount(FPDFEMB_SCHHANDLE handle, int* count);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_FindClose in fpdf_text.h .
 * @brief Release a search context.     
 *
 * @param[in] handle	A search context handle returned by ::FPDFEMB_Text_FindStart. 
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Text_FindClose(FPDFEMB_SCHHANDLE handle);

/********************************************************************************************
****
****		Extracting Hyperlinks from Page Text
****
*********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_PAGELINK</b> in fpdf_base.h.
 * @brief PDF page extracted link information handle type.
 */
typedef void* FPDFEMB_PAGELINK;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_LoadWebLinks in fpdf_text.h .
 * @brief Process page text for URL formatted text.
 *
 * @details This function must be called before any other extracted link related function
 * can be called for the page.
 *
 * @param[in]	textPage	Handle to page specific text information.
 * @param[out]	linkPage	Receiving the handle to extracted link information.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLink_ExtractWebLinks(FPDFEMB_TEXTPAGE textPage, FPDFEMB_PAGELINK* linkPage);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_CountWebLinks in fpdf_text.h .
 * @brief Get number of URL formatted strings inside a page.
 *
 * @param[in]	linkPage	Handle to extracted links.
 * @param[out]	linkCount	Pointer to an integer receiving the number of links.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLink_GetCount(FPDFEMB_PAGELINK linkPage, int* linkCount);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_GetDest in fpdf_text.h .
 * @brief Get URL destination associated with a particular extracted hyperlink.
 *
 * @details If "url" is NULL, this function will return the data size.
 *
 * @param[in]  linkPage			Handle to extracted links.
 * @param[in]  linkIndex	Zero-based index for the link.
 * @param[out] buffer		Pointer to application allocated buffer for the entire
 *							::FPDFEMB_URLDEST structure.
 * @param[out] buflen		Pointer to an integer receiving data block size for the destination.
 *							If this parameter is NULL, then data size won't be retrieved.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 * @note In order to get a specified URL destination, the user should call this function twice. <br>
 *		 First, call this function to get the <i>buflen</i> of the URL which is to be got. And use the <i>buflen</i> to allocate the memory space for the member of ::FPDFEMB_URLDEST.<br>
 *		 Then call this function again, using the allocated ::FPDFEMB_URLDEST and the got <i>buflen</i>, to get the specified URL destination.<br>
 *		 Assume that <i>nCount</i> is the result generated by ::FPDFEMB_PageLink_GetCount.<br>
 *		 The range of <i>linkIndex</i> should be 0 to (<i>nCount</i> - 1), including 0 and (<i>nCount</i> - 1).
 */
FPDFEMB_RESULT FPDFEMB_PageLink_GetDest(FPDFEMB_PAGELINK linkPage, int linkIndex, 
										FPDFEMB_URLDEST* buffer, int* buflen);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_CountRects in fpdf_text.h .
 * @brief Get number of areas (rectangles) for an extracted link.
 *
 * @param[in]	linkPage		Handle to extracted links.
 * @param[in]	linkIndex	Zero-based index for the link.
 * @param[out]	count		Pointer to an integer receiving number of quadrilaterals.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLink_GetAreaCount(FPDFEMB_PAGELINK linkPage, int linkIndex, int* count);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_GetRect in fpdf_text.h .
 * @brief Get a particular rectangle for an extracted link.
 *
 * @details The result in "points" array are the X/Y coordinations for the four vertices
 * of the rectangle. Vertices are in the following order: lower left, lower
 * right, upper right, upper left.
 *
 * @param[in] linkPage			Handle to extracted links.
 * @param[in] linkIndex		Zero-based index for the link.
 * @param[in] areaIndex		Zero-based index for the quadrilateral.
 * @param[out] points		Pointer to an array consists 4 points, receiving coordinations.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLink_GetArea(FPDFEMB_PAGELINK linkPage, int linkIndex, int areaIndex, 
										struct FPDFEMB_POINT* points); 

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Link_CloseWebLinks in fpdf_text.h .
 * @brief Release extracted hyperlink information.
 *
 * @param[in] linkPage	Handle to extracted link information.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLink_DiscardWebLinks(FPDFEMB_PAGELINK linkPage);

#ifdef __cplusplus
};
#endif
