/**************************************************************************
    filename:   CMSEnvelopeOperations.h
    author:     xybei
    created:    2012/12/02
    purpose:    Declare CMS envelope functions	
                
**************************************************************************/
#ifndef _CMS_ENVELOPE_OPERATIONS_H
#define _CMS_ENVELOPE_OPERATIONS_H

//*************************************************************************
// Method:      GetOIDFromNID
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN] int NID
// Parameter:   [OUT]char **ppszOID
// Parameter:   [OUT]int *pnOIDLen
// Description: get OID from NID
//            
// Author:      xxzhang
// Date:        2013/05/08
//*************************************************************************
int GetOIDFromNID( int NID, 
                   char **ppszOID, int *pnOIDLen);

//*************************************************************************
// Method:      Encode_ObjectIdentifier
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN] char * pszOid
// Parameter:   [OUT]unsigned char * * ppbyEncodedData
// Parameter:   [OUT]int * pnEncodedSize
// Parameter:   [IN]bool bWithTL = true
// Description: if bWithTL is false, This function only encode the value(V) of TLV triple
//            
// Author:      xybei
// Date:        2012/12/02
//*************************************************************************
int Encode_ObjectIdentifier( char* pszOid,
                             unsigned char** ppbyEncodedData,
                             int* pnEncodedSize,
                             bool bWithTL = true );


//*************************************************************************
// Method:      Encode_AlgorithmIdentifier
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszAlgorithmOid
// Parameter:   [IN]unsigned char * pbyParameterTLVData: The TLV triple Data of the parameter. {0x05,0x00} for NULL
// Parameter:   [IN]int nParameterTLVSize
// Parameter:   [OUT]unsigned char * * ppbyEncodedData
// Parameter:   [OUT]int * pnEncodedSize
// Parameter:   [IN]bool bWithTL = true
// Description: if bWithTL is false, This function only encode the value(V) of TLV triple
//            
// Author:      xybei
// Date:        2012/12/02
//*************************************************************************
int Encode_AlgorithmIdentifier( char* pszAlgorithmOid,
                                unsigned char* pbyParameterTLVData, int nParameterTLVSize,
                                unsigned char** ppbyEncodedData, int* pnEncodedSize,
                                bool bWithTL = true );


//*************************************************************************
// Method:      ConstructNode_ObjectIdentifier
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszOid
// Parameter:   [OUT]NodeEx * * ppNodeObjectIdentifier
// Description: Construct "ObjectIdentifier" node
//            
// Author:      xybei
// Date:        2012/12/04
//*************************************************************************
int ConstructNode_ObjectIdentifier( char* pszOid,
                                    NodeEx** ppNodeObjectIdentifier );


//*************************************************************************
// Method:      ConstructNode_AlgorithmIdentifier
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszAlgorithmOid
// Parameter:   [IN]unsigned char * pbyParameterTLVData
// Parameter:   [IN]int nParameterTLVSize
// Parameter:   [OUT]NodeEx * * ppNodeAlgorithmIdentifier
// Description: Construct "AlgorithmIdentifier" node
//            
// Author:      xybei
// Date:        2012/12/04
//*************************************************************************
int ConstructNode_AlgorithmIdentifier( char* pszAlgorithmOid,
                                       unsigned char* pbyParameterTLVData, int nParameterTLVSize,
                                       NodeEx** ppNodeAlgorithmIdentifier );

//*************************************************************************
// Method:      ConstructNode_KeyTransRecipientInfo
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]int nVersion
// Parameter:   [IN]unsigned char * pbyRecipientSubjectKeyID
// Parameter:   [IN]int nRecipientSubjectKeyID
// Parameter:   [IN]char * pszKeyEncryptionAlgOid
// Parameter:   [IN]unsigned char * pbyKeyEncryptionAlgParameter
// Parameter:   [IN]int nKeyEncryptionAlgParameterSize
// Parameter:   [IN]unsigned char * pbyEncryptedKey
// Parameter:   [IN]int nEncryptedKeySize
// Parameter:   [OUT]NodeEx * * ppNodeKeyTransRecipientInfo
// Description: Construct "KeyTransRecipientInfo" node of CMS Envelope
//            
// Author:      xybei
// Date:        2012/12/02
//*************************************************************************
int ConstructNode_KeyTransRecipientInfo( int nVersion,
                                         unsigned char* pbyRecipientSubjectKeyID, int nRecipientSubjectKeyID,
                                         char* pszKeyEncryptionAlgOid,
                                         unsigned char* pbyKeyEncryptionAlgParameter, int nKeyEncryptionAlgParameterSize,
                                         unsigned char* pbyEncryptedKey, int nEncryptedKeySize,
                                         NodeEx** ppNodeKeyTransRecipientInfo );


//*************************************************************************
// Method:      ConstructNode_EncryptedContentInfo
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszContentTypeOid
// Parameter:   [IN]char * pszContentEncryptionAlgAlgOid
// Parameter:   [IN]unsigned char * pbyContentEncryptionAlgParameter
// Parameter:   [IN]int nContentEncryptionAlgParameterSize
// Parameter:   [IN]unsigned char * pbyEncryptedContent
// Parameter:   [IN]int nEncryptedContentSize
// Parameter:   [OUT]NodeEx * * ppNodeEncryptedContentInfo
// Description: Construct "EncryptedContentInfo" node of CMS Envelope
//            
// Author:      xybei
// Date:        2012/12/03
//*************************************************************************
int ConstructNode_EncryptedContentInfo( char* pszContentTypeOid,
                                        char* pszContentEncryptionAlgOid,
                                        unsigned char* pbyContentEncryptionAlgParameter, int nContentEncryptionAlgParameterSize,
                                        unsigned char* pbyEncryptedContent,  int nEncryptedContentSize,
                                        NodeEx** ppNodeEncryptedContentInfo );


//*************************************************************************
// Method:      ConstructNode_EnvelopedData
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]int nVersion
// Parameter:   [IN]NodeEx * pNodeRecipientInfos
// Parameter:   [IN]NodeEx * pNodeEncryptedContentInfo
// Parameter:   [OUT]NodeEx * * ppNodeEnvelopedData
// Description: Construct "EnvelopedData" node of CMS Envelope
//            
// Author:      xybei
// Date:        2012/12/04
//*************************************************************************
int ConstructNode_EnvelopedData( int nVersion,
                                 NodeEx* pNodeRecipientInfos,
                                 NodeEx* pNodeEncryptedContentInfo,
                                 NodeEx** ppNodeEnvelopedData );


//*************************************************************************
// Method:      ConstructNode_ContentInfo
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszContentTypeOid
// Parameter:   [IN]NodeEx * pNodeContent
// Parameter:   [OUT]NodeEx * * ppNodeContentInfo
// Description: Construct the outermost layer "ContentInfo" node of CMS Envelope
//            
// Author:      xybei
// Date:        2012/12/04
//*************************************************************************
int ConstructNode_ContentInfo( char* pszContentTypeOid,
                               NodeEx* pNodeContent,
                               NodeEx** ppNodeContentInfo );


//*************************************************************************
// Method:      Encode_CMSEnvelope
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char* pszEnvelopeContentTypeOid
// Parameter:   [IN]unsigned char * pbyRecipientSubjectKeyID
// Parameter:   [IN]int nRecipientSubjectKeyID
// Parameter:   [IN]char* pszContentEncryptionTypeOid
// Parameter:   [IN]char * pszKeyEncryptionAlgOid
// Parameter:   [IN]unsigned char * pbyEncryptedKey
// Parameter:   [IN]int nEncryptedKeySize
// Parameter:   [IN]char * pszContentEncryptionAlgAlgOid
// Parameter:   [IN]unsigned char * pbyContentEncryptionAlgParameter
// Parameter:   [IN]int nContentEncryptionAlgParameter
// Parameter:   [IN]unsigned char * pbyEncryptedContent
// Parameter:   [IN]int nEncryptedContentSize
// Parameter:   [OUT]unsigned char * * ppbyEncodedData
// Parameter:   [OUT]int * pnEncodedDataSize
// Description: Encode CMS envelope
//            
// Author:      xybei
// Date:        2012/12/04
//*************************************************************************
int Encode_CMSEnvelope( char* pszEnvelopeContentTypeOid,
                        unsigned char* pbyRecipientSubjectKeyID, int nRecipientSubjectKeyID,
                        char* pszKeyEncryptionAlgOid,
                        unsigned char* pbyEncryptedKey, int nEncryptedKeySize,
                        char* pszContentEncryptionTypeOid, 
                        char* pszContentEncryptionAlgOid,
                        unsigned char* pbyContentEncryptionAlgParameter, int nContentEncryptionAlgParameter,
                        unsigned char* pbyEncryptedContent,  int nEncryptedContentSize,
                        unsigned char** ppbyEncodedData, int* pnEncodedDataSize );

//*************************************************************************
// Method:      Decode_CMSEnvelopeData
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCMSEnvelopeData
// Parameter:   [IN]int nCMSEnvelopeSize
// Parameter:   [OUT]unsigned char * * ppbyRecipientSubjectKeyID
// Parameter:   [OUT]int * pnRecipientSubjectKeyID
// Parameter:   [OUT]unsigned char * * ppbyEncryptedKey
// Parameter:   [OUT]int * pnEncryptedKeySize
// Parameter:   [OUT]unsigned char * * ppbyEncryptedContent
// Parameter:   [OUT]int * pnEncryptedContentSize
// Parameter:   [OUT]char * * ppszKeyEncryptionAlgOid
// Parameter:   [OUT]int * pnKeyEncryptionAlgOidLength
// Parameter:   [OUT]char * * ppszContentEncryptionAlgOid
// Parameter:   [OUT]int * pnContentEncryptionAlgOidLength
// Parameter:   [OUT]unsigned char * * ppbyContentEncryptionAlgParameter
// Parameter:   [OUT]int * pnContentEncryptionAlgParameterSize
// Description: Decode CMS Envelope Data
//            
// Author:      xybei
// Date:        2012/12/17
//*************************************************************************
int Decode_CMSEnvelopeData( unsigned char* pbyCMSEnvelopeData,          int nCMSEnvelopeSize,
                            unsigned char** ppbyRecipientSubjectKeyID,  int* pnRecipientSubjectKeyID,
                            unsigned char** ppbyEncryptedKey,           int* pnEncryptedKeySize,
                            unsigned char** ppbyEncryptedContent,       int* pnEncryptedContentSize,
                            char** ppszKeyEncryptionAlgOid = NULL,      int* pnKeyEncryptionAlgOidLength = NULL,
                            char** ppszContentEncryptionAlgOid = NULL,  int* pnContentEncryptionAlgOidLength = NULL,
                            unsigned char** ppbyContentEncryptionAlgParameter = NULL, int* pnContentEncryptionAlgParameterSize = NULL );

//*************************************************************************
// Method:      Decode_CMSEnvelopeFile
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE * fpCMSEnvelopeFile
// Parameter:   [OUT]unsigned char * * ppbyRecipientSubjectKeyID
// Parameter:   [OUT]int * pnRecipientSubjectKeyID
// Parameter:   [OUT]unsigned char * * ppbyEncryptedKey
// Parameter:   [OUT]int * pnEncryptedKeySize
// Parameter:   [OUT]long long * pEncryptedContentStartPos
// Parameter:   [OUT]int * pnEncryptedContentSize
// Parameter:   [OUT]char * * ppszKeyEncryptionAlgOid
// Parameter:   [OUT]int * pnKeyEncryptionAlgOidLength
// Parameter:   [OUT]char * * ppszContentEncryptionAlgOid
// Parameter:   [OUT]int * pnContentEncryptionAlgOidLength
// Parameter:   [OUT]unsigned char * * ppbyContentEncryptionAlgParameter
// Parameter:   [OUT]int * pnContentEncryptionAlgParameterSize
// Description: Decode CMS Envelope file
//            
// Author:      xybei
// Date:        2012/12/18
//*************************************************************************
int Decode_CMSEnvelopeFile( FILE* fpCMSEnvelopeFile,
                            unsigned char** ppbyRecipientSubjectKeyID,  int* pnRecipientSubjectKeyID,
                            unsigned char** ppbyEncryptedKey,           int* pnEncryptedKeySize,
                            long long* pEncryptedContentStartPos,       int* pnEncryptedContentSize,
                            char** ppszKeyEncryptionAlgOid = NULL,      int* pnKeyEncryptionAlgOidLength = NULL,
                            char** ppszContentEncryptionAlgOid = NULL,  int* pnContentEncryptionAlgOidLength = NULL,
                            unsigned char** ppbyContentEncryptionAlgParameter = NULL, int* pnContentEncryptionAlgParameterSize = NULL );

#endif  // _CMS_ENVELOPE_OPERATIONS_H

