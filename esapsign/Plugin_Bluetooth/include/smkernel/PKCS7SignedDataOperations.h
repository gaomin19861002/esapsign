/**************************************************************************
    filename:   PKCS7SignedDataOperations.h
    author:     xybei
    created:    2012/12/05
    purpose:    Declare PKCS#7 SignedData operation functions	
                
**************************************************************************/
#ifndef _PKCS7_SIGNED_DATA_OPERATIONS_H
#define _PKCS7_SIGNED_DATA_OPERATIONS_H

#include "ASN1EngineEx.h"
#include "openssl/pkcs7.h"

typedef struct sm2pkcs7_content_st
{
    ASN1_OBJECT 			*type;	
    ASN1_OCTET_STRING		*content;
} SM2PKCS7_CONTENT;
DECLARE_ASN1_FUNCTIONS(SM2PKCS7_CONTENT)

typedef struct sm2pkcs7_signer_info_st
{
    ASN1_INTEGER 			*version;	// version 1 
    PKCS7_ISSUER_AND_SERIAL	*issuer_and_serial;
    X509_ALGOR			    *digest_alg;
    X509_ALGOR			    *digest_enc_alg;
    ASN1_OCTET_STRING		*enc_digest_r;
    ASN1_OCTET_STRING		*enc_digest_s;
} SM2PKCS7_SIGNER_INFO;

DECLARE_STACK_OF(SM2PKCS7_SIGNER_INFO)
DECLARE_ASN1_SET_OF(SM2PKCS7_SIGNER_INFO)
DECLARE_ASN1_FUNCTIONS(SM2PKCS7_SIGNER_INFO)

DECLARE_ASN1_SET_OF(X509)
typedef struct sm2pkcs7_signed_st
{
    ASN1_INTEGER		 *version;
    STACK_OF(X509_ALGOR) *md_algs;
    SM2PKCS7_CONTENT	 *contents;
    X509			     *cert;
    STACK_OF(SM2PKCS7_SIGNER_INFO)  *signer_info;
}SM2PKCS7_SIGNED;
DECLARE_ASN1_FUNCTIONS(SM2PKCS7_SIGNED)

typedef struct sm2pkcs7
{
    ASN1_OBJECT			*SM2PKCS7SignedDataType;
    SM2PKCS7_SIGNED		*SM2PKCS7SignedData;
}SM2PKCS7;
DECLARE_ASN1_FUNCTIONS(SM2PKCS7)

#define sk_SM2PKCS7_SIGNER_INFO_new_null() SKM_sk_new_null(SM2PKCS7_SIGNER_INFO)
#define sk_SM2PKCS7_SIGNER_INFO_push(st, val) SKM_sk_push(SM2PKCS7_SIGNER_INFO, (st), (val))
#define sk_SM2PKCS7_SIGNER_INFO_pop(st) SKM_sk_pop(SM2PKCS7_SIGNER_INFO, (st))
#define sk_SM2PKCS7_SIGNER_INFO_free(st) SKM_sk_free(SM2PKCS7_SIGNER_INFO, (st))

#define sk_SM2PKCS7_SIGNED_new_null() SKM_sk_new_null(SM2PKCS7_SIGNED)
#define sk_SM2PKCS7_SIGNED_push(st, val) SKM_sk_push(SM2PKCS7_SIGNED, (st), (val))
#define sk_SM2PKCS7_SIGNED_pop(st) SKM_sk_pop(SM2PKCS7_SIGNED, (st))
#define sk_SM2PKCS7_SIGNED_free(st) SKM_sk_free(SM2PKCS7_SIGNED, (st))

//*************************************************************************
// Method:      ParsePKCS7Signature
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySM2PKCS7SingatureData
// Parameter:   [IN]int nSM2PKCS7Signature
// Parameter:   [OUT]unsigned char * * ppbyCertData
// Parameter:   [OUT]int * pnCertDataSize
// Parameter:   [OUT]unsigned char * * ppbyRawSignagure
//                   RSA: PKCS#1
//                   SM2: 64 bits raw signature
// Parameter:   [OUT]int * pnRawSingatureSize
// Parameter:   [OUT]unsigned char * * ppbySourceData
// Parameter:   [OUT]int * pnSourceDataSize
// Parameter:   [OUT]char * * ppDigestAlgOid
// Parameter:   [OUT]int * pnDigestAlgOidLength
// Parameter:   [OUT]char * * ppDigestEncryptionAlgOid
// Parameter:   [OUT]int * pnDigestEncryptionAlgOidLength
// Description: Parse SM2 or RSA Signature, if the PKCS#7 is a SM2 signature,
//              the output "ppbyRawSignagure" is 64 bytes raw RS.
//            
// Author:      xybei
// Date:        2013/06/04
//*************************************************************************
int ParsePKCS7Signature(unsigned char* pbySM2PKCS7SingatureData, int nSM2PKCS7Signature,
                        unsigned char** ppbyCertData,            int* pnCertDataSize,
                        unsigned char** ppbyRawSignagure,        int* pnRawSingatureSize,
                        unsigned char** ppbySourceData = NULL,   int* pnSourceDataSize = NULL,
                        char** ppDigestAlgOid = NULL,            int* pnDigestAlgOidLength = NULL,
                        char** ppDigestEncryptionAlgOid = NULL,  int* pnDigestEncryptionAlgOidLength = NULL);


//*************************************************************************
// Method:      ParsePKCS7AttachedSignatureFile
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpP7AttachedSignatureFileName
// Parameter:   [OUT]unsigned char** ppbyCertData
// Parameter:   [OUT]int* pnCertDataSize
// Parameter:   [OUT]unsigned char** ppbyRawSignagure
//                   RSA: PKCS#1
//                   SM2: 64 bits raw signature
// Parameter:   [OUT]int* pnRawSignatureSize
// Parameter:   [OUT]long long* pSourceDataStartPos
// Parameter:   [OUT]int* pnSourceDataSize
// Parameter:   [OUT]char** ppDigestAlgOid
// Parameter:   [OUT]int* pnDigestAlgOidLength
// Parameter:   [OUT]char** ppDigestEncryptionAlgOid
// Parameter:   [OUT]int* pnDigestEncryptionAlgOidLength
// Description: Parse "PKCS7AttachedSignatureFile" to Cert(TLV) ,RawSignagure(V),
//              SourceData offset, DigestAlgOid(V) and DigestEncryptionAlgOid(V).
//            
// Author:      xyyang
// Date:        2012/12/18
//*************************************************************************
int ParsePKCS7AttachedSignatureFile(FILE* fpP7AttachedSignatureFileName,
                                    unsigned char** ppbyCertData,            int* pnCertDataSize,
                                    unsigned char** ppbyRawSignagure,        int* pnRawSignatureSize,
                                    long long* pSourceDataStartPos,          int* pnSourceDataSize,
                                    char** ppDigestAlgOid = NULL,            int* pnDigestAlgOidLength = NULL,
                                    char** ppDigestEncryptionAlgOid = NULL,  int* pnDigestEncryptionAlgOidLength = NULL);


//*************************************************************************
// Method:      ConstructNode_IssuerAndSerialNumber
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyASN1Issuer
// Parameter:   [IN]int nASN1IssuerSize
// Parameter:   [IN]unsigned char * pbyASN1SerialNumber
// Parameter:   [OUT]int nASN1SerialNumber
// Parameter:   [OUT]NodeEx * * ppNodeIssuerAndSerialNumber
// Description: Construct "IssuerAndSerialNumber" node
//            
// Author:      xybei
// Date:        2012/12/05
//*************************************************************************
int ConstructNode_IssuerAndSerialNumber( unsigned char* pbyASN1Issuer,       int nASN1IssuerSize,
                                         unsigned char* pbyASN1SerialNumber, int nASN1SerialNumber,
                                         NodeEx** ppNodeIssuerAndSerialNumber );


//*************************************************************************
// Method:      ConstructNode_SM2Q1
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyRData
// Parameter:   [IN]int nRSize(32)
// Parameter:   [IN]unsigned char * pbySData
// Parameter:   [IN]int nSSize(32)
// Parameter:   [OUT]NodeEx * * ppNodeSM2Q1
// Description: The Q1 node:
//              SEQUENCE
//                 INTEGER(R)
//                 INTEGER(S)
//            
// Author:      xybei
// Date:        2013/06/03
//*************************************************************************
int ConstructNode_SM2Q1(unsigned char* pbyRData, int nRSize,
                        unsigned char* pbySData, int nSSize,
                        NodeEx** ppNodeSM2Q1);


//*************************************************************************
// Method:      ConstructNode_SignerInfo
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]int nVersion
// Parameter:   [IN]NodeEx * pNodeIssuerAndSerialNumber
// Parameter:   [IN]char * pszDigestAlgOid
// Parameter:   [IN]char * pszDigestEncryptionAlgOid
// Parameter:   [IN]unsigned char * pbyRawSignature
// Parameter:   [IN]int nRawSignatureSize
// Parameter:   [IN]unsigned long fSignatureEncodedType,
//                  RSA: SIG_TYPE_RSA;
//                  SM2: SIG_TYPE_SM2_Q7_V1 / SIG_TYPE_SM2_Q7_V2 / SIG_TYPE_SM2_Q7_V3
// Parameter:   [OUT]NodeEx * * ppNodeSignerInfo
// Description: Construct "SignerInfo" node
//            
// Author:      xybei
// Date:        2012/12/06
//*************************************************************************
int ConstructNode_SignerInfo( int nVersion,
                              NodeEx* pNodeIssuerAndSerialNumber,
                              char* pszDigestAlgOid, char* pszDigestEncryptionAlgOid,
                              unsigned char* pbyRawSignature, int nRawSignatureSize,
                              unsigned long fSignatureEncodedType,
                              NodeEx** ppNodeSignerInfo );


//*************************************************************************
// Method:      ConstructNode_SignedData
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]int nVersion
// Parameter:   [IN]char * pszDigestAlgOid
// Parameter:   [IN]char * pszContentTypeOid_Data
//                  szOID_SM2_data / szOID_RSA_data
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceDataSize
// Parameter:   [IN]FILE * fpSourceFile
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [IN]NodeEx * pNodeSignerInfoSet
// Parameter:   [OUT]NodeEx * * ppNodeSignedData
// Description: Construct "SignedData" node
//            
// Author:      xybei
// Date:        2012/12/06
//*************************************************************************
int ConstructNode_SignedData( int nVersion,
                              char* pszDigestAlgOid,
                              char* pszContentTypeOid_Data,
                              unsigned char* pbySourceData, int nSourceDataSize,
                              FILE* fpSourceFile,
                              bool bWithSourceData,
                              unsigned char* pbyCertData, int nCertDataSize,
                              NodeEx* pNodeSignerInfoSet,
                              NodeEx** ppNodeSignedData );


//*************************************************************************
// Method:      Encode_SM2Q1
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyRData
// Parameter:   [IN]int nRSize
// Parameter:   [IN]unsigned char * pbySData
// Parameter:   [IN]int nSSize
// Parameter:   [OUT]unsigned char * * ppbyASN1EncodedQ1Data
// Parameter:   [OUT]int * pnASN1EncodedQ1Size
// Description: The Q1 node:
//              SEQUENCE
//                 INTEGER(R)
//                 INTEGER(S)
//            
// Author:      xybei
// Date:        2013/06/03
//*************************************************************************
int Encode_SM2Q1(unsigned char* pbyRData, int nRSize,
                 unsigned char* pbySData, int nSSize,
                 unsigned char** ppbyASN1EncodedQ1Data, int* pnASN1EncodedQ1Size);


//*************************************************************************
// Method:      Decode_SM2Q1
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyASN1EncodedQ1Data
// Parameter:   [IN]int nASN1EncodedQ1Size
// Parameter:   [OUT]unsigned char * * ppbySM2RawSignatureRS
// Parameter:   [OUT]int * pnSM2RawSignatureRSSize
// Description: The out put data is raw RS(64 bytes).
//            
// Author:      xybei
// Date:        2013/06/03
//*************************************************************************
int Decode_SM2Q1( unsigned char* pbyASN1EncodedQ1Data, int nASN1EncodedQ1Size,
                  unsigned char** ppbySM2RawSignatureRS, int* pnSM2RawSignatureRSSize );


//*************************************************************************
// Method:      Encode_PKCS7Signature
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceDataSize
// Parameter:   [IN]FILE * fpSourceFile
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [IN]char * pszContentTypeOid_SignedData
//                  szOID_SM2_signedData / szOID_RSA_signedData
// Parameter:   [IN]char * pszContentTypeOid_Data
//                  szOID_SM2_data / szOID_RSA_data
// Parameter:   [IN]char * pszDigestAlgOid
// Parameter:   [IN]char * pszDigestEncryptionAlgOid
// Parameter:   [IN]unsigned char * pbyPKCS1Signature
//                  RSA: PKCS#1
//                  SM2: 64 bits raw signature
// Parameter:   [IN]int nPKCS1SignatureSize
// Parameter:   [IN]unsigned long fSignatureEncodedType
//                  RSA: SIG_TYPE_RSA;
//                  SM2: SIG_TYPE_SM2_Q7_V1 / SIG_TYPE_SM2_Q7_V2 / SIG_TYPE_SM2_Q7_V3
// Parameter:   [OUT]unsigned char * * ppbyEncodedPKCS7Signature
// Parameter:   [OUT]int * pnEncodedPKCS7SignatureSize
// Parameter:   [IN/OUT]FILE * fpEncodedSignatureOutFile
//                  You should open this file in "wb" mode.
// Parameter:   [OUT]int * pnEnncodedSignatureFileSize
// Description: Encode (Data/File) PKCS#7 signature in DER.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int Encode_PKCS7Signature( unsigned char* pbyCertData, int nCertDataSize,
                           unsigned char* pbySourceData, int nSourceDataSize,
                           FILE* fpSourceFile,
                           bool bWithSourceData,
                           char* pszContentTypeOid_SignedData,
                           char* pszContentTypeOid_Data,
                           char* pszDigestAlgOid,
                           char* pszDigestEncryptionAlgOid,
                           unsigned char* pbyPKCS1Signature, int nPKCS1SignatureSize,
                           unsigned long fSignatureEncodedType,
                           unsigned char** ppbyEncodedPKCS7Signature, int* pnEncodedPKCS7SignatureSize,
                           FILE* fpEncodedSignatureOutFile = NULL, int* pnEnncodedSignatureFileSize = NULL );


//*************************************************************************
// Method:      DecodeRSAPKCS7Signature
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyDERSignatureData
// Parameter:   [IN]int nDERSignatureSize
// Parameter:   [OUT]X509 * * ppX509Cert
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnDigestAlgNID
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]unsigned char * * ppbyEncryptedDigest
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnEncryptedDigestSize
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]unsigned char * * ppbySourceData
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnSourceSize
//                   The value will not be returned, if this parameter is NULL.
// Description: The signature to parse should be DER encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int DecodeRSAPKCS7Signature( unsigned char* pbyDERSignatureData,  int nDERSignatureSize,
                             X509** ppX509Cert,
                             int* pnDigestAlgNID,
                             unsigned char** ppbyEncryptedDigest, int* pnEncryptedDigestSize,
                             unsigned char** ppbySourceData,      int* pnSourceSize );


#endif  //_PKCS7_SIGNED_DATA_OPERATIONS_H
