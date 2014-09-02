/**************************************************************************
    filename:   Misc.h
    author:     xybei
    created:    2012/12/10
    purpose:    Declare misc functions
                
**************************************************************************/
#ifndef _MISC_H__
#define _MISC_H__

#include <string>
#include <vector>
#define INFO            1

void TraceInfo(char* pszTraceInfo);

void TraceError(char* pszErrorInfo);
int TRACE(int type, char const* format, ...);

//*************************************************************************
// Method:      GetFileSize_Ex
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE * fpFile
// Parameter:   [OUT]unsigned int * pnFileSize
// Description: WARNING: This function will modify the current position of file pointer to the beginning 
//            
// Author:      xybei
// Date:        2012/12/10
//*************************************************************************
int GetFileSize_Ex( FILE* fpFile, unsigned int* pnFileSize );

//*************************************************************************
// Method:      SplitString
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN] char* pszStr
// Parameter:   [IN] const char* pszSplit
// Parameter:   [OUT] std::vector<char*>& tokens
// Description: Split pszStr with pszSplit to tokens array 
// Warning    : The caller must free tokens array item char*  by free()
//            
// Author:      kjduan
// Date:        2013/07/19
//*************************************************************************
int SplitString( char* pszStr, const char* pszSplit, std::vector<char*>& tokens);

//*************************************************************************
// Method:      ConvertBinaryDataToString
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyBinaryData
// Parameter:   [IN]int nBinaryDataSize
// Parameter:   [OUT]char ** ppszHexString
// Parameter:   [IN]bool  bChangeByteOrder
// Description: Convert binary data to string. 
//            
// Author:      xxzhang
// Date:        2013/07/15
//*************************************************************************
int ConvertBinaryDataToString(unsigned char* pbyBinaryData, 
                              int nBinaryDataSize, 
                              char **ppszHexString, 
                              bool bChangeByteOrder);
#endif // _MISC_H__
