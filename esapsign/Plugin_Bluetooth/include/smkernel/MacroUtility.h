/*****************************************************************************/
/* File Name: MacroUtility.h                                                 */
/* Description: Define macro utility                                         */
/*                                                                           */
/* Author: Xiangyou Bei                                                      */
/* Creation Date: Nov 22, 2012                                               */
/* Last Revision:                                                            */
/*                                                                           */
/* history:                                                                  */
/*     2013-2-20 duankuanjun  new add zlog to this                           */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef _MACRO_UTILITY_H
#define _MACRO_UTILITY_H

#include "Misc.h"
// zlog interface header file
#ifndef WIN32  // NOT WIN32
#else // WIN32
#pragma warning(disable : 4996)
#endif 



#define ALLOCATE_MEMORY(_ptr, _type, _len) \
        { \
            _ptr = new _type[_len]; \
            CHECK_ERROR(!_ptr, CFCA_ERROR, "New memory"); \
            memset(_ptr, 0, sizeof(_type) * (_len)); \
        }

#define DELETE_MEMORY(_ptr) \
        if (_ptr) \
        { \
            delete[] (_ptr); \
            _ptr = NULL; \
        }

#define DELETE_OBJECT(_ptr) \
        if (_ptr) \
        { \
            delete (_ptr); \
            _ptr = NULL; \
        }

#define CHECK_ERROR(_exp, _err_code, _trace) \
        if (_exp) \
        { \
            int nBufSize = (int)(128 + strlen(_trace) + strlen(__FILE__) + strlen(__FUNCTION__)); \
            char* pszErrorInfo = NULL; \
            pszErrorInfo = new char[nBufSize]; \
            if (pszErrorInfo) \
            { \
                memset(pszErrorInfo, 0, nBufSize); \
                sprintf(pszErrorInfo, "[%s(%d):](%s -- %s)\t\t--Failed:(0x%08x)\n", __FILE__, __LINE__, __FUNCTION__, _trace, _err_code); \
                TraceError(pszErrorInfo); \
                delete[] pszErrorInfo; \
                pszErrorInfo = NULL; \
            } \
            else \
            { \
                TraceError("CHECK_ERROR new memory failed!"); \
            } \
            nResult = _err_code; \
            goto _err;  \
        } \
        else \
        { \
            int nBufSize = (int)(128 + strlen(_trace) + strlen(__FILE__) + strlen(__FUNCTION__)); \
            char* pszTraceInfo = NULL; \
            pszTraceInfo = new char[nBufSize]; \
            if (pszTraceInfo) \
            { \
                memset(pszTraceInfo, 0, nBufSize); \
                sprintf(pszTraceInfo, "[%s(%d)]:(%s -- %s)\t\t--OK\n", __FILE__, __LINE__, __FUNCTION__, _trace); \
                TraceInfo(pszTraceInfo); \
                delete[] pszTraceInfo; \
                pszTraceInfo = NULL; \
            } \
            else \
            { \
                TraceError("CHECK_ERROR new memory failed!"); \
            } \
        }

#define CHECK_OPENSSL_ERROR(_exp, _err_code, _trace) \
        if (_exp) \
        { \
            int nBufSize = (int)(128 + strlen(_trace) + strlen(__FILE__) + strlen(__FUNCTION__)); \
            char* pszErrorInfo = NULL; \
            pszErrorInfo = new char[nBufSize]; \
            if (pszErrorInfo) \
            { \
                memset(pszErrorInfo, 0, nBufSize); \
                sprintf(pszErrorInfo, "[%s(%d):](%s -- %s)\t\t--Failed:(0x%08x) Openssl Error: lib(%d)-func(%d)-reason(%d) \n", \
                __FILE__, __LINE__, __FUNCTION__, _trace, _err_code, ERR_GET_LIB(ERR_peek_last_error()), ERR_GET_FUNC(ERR_peek_last_error()),ERR_GET_REASON(ERR_peek_last_error())); \
                TraceError(pszErrorInfo); \
                delete[] pszErrorInfo; \
                pszErrorInfo = NULL; \
            } \
            else \
            { \
                TraceError("CHECK_OPENSSL_ERROR new memory failed!"); \
            } \
            nResult = _err_code; \
            goto _err;  \
        } \
        else \
        { \
            int nBufSize = (int)(128 + strlen(_trace) + strlen(__FILE__) + strlen(__FUNCTION__)); \
            char* pszTraceInfo = NULL; \
            pszTraceInfo = new char[nBufSize]; \
            if (pszTraceInfo) \
            { \
                memset(pszTraceInfo, 0, nBufSize); \
                sprintf(pszTraceInfo, "[%s(%d)]:(%s -- %s)\t\t--OK\n", __FILE__, __LINE__, __FUNCTION__, _trace); \
                TraceInfo(pszTraceInfo); \
                delete[] pszTraceInfo; \
                pszTraceInfo = NULL; \
            } \
            else \
            { \
                TraceError("CHECK_OPENSSL_ERROR new memory failed!"); \
            } \
        }

#endif //_MACRO_UTILITY_H