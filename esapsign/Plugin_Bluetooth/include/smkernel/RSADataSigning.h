/**************************************************************************
    filename:   RSADataSigning.h
    author:     xybei
    created:    2013/03/27
    purpose:    Declare RSA data signing interfaces.
                
**************************************************************************/

#ifndef _RSA_DATA_SIGNING_H
#define _RSA_DATA_SIGNING_H

#include <openssl/pkcs7.h>

//*************************************************************************
// Method:      PKCS7_sign_ex
// Access:      public 
// Returns:     Success: PKCS7 object pointer; Failed:NULL
// Parameter:   [IN]X509 * signcert
// Parameter:   [IN]EVP_PKEY * pkey
// Parameter:   [IN]STACK_OF(X509) * certs
// Parameter:   [IN]BIO * data
// Parameter:   [IN]int md_nid
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]int flags
// Description: This method is an extension of OpenSSL PKCS7_sign() 
//              You can specify the hash algorithm by md_nid.
//              Other parameters please refer to PKCS7_sign()
// Author:      xybei
// Date:        2013/04/17
//*************************************************************************
PKCS7 *PKCS7_sign_ex( X509 *signcert,
                      EVP_PKEY *pkey,
                      STACK_OF(X509) *certs,
                      BIO *data, 
                      int md_nid,
                      int flags );
                
//*************************************************************************
// Method:      ParsePFXFile
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE * fpPFX 
//                  The file should be opened in "rb" mode.
// Parameter:   [IN]char * pszPFXPwd
// Parameter:   [OUT]EVP_PKEY * * ppPrivKey
// Parameter:   [OUT]X509 * * ppPubCert
// Parameter:   [OUT]STACK_OF(X509) * * ppCACerts
// Description: Load and parse a RSA PFX file.
//            
// Author:      xybei
// Date:        2013/04/15
//*************************************************************************
int ParsePFXFile( FILE* fpPFX, char* pszPFXPwd,
                  EVP_PKEY** ppPrivKey, X509** ppPubCert,
                  STACK_OF(X509)** ppCACerts );

//*************************************************************************
// Method:      CalculateDataHash
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [OUT]unsigned char * * ppbyHashValue
// Parameter:   [OUT]int * pnHashSize
// Description: 
//            
// Author:      xybei
// Date:        2013/04/15
//*************************************************************************
int CalculateDataHash( unsigned char* pbySourceData, int nSourceSize,
                       int nHashNID,
                       unsigned char** ppbyHashValue, int* pnHashSize );

//*************************************************************************
// Method:      RSA_SignData_PKCS1_ByPrivateKey
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]RSA * pPrivateKey
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [OUT]unsigned char * * ppbySignature
// Parameter:   [OUT]int * pnSignatureSize
// Description: 
//            
// Author:      xybei
// Date:        2013/04/15
//*************************************************************************
int RSA_SignData_PKCS1_ByPrivateKey( unsigned char* pbySourceData, int nSourceSize,
                                     RSA* pPrivateKey,
                                     int nHashNID,
                                     unsigned char** ppbySignature, int* pnSignatureSize );

//*************************************************************************
// Method:      RSA_SignData_PKCS1_ByPFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE * fpPFX
//                  The file should be opened in "rb" mode.
// Parameter:   [IN]char * pszPFXPwd
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [OUT]unsigned char * * ppbySignature
// Parameter:   [OUT]int * pnSignatureSize
// Description: 
//            
// Author:      xybei
// Date:        2013/04/15
//*************************************************************************
int RSA_SignData_PKCS1_ByPFX( unsigned char* pbySourceData, int nSourceSize,
                              FILE* fpPFX, char* pszPFXPwd,
                              int nHashNID,
                              unsigned char** ppbySignature, int* pnSignatureSize );

//*************************************************************************
// Method:      RSA_SignData_PKCS1
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE * fpPFX
//                  The file should be opened in "rb" mode.
// Parameter:   [IN]char * pszPFXPwd
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]unsigned long fBase64Flags
//                  ATL_BASE64_FLAG_NONE	0
//                  ATL_BASE64_FLAG_NOPAD	1
//                  ATL_BASE64_FLAG_NOCRLF  2
// Parameter:   [OUT]char * * ppszBase64Signature
// Parameter:   [OUT]int * pnBase64SignatureLen
// Description: 
//            
// Author:      xybei
// Date:        2013/04/15
//*************************************************************************
int RSA_SignData_PKCS1( unsigned char* pbySourceData, int nSourceSize,
                        FILE* fpPFX, char* pszPFXPwd,
                        int nHashNID,
                        unsigned long fBase64Flags,
                        char** ppszBase64Signature, int* pnBase64SignatureLen );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_PKCS1_ByX509
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]X509 * pPublicCert
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]unsigned char * pbySignature
// Parameter:   [IN]int nSignatureSize
// Description: 
//            
// Author:      xybei
// Date:        2013/04/16
//*************************************************************************
int RSA_VerifyDataSignature_PKCS1_ByX509( unsigned char* pbySourceData, int nSourceSize,
                                          X509* pPublicCert,
                                          int nHashNID,
                                          unsigned char* pbySignature, int nSignatureSize );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_PKCS1
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]char * pszBase64CertContent
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]char * pszBase64Signature
// Description: 
//            
// Author:      xybei
// Date:        2013/04/16
//*************************************************************************
int RSA_VerifyDataSignature_PKCS1( unsigned char* pbySourceData, int nSourceSize,
                                   char* pszBase64CertContent,
                                   int nHashNID,
                                   char* pszBase64Signature );

//*************************************************************************
// Method:      RSA_SignData_PKCS7_ByKeyPair
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]X509 * pX509
// Parameter:   [IN]EVP_PKEY * pPrivateKey
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [OUT]unsigned char * * ppbyDERSignature
// Parameter:   [OUT]int * pnDERSignatureSize
// Description: The PKCS#7 signature is DER encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_SignData_PKCS7_ByKeyPair( unsigned char* pbySourceData, int nSourceSize,
                                  X509* pX509, EVP_PKEY* pPrivateKey,
                                  int nHashNID,
                                  bool bWithSourceData,
                                  unsigned char** ppbyDERSignature, int* pnDERSignatureSize );

//*************************************************************************
// Method:      RSA_SignData_PKCS7_ByPFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE * fpPFX
//                  You should open the PFX file in "rb" mode.
// Parameter:   [IN]char * pszPFXPwd
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [OUT]unsigned char * * ppbyDERSignature
// Parameter:   [OUT]int * pnDERSignatureSize
// Description: The PKCS#7 signature is DER encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_SignData_PKCS7_ByPFX( unsigned char* pbySourceData, int nSourceSize,
                              FILE* fpPFX, char* pszPFXPwd,
                              int nHashNID,
                              bool bWithSourceData,
                              unsigned char** ppbyDERSignature, int* pnDERSignatureSize );

//*************************************************************************
// Method:      RSA_SignData_PKCS7
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE * fpPFX
//                  You should open the PFX file in "rb" mode.
// Parameter:   [IN]char * pszPFXPwd
// Parameter:   [IN]int nHashNID
//                  NID_sha1
//                  NID_sha256
//                  NID_sha384
//                  NID_sha512
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [IN]unsigned long fBase64Flags
//                  ATL_BASE64_FLAG_NONE
//                  ATL_BASE64_FLAG_NOPAD
//                  ATL_BASE64_FLAG_NOCRLF
// Parameter:   [OUT]char * * ppszBase64Signature
// Parameter:   [OUT]int * pnBase64SignatureLen
// Description: The PKCS#7 signature is Base64 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_SignData_PKCS7( unsigned char* pbySourceData, int nSourceSize,
                        FILE* fpPFX, char* pszPFXPwd,
                        int nHashNID,
                        bool bWithSourceData,
                        unsigned long fBase64Flags,
                        char** ppszBase64Signature, int* pnBase64SignatureLen );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_DERPKCS7Detached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyDERSignature
// Parameter:   [IN]int nDERSignatureSize
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [OUT]unsigned char * * ppbyDERSignCertContent
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnDERSignCertSize
//                   The value will not be returned, if this parameter is NULL.
// Description: The PKCS#7 signature to verify should be DER encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_VerifyDataSignature_DERPKCS7Detached( unsigned char* pbyDERSignature, int nDERSignatureSize,
                                              unsigned char* pbySourceData, int nSourceSize,
                                              unsigned char** ppbyDERSignCertContent, int* pnDERSignCertSize );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_PKCS7Detached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszBase64PKCS7DetachedSignature
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [OUT]unsigned char * * ppbyDERSignCertContent
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnDERSignCertSize
//                   The value will not be returned, if this parameter is NULL.
// Description: The PKCS#7 signature to verify should be Base64 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_VerifyDataSignature_PKCS7Detached( char* pszBase64PKCS7DetachedSignature,
                                           unsigned char* pbySourceData, int nSourceSize,
                                           unsigned char** ppbyDERSignCertContent, int* pnDERSignCertSize );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_DERPKCS7Attached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyDERSignature
// Parameter:   [IN]int nDERSignatureSize
// Parameter:   [OUT]unsigned char * * ppbySourceData
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnSourceSize
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]unsigned char * * ppbyDERSignCertContent
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnDERSignCertSize
//                   The value will not be returned, if this parameter is NULL.
// Description: The PKCS#7 signature to verify should be DER encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_VerifyDataSignature_DERPKCS7Attached( unsigned char* pbyDERSignature, int nDERSignatureSize,
                                              unsigned char** ppbySourceData, int* pnSourceSize,
                                              unsigned char** ppbyDERSignCertContent, int* pnDERSignCertSize );

//*************************************************************************
// Method:      RSA_VerifyDataSignature_PKCS7Attached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszBase64PKCS7DetachedSignature
// Parameter:   [OUT]unsigned char * * ppbySourceData
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnSourceSize
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]unsigned char * * ppszDERSignCertContent
//                   The value will not be returned, if this parameter is NULL.
// Parameter:   [OUT]int * pnDERSignCertSize
//                   The value will not be returned, if this parameter is NULL.
// Description: The PKCS#7 signature to verify should be Base64 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int RSA_VerifyDataSignature_PKCS7Attached( char* pszBase64PKCS7DetachedSignature,
                                           unsigned char** ppbySourceData, int* pnSourceSize,
                                           unsigned char** ppszDERSignCertContent, int* pnDERSignCertSize );

#endif // _RSA_DATA_SIGNING_H
