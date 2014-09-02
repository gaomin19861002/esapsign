   
/**
 * @deprecated	As of release 2.0 version, this header file will not be used. 
 *				This header file will be replaced by fs_base.h, fpdf_view.h, fpdf_document.h, fpdf_text.h and fs_exception.h.
 *
 * Copyright (C) 2014 Foxit Corporation. All Rights Reserved.
 * The following code is copyrighted and contains proprietary information and trade secrets of Foxit Corporation. 
 * You can only redistribute files listed below to customers of your application, under a written SDK license agreement with Foxit. 
 * You cannot distribute any part of the SDK to general public, even with a SDK license agreement. 
 * Without SDK license agreement, you cannot redistribute anything.
 * @file fpdfemb.h
 * @author	Foxit Corporation
 */

#ifndef _FPDFEMB_H_
#define _FPDFEMB_H_

#ifdef __cplusplus
extern "C" {
#endif

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_RESULT in fs_base.h .
 * @brief Standard return type for many FPDFEMB functions: ::FPDFERR_SUCCESS for success, otherwise error code. 
 */
typedef int FPDFEMB_RESULT;

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_BOOL in fs_base.h .
 * @brief Standard boolean type: 0 for false, non-zero for true. 
 */
typedef int FPDFEMB_BOOL;

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_WCHAR in fs_base.h .
 * @brief Unicode character. FPDFEMB uses UTF16LE format for unicode string.
 */
typedef unsigned short FPDFEMB_WCHAR;

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Error codes for FPDFEMB SDK
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_SUCCESS in fs_base.h .
 * @brief Success.
 */
#define FPDFERR_SUCCESS		0
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_MEMORY in fs_base.h .
 * @brief Out of memory.
 */
#define FPDFERR_MEMORY		1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_ERROR in fs_base.h .
 * @brief Error of any kind, without specific reason.
 */
#define FPDFERR_ERROR		2
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_PASSWORD in fs_base.h .
 * @brief Incorrect password.
 */
#define FPDFERR_PASSWORD	3
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_FORMAT in fs_base.h .
 * @brief File or data format error.
 */
#define FPDFERR_FORMAT		4
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_FILE in fs_base.h .
 * @brief File access error.
 */
#define FPDFERR_FILE		5
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_PARAM in fs_base.h .
 * @brief Parameter error.
 */
#define FPDFERR_PARAM		6
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_STATUS in fs_base.h .
 * @brief Not in correct status.
 */
#define FPDFERR_STATUS		7
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_TOBECONTINUED in fs_base.h .
 * @brief To be continued.
 */
#define FPDFERR_TOBECONTINUED	8
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_ERR_NOTFOUND in fs_base.h .
 * @brief Search result not found.
 */
#define FPDFERR_NOTFOUND	9
/**@}*/ 

/********************************************************************************************
****
****		Library Memory Management
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_MEM_MGR in fs_base.h .
 * @brief	Including interfaces implemented by host application, providing memory allocation
 *			facilities. All members are required.
 * @details	A memory manager structure is required to be valid during the entire period
 *			when an application using FPDFEMB module.
 *
 * @note	Using of this interface is strongly not recommended, because
 *			FPDFEMB now internally use FPDFEMB_MEMMGR_EX interface, which allows more
 *			advanced memory management. This interface is retained for backward compatibility
 *			only, and maybe discontinued in the future.
 */
struct FPDFEMB_MEMMGR {
	/**
	 * @brief Allocate a memory block.
	 *
	 * @details	In order to handle OOM situation, application can use longjmp() inside 
	 *			implementation of this function. If underlying memory manager fails to 
	 *			allocate enough memory, then application can use longjmp() to jump to
	 *			OOM handling codes.
	 *
	 * @param[in] pMgr		Pointer to the memory manager.
	 * @param[in] size		Number of bytes for the memory block.
	 * @return The pointer to allocated memory block. NULL if no memory available.
	 */
	void*			(*Alloc)(struct FPDFEMB_MEMMGR* pMgr, unsigned int size);

	/**
	 * @brief Allocate a memory block, without leaving.
	 *
	 * @details	Implementation MUST return NULL if no memory available, no exception
	 *			or longjmp() can be used.
	 *
	 * @param[in] pMgr		Pointer to the memory manager.
	 * @param[in] size		Number of bytes for the memory block.
	 * @return The pointer to allocated memory block. NULL if no memory available.
	 */
	void*			(*AllocNL)(struct FPDFEMB_MEMMGR* pMgr, unsigned int size);

	/**
	 * @brief Reallocate a memory block.
	 *
	 * @details	If an existing memory block specified, the data in the memory block will
	 *			be copied to the new block, if reallocated.<br>
	 *			In order to handle OOM situation, application can use longjmp() inside 
	 *			implementation of this function. If underlying memory manager fails to 
	 *			allocate enough memory, then application can use longjmp() to jump to
	 *			OOM handling codes.
	 *
	 * @param[in] pMgr		Pointer to the memory manager.
	 * @param[in] pointer	An existing memory block, or NULL.
	 * @param[in] new_size	New size (number of bytes) of the memory block. Can be zero.
	 * @return The pointer of reallocated memory block, it could be a new block, or just
	 *		the previous block with size modified.
	 */
	void*			(*Realloc)(struct FPDFEMB_MEMMGR* pMgr, void* pointer, unsigned int new_size);

	/**
	 * @brief Free a memory block.
	 *
	 * @param[in] pMgr		Pointer to the memory manager.
	 * @param[in] pointer	An existing memory block.
	 * @return None.
	 */
	void			(*Free)(struct FPDFEMB_MEMMGR* pMgr, void* pointer);
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_Init in fs_base.h .
 * @brief Initialize the FPDFEMB module.
 *
 * @details This function will allocate necessary internal data structure for
 *			the whole module to operate.
 *
 * @param[in] mem_mgr		Pointer to memory manager structure.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Init(struct FPDFEMB_MEMMGR* mem_mgr);

/** 
 * @deprecated As of release 2.0, this will be replaced by FPDF_FIXED_OOM_HANDLER in ::FS_MEM_FIXEDMGR structure in fs_base.h .
 * @brief Fixed memory OOM(out-of-memory) handler type.
 */ 
typedef void (*FPDFEMB_FIXED_OOM_HANDLER)(void* memory, int size);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_InitFixed in fs_base.h .
 * @brief Initialize the FPDFEMB module, providing a fixed memory heap.
 *
 * @details In many embedded system, memory usage are predetermined. The application
 *			is assigned with fixed size of available memory, then it can pre-allocate
 *			a memory block with maximum size and pass to this function to initialize
 *			FPDFEMB module. In this case, FPDFEMB won't need any additional memory
 *			allocation.<br>
 *			In case the pre-allocated memory has run out, the "oom_proc" callback
 *			function will be called to notify the application that an OOM recovery
 *			procedure needs to be performed.
 *
 * @param[in] memory		Pointer to a pre-allocated memory block.
 * @param[in] size			Number of bytes in the memory block.
 * @param[in] oom_handler	Pointer to a function which will be called when OOM happens. Can be
 *							NULL if application doesn't want to be notified OOM.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_InitFixedMemory(void* memory, int size, FPDFEMB_FIXED_OOM_HANDLER oom_handler);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_MEM_FIXEDMGR in fs_base.h .
 * @brief	Interfaces for extensible fixed memory manager. This kind of memory manager starts with
 *			a fixed memory pool but when it runs out, the manager will call out and ask for more
 *			memory.
 */
struct FPDFEMB_MEMMGR2
{
	/**
	 * @brief Called when FPDFEMB memory manager needs more memory to allocate some block.
	 * 
	 * @param[in] pMgr			Pointer to this structure.
	 * @param[in] alloc_size	Size of object FPDFEMB is trying to allocate.
	 * @param[out] new_memory	Receiving newly allocated memory pool.
	 * @param[out] new_size		Receiving newly allocated size. This size must be same or bigger than alloc_size.
	 * @return Nonzero for successfully allocated new memory pool, zero for memory not available.
	 */
	FPDFEMB_BOOL	(*More)(struct FPDFEMB_MEMMGR2* pMgr, int alloc_size, void** new_memory, int* new_size);

	/**
	 * @brief Called when a memory pool become empty and can be released
	 *
	 * @param[in] pMgr			Pointer to this structure
	 * @param[in] memory		Pointer to the memory pool
	 * @return None.
	 */
	void			(*Free)(struct FPDFEMB_MEMMGR2* pMgr, void* memory);
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_GetExtraMemoryUsedSize in fs_base.h .
 * @brief Get the size of the occupied memory.	
 *
 * @details	This function is used to count memory applied for by More(), and exclude the part initialized by the ::FPDFEMB_InitFixedMemory2.
 *
 * @return size		The size of the occupied memory. 
 */
int FPDFEMB_GetExtralMemoryUsedSize();


/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_InitFixed in fs_base.h .
 * @brief Initialize FPDFEMB using an extensible fixed memory manager. With this kind of manager,
 *			when current memory pool runs out, the application may provide some additional memory block
 *			for the manager to use.
 *
 * @param[in] memory			Pointer to a pre-allocated memory block
 * @param[in] size				Number of bytes in the memory block
 * @param[in] callbacks			Callback functions when FPDFEMB runs out of current memory pool, or
 *								when a pool become empty and can be dropped
 * @param[in] oom_handler		Pointer to a function which will be called when OOM happens. Can be
 *								NULL if application doesn't want to be notified om OOM.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_InitFixedMemory2(void* memory, int size, struct FPDFEMB_MEMMGR2* callbacks, FPDFEMB_FIXED_OOM_HANDLER oom_handler);

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Macro Definitions for Memory Management Flags
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FS_MEM_NONLEAVE in fs_base.h .
 * @brief Non-leave. 
 */
#define FPDFEMB_NONLEAVE		1
/** 
 * @deprecated As of release 2.0, this will not be used .
 * @brief Movable.
 */
#define FPDFEMB_MOVABLE			2
/** 
 * @deprecated As of release 2.0, this will not be used .
 * @brief Discardable.
 */
#define FPDFEMB_DISCARDABLE		4
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_MEM_MGR_EX in fs_base.h .
 * @brief	This is an extended version of memory manager interface, allowing advanced
 *			memory management, including movable and discardable memory blocks.
 *
 * @note	Use this interface with FPDFEMB_InitEx function.
 */
struct FPDFEMB_MEMMGR_EX {

	int				m_Size;		/**< @brief size of the structure. */

	/**
	 * @brief Allocate a memory block.
	 *
	 * @details The implementation should not do any action if no memory available,
	 *			just return NULL. OOM handling can be done in OOM_Handler interface.
	 *
	 * @param[in] pMgr			Pointer to the memory manager.
	 * @param[in] size			Number of bytes for the memory block.
	 * @param[in] flags			A combination of flags defined above.
	 * @return The pointer to allocated memory block. NULL if no memory available.
	 *		If FPDFEMB_MOVABLE flag is used, implementation should return a handle
	 *		to the memory block, if it supports movable block allocation.
	 */
	void*			(*Alloc)(struct FPDFEMB_MEMMGR_EX* pMgr, unsigned int size, int flags);

	/**
	 * @brief OOM (out-of-memory) situation handler.
	 *
	 * @details In order to handle OOM situation, application can use longjmp() inside 
	 *		implementation of this function.
	 *
	 * @param[in] pMgr			Pointer to the memory manager.
	 */
	void			(*OOM_Handler)(struct FPDFEMB_MEMMGR_EX* pMgr);

	/**
	 * @brief	Reallocate a memory block
	 *
	 * @details If an existing memory block specified, the data in the memory block should
	 *			be copied to the new block, if reallocated.<br>
	 *			The implementation should not do any action if no memory available,
	 *			just return NULL. OOM handling can be done in OOM_Handler interface.
	 *
	 * @param[in] pMgr			Pointer to the memory manager.
	 * @param[in] pointer		Pointer to an existing memory block, or handle to a movable
	 *							block. Can not be NULL.
	 * @param[in] new_size		New size (number of bytes) of the memory block. Can not be zero.
	 * @return The pointer of reallocated memory block, it could be a new block, or just
	 *		the previous block with size modified.
	 *		If FPDFEMB_MOVABLE flag is used, implementation should return a handle
	 *		to the memory block, if it supports movable block allocation.
	 */
	void*			(*Realloc)(struct FPDFEMB_MEMMGR_EX* pMgr, void* pointer, unsigned int new_size, int flags);

	/**
	 * @brief Lock a movable memory block
	 * @details	This interface is optional, if implementation doesn't support movable memory
	 *			block, then this interface can be set to NULL.
	 * 
	 * @param[in] pMgr			Pointer to the memory manager.
	 * @param[in] handle		Handle to movable memory block, returned by Alloc or Realloc.
	 * @return The pointer of the memory block. NULL if the block was discarded.
	 */
	void*			(*Lock)(struct FPDFEMB_MEMMGR_EX* pMgr, void* handle);

	/**
	 * @brief Unlock a locked movable memory block.
	 *
	 * @details This interface is optional, if implementation doesn't support movable memory
	 *			block, then this interface can be set to NULL.
	 *
	 * @param[in] pMgr			Pointer to the memory manager.
	 * @param[in] handle		Handle to movable memory block, returned by Alloc or Realloc.
	 */
	void			(*Unlock)(struct FPDFEMB_MEMMGR_EX* pMgr, void* handle);

	/**
	 * @brief Free a memory block
	 *
	 * @param[in] pMgr			Pointer to the memory manager.
	 * @param[in] pointer		Pointer to an existing memory block, or handle to a movable block.
	 */
	void			(*Free)(struct FPDFEMB_MEMMGR_EX* pMgr, void* pointer, int flags);

	void*			user;		/**< @brief A user pointer, used by the application. */

};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_InitEx in fs_base.h .
 * @brief Initialize the FPDFEMB module with the extended memory manager
 * @details This function will allocate necessary internal data structure for
 *			the whole module to operate.
 *
 * @param[in] mem_mgr			Pointer to memory manager structure.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_InitEx(struct FPDFEMB_MEMMGR_EX* mem_mgr);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_Destroy in fs_base.h .
 * @brief Stop using FPDFEMB module and release all resources
 * @details All loaded documents and pages will become invalid after this call.<br>
 *			This function is useful for OOM recovery: when your application hits
 *			an OOM situation, calling this function will clear all memory allocated
 *			by FPDFEMB module, then you can call one of the initialization functions,
 *			reopen the document and recovery from OOM.
 * @return None.
 */
void FPDFEMB_Exit();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_LoadJbig2Decoder in fs_base.h .
 * @brief  Enable JBIG2 image decoder. For embedded platform only  and on desktop it's automatically loaded.
 *
 * @details If you want to display JBIG2 encoded images, you need to call 
 *			these functions after the SDK initialized.<br>
 *			Calling these functions will increase code size by about 200K-400K bytes.
 * @return None.
 */
void FPDFEMB_LoadJbig2Decoder();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_LoadJpeg2000Decoder in fs_base.h .
 * @brief Enable JBIG2000 image decoder. For embedded platform only  and on desktop it's automatically loaded.
 *
 * @details If you want to display JPEG2000 encoded images, you need to call 
 *			these functions after the SDK initialized.<br>
 *			Calling these functions will increase code size by about 200K-400K bytes.
 *			JPEG2000 decoder may not be available on some platforms.
 * @return None.
 */
void FPDFEMB_LoadJpeg2000Decoder();


/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_Alloc in fs_base.h .
 * @brief Allocate memory
 *
 * @param[in] size			Number of bytes
 * @return The allocated buffer pointer. <b>NULL</b> for out of memory.
 */
void* FPDFEMB_AllocMemory(unsigned int size);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_Free in fs_base.h .
 * @brief Free allocated memory
 *
 * @param[in] pointer		Pointer returned by ::FPDFEMB_AllocMemory.
 * @return None.
 */
void FPDFEMB_FreeMemory(void* pointer);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Memory_FreeCaches in fs_base.h .
 * @brief Free all expendable caches used by the SDK in order to save memory.
 *
 * @details When an application memory manager runs out of memory, before an OOM situation 
 *			is raised, the application can try this 
 * @return None.
 */
void FPDFEMB_FreeCaches();

/********************************************************************************************
****
****		Document Operations
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FILEREAD in fs_base.h .
 * @brief Describe the way to access a file (readonly).
 */
struct FPDFEMB_FILE_ACCESS {
	/**
	 * @brief Get total size of the file
	 *
	 * @param[in] file			Pointer to this file access structure
	 * @return File size, in bytes. Implementation can return 0 for any error.
	 */
	unsigned int	(*GetSize)(struct FPDFEMB_FILE_ACCESS* file);

	/**
	 * @brief Read a data block from the file
	 *
	 * @param[in] file			Pointer to this file access structure
	 * @param[in,out] buffer		Pointer to a buffer receiving read data
	 * @param[in] offset		Byte offset for the block, from beginning of the file
	 * @param[in] size			Number of bytes for the block.
	 * @return	::FPDFERR_SUCCESS means success.<br>
	 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
	 */
	FPDFEMB_RESULT	(*ReadBlock)(struct FPDFEMB_FILE_ACCESS* file, void* buffer, 
									unsigned int offset, unsigned int size);

	void*		user;		/**< @brief A user pointer, used by the application. */
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_PAUSE in fs_base.h .
 * @brief An interface for pausing a progressive process.
 */
struct FPDFEMB_PAUSE {
	/**
	 * @brief Check if we need to pause a progressive process now.
	 *
	 * @details Typically implementation of this interface compares the current system tick
	 *			with the previous one, if the time elapsed exceeds certain threshold, then
	 *			the implementation returns TRUE, indicating a pause is needed.
	 *
	 * @param[in] pause			Pointer to the pause structure
	 * @return Non-zero for pause now, 0 for continue.
	 */
	FPDFEMB_BOOL	(*NeedPauseNow)(struct FPDFEMB_PAUSE* pause);

	void*			user;		/**< @brief A user pointer, used by the application. */
};

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_DOCUMENT</b> in fpdf_base.h .
 * @brief PDF document handle type.
 */
typedef void* FPDFEMB_DOCUMENT;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_Load in fpdf_document.h .
 * @brief Start loading a PDF document
 *
 * @details	Document loading is a progressive process. It might take a long time to
 *			load a document, especially when a file is corrupted, and it will try to
 *			recover the document contents by scanning the whole file. <br>
 *
 * @param[in] file			Pointer to file access structure.
 *							This structure must be kept valid as long as the document is open.
 * @param[in] password		Pointer to a zero-terminated byte string, for the password.
 *							Or NULL for no password.
 * @param[out] document		Receiving the document handle
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. <br>
 *							<b>This should be NULL because of not being supported now.</b>
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartLoadDocument(struct FPDFEMB_FILE_ACCESS* file, const char* password, 
									FPDFEMB_DOCUMENT* document, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As release of 2.0, this function will not be supported.
 * @brief		Continue loading a PDF document
 *
 * @param[in] document		Document handle returned by FPDFEMB_StartLoadDocument function
 * @param[in] pause			A callback mechanism allowing the document loading process
 *							to be paused before it's finished. This can be NULL if you
 *							don't want to pause.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 */
FPDFEMB_RESULT FPDFEMB_ContinueLoadDocument(FPDFEMB_DOCUMENT document, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_Close in fpdf_document.h .
 * @brief Close a PDF document and free all associated resources
 *
 * @param[in] document			The document handle.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_CloseDocument(FPDFEMB_DOCUMENT document);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_GetPageCount in fpdf_document.h .
 * @brief Get the count of pages in the document
 * 
 * @param[in] document			Document handle
 * @return	The count of pages.<br>
 *			The following are some special return values:
 *			<ul>
 *			<li>0: Parameter error.</li>
 *			<li>-1: Out of memory.</li>
 *			</ul>
 */
int FPDFEMB_GetPageCount(FPDFEMB_DOCUMENT document);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_SetFileBufferSize in fpdf_document.h .
 * @brief Set size of internal buffer used to read from source file.
 *
 * @details Currently FPDFEMB uses 512 bytes as default buffer size. The new buffer size 
 *			takes effect next time you call FPDFEMB_StartLoadDocument.
 *
 * @param[in] size				Number of bytes.
 * @return None.
 */
void FPDFEMB_SetFileBufferSize(int size);

/********************************************************************************************
****
****		Page Basic Operations
****
********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_PAGE</b> in fpdf_base.h .
 * @brief PDF page handle type.
 */
typedef void* FPDFEMB_PAGE;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_Load in fpdf_document.h .
 * @brief	Load the specified page.
 *
 * @param[in] document		A document handle.
 * @param[in] index			A zero-based index of the page which is to be loaded.
 * @param[out] page			Used to receive the loaded page handler.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_LoadPage(FPDFEMB_DOCUMENT document, int index, FPDFEMB_PAGE* page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_Close in fpdf_document.h .
 * @brief Close a page and release all related resources
 *
 * @param[in] page			A page handle
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_ClosePage(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_EstimatePageComplexity in fpdf_document.h .
 * @brief Get the complexity estimate before parsing page to help decide how
 *          to handle page operations
 * @details Size of page content stream returned by this function
 *          may not accurately reflect page complexity because page content
 *          stream may inline content which artificially inflate the size
 *
 * @param[in]     page			Page handle
 * @param[in,out] size			Receiving size of page content stream
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_EstimatePageComplexity(FPDFEMB_PAGE page, int* size);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_GetSize in fpdf_view.h .
 * @brief Get the size of a page
 *
 * @param[in] page			Page handle
 * @param[out] width		Receiving page width, in hundredth of points
 * @param[out] height		Receiving page height, in hundredth of points
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetPageSize(FPDFEMB_PAGE page, int* width, int* height);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_RECT in fs_base.h .
 * @brief Rectangle area in device or page coordination system
 */
struct FPDFEMB_RECT
{
	/**
	 * @name For device system, coordinations are measured in pixels;
	 * For page system, coordinations are measured in hundredth of points.
	 */
	/**@{*/
	/** @brief The x-coordinate of the left-top corner. */
	int		left;
	/** @brief The y-coordinate of the left-top corner. */
	int		top;
	/** @brief The x-coordinate of the right-bottom corner. */
	int		right;
	/** @brief The y-coordinate of the right-bottom corner. */
	int		bottom;
	/**@}*/
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_GetBBox in fpdf_view.h .
 * @brief Get the displayable area (bounding box) of a page
 *
 * @param[in] page			Page handle
 * @param[out] rect			Pointer to a structure receiving the rectangle
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetPageBBox(FPDFEMB_PAGE page, struct FPDFEMB_RECT* rect);

/********************************************************************************************
****
****		Page Parsing
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_StartParse in fpdf_document.h .
 * @brief Start parsing a page, so it can get rendered or searched.
 *
 * @details Parsing is a progressive process. This function starts the parsing process,
 *			and may return before parsing is finished, if a pause structure is provided.<br>
 *			Application should call ::FPDFEMB_ContinueParse repeatedly to finish the parsing
 *			when return value is ::FPDFERR_TOBECONTINUED.<br>
 *			There can be only one parsing procedure active for a page, and if a page
 *			has already been parsed, you can't start a parsing again.
 *
 * @param[in] page			Page handle
 * @param[in] text_only		flag for parsing texts only (used for searching)
 * @param[in] pause			A structure that can pause the parsing process.
 *							Or <b>NULL</b> if you don't want to pause the process.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartParse(FPDFEMB_PAGE page, FPDFEMB_BOOL text_only, 
												struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_ContinueParse in fpdf_document.h .
 * @brief Continue the page parsing.
 *
 * @details ::FPDFEMB_StartParse should be called before on the page.<br>
 *			Application should call ::FPDFEMB_ContinueParse repeatedly to finish the parsing
 *			when return value is ::FPDFERR_TOBECONTINUED.
 *
 * @param[in] page			Page handle
 * @param[in] pause			A structure that can pause the parsing process.
 *							Or <b>NULL</b> if you don't want to pause the process.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_ContinueParse(FPDFEMB_PAGE page, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_GetParseProgress in fpdf_document.h .
 * @brief Get an estimated parsing progress in percentage
 *
 * @param[in] page			A Page handle
 * @return  An integer between 0 and 100 (inclusive) indicating the parsing progress.
 *			The result is just a rough estimation.<br>
 *			-1 means parameter error.
 */
int FPDFEMB_GetParseProgress(FPDFEMB_PAGE page);

/********************************************************************************************
****
****		Page Rendering
****
********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FS_BITMAP</b> in fs_base.h .
 * @brief Bitmap handle type.
 */
typedef void* FPDFEMB_BITMAP;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RenderPage_StartQuickDraw in fpdf_view.h .
 * @brief Start drawing a quick preview of a page
 * @details It's often useful to present user a quick preview of a page, right after the
 *			page is parsed. This preview renders only a limited set of easy features in the
 *			page, so it'll be rather quick to finish this process.
 *
 * @param[in] dib			DIB handle, as the rendering device
 * @param[in] page			Page handle. The page has to be parsed first.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in] flags			Reserved, must be zero.
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 *							Can be NULL if no pausing is needed.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartQuickDraw(FPDFEMB_BITMAP dib, FPDFEMB_PAGE page,
							int start_x, int start_y, int size_x, int size_y, int rotate,
							int flags, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RenderPage_ContinueQuickDraw in fpdf_view.h .
 * @brief Continue a quick draw processing
 *
 * @param[in] page			Page handle. The page has to be parsed first.
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 *							Can be NULL if no pausing is needed.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_ContinueQuickDraw(FPDFEMB_PAGE page, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Render flags.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RENDER_ANNOT in fpdf_base.h .
 * @brief Set if annotations are to be rendered.
 */
#define FPDFEMB_ANNOT			0x01
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RENDER_LCD_TEXT in fpdf_base.h .
 * @brief Set if using text rendering optimized for LCD display.
 */
#define FPDFEMB_LCD_TEXT		0x02
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RENDER_BGR_STRIPE in fpdf_base.h .
 * @brief Set if the device is using BGR LCD stripe.
 */
#define FPDFEMB_BGR_STRIPE		0x04
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RENDER_DROP_OBJECTS in fpdf_base.h .
 * @brief Drop the page objects that are rendered. This will make the most complicated pages renderable
	within very limited memory. HOWEVER, after rendering the page will not be useable anymore! You will
	have to close the page and start it over!
 */
#define FPDFEMB_DROP_OBJECTS	0x08
/**@}*/ 

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDFEMB_RenderPage_Start in fpdf_view.h .
 * @brief Start rendering of a page.
 *
 * @details Rendering is a progressive process. This function starts the rendering process,
 *			and may return before rendering is finished, if a pause structure is provided.
 *			Application should call ::FPDFEMB_ContinueRender repeatedly to finish the rendering 
 *			when return value is ::FPDFERR_TOBECONTINUED.<br>
 *			There can be only one rendering procedure for a page at any time. And rendering
 *			can be started over and over again for the same page. If a page rendering is already
 *			active, starting another one will cancel the previous rendering.<br>
 *			Rendering of a page doesn't draw the page background, therefore, you usually need
 *			to draw the background in the DIB yourself.<br>
 *			You don't have to parse the page before you can render it. The engine will parse
 *			the page along with the rendering process. With this technique, along with
 *			::FPDFEMB_DROP_OBJECTS flag, you can really render very complicated pages without
 *			much memory consumption (because no page objects will be cached).
 *
 * @param[out] dib			DIB handle, as the rendering device
 * @param[in] page			Page handle. The page has to be parsed first.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in] flags			0 means normal display. This can also be the combination of macro definitions:
 *							<ul>
 *							<li>::FPDFEMB_ANNOT</li>
 *							<li>::FPDFEMB_LCD_TEXT</li>
 *							<li>::FPDFEMB_BGR_STRIPE</li>
 *							<li>::FPDFEMB_DROP_OBJECTS</li>
 *							</ul>
 * @param[in] clip			Pointer to clip rectangle (in DIB device coordinations),
 *							or NULL if no clipping needed.
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 * 							Can be NULL if no pausing is needed.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StartRender(FPDFEMB_BITMAP dib, FPDFEMB_PAGE page,
						int start_x, int start_y, int size_x, int size_y, int rotate, int flags,
						struct FPDFEMB_RECT* clip, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDFEMB_RenderPage_Continue in fpdf_view.h .
 * @brief Continue the page rendering
 *
 * @details This function may return any time when the pause interface indicates 
 *			a pause is needed. Application can call ::FPDFEMB_ContinueRender any number
 *			of times, until ::FPDFERR_TOBECONTINUED is not returned.
 *
 * @param[in] page			Page handle
 * @param[in] pause			Pointer to a structure that can pause the rendering process.
 *							Can be NULL if no pausing is needed.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_ContinueRender(FPDFEMB_PAGE page, struct FPDFEMB_PAUSE* pause);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RenderPage_GetProgress in fpdf_view.h .
 * @brief Get an estimated rendering progress in percentage
 *
 * @param[in] page					Page handle
 * @return	An integer between 0 and 100 (inclusive) indicating the rendering progress.
 *			The result is just a rough estimation.<br>
 *			If the rendering just finished, this function will return 0.<br>
 *			-1 means parameter error.
 */
int FPDFEMB_GetRenderProgress(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RenderPage_Cancel in fpdf_view.h .
 * @brief Cancel the page rendering.
 *
 * @param[in] page					Page handle
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_CancelRender(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_RenderPage_SetHalftoneLimit in fpdf_view.h .
 * @brief Set pixel count limit for using halftone when display image
 *
 * @details By default, FPDFEMB displays all bitmaps using downsamping, which means
 *			if the image is shrinked onto screen, only part of pixels will be picked
 *			and displayed. This saves a lot of calculation, especially for big images
 *			with millions of pixels. However the display quality can be bad. In order to
 *			reach a balance between performance and quality, application can use this
 *			function to set a limit, if number of pixels in an image is more than this
 *			limit, then FPDFEMB will use downsampling for quick drawing, otherwise, if
 *			the image has less pixels, FPDFEMB will use halftoning for better quality.
 *
 * @param[in] limit			Number of pixels for the limit
 * @return None.
 */
void FPDFEMB_SetHalftoneLimit(int limit);

/********************************************************************************************
****
****		Coordination Conversion
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_POINT in fs_base.h .
 * @brief A point in device or page coordination system
 */
struct FPDFEMB_POINT
{
	/**
	 * @name For device system, coordinations are measured in pixels;
	 * For page system, coordinations are measured in hundredth of points.
	 */
	/**@{*/
	/** @brief The x-coordinate. */
	int		x;
	/** @brief The y-coordinate. */
	int		y;
	/**@}*/
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_POINTF in fs_base.h .
 * @brief A point in device or page coordination system
 */
struct FPDFEMB_POINTF
{
	/**
	 * @name For device system, coordinations are measured in pixels;
	 * For page system, coordinations are measured in hundredth of points.
	 */
	/**@{*/
	/** @brief The x-coordinate. */
	float	x;
	/** @brief The y-coordinate. */
	float	y;
	/**@}*/
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_RECTF in fs_base.h .
 * @brief Rectangle area in device or page coordination system
 */
struct FPDFEMB_RECTF
{
	/**
	 * @name For device system, coordinations are measured in pixels;
	 * For page system, coordinations are measured in hundredth of points.
	 */
	/**@{*/
	/** @brief The x-coordinate of the left-top corner. */
	float	left;
	/** @brief The y-coordinate of the left-top corner. */
	float	top;
	/** @brief The x-coordinate of the right-bottom corner. */
	float	right;
	/** @brief The y-coordinate of the right-bottom corner. */
	float	bottom;
	/**@}*/
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_DeviceToPagePoint in fpdf_view.h .
 * @brief Convert the device coordinations of a point(<b>int</b>) to page coordinations.
 *
 * @details The page coordination system has its origin at left-bottom corner of the page, 
 *			with X axis goes along the bottom side to the right, and Y axis goes along the 
 *			left side upward. No matter how you zoom, scroll, or rotate a page, a particular
 *			element (like text or image) on the page should always have the same coordination 
 *			values in the page coordination system. <br>
 *			The device coordination system is device dependent. For bitmap device, its origin 
 *			is at left-top corner of the window. You must make sure the start_x, start_y, size_x, 
 *			size_y and rotate parameters have exactly same values as you used in 
 *			::FPDFEMB_StartRender function call.<br>
 *			For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			page coordinations, left is always smaller than right, bottom is smaller than top.
 *
 * @param[in] page			Handle to the page. Returned by FPDFEMB_LoadPage function.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] point		A point structure(::FPDFEMB_POINT) with device coordinations upon the call,
 *							also receiving the result page coordinations.
 * @return None.
 */
void FPDFEMB_DeviceToPagePoint(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_POINT* point);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_DeviceToPagePointF in fpdf_view.h .
 * @brief Convert the device coordinations of a point(<b>float</b>) to page coordinations.
 *
 * @details The page coordination system has its origin at left-bottom corner of the page, 
 *			with X axis goes along the bottom side to the right, and Y axis goes along the 
 *			left side upward. No matter how you zoom, scroll, or rotate a page, a particular
 *			element (like text or image) on the page should always have the same coordination 
 *			values in the page coordination system. <br>
 *			The device coordination system is device dependent. For bitmap device, its origin 
 *			is at left-top corner of the window. You must make sure the start_x, start_y, size_x, 
 *			size_y and rotate parameters have exactly same values as you used in 
 *			::FPDFEMB_StartRender function call.<br>
 *			For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			page coordinations, left is always smaller than right, bottom is smaller than top.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] point		A point structure(::FPDFEMB_POINTF) with device coordinations upon the call,
 *							also receiving the result page coordinations.
 * @return None.
 */void FPDFEMB_DeviceToPagePointF(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_POINTF* point);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_DeviceToPageRect in fpdf_view.h .
 * @brief Convert the device coordinations of a rectangle(<b>int</b>) to page coordinations.
 *
 * @details The page coordination system has its origin at left-bottom corner of the page, 
 *			with X axis goes along the bottom side to the right, and Y axis goes along the 
 *			left side upward. No matter how you zoom, scroll, or rotate a page, a particular
 *			element (like text or image) on the page should always have the same coordination 
 *			values in the page coordination system. <br>
 *			The device coordination system is device dependent. For bitmap device, its origin 
 *			is at left-top corner of the window. You must make sure the start_x, start_y, size_x, 
 *			size_y and rotate parameters have exactly same values as you used in 
 *			::FPDFEMB_StartRender function call.<br>
 *			For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			page coordinations, left is always smaller than right, bottom is smaller than top.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] rect		A rectangle structure(::FPDFEMB_RECT) with device coordinations upon the call,
 *							also receiving the result page coordinations.
 * @return None.
 */
void FPDFEMB_DeviceToPageRect(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_RECT* rect);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_DeviceToPageRectF in fpdf_view.h .
 * @brief Convert the device coordinations of a rectangle(<b>float</b>) to page coordinations.
 *
 * @details The page coordination system has its origin at left-bottom corner of the page, 
 *			with X axis goes along the bottom side to the right, and Y axis goes along the 
 *			left side upward. No matter how you zoom, scroll, or rotate a page, a particular
 *			element (like text or image) on the page should always have the same coordination 
 *			values in the page coordination system. <br>
 *			The device coordination system is device dependent. For bitmap device, its origin 
 *			is at left-top corner of the window. You must make sure the start_x, start_y, size_x, 
 *			size_y and rotate parameters have exactly same values as you used in 
 *			::FPDFEMB_StartRender function call.<br>
 *			For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			page coordinations, left is always smaller than right, bottom is smaller than top.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 *								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] rect		A rectangle structure(::FPDFEMB_RECTF) with device coordinations upon the call,
 *							also receiving the result page coordinations.
 * @return None.
 */
void FPDFEMB_DeviceToPageRectF(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_RECTF* rect);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageToDevicePoint in fpdf_view.h .
 * @brief Convert the page coordinations of a point(<b>int</b>) to device coordinations.
 *
 * @details For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			device coordinations, left is always smaller than right, top is smaller than bottom.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage function.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 * 								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] point		A point structure(::FPDFEMB_POINT) with page coordinations upon the call,
 *							also receiving the result device coordinations.
 * @return None.
 */
void FPDFEMB_PageToDevicePoint(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_POINT* point);

/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageToDevicePointF in fpdf_view.h .
 * @brief Convert the page coordinations of a point(<b>float</b>) to device coordinations.
 *
 * @details For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			device coordinations, left is always smaller than right, top is smaller than bottom.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage function.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 * 								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] point		A point structure(::FPDFEMB_POINTF) with page coordinations upon the call,
 *							also receiving the result device coordinations.
 * @return None.
 */
void FPDFEMB_PageToDevicePointF(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_POINTF* point);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageToDeviceRect in fpdf_view.h .
 * @brief Convert the page coordinations of a rectangle(<b>int</b>) to device coordinations.
 *
 * @details For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			device coordinations, left is always smaller than right, top is smaller than bottom.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage function.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 * 								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] rect		A rectangle structure(::FPDFEMB_RECT) with page coordinations upon the call,
 *							also receiving the result device coordinations.
 * @return None.
 */
void FPDFEMB_PageToDeviceRect(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_RECT* rect);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageToDeviceRectF in fpdf_view.h .
 * @brief Convert the page coordinations of a rectangle(<b>float</b>) to device coordinations.
 *
 * @details For rectangle conversion, the result rectangle is always "normalized", meaning for
 *			device coordinations, left is always smaller than right, top is smaller than bottom.
 *
 * @param[in] page			Handle to the page. Returned by ::FPDFEMB_LoadPage function.
 * @param[in] start_x		Left pixel position of the display area in the device coordination
 * @param[in] start_y		Top pixel position of the display area in the device coordination
 * @param[in] size_x		Horizontal size (in pixels) for displaying the page
 * @param[in] size_y		Vertical size (in pixels) for displaying the page
 * @param[in] rotate		Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
 * 								2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
 * @param[in,out] rect		A rectangle structure(::FPDFEMB_RECTF) with page coordinations upon the call,
 *							also receiving the result device coordinations.
 * @return None.
 */
void FPDFEMB_PageToDeviceRectF(FPDFEMB_PAGE page, 
						int start_x, int start_y, int size_x, int size_y, int rotate, 
						struct FPDFEMB_RECTF* rect);

/********************************************************************************************
****
****		Text Search
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Search flags for FPDFEMB_FindFirst function.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_MATCHCASE in fpdf_base.h .
 * @brief whether matching case.
 */
#define FPDFEMB_MATCHCASE		1
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_MATCHWHOLEWORD in fpdf_base.h .
 * @brief whether matching whole word.
 */
#define FPDFEMB_MATCHWHOLEWORD	2
/** 
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_CONSECUTIVE in fpdf_base.h .
 * @brief (This is not supported now. Maybe it will be supported in a later release.)Whether matching consecutively (for example, "CC" will match twice in "CCC").
 */
#define FPDFEMB_CONSECUTIVE		4
/**@}*/

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Find first occurrence of a pattern string in a page
 *
 * @details A page must be parsed first before it can be searched.
 *			There can be only one search in progress for a page. A new search will 
 *			cancel the previous one.<Br>
 *			IMPORTANT: this function is now obsolete and kept for back compatibility
 *			only, please use ::FPDFEMB_FindFrom function.
 *
 * @param[in] page			Page handle.
 * @param[in] pattern		A zero-terminated unicode string to be found. 
 * @param[in] from_last		Whether we start from the end of page
 * @param[in] flags			Search flags.This can be the combination of macro definitions:
 *							<ul>
 *							<li>::FPDFEMB_MATCHCASE</li>
 *							<li>::FPDFEMB_MATCHWHOLEWORD</li>
 *							</ul>
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_FindFirst(FPDFEMB_PAGE page, const FPDFEMB_WCHAR* pattern, 
								 FPDFEMB_BOOL from_last, unsigned int flags);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Find first occurrence of a pattern string in a page, from a particular position
 *
 * @details A page must be parsed first before it can be searched.
 *			There can be only one search in progress for a page. A new search will 
 *			cancel the previous one.
 *
 * @param[in] page			Page handle.
 * @param[in] pattern		A zero-terminated unicode string to be found. 
 * @param[in] pos			The position, returned from FPDFEMB_GetSearchPos.
 *							Or 0 from the beginning of page, -1 from the end of page.
 * @param[in] flags			Search flags.This can be the combination of macro definitions:
 *							<ul>
 *							<li>::FPDFEMB_MATCHCASE</li>
 *							<li>::FPDFEMB_MATCHWHOLEWORD</li>
 *							</ul>
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_FindFrom(FPDFEMB_PAGE page, const FPDFEMB_WCHAR* pattern, 
								 int pos, unsigned int flags);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Find the next occurrence of a search
 *
 * @param[in] page			Page handle. 
 *							::FPDFEMB_FindFirst must be called for this page first.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_FindNext(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Find previous occurrence of a search
 *
 * @param[in] page			Page handle.
 *							::FPDFEMB_FindFirst must be called for this page first.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_FindPrev(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Get number of rectangles for last found result
 *
 * @param[in] page			Page handle.
 * @return Number of rectangles for last found result. The following are some special return values:
 *			<ul>
 *			<li>-1: The license of the SDK is invalid.</li>
 *			<li>-2: Parameter error.</li>
 *			<li>-3: Not found.</li>
 *			</ul>
 */
int FPDFEMB_CountFoundRects(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Get a particular found rectangle
 *
 * @details Application should always call ::FPDFEMB_CountFoundRects first to get
 *			number of rectangles, then use this function to get each rectangle.<br>
 *			The returned rectangle uses page coordination system.
 *
 * @param[in] page			Page handle.
 * @param[in] index			Zero-based index for the rectangle.
 * @param[out] rect			Receiving the result rectangle, in hundredth of points
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetFoundRect(FPDFEMB_PAGE page, int index, struct FPDFEMB_RECT* rect);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Return position of current search result
 *
 * @param[in] page			Page handle.
 * @return Zero based character index for the current search result.  The following are some special return values:
 *			<ul>
 *			<li>-1: The license of the SDK is invalid.</li>
 *			<li>-2: Parameter error.</li>
 *			<li>-3: Not found.</li>
 *			</ul>
 */
int FPDFEMB_GetSearchPos(FPDFEMB_PAGE page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Text_QuickSearch in fpdf_text.h .
 * @brief Search a pattern in a page quickly, without the page to be parsed
 *
 * @details This function does a rough and quick search in a page, before the page is loaded. 
 *			The quick search will not generate an exact result saying where the pattern is
 *			found, and, it might be possible if a quick search result is "pattern found", and
 *			a real search for the same pattern, in the same page, will result in "not found".<br>
 *			However, if quick search doesn't find a pattern in a page, then we can be sure the
 *			pattern won't be found in this page when we do a real search. So, this function is 
 *			very useful when we search in a multiple-page document, and we want to quickly skip
 *			those pages in which the pattern can't possibly be found.
 *
 * @param[in] document			Document handle returned by ::FPDFEMB_StartLoadDocument function
 * @param[in] page_index		Zero-based index of the page
 * @param[in] pattern			A zero-terminated unicode string to be found. 
 * @param[in] case_sensitive	Non-zero for case-sensitive searching, zero for case-insensitive
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_QuickSearch(FPDFEMB_DOCUMENT document, int page_index, 
								   const FPDFEMB_WCHAR* pattern, int case_sensitive);

/********************************************************************************************
****
****		Text Information
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Get number of characters in the page
 *
 * @param[in] page			Page handle
 * @param[out] count		Receiving number of characters
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetCharCount(FPDFEMB_PAGE page, int* count);

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @brief Character information.
 */
struct FPDFEMB_CHAR_INFO {
	/**
	 * Unicode for the character. 0 if not available.
	 * Space and new line characters (U+0020 and U+000A) may be generated
	 * according to the text formatting.
	 */
	int		unicode;
	/** X/Y position for the character origin, in hundredth of points. */
	struct FPDFEMB_POINT	origin;
	/**
	 * Bounding box of the character, in hundredth of points
	 * Maybe an empty box (left == right or top == bottom).
	 */
	struct FPDFEMB_RECT	bbox;
};

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Get character information
 *
 * @details Application must call ::FPDFEMB_GetCharCount first before it can call this function
 *			for any particular characters.
 *
 * @param[in] page			Page handle
 * @param[in] index			Character index, starting from zero
 * @param[out] char_info	Receiving the character info
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetCharInfo(FPDFEMB_PAGE page, int index, struct FPDFEMB_CHAR_INFO* char_info);

/**
 * @deprecated As of release 2.0, this will not be used.
 * @brief Get index of character nearest to a certain position on the page
 *
 * @details This function finds the character that's nearest to the particular page position.
 *			If there is no character, the output index will be -1.
 *
 * @param[in] page			Page handle
 * @param[in] x				X position in PDF page coordination system
 * @param[in] y				Y position in PDF page coordination system
 * @param[out] index			Pointer to an integer receiving zero-based character index. -1 means no character.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetCharIndexAtPos(FPDFEMB_PAGE page, double x, double y, int* index);

/********************************************************************************************
****
****		Device Independent Bitmap
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name DIB format.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_BGR in fs_base.h .
 * @brief 3 bytes per pixel, byte order: Blue, Green, Red.
 */
#define FPDFDIB_BGR		1
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_BGRx in fs_base.h .
 * @brief 4 bytes per pixel, byte order: Blue, Green, Red, not used.
 */
#define FPDFDIB_BGRx	2
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_BGRA in fs_base.h .
 * @brief 4 bytes per pixel, byte order: Blue, Green, Red, Alpha.
 */
#define FPDFDIB_BGRA	3
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_GRAY in fs_base.h .
 * @brief 1 byte per pixel (grayscale).
 */
#define FPDFDIB_GRAY	4
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_RGB in fs_base.h .
 * @brief 3 bytes per pixel, byte order: Red, Green, Blue.
 */
#define FPDFDIB_RGB		5
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_RGBx in fs_base.h .
 * @brief 4 bytes per pixel, byte order: Red, Green, Blue, not used.
 */
#define FPDFDIB_RGBx	6
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_RGBA in fs_base.h .
 * @brief 4 bytes per pixel, byte order: Red, Green, Blue, Alpha.
 */
#define FPDFDIB_RGBA	7
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_DIBFORMAT_RGB565 in fs_base.h .
 * @brief 2 bytes per pixel, byte order: Red 5 bits, Green 6 bits, Blue 5 bits. If this format available, other DIB formats will not be used.
 */
#define FPDFDIB_RGB565	8
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_Create in fs_base.h .
 * @brief Create a DIB (Device Independent Bitmap)
 *
 * @details If "buffer" parameter is not NULL, then the provided buffer must conform
 *			to standard DIB format (see comments of FPDFEMB_GetDIBData function below).<br>
 *			This function doesn't initialize the pixels inside the DIB buffer. So if you
 *			want to use the DIB to display a PDF page, you usually need to initialize
 *			the DIB to white background by youself.
 *
 * @param[in] width			Width pixels.
 * @param[in] height		Height pixels.
 * @param[in] format		The format type. See macro definitions FPDFDIB_XXX.
 * @param[in] buffer		It's often set to be <b>NULL</b>. 
 *							If it's not <b>NULL</b>, it'll be an external buffer(<b>with enough size</b>) provided for the DIB.
 * @param[in] stride		Number of bytes for each scan line, for an external buffer only.
 *							If not specified, 4-byte alignment assumed.
 * @param[out] dib			Used to Receive the created DIB handle.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_CreateDIB(int width, int height, int format, 
									   void* buffer, int stride, FPDFEMB_BITMAP* dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_Destroy in fs_base.h .
 * @brief Destroy a DIB
 *
 * @details If external buffer is used (specified in "buffer" parameter when calling
 *			FPDFEMB_CreateDIB), the buffer will not be destroyed.
 *
 * @param[in] dib			DIB handle
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_DestroyDIB(FPDFEMB_BITMAP dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_GetWidth in fs_base.h .
 * @brief Get the width (in pixels) of a DIB.
 *
 * @param[in] dib				The handle to a DIB.
 * @return  The width of the DIB in pixels.<br>
 *			-1 means parameter error.
 */
int FPDFEMB_GetDIBWidth(FPDFEMB_BITMAP dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_GetHeight in fs_base.h .
 * @brief Get the height (in pixels) of a DIB.
 *
 * @param[in] dib			The handle to a DIB.
 * @return  The height of a DIB in pixels.<br>
 *			-1 means parameter error.
 */
int FPDFEMB_GetDIBHeight(FPDFEMB_BITMAP dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_GetBuffer in fs_base.h .
 * @brief Get data pointer to a DIB
 *
 * @details DIB data are organized in scanlines, from top down.
 *
 * @param[in] dib				DIB handle
 * @return	The pointer to the DIB data.
 *			<b>NULL</b> means parameter error.
 */
void* FPDFEMB_GetDIBData(FPDFEMB_BITMAP dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_GetStride in fs_base.h .
 * @brief Get the scan line stride of a DIB.
 *
 * @param[in] dib				The handle to a DIB.
 * @return The number of bytes occupied by a scanline.<br>
 *			-1 means parameter error.
 */
int FPDFEMB_GetDIBStride(FPDFEMB_BITMAP dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_GetFlippedDIB in fs_base.h .
 * @brief Swap X/Y dimensions of a DIB to generate a rotated new DIB
 *
 * @param[in] dib			DIB handle
 * @param[in] bFlipX		Whether flip pixels on the destination X dimension (left/right)
 * @param[in] bFlipY		Whether flip pixels on the destination Y dimension (up/down)
 * @param[out] result_dib	Receiving the result DIB handle
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetRotatedDIB(FPDFEMB_BITMAP dib, 
									 FPDFEMB_BOOL bFlipX, FPDFEMB_BOOL bFlipY,
									 FPDFEMB_BITMAP* result_dib);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_Stretch in fs_base.h .
 * @brief Stretch a source DIB into another destination DIB
 *
 * @param[out] dest_dib		The destination DIB handle
 * @param[in] dest_left		Left position in the destination DIB
 * @param[in] dest_top		Top position in the destination DIB
 * @param[in] dest_width	Destination width, in pixels. Can be negative for horizontal flipping
 * @param[in] dest_height	Destination height, in pixels. Can be negative for vertical flipping
 * @param[in] clip_rect		Destination clipping rectangle, or NULL for no clipping.
 *							The coordinations are measured in destination bitmap.
 * @param[in] src_dib		Source DIB handle.
 * @param[in] interpol		Whether we use interpolation to improve the result quality
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_StretchDIB(FPDFEMB_BITMAP dest_dib, int dest_left, int dest_top,
								  int dest_width, int dest_height, struct FPDFEMB_RECT* clip_rect, 
								  FPDFEMB_BITMAP src_dib, FPDFEMB_BOOL interpol);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_Transform in fs_base.h .
 * @brief Transform a source DIB into another destination DIB
 *
 * @details All coordinations and distances are measured in destination bitmap system.<br>
 *			This function places the bottom-left pixel of the image at the destination
 *			origin, then the bottom sideline along the destination X vector, and left 
 *			sideline along the destination Y vector.
 *
 * @param[out] dest_dib		The destination DIB handle
 * @param[in] clip_rect		Destination clipping rectangle, or NULL for no clipping.
 * 							The coordinations are measured in destination bitmap.
 * @param[in] src_dib		Source DIB handle.
 * @param[in] x				X coordination of the dest origin
 * @param[in] y				Y coordination of the dest origin
 * @param[in] xx			X distance of the dest X vector
 * @param[in] yx			Y distance of the dest X vector
 * @param[in] xy			X distance of the dest Y vector
 * @param[in] yy			Y distance of the dest Y vector
 * @param[in] interpol		Whether we use interpolation to improve the result quality
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_TransformDIB(FPDFEMB_BITMAP dest_dib, struct FPDFEMB_RECT* clip_rect, 
								  FPDFEMB_BITMAP src_dib, int x, int y, int xx, int yx,
								  int xy, int yy, FPDFEMB_BOOL interpol);

/********************************************************************************************
****
****		Custom Font Handler and CJK Support
****
********************************************************************************************/

// FPDFEMB comes with standard fonts for Latin characters. If your device is targeted to
// Eastern Asian markets, then system fonts must be provided and registered with FPDFEMB.
// Depending on your device configuration, those system fonts might be in TrueType or Type1
// format, or some other non-standard compact format. For the first case, you should register
// a font mapper so FPDFEMB can pick the right font file, and for the second case, you
// should register a glyph provider so FPDFEMB can get glyph bitmap for each character.

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Charset defines.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_DEFAULT in fs_base.h .
 * @brief Default.
 */
#define FPDFEMB_CHARSET_DEFAULT		0
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_GB in fs_base.h .
 * @brief For simplified Chinese.
 */
#define FPDFEMB_CHARSET_GB			936
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_BIG5 in fs_base.h .
 * @brief For traditional Chinese.
 */
#define FPDFEMB_CHARSET_BIG5		950
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_JIS in fs_base.h .
 * @brief For Japanese.
 */
#define FPDFEMB_CHARSET_JIS			932
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_KOREA in fs_base.h .
 * @brief For Korea.
 */
#define FPDFEMB_CHARSET_KOREA		949
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_CHARSET_UNICODE in fs_base.h .
 * @brief Unicode.
 */
#define FPDFEMB_CHARSET_UNICODE		1200
/**@}*/

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Font flags.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_FIXEDPITCH in fs_base.h .
 * @brief Fixed pitch.
 */
#define FPDFEMB_FONT_FIXEDPITCH		1
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_SERIF in fs_base.h .
 * @brief Serif.
 */
#define FPDFEMB_FONT_SERIF			2
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_SYMBOLIC in fs_base.h .
 * @brief Symbolic.
 */
#define FPDFEMB_FONT_SYMBOLIC		4
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_SCRIPT in fs_base.h .
 * @brief Script.
 */
#define FPDFEMB_FONT_SCRIPT			8
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_NONSYMBOLIC in fs_base.h .
 * @brief Non-symbolic.
 */
#define FPDFEMB_FONT_NONSYMBOLIC	32
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_ITALIC in fs_base.h .
 * @brief Italic.
 */
#define FPDFEMB_FONT_ITALIC			64
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_ALLCAP in fs_base.h .
 * @brief All cap.
 */
#define FPDFEMB_FONT_ALLCAP			0x10000
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_SMALLCAP in fs_base.h .
 * @brief Small cap. 
 */
#define FPDFEMB_FONT_SMALLCAP		0x20000
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_FORCEBOLD in fs_base.h .
 * @brief Force bold.
 */
#define FPDFEMB_FONT_FORCEBOLD		0x40000
/**@}*/

/**
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_FILE_MAPPER in fs_base.h .
 * @brief Defines interface for system font mapper.
 * @note This should be declared to be a global variable.
 */
struct FPDFEMB_FONT_MAPPER
{
	/**
	 * @brief Find font file path for a particular PDF font
	 *
	 * @param[in] mapper		Pointer to the FPDFEMB_FONT_MAPPER structure
	 * @param[in] name			Font name
	 * @param[in] charset		Charset ID (see above FPDFEMB_CHARSET_xxx constants)
	 * @param[in] flags			Font flags (see above FPDFEMB_FONT_xxx constants)
	 * @param[in] weight		Weight of the font. Range from 100 to 900. 400 is normal,
	 * 							700 is bold.
	 * @param[out] path			Receiving the full file path. The buffer size is 512 bytes.
	 * @param[out] face_index	Receiving an zero-based index value for the font face, if the 
	 * 							mapped font file is a "collection" (meaning a number of faces 
	 *							are stored in the same file). If the font file is not a 
	 *							collection, the index value should be zero.
	 * @return	Non-zero for a substitution font has be specified.
	 *			Zero if the mapper doesn't map the font, or something is wrong.
	 */
	FPDFEMB_BOOL	(*MapFont)(struct FPDFEMB_FONT_MAPPER* mapper, const char* name, int charset,
									unsigned int flags,	int weight,
									char* path, int* face_index);

	void*		user;		/**< @brief A user pointer, used by the application. */
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_SetFontFileMapper in fs_base.h .
 * @brief Use a system font mapper (typically for Chinese/Japanese/Korean charsets)
 *
 * @details This function is used with devices that come with one or more system fonts,
 *			and those fonts are in standard TT or T1 format.
 *
 * @param[in] mapper			Pointer to ::FPDFEMB_FONT_MAPPER structure.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_SetFontMapper(struct FPDFEMB_FONT_MAPPER* mapper);

/**
 * @deprecated As of release 2.0, this will not be replaced by ::FS_FONT_DATA_MAPPER in fs_base.h .
 * @brief Defines interface for system font mapper.
 */
struct FPDFEMB_FONT_MAPPEREx
{
	 /**
	 * @brief Find font Data for a particular PDF font
	 *
	 * @param[in] mapper		Pointer to the FPDFEMB_FONT_MAPPEREx structure
	 * @param[in] name			Font name
	 * @param[in] charset		Charset ID (see above FPDFEMB_CHARSET_xxx constants)
	 * @param[in] flags			Font flags (see above FPDFEMB_FONT_xxx constants)
	 * @param[in] weight		Weight of the font. Range from 100 to 900. 400 is normal,
	 * 							700 is bold.
	 * @param[out] fontdata		Pointer to the external data.
	 * @param[out] fontsize     Number of bytes in the external data.
 	 * @param[out] face_index	Receiving an zero-based index value for the font face, if the 
	 * 							mapped font file is a "collection" (meaning a number of faces 
	 *							are stored in the same file). If the font file is not a 
	 *							collection, the index value should be zero.
	 * @return	Non-zero for a substitution font has be specified.
	 *			Zero if the mapper doesn't map the font, or something is wrong.
	 */
	FPDFEMB_BOOL	(*MapFontEx)(struct FPDFEMB_FONT_MAPPEREx* mapper, const char* name, int charset,
		unsigned int flags, int weight,
		 char** fontdata, int* fontsize,int* face_index);


	void*		user;		/**< @brief A user pointer, used by the application. */
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_SetFontDataMapper in fs_base.h .
 * @brief Use a system font mapper (typically for Chinese/Japanese/Korean charsets)
 *
 * @details This function is used with devices that come with one or more system fonts,
 *			and those fonts are in standard TT or T1 format.
 *
 * @param[in] mapper			Pointer to ::FPDFEMB_FONT_MAPPEREx structure.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_SetFontMapperEx(struct FPDFEMB_FONT_MAPPEREx* mapper);

/**
 * @deprecated As of release 2.0, this will not be replaced by ::FS_GLYPH_PROVIDER in fs_base.h .
 * @brief Interface for providing glyph bitmap of non-latin characters.
 *			This is usually used for embedded devices with Chinese/Japanese/Korean 
 *			fonts installed, but those fonts are not in TrueType or Type1 format.
 */
struct FPDFEMB_GLYPH_PROVIDER
{
	/**
	 * @brief Return an internal handle for a font
	 * 
	 * @param[in] provider		Pointer to this structure
	 * @param[in] name			Font name
	 * @param[in] charset		Charset ID (see above FPDFEMB_CHARSET_xxx constants)
	 * @param[in] flags			Font flags (see above FPDFEMB_FONT_xxx constants)
	 * @param[in] weight		Weight of the font. Range from 100 to 900. 400 is normal,
	 * 						700 is bold.
	 * @return	An internal handle to the mapped font. If the embedded device supports
	 *		multiple fonts, then this value can serve as an identifier to differentiate
	 *		among them. If the device supports only one font, then implementation of
	 *		this function can simply return NULL.
	 */
	void*			(*MapFont)(struct FPDFEMB_GLYPH_PROVIDER* provider, const char* name, int charset,
									unsigned int flags,	int weight);
	/**
	 * @brief Get glyph bounding box
	 *
	 * @details The bounding box is measure in a glyph coordination system, in which the
	 *		origin is set to character origin, and unit is set to one-thousandth of
	 *		"em size" (representing the font size).
	 *
	 *		In most CJK fonts, all CJK characters (except some symbols or western 
	 *		characters) have same glyph bounding box:
	 *		left = 0, right = 1000, bottom = -220, top = 780.
	 *
	 *		It's OK to return a box that's larger than the actual glyph box.
	 *
	 * @param[in] provider		Pointer to this structure
	 * @param[in] font			Internal handle to the font. Returned by MapFont interface.
	 * @param[in] unicode		Unicode of the character
	 * @param[in] CID			Adobe CID for this character. Or zero if not available.
	 * @param[out] bbox			Receiving the result bounding box. See comments below.
	 */
	void			(*GetGlyphBBox)(struct FPDFEMB_GLYPH_PROVIDER* provider, void* font,
									FPDFEMB_WCHAR unicode, unsigned short CID,
									struct FPDFEMB_RECT* bbox);

	/**
	 * @brief Get bitmap of a glyph
	 *
	 * @details The buffer should be allocated by implementation. And it must be allocated
	 *		using FPDFEMB_AllocMemory function. The result buffer will be destroyed by
	 *		FPDFEMB SDK, so implementation should not destroy it.
	 *
	 *		The implementation should write "coverage" data into allocated buffer, one byte 
	 *		for each pixel, from top scanline to bottom scanline, within each scan line, 
	 *		from left pixel to right. Coverage 0 means the pixel is outside the glyph, 
	 *		coverage 255 means the pixel is inside the glyph.
	 *
	 *		The "pdf_width" parameter can be used to scale the character in system font
	 *		horizontally to match the font width specified in PDF. For example, if we have
	 *		a PDF file which requires a character in half-width (pdf_width is 500), but
	 *		in the system font the character has full-width (1000), then the glyph provider
	 *		implementation should scale the font horizontally to half of its original width.
	 *
	 * @param[in] provider		Pointer to this structure
	 * @param[in] font			Internal handle to the font. Returned by MapFont interface.
	 * @param[in] unicode		Unicode of the character
	 * @param[in] CID			Adobe CID for this character. Or zero if not available.
	 * @param[in] font_width	Width of the font em square, measured in device units.
	 * @param[in] font_height	Height of the font em square, measured in device units.
	 * @param[out] left			Receiving the left offset, from the character origin, of the
	 *							result glyph bitmap. Positive value will move the bitmap to
	 *							the right side, negative to the left.
	 * @param[out] top			Receiving the top offset, from the character origin, of the
	 *	 						result glyph bitmap. Positive value will move the bitmap upward,
	 *							negative downward.
	 * @param[out] bitmap_width		Receiving number of width pixels in the result bitmap
	 * @param[out] bitmap_height	Receiving number of height pixels in the result bitmap
	 * @param[out] buffer		Receiving a data buffer pointer, allocated by the implementation.
	 *							See comments below.
	 * @param[out] stride		Receiving number of bytes per scanline, in the data buffer.
	 * @param[in] pdf_width		Width of the character specified in PDF. It is measured in one-
	 *							thousandth of the font width. It can be 0 if width not specified
	 *							in PDF. See comments below.
	 * @return Non-zero for success. 0 for failure. In this case the glyph can not be displayed.
	 */
	FPDFEMB_BOOL	(*GetGlyphBitmap)(struct FPDFEMB_GLYPH_PROVIDER* provider, void* font,
									FPDFEMB_WCHAR unicode, unsigned short CID,
									double font_width, double font_height, int* left, int* top,
									int* bitmap_width, int* bitmap_height, 
									void** buffer, int* stride, int pdf_width);

	void*		user;		/**< @brief A user pointer, used by the application. */
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_SetGlyphProvider in fs_base.h .
 * @brief Make use of a glyph provider: generating glyph bitmap for non-Latin characters
 *
 * @details FPDFEMB embeds some standard fonts for Latin characters and symbols, like
 *			Times, Courier and Helvetica (Arial). For non-Latin characters, however,
 *			FPDFEMB has to ask glyph provide for help.
 *
 *			If an embedded device carries fonts for non-Latin character sets, especially
 *			those for CJK markets, then the application can implement a glyph provider,
 *			allowing PDFs using non-embedded CJK fonts to be properly displayed.
 *
 * @param[in] provider		Pointer to the glyph provider structure.
 *							This structure must stay valid throughout usage of EMB SDK.
 * @return None.
 */
void FPDFEMB_SetGlyphProvider(struct FPDFEMB_GLYPH_PROVIDER* provider);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_UseExternalData in fs_base.h .
 * @brief Make use of external data for FPDFEMB
 *
 * @details Some embedded system has limitation on program size, therefore we might not be able to
 *			embed a lot of data (like cmap data and embedded font data) into the FPDFEMB library. 
 *			We introduced this function so device can choose to store those data outside of program, 
 *			and make it available to FPDFEMB using this function. The data has to be provided by Foxit.
 *
 *			This function is only available in library specially built for using external data.
 *
 * @param[in]	data		Pointer to the external data
 * @param[in]	size		Number of bytes in the external data.
 * @return None.
 */
void FPDFEMB_UseExternalData(const unsigned char* data, unsigned int size);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadGB in fs_base.h .
 * @brief Make use of character encoding maps embedded with FPDFEMB
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_GB();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadGBExt in fs_base.h .
 * @brief Load CMaps for Adobe-GB1 character collection. Same as ::FPDFEMB_LoadCMap_GB. 
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_GB_Ext();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadCNS in fs_base.h .
 * @brief Load CMaps for Adobe-CNS1 character collection.
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_CNS();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadKorea in fs_base.h .
 * @brief Load CMaps for Adobe-Korea1 character collection.
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_Korea();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadJapan in fs_base.h .
 * @brief Load CMaps for Adobe-Japan1 character collection.
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_Japan();

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_FontCMap_LoadJapanExt in fs_base.h .
 * @brief Load CMaps for Adobe-Japan1 character collection. Same as ::FPDFEMB_LoadCMap_Japan
 *
 * @details These functions add character encoding data to your application. Each call
 *			will increase the code size of your application. Total data size for all
 *			character sets is around 434K bytes.
 * @return None.
 */
void FPDFEMB_LoadCMap_Japan_Ext();

/********************************************************************************************
****
****		Document Information
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Doc_GetMetaText in fpdf_document.h .
 * @brief Get the information string about the document, like creator, modification date, etc.
 *
 * @details The string is output in Unicode, using UTF-16LE format. It's terminated by
 *			two consecutive zero bytes.
 *
 *			If the "buffer" parameter is NULL, then the "bufsize" parameter will receive
 *			number of bytes required to store the string (including the two-byte terminator).
 *
 * @param[in] document		A handle to the document
 * @param[in] key			A byte string for the information key.<br>
 *							Currently it can be one of the followings:
 *							<ul>
 *							<li>"Title"</li> 
 *							<li>"Author"</li>
 *							<li>"Subject"</li>
 *							<li>"Keywords"</li>
 *							<li>"Creator"</li>
 *							<li>"Producer"</li>
 *							<li>"CreationDate"</li>
 *							<li>"ModDate"</li>
 *							<li>Some other custom information keys, if they're supported by the PDF file.</li>
 *							</ul>
 * @param[out] buffer		A buffer allocated by the application, or <b>NULL</b>.
 * @param[in,out] bufsize	A pointer to a unsigned integer which indicates the buffer size (count of bytes),
 *							before this function is called. Then after the function returns, this paremeter will store
 *							the actual count of bytes of the meta text.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetDocInfoString(FPDFEMB_DOCUMENT document, const char* key, void* buffer, unsigned int* bufsize);

/********************************************************************************************
****
****		Action (Destination) Information
****
********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will not be replaced by <b>FPDF_ACTION</b> in fpdf_base.h .
 * @brief PDF action handle type.
 */
typedef void* FPDFEMB_ACTION;

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Action types supported by FPDFEMB
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DEST_NONE in fpdf_base.h .
 * @brief No or unsupported destination.
 */
#define FPDFEMB_DEST_NONE			0
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DEST_PAGE in fpdf_base.h .
 * @brief A page inside the same document.
 */
#define FPDFEMB_DEST_PAGE			1
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DEST_DOC in fpdf_base.h .
 * @brief An external PDF document.
 */
#define FPDFEMB_DEST_DOC			2
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DEST_URL in fpdf_base.h .
 * @brief An external URL.
 */
#define FPDFEMB_DEST_URL			3
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ACTION_LAUNCH in fpdf_base.h .
 * @brief Launch an external file or command.
 */
#define FPDFEMB_ACTION_LAUNCH		4
/**@}*/

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Zoom mode for destination.
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_NONE in fpdf_base.h .
 * @brief Zoom mode not specified.
 */
#define FPDFEMB_ZOOM_NONE			0
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FACTOR in fpdf_base.h .
 * @brief Specific zoom factor is used.
 */
#define FPDFEMB_ZOOM_FACTOR			1
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITPAGE in fpdf_base.h .
 * @brief Fit the whole page on screen.
 */
#define FPDFEMB_ZOOM_FITPAGE		2
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITWIDTH in fpdf_base.h .
 * @brief Fit width of the page on screen.
 */
#define FPDFEMB_ZOOM_FITWIDTH		3
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITHEIGHT in fpdf_base.h .
 * @brief Fit height of the page on screen.
 */
#define FPDFEMB_ZOOM_FITHEIGHT		4
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITRECT in fpdf_base.h .
 * @brief Fit a particular rectangle on screen.
 */
#define FPDFEMB_ZOOM_FITRECT		5
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITCONTENT in fpdf_base.h .
 * @brief Fit whole content of page on screen.
 */
#define FPDFEMB_ZOOM_FITCONTENT		6
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITCONTENTW in fpdf_base.h .
 * @brief Fit content width of page on screen.
 */
#define FPDFEMB_ZOOM_FITCONTENTW	7
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ZOOM_FITCONTENTH in fpdf_base.h .
 * @brief Fit content height of page on screen.
 */
#define FPDFEMB_ZOOM_FITCONTENTH	8
/**@}*/

/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DEST in fpdf_base.h .
 * @brief Data structure for page destination.
 */
struct FPDFEMB_PAGEDEST
{
	int				page_index;		/**< @brief Zero based index for the page. */
	int				zoom_mode;		/**< @brief See FPDFEMB_ZOOM_xxx definition above. */
	int				zoom_factor;	/**< @brief For FPDFEMB_ZOOM_FACTOR only: the zoom factor (in percentage). */
	/**
	 * @brief Specify position inside the page. 
	 * @details Depends on the zoom mode,
	 * different members of the rectangle are used:<br>
	 * <ul>
	 * <li>FPDFEMB_ZOOM_NONE:			left, top</li>
	 * <li>FPDFEMB_ZOOM_FACTOR:		left, top</li>
	 * <li>FPDFEMB_ZOOM_FITPAGE:		none</li>
	 * <li>FPDFEMB_ZOOM_FITWIDTH:		top</li>
	 * <li>FPDFEMB_ZOOM_FITHEIGHT:	left</li>
	 * <li>FPDFEMB_ZOOM_FITRECT:		left, top, bottom, right</li>
	 * <li>FPDFEMB_ZOOM_FITCONTENT:	none</li>
	 * <li>FPDFEMB_ZOOM_FITCONTENTW:	top</li>
	 * <li>FPDFEMB_ZOOM_FITCONTENTH:	left</li>
	 * </ul>
	 */
	struct FPDFEMB_RECT	position;
};

/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_DOCDEST in fpdf_base.h .
 * @brief Data structure for document destination.
 */
struct FPDFEMB_DOCDEST
{
	struct FPDFEMB_PAGEDEST	page_data;	/**< @brief page data. */
	char*				file_name;	/**< @brief The file name, encoded in original charset (maybe MBCS). */
};

/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_URLDEST in fpdf_base.h .
 * @brief Data structure for URL destination.
 */
struct FPDFEMB_URLDEST
{
	char*				url;		/**< @brief URL encoded in 7-bit ASCII. */
};

/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_LAUNCHACTION in fpdf_base.h .
 * @brief Data structure for Launch action.
 */
struct FPDFEMB_LAUNCHACTION
{
	int					new_window;	/**< @brief Whether a new window should be opened. */
	char*				file_name;	/**< @brief The file name, encoded in original charset (maybe MBCS). */
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Action_GetType in fpdf_document.h .
 * @brief Get type of an action
 *
 * @details Each different type of destination has different data structure. The "data_size" result
 *			indicates how many bytes is required to hold the destination data structure. The application
 *			can then allocate sufficient buffer and then call ::FPDFEMB_Action_GetData function to
 *			get the real data.
 *
 * @param[in] document		Handle to the document
 * @param[in] action		Handle to the action
 * @param[out] dest_type	Pointer to an integer receiving type of the destination. See macro definitions <b>FPDFEMB_DEST_xxx</b>.
 * @param[out] data_size	Pointer to an integer receiving data block size for the destination.
 *							If this parameter is <b>NULL</b>, then data size won't be retrieved.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Action_GetType(FPDFEMB_DOCUMENT document, FPDFEMB_ACTION action, int* dest_type, int* data_size);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Action_GetData in fpdf_document.h .
 * @brief Get detailed data of a particular action.
 * @details The following data structures are used for different action types returned by ::FPDFEMB_Action_GetType :
 *			<ul>
 *			<li>::FPDFEMB_PAGEDEST</li>
 *			<li>::FPDFEMB_DOCDEST</li>
 *			<li>::FPDFEMB_URLDEST</li>
 *			<li>::FPDFEMB_LAUNCHACTION</li>
 *			</ul>
 *			See the definitions of each structure above for more details.
 *			Please note the actual action data might use more space than the structure definition
 *			shows, to store things like file name or URL. So you should always call
 *			::FPDFEMB_Action_GetType first to get data size then allocate enough buffer
 *			for this call.
 *
 * @param[in] document		Handle to the document
 * @param[in] action		Handle to the action
 * @param[out] buffer		Application allocated buffer receiving the destination data
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Action_GetData(FPDFEMB_DOCUMENT document, FPDFEMB_ACTION action, void* buffer);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Action_GetNext in fpdf_document.h .
 * @brief Get the next action in an action chain
 *
 * @details If there is no next action, the parameter <i>next</i> will be set to <b>NULL</b> and the function will return ::FPDFERR_SUCCESS.
 *
 * @param[in] action		Handle to current action
 * @param[out] next			Receiving handle to next action.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Action_GetNext(FPDFEMB_ACTION action, FPDFEMB_ACTION* next);

/********************************************************************************************
****
****		Bookmark Information
****
********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will be replaced by <b>FPDF_BOOKMARK</b> in fpdf_base.h .
 * @brief PDF bookmark handle type.
 */
typedef void* FPDFEMB_BOOKMARK;

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Bookmark_GetFirstChild in fpdf_document.h .
 * @brief Get the first child of a bookmark item, or first top level bookmark item
 *
 * @param[in] document		Handle to the document
 * @param[in] parent		Handle to the parent bookmark. 
 *							Can be <b>NULL</b> if you want to get the first top level item.
 * @param[out] bookmark		Receiving handle to the first child or top level bookmark item. 
 *							If result is <b>NULL</b>, then bookmark not found.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Bookmark_GetFirstChild(FPDFEMB_DOCUMENT document, FPDFEMB_BOOKMARK parent,
											  FPDFEMB_BOOKMARK* bookmark);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Bookmark_GetNextSibling in fpdf_document.h .
 * @brief Get the next sibling of a bookmark item
 *
 * @param[in] document		Handle to the document
 * @param[in] bookmark		Handle to the bookmark 
 * @param[out] sibling		Receiving the handle of next sibling.
 *							If result is <b>NULL</b>, then this is the last bookmark in this level.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Bookmark_GetNextSibling(FPDFEMB_DOCUMENT document, FPDFEMB_BOOKMARK bookmark,
											  FPDFEMB_BOOKMARK* sibling);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Bookmark_GetTitle in fpdf_document.h .
 * @brief Get the title of a bookmark
 *
 * @details The title is output in Unicode, using UTF-16LE format. It's terminated by
 *			two consecutive zero bytes.<br>
 *			If the "buffer" parameter is <b>NULL</b>, then the "bufsize" parameter will receive
 *			number of bytes required to store the bookmark title (including the two-
 *			byte terminator).<br>
 *			If the paramter <i>bufsize</i>(the size of <i>buffer</i>) is smaller than the required size, then this function
 *			will not copy any data, return ::FPDFERR_PARAM, and the required buffer size will 
 *			also be put in "bufsize" parameter.
 *
 * @param[in] bookmark		Handle to the bookmark 
 * @param[out] buffer		A buffer allocated by the application, or <b>NULL</b>.
 * @param[in,out] bufsize	A pointer to a number indicating the buffer size,
 *							before this function call. After return, this place will store
 *							number of bytes used by the output (including terminator).
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Bookmark_GetTitle(FPDFEMB_BOOKMARK bookmark, void* buffer, unsigned int* bufsize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Bookmark_GetPage in fpdf_document.h .
 * @brief Get page number of a bookmark pointing to
 *
 * @details Some bookmark might not point to a page, some bookmark might have more than one destination
 *			(action), for detailed information about a bookmark, you should call ::FPDFEMB_Bookmark_GetAction.
 *			This function only checks the first action of the bookmark. If the type of the first action is not <b>GOTO</b>,
 *			the return value will be ::FPDFERR_PARAM and the parameter will be set to be -1.
 *
 * @param[in] document		Handle to the document
 * @param[in] bookmark		Handle to the bookmark 
 * @param[out] page			Receiving the page number. -1 if this bookmark doesn't actually
 *							point to a page inside the document.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Bookmark_GetPage(FPDFEMB_DOCUMENT document, FPDFEMB_BOOKMARK bookmark, int* page);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Bookmark_GetAction in fpdf_document.h .
 * @brief Get action(s) associated with a particular bookmark
 *
 * @param[in] document		Handle to the document
 * @param[in] bookmark		Handle to the bookmark 
 * @param[out] action		Receiving handle of first action
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Bookmark_GetAction(FPDFEMB_DOCUMENT document, FPDFEMB_BOOKMARK bookmark, FPDFEMB_ACTION* action);

/********************************************************************************************
****
****		Hyperlink Information
****
********************************************************************************************/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetLinkCount in fpdf_annot.h .
 * @brief Get the count of hyperlinks inside a page
 *
 * @details This function must be called before any other link related function can
 *			be called for the page.
 *
 * @param[in] page			Page handle.
 * @param[out] link_count	Pointer to an integer receiving the number of links
 * @param[in] reserved		This parameter is reserved. And it must be set to zero now.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Link_GetCount(FPDFEMB_PAGE page, int* link_count, int reserved);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetLinkAction in fpdf_annot.h .
 * @brief Get action(s) associated with a particular hyperlink
 *
 * @param[in] page			Page handle
 * @param[in] link_index	Zero-based index for the link
 * @param[out] action		Receiving handle of first action
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Link_GetAction(FPDFEMB_PAGE page, int link_index, FPDFEMB_ACTION* action);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetLinkAreaCount in fpdf_annot.h .
 * @brief Get the count of area (quadrilaterals) for a link
 *
 * @param[in] page			Page handle
 * @param[in] link_index	Zero-based index for the link
 * @param[out] count		Pointer to an integer receiving number of quadrilaterals
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Link_GetAreaCount(FPDFEMB_PAGE page, int link_index, int* count);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Annot_GetLinkArea in fpdf_annot.h .
 * @brief Get a particular quadrilateral for a link
 *
 * @details The result in "points" array are the X/Y coordinations for the four vertices
 *			of the quadrilateral. Vertices are in the following order: lower left, lower
 *			right, upper right, upper left.
 *
 * @param[in] page			Page handle
 * @param[in] link_index	Zero-based index for the link
 * @param[in] area_index	Zero-based index for the quadrilateral
 * @param[out] points		-	Pointer to an array consists 4 points, receiving coordinations
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_Link_GetArea(FPDFEMB_PAGE page, int link_index, int area_index, 
									struct FPDFEMB_POINT* points);

/********************************************************************************************
****
****		Text Output
****
********************************************************************************************/

/** 
 * @deprecated As of release 2.0, this will not be replaced by <b>FS_FONT</b> in fs_base.h .
 * @brief PDF font handle type.
 */
typedef void* FPDFEMB_FONT;

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Macro definitions for Standard font ID
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_COURIER in fpdf_base.h .
 * @brief Courier.
 */
#define FPDFEMB_FONT_COURIER			0
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_COURIER_B in fpdf_base.h .
 * @brief bold. Courier-Bold.
 */
#define FPDFEMB_FONT_COURIER_B			1
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_COURIER_BI in fpdf_base.h .
 * @brief bold italic. Courier-BoldOblique.
 */
#define FPDFEMB_FONT_COURIER_BI			2
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_COURIER_I in fpdf_base.h .
 * @brief italic. Courier-Oblique.
 */
#define FPDFEMB_FONT_COURIER_I			3
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_HELVETICA in fpdf_base.h .
 * @brief Helvetica.
 */
#define FPDFEMB_FONT_HELVETICA			4
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_HELVETICA_B in fpdf_base.h .
 * @brief bold. Helvetica-Bold.
 */
#define FPDFEMB_FONT_HELVETICA_B		5
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_HELVETICA_BI in fpdf_base.h .
 * @brief bold italic. Helvetica-BoldOblique.
 */
#define FPDFEMB_FONT_HELVETICA_BI		6
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_HELVETICA_I in fpdf_base.h .
 * @brief italic. Helvetica-Oblique.
 */
#define FPDFEMB_FONT_HELVETICA_I		7
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_TIMES in fpdf_base.h .
 * @brief Times-Roman.
 */
#define FPDFEMB_FONT_TIMES				8
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_TIMES_B in fpdf_base.h .
 * @brief bold. Times-Bold.
 */
#define FPDFEMB_FONT_TIMES_B			9
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_TIMES_BI in fpdf_base.h .
 * @brief bold italic. Times-BoldItalic.
 */
#define FPDFEMB_FONT_TIMES_BI			10
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_TIMES_I in fpdf_base.h .
 * @brief italic. Times-Italic.
 */
#define FPDFEMB_FONT_TIMES_I			11
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_SYMBOL in fpdf_base.h .
 * @brief Symbol.
 */
#define FPDFEMB_FONT_SYMBOL				12
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_FONT_ZAPF_DINGBATS in fpdf_base.h .
 * @brief ZapfDingbats.
 */
#define FPDFEMB_FONT_ZAPF_DINGBATS		13
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_OpenStandardFont in fs_base.h .
 * @brief Get ready to use a standard PDF font
 *
 * @param[in] font_id			ID of font. See macro definitions <b>FPDFEMB_FONT_XXX</b>.
 * @param[out] font_handle		Receiving the font handle.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_OpenStandardFont(int font_id, FPDFEMB_FONT* font_handle);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_OpenFileFont in fs_base.h .
 * @brief Load a font from a file
 *
 * @details EMB SDK only supports TrueType or Type1 font.
 *
 * @param[in] file			Pointer to file access structure.
 *							This structure must be kept valid as long as the font is open.
 * @param[out] font_handle	Receiving the font handle.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_OpenFileFont(struct FPDFEMB_FILE_ACCESS* file,  FPDFEMB_FONT* font_handle);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_CloseFont in fs_base.h .
 * @brief Close a font handle.
 *
 * @param[in] font_handle	Handle to the font.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_CloseFont(FPDFEMB_FONT font_handle);

/**
 * @deprecated As of release 2.0, these definitions will not be used.
 * @name Font encodings
 */
/**@{*/
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ENCODING_INTERNAL in fpdf_base.h .
 * @brief Whatever internal encoding in the font.
 */
#define FPDFEMB_ENCODING_INTERNAL		0
/** 
 * @deprecated As of release 2.0, this will not be replaced by ::FPDF_ENCODING_UNICODE in fpdf_base.h .
 * @brief Unicode encoding.
 */
#define FPDFEMB_ENCODING_UNICODE		1
/**@}*/

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_GetGlyphIndex in fs_base.h .
 * @brief Get glyph index of a character
 *
 * @param[in] font_handle	Handle to the font.
 * @param[in] encoding		Encoding. See macro definitions <b>FPDFEMB_ENCODIN_XXX</b>.
 * @param[in] char_code		Character code, depends on the encoding used. <br>For example, if <i>encoding</i>
 * 							is ::FPDFEMB_ENCODING_UNICODE, then <i>char_code</i> should be unicode.
 * @param[out] glyph_index	Receiving the result glyph index.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetGlyphIndex(FPDFEMB_FONT font_handle, int encoding, unsigned long char_code,
									 unsigned long* glyph_index);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_GetGlyphWidth in fs_base.h .
 * @brief Get width of a glyph in a font
 *
 * @param[in] font_handle		Handle to the font.
 * @param[in] glyph_index		Index of the glyph in font.
 * @param[out] width			Receiving the character width, in 1/1000 of design size (em)
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetGlyphWidth(FPDFEMB_FONT font_handle, unsigned long glyph_index, unsigned long* width);

/** 
 * @deprecated As of release 2.0, this will not be used.
 * @brief Text matrix for FPDFEMB.
 */
struct FPDFEMB_TEXTMATRIX
{
	double	a, b, c, d;
};

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Font_GetGlyphBitmapBearing in fs_base.h .
 * @brief Get bitmap bearing of a glyph in a font
 *
 * @param[in] font_handle		Handle to the font.
 * @param[in] glyph_index		Index of the glyph in font.
 * @param[in] matrix			Matrix for the glyph. Can be NULL.
 * @param[in] font_size			Font size in pixels.
 * @param[out] bitmap_left	    Receiving the glyph bitmap's left bearing expressed in integer pixels.
 * @param[out] bitmap_top	    Receiving the glyph bitmap's top bearing expressed in integer pixels.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
 FPDFEMB_RESULT FPDFEMB_GetGlyphBitmapBearing(FPDFEMB_FONT font_handle, unsigned long glyph_index, struct FPDFEMB_TEXTMATRIX* matrix, double font_size, int *bitmap_left, int *bitmap_top);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_OutputGlyph in fs_base.h .
 * @brief Output a glyph onto a DIB device
 *
 * @param[in] dib			DIB handle, as the output device
 * @param[in] x				DIB x-coordination for the glyph origin
 * @param[in] y				DIB y-coordination for the glyph origin.
 * @param[in] font_handle	Handle to the font
 * @param[in] font_size		Font size in pixels
 * @param[in] matrix		Matrix for the text output. Can be NULL.
 * @param[in] glyph_index	Index of glyph to be output
 * @param[in] color			Color of the text, in 0xrrggbb format.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_OutputGlyph(FPDFEMB_BITMAP dib, int x, int y, FPDFEMB_FONT font_handle, double font_size,
								  struct FPDFEMB_TEXTMATRIX* matrix, unsigned long glyph_index, unsigned long color);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_Bitmap_OutputText in fs_base.h .
 * @brief Output text string onto a DIB device.
 *
 * @param[in] dib			DIB handle, as the output device
 * @param[in] x				DIB x-coordination for the origin point of the first character.
 * @param[in] y				DIB y-coordination for the origin point of the first character.
 * @param[in] font_handle	Handle to the font
 * @param[in] font_size		Font size in pixels
 * @param[in] matrix		Matrix for the text output. Can be NULL.
 * @param[in] text			Zero-terminated unicode text string
 * @param[in] color			Color of the text, in 0xrrggbb format.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_OutputText(FPDFEMB_BITMAP dib, int x, int y, FPDFEMB_FONT font_handle, double font_size,
								  struct FPDFEMB_TEXTMATRIX* matrix, const FPDFEMB_WCHAR* text, unsigned long color);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FS_LOG_CALLBACK in fs_exception.h .
 * @brief Set a logging procedure to output debugging messages from FPDFEMB
 *
 * @param[in] proc			A callback function for output logging info
 * @return None.
 */
void FPDFEMB_SetLogProc(void (*proc)(const char* msg));

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_GetContentMargin in fpdf_view.h .
 * @brief Get content margin
 *
 * @param[in] page			Page handle
 * @param[out] left			Receiving the left margin (in hundredth of points)
 * @param[out] top			Receiving the top margin (in hundredth of points)
 * @param[out] right			Receiving the right margin (in hundredth of points)
 * @param[out] bottom		Receiving the bottom margin (in hundredth of points)
 * @param[in] backcolor		Color for intended background in the page. In 0xRRGGBB format.
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetContentMargin(FPDFEMB_PAGE page, int* left, int* top, int* right, int* bottom, 
								  unsigned long backcolor/*=0xfffffff*/);


/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_GetPageLabel in fpdf_document.h .
 * @brief Get Page label
 *
 * @details The string is output in Unicode, using UTF-16LE format. It's terminated by
 *			two consecutive zero bytes.<br>
 *			If the "buffer" parameter is <b>NULL</b>, then the "bufsize" parameter will receive
 *			number of bytes required to store the string (including the two-byte terminator).
 *
 * @param[in] document		Handle to the document
 * @param[out] nPage		Page index
 * @param[out] buffer		A buffer allocated by the application, or <b>NULL</b>.
 * @param[in,out] bufsize	A pointer to a number indicating the buffer size (number of bytes),
 *							before this function call. After return, this place will store
 *							number of bytes used by the output (including terminator).
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_GetPageLabel(FPDFEMB_DOCUMENT document, int nPage, void* buffer, unsigned int* bufsize);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageLabelToPageNum in fpdf_document.h .
 * @brief Get Page Number by Page Label
 *
 * @param[in] document		Handle to the document
 * @param[in] pagelabel		A zero-terminated unicode page label string to be found. 
 * @param[out] pageNum		Receiving the found page number
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLabelToPageNum(FPDFEMB_DOCUMENT document, FPDFEMB_WCHAR* pagelabel,int* pageNum);

/**
 * @deprecated As of release 2.0, this will be replaced by ::FPDF_Page_PageLabelToPageNum in fpdf_document.h .
 * @brief Get Page Number by Page Label, without case-sensitivity.
 *
 * @param[in] document		Handle to the document
 * @param[in] pagelabel		A zero-terminated unicode page label string to be found. 
 * @param[out] pageNum		Receiving the found page number
 *
 * @return	::FPDFERR_SUCCESS means success.<br>
 *			For more definitions please see macro definitions <b>FPDFERR_XXX</b>.
 *
 */
FPDFEMB_RESULT FPDFEMB_PageLabelToPageNumNoCase(FPDFEMB_DOCUMENT document, FPDFEMB_WCHAR* pagelabel, int* pageNum);

#ifdef __cplusplus
};
#endif

#endif	// #ifdef _FPDFEMB_H_

