/*****************************************************************************/
/* File Name: ASN1Engine.h                                                   */
/* Description: Implement functions to decode ASN.1 (file or memory)         */
/*                                                                           */
/* Author: Feng Lin                                                          */
/* Creation Date: August 22, 2011                                            */
/* Last Revision:                                                            */
/*                                                                           */
/* Add ASN.1 encoding functions                                              */
/* Author: Xiangyou Bei                                                      */
/* Date: November 29, 2012                                                   */
/*****************************************************************************/

#ifndef _ASN1ENGINE_EX_H
#define _ASN1ENGINE_EX_H

#include <vector>
using namespace std;

#define MAX_ASN1_DATA_MEMORY_SIZE    (50*1024*1024)  // 50M
#define ONCE_PROCESS_BLOCK_BUFFER    (3*1024*1024)   // 3M


//The following definition reference:http://en.wikipedia.org/wiki/Basic_Encoding_Rules#BER_encoding

#define ASN1_TAG_CLASS_UNIVERSAL        0x00
#define ASN1_TAG_CLASS_APPLICATION      0x40
#define ASN1_TAG_CLASS_CONTEXT          0x80
#define ASN1_TAG_CLASS_PRIVATE          0xC0

#define ASN1_TAG_PRIMITIVE              0x00
#define ASN1_TAG_CONSTRUCTED            0x20

#define ASN1_TAG_P_BOOLEAN              0x01
#define ASN1_TAG_P_INTEGER              0x02
#define ASN1_TAG_P_BIT_STRING           0x03
#define ASN1_TAG_P_OCTET_TTRING         0x04
#define ASN1_TAG_P_NULL                 0x05
#define ASN1_TAG_P_OBJECT_IDENTIFIER    0x06

#define ASN1_TAG_P_UTF8_STRING          0X0C
#define ASN1_TAG_C_UTF8_STRING          (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_UTF8_STRING)

#define ASN1_TAG_C_SEQUENCE             (ASN1_TAG_CONSTRUCTED | 0x10)
#define ASN1_TAG_C_SEQUENCE_OF          (ASN1_TAG_CONSTRUCTED | 0x10)

#define ASN1_TAG_C_SET                  (ASN1_TAG_CONSTRUCTED | 0x11)
#define ASN1_TAG_C_SET_OF               (ASN1_TAG_CONSTRUCTED | 0x11)

#define ASN1_TAG_P_PRINTABLE_STRING     0x13
#define ASN1_TAG_C_PRINTABLE_STRING     (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_PRINTABLE_STRING)

#define ASN1_TAG_P_T61_STRING           0x14
#define ASN1_TAG_C_T61_STRING           (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_T61_STRING)

#define ASN1_TAG_P_IA5_STRING           0x16
#define ASN1_TAG_C_IA5_STRING           (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_IA5_STRING)

#define ASN1_TAG_P_UTC_TIME             0x17
#define ASN1_TAG_C_UTC_TIME             (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_UTC_TIME)

#define ASN1_TAG_P_GENERALIZED_TIME     0x18
#define ASN1_TAG_C_GENERALIZED_TIME     (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_GENERALIZED_TIME)

#define ASN1_TAG_P_BMP_STRING           0x1E
#define ASN1_TAG_C_BMP_STRING           (ASN1_TAG_CONSTRUCTED | ASN1_TAG_P_BMP_STRING)


class NodeEx
{
public:
    FILE* pFile;                      //decode ASN.1 from file
    unsigned char* pMemoryStart;      //decode ASN.1 from memory
    long long      ValueStartPos;

    unsigned char  Tag;
    unsigned long  LengthSize;
    unsigned long  ValueLength;
    unsigned long  CurrentValueLength;//If the current value is not the final complete value, the current value length should be recorded.  (CurrentValueLength <= ValueLength)
    unsigned char* pValue;            //Used for encode, the buffer is released by the destructor.

    unsigned long  TotalLength;       //Include tag+length size+value size

    unsigned long  FileLength;

    unsigned short isInfiniteLength;  //If it is infinite length ASN.1 node. 0:No 1:Yes

    unsigned short isNodesinMemory;   //Reserved attribute(Now it is not used)

    NodeEx*        pParentNode;

    vector<NodeEx*> vetNodes;          

    NodeEx()
    {
        pFile = NULL;
        pMemoryStart = NULL;
        ValueStartPos = 0;
        Tag = 0x00;
        LengthSize = 0;
        ValueLength = 0;
        CurrentValueLength = 0;
        pValue = NULL;
        TotalLength = 0;
        FileLength = 0;
        isInfiniteLength = 0;
        isNodesinMemory = 0;
        pParentNode = NULL;
    }
    ~NodeEx()
    {
        if (NULL != pValue)
        {
            delete [] pValue;
            pValue = NULL;
        }
        int size = (int)vetNodes.size();
        for(int i=0; i<size; i++)
        {
            delete vetNodes[i];
        }

        vetNodes.clear();
    }

    int GetTotalRequiredSize();
    int GetCurrentRequiredLength();
    void AddChild(NodeEx* pChildNode);
};

#ifdef __cplusplus
extern "C" {
#endif
//*************************************************************************
// Method:      EncodeASN1Length
// Access:      public 
// Returns:     int Success: The length of encoded length octets; Failed: -1
// Parameter:   [IN]long long length
// Parameter:   [OUT]unsigned char * * ppLengthOctets
// Description: Encode the Length field in a TLV triplet                 
//              e.g.   16  -> 0x10                                          
//                     127 -> 0x7F                                          
//                     128 -> 0x81 0x80                                     
//                     146 -> 0x81 0x92                                     
//                     256 -> 0x82 0x01 0x00                                
//              For more ASN.1 value length encoding, please refer to          
//              http://msdn.microsoft.com/en-us/library/bb648641(v=vs.85).aspx 
//
// Author:      xybei
// Date:        2012/11/29
//*************************************************************************
int EncodeASN1Length(long long length,
                     unsigned char** ppLengthOctets);


//*************************************************************************
// Method:      ASN1Encode
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char byTag
// Parameter:   [IN]unsigned char * pbyValue
// Parameter:   [IN]int nLength
// Parameter:   [OUT]unsigned char * * ppbyEncodedData
// Parameter:   [OUT]int * pnEncodedSize
// Description: Encode data to a TLV triple.
//            
// Author:      xybei
// Date:        2012/12/02
//*************************************************************************
int ASN1Encode(unsigned char byTag,
               unsigned char* pbyValue,
               int nLength,
               unsigned char** ppbyEncodedData,
               int* pnEncodedSize);


//*************************************************************************
// Method:      EncodeASN1ToMemory
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]NodeEx * pNode: The nodes tree need to encode
// Parameter:   [OUT]unsigned char * * ppEncodedData
// Parameter:   [OUT]int * pnEncodedDataSize
// Parameter:   [IN/OUT]int * pnRecursiveCount: Output the depth(limit <= 256) of recursive, Pass NULL if do not need limit
// Description: Encode a nodes tree to memory. 
//              In order to support large data, the last node's Value(large data) can be set to NULL,
//              you can write the lack of Value(large data) after the encoding is done
//            
// Author:      xybei
// Date:        2012/11/29
//*************************************************************************
int EncodeASN1ToMemory(NodeEx* pNode,
                       unsigned char** ppEncodedData,
                       int* pnEncodedDataSize,
                       int* pnRecursiveCount = NULL);


//*************************************************************************
// Method:      EncodeASN1ToFile
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]NodeEx * pNode: The nodes tree need to encode
// Parameter:   [IN/OUT]FILE * fpOutFile
// Parameter:   [OUT]int * pnEncodedDataSize
// Parameter:   [IN/OUT]int * pnRecursiveCount: Output the depth(limit <= 256) of recursive, Pass NULL if do not need limit
// Description: Encode a nodes tree to file. (support large file)
//            
// Author:      xybei
// Date:        2012/11/29
//*************************************************************************
int EncodeASN1ToFile(NodeEx* pNode,
                     FILE* fpOutFile,
                     int* pnEncodedDataSize,
                     int* pnRecursiveCount = NULL);

int ParseASN1TLVEx(FILE* pFile,
                   unsigned char* pMemoryStart,
                   long long* startPosition, 
                   long long* endPosition,
                   unsigned char* tag,
                   unsigned long* lengthSize,
                   unsigned long* valueLength,        
                   unsigned long* valueBeginPos,      
                   unsigned long* valueEndPos,
                   unsigned short* isInfiniteLength);       

int GetASN1ValueLengthEx(FILE* pFile,
                         unsigned char* pMemoryStart,
                         long long* lengthStartPos,
                         long long* endPosition,
                         unsigned long*lengthByteSize,
                         unsigned long*valueLength,
                         unsigned long*valueStartPos,
                         unsigned short* isInfiniteLength);

int ParseNodeEx(NodeEx* pNode,unsigned int& recursiveCount);

int DecodeASN1MemoryEx(unsigned char* pMemoryStartPoint, unsigned long memoryLength, NodeEx** ppNode);

int DecodeASN1FileEx(FILE* pASN1File, NodeEx** ppNode);

//Helper functions
void PrintNodeEx(NodeEx* pNode);
#ifdef __cplusplus
}
#endif
#endif //_ASN1ENGINE_EX_H


