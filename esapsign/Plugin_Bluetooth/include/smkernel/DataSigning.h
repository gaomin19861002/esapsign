/**************************************************************************
    filename:   DataSigning.h
    author:     xybei
    created:    2012/12/09
    purpose:    Declare SM2 data signing functions
                
**************************************************************************/

#ifndef _SM2_DATA_SIGNING_H
#define _SM2_DATA_SIGNING_H

#include <stdio.h>

#include <openssl/asn1t.h>

#include "SMFileCertOperations.h"
#include "Constant.h"

int SMKernelInitialize();

int SMKernelUninitialize();

int SM2_CalculateZValue(unsigned char* pbyID, int nIDBytesLen, unsigned char* pubx, unsigned char* puby,unsigned char* digestData);

int CalculateSM3Hash(
                    unsigned char* pbySourceData, int nSourceSize,
                    unsigned char* pbyPubkeyX, unsigned char* pbyPubkeyY,
                    unsigned char* pbySM3Hash,
                    bool bWithZValue = true );

int CalculateSM3FileHash(
                    FILE* fpSourceFile, unsigned long ulBytesToRead,
                    unsigned char* pbyPubkeyX, unsigned char* pbyPubkeyY,
                    unsigned char* pbySM3Hash,
                    bool bWithZValue = true ); 

int CalculateSM3FileHashEx(
                    FILE* fpSourceFile,
                    unsigned char* pbyPubkeyX, unsigned char* pbyPubkeyY,
                    unsigned char* pbySM3Hash,
                    bool bWithZValue = true ); 

//*************************************************************************
// Method:      SignData_Raw_ByKeyPair
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]PSM2_KEY_PAIR pstSM2KeyPair
// Parameter:   [OUT]unsigned char** ppbySM2RawSignatureRS
// Parameter:   [OUT]int* pnSM2RawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: Sign data by key pair, The result is a 64-byte unsigned char binary data.
//              This binary data is composed by the R and S. R and S both are a 32-byte
//              big-ending binary data.
//
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int SignData_Raw_ByKeyPair(
                    unsigned char* pbySourceData, int nSourceSize,
                    PSM2_KEY_PAIR  pstSM2KeyPair,
                    unsigned char** ppbySM2RawSignatureRS, int* pnSM2RawSignatureRSSize,
                    bool bWithZValue = true);

//*************************************************************************
// Method:      SignData_Raw_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char* pszPassword
// Parameter:   [OUT]unsigned char** ppbySM2RawSignatureRS
// Parameter:   [OUT]int* pnSM2RawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: Sign data by SM2 file, The result is a 64-byte unsigned char binary data.
//              This binary data is composed by the R and S. R and S both are a 32-byte
//              big-ending binary data.
//
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int SignData_Raw_BySM2PFX(
                    unsigned char* pbySourceData, int nSourceSize,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    unsigned char** ppbySM2RawSignatureRS, int* pnSM2RawSignatureRSSize,
                    bool bWithZValue = true );

//*************************************************************************
// Method:      SignData_PKCS1_ByKeyPair
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]PSM2_KEY_PAIR  pstSM2KeyPair
// Parameter:   [OUT]unsigned char** ppbyBase64PKCS1Signature
// Parameter:   [OUT]int* pnBase64PKCS1SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue = true
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q1_V1 / SIG_TYPE_SM2_Q1_V2
// Description: Sign data by key pair, The result is base64 encoded value,
//              which is encoding a 64-byte unsigned char binary data.
//
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int SignData_PKCS1_ByKeyPair(
                    unsigned char* pbySourceData, int nSourceSize,
                    PSM2_KEY_PAIR  pstSM2KeyPair,
                    char** ppbyBase64PKCS1Signature, int* pnBase64PKCS1SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true, 
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q1_V2 );

//*************************************************************************
// Method:      SignData_PKCS1_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char* pszPassword
// Parameter:   [OUT]unsigned char** ppbyBase64PKCS1Signature
// Parameter:   [OUT]int* pnBase64PKCS1SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue = true
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q1_V1 / SIG_TYPE_SM2_Q1_V2
// Description: Sign data by SM2 file, The result is base64 encoded value,
//              which is encoding a 64-byte unsigned char binary data.
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int SignData_PKCS1_BySM2PFX(
                    unsigned char* pbySourceData, int nSourceSize,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    char** ppszBase64PKCS1Signature, int* pnBase64PKCS1SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true, 
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q1_V2 );

//*************************************************************************
// Method:      SignData_PKCS7_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char * pszPassword
// Parameter:   [IN]bool bWithSourceData
// Parameter:   [OUT]char * * ppszBase64PKCS7Signature
// Parameter:   [OUT]int * pnBase64PKCS7SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q7_V1 / SIG_TYPE_SM2_Q7_V2 / SIG_TYPE_SM2_Q7_V3
// Parameter:   [IN]char* pszDigestEncryptionAlgOid
//                  SM2 sign algorithm OID.
// Description: Sign data PKCS#7 by SM2 file, The result is base64 encoded value,
//              which is encoding a 64-byte unsigned char binary data.
//            
// Author:      jzjiang
// Date:        2012/12/12
//*************************************************************************
int SignData_PKCS7_BySM2PFX(
                    unsigned char* pbySourceData, int nSourceSize,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    bool bWithSourceData,
                    char** ppszBase64PKCS7Signature, int* pnBase64PKCS7SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true,
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q7_V3,
                    char* pszDigestEncryptionAlgOid = szOID_SM2_SIGN );

//*************************************************************************
// Method:      VerifySignature_Raw
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]unsigned char* pbyPublicKeyX
// Parameter:   [IN]unsigned char* PbyPublicKeyY
// Parameter:   [IN]unsigned char* pbyRawSignatureRS
// Parameter:   [IN]int nRawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: Verify Signature by public key, which is a 64-byte unsigned char binary data.
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int VerifySignature_Raw(
                    unsigned char* pbySourceData, int NSourceSize,
                    unsigned char* pbyPublicKeyX,
                    unsigned char* PbyPublicKeyY,
                    unsigned char* pbyRawSignatureRS, int nRawSignatureRSSize,
                    bool bWithZValue = true );

//TODO:
int VerifySignature_Raw_ByCert(
                    unsigned char* pbySourceData, int nSourceSize,
                    char* pszBase64Cert, int nBase64CertLength,
                    unsigned char* pbyRawSignatureRS, int nRawSignatureRSSize,
                    bool bWithZValue = true,
                    int nVerifyFlag = 0,
                    char* pszTrustedCertificates = NULL,
                    char* pszCRLFileName = NULL );

//*************************************************************************
// Method:      VerifySignature_PKCS1_ByCert
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char* pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [IN]char* pszBase64Cert
// Parameter:   [IN]int nBase64CertLength
// Parameter:   [IN]char* pszBase64RawSignature
// Parameter:   [IN]int nBase64RawSignature
// Parameter:   [IN]bool bWithZValue = true
// Description: Verify Signature by cert file, which is a 64-byte unsigned char binary data.
// Author:      jzjiang 
// Date:        2012/12/11
//*************************************************************************
int VerifySignature_PKCS1_ByCert(
                    unsigned char* pbySourceData, int nSourceSize,
                    char* pszBase64Cert, int nBase64CertLength,
                    char* pszBase64RawSignature, int nBase64RawSignature,
                    bool bWithZValue = true);

//*************************************************************************
// Method:      VerifySignature_PKCS7Attached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszBase64PKCS7AttachedSignature
// Parameter:   [IN]int nBase64PKCS7AttachedSignatureLength
// Parameter:   [OUT]unsigned char * * ppbySourceData
// Parameter:   [OUT]int * pnSourceSize
// Parameter:   [OUT]unsigned char * * ppbyPublicCertData
// Parameter:   [OUT]int * pnPublicCertSize
// Parameter:   [IN]bool bWithZValue
// Description: Verify PKCS#7 Attached Signature.
//            
// Author:      jzjiang
// Date:        2012/12/12
//*************************************************************************
int VerifySignature_PKCS7Attached(
                    char* pszBase64PKCS7AttachedSignature, int nBase64PKCS7AttachedSignatureLength,
                    unsigned char** ppbySourceData = NULL, int* pnSourceSize = NULL,
                    unsigned char** ppbyPublicCertData = NULL, int* pnPublicCertSize = NULL,
                    bool bWithZValue = true);
                    
//*************************************************************************
// Method:      VerifySignature_PKCS7Detached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char * pszBase64PKCS7DetachedSignature
// Parameter:   [IN]int nBase64PKCS7DetachedSignatureLength
// Parameter:   [IN]unsigned char * pbySourceData
// Parameter:   [IN]int nSourceSize
// Parameter:   [OUT]unsigned char * * ppbyDERPublicCertData
// Parameter:   [OUT]int * pnDERPublicCertSize
// Parameter:   [IN]bool bWithZValue
// Description: Verify PKCS#7 Detached Signature.
//            
// Author:      jzjiang
// Date:        2012/12/12
//*************************************************************************
int VerifySignature_PKCS7Detached(
                    char* pszBase64PKCS7DetachedSignature, int nBase64PKCS7DetachedSignatureLength,
                    unsigned char* pbySourceData = NULL, int nSourceSize = NULL,
                    unsigned char** ppbyDERPublicCertData = NULL, int* pnDERPublicCertSize = NULL,
                    bool bWithZValue = true);

//*************************************************************************
// Method:      SignFile_Raw_ByKeyPair
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]PSM2_KEY_PAIR pstSM2KeyPair
// Parameter:   [OUT]unsigned char** ppbySM2RawSignatureRS
// Parameter:   [OUT]int* pnSM2RawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: Sign file by key pair, The result is a 64-byte unsigned char binary data.
//              This binary data is composed by the R and S. R and S both are a 32-byte
//              big-ending binary data.
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int SignFile_Raw_ByKeyPair(
                    FILE* fpSourceFile,
                    PSM2_KEY_PAIR pstSM2KeyPair,
                    unsigned char** ppbySM2RawSignatureRS, int* pnSM2RawSignatureRSSize,
                    bool bWithZValue = true );

//*************************************************************************
// Method:      SignFile_Raw_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]FILE* pfSM2PFXFile
// Parameter:   [IN]char* pszPassword
// Parameter:   [OUT]unsigned char** ppbySM2RawSignatureRS
// Parameter:   [OUT]int* pnSM2RawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: Sign file by SM2PFX file, The result is a 64-byte unsigned char binary data.
//              This binary data is composed by the R and S. R and S both are a 32-byte
//              big-ending binary data.
//            
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int SignFile_Raw_BySM2PFX(
                    FILE* fpSourceFile,
                    FILE*           pfSM2PFXFile, char* pszPassword,
                    unsigned char** ppbySM2RawSignatureRS, int* pnSM2RawSignatureRSSize,
                    bool bWithZValue = true );

//*************************************************************************
// Method:      SignFile_PKCS1_ByKeyPair
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]PSM2_KEY_PAIR pstSM2KeyPair
// Parameter:   [OUT]unsigned char** ppbyBase64PKCS1Signature
// Parameter:   [OUT]int* pnBase64PKCS1SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue = true
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q1_V1 / SIG_TYPE_SM2_Q1_V2
// Description: Sign file by key pair, The result is base64 encoded value,
//              which is encoding a 64-byte unsigned char binary data.
//            
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int SignFile_PKCS1_ByKeyPair(
                    FILE* fpSourceFile,
                    PSM2_KEY_PAIR  pstSM2KeyPair,
                    char** ppbyBase64PKCS1Signature, int* pnBase64PKCS1SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true, 
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q1_V2 );

//*************************************************************************
// Method:      SignFile_PKCS1_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char* pszPassword
// Parameter:   [OUT]unsigned char** ppbyBase64PKCS1Signature
// Parameter:   [OUT]int* pnBase64PKCS1SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue = true
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q1_V1 / SIG_TYPE_SM2_Q1_V2
// Description: Sign file by SM2PFX file, The result is base64 encoded value,
//              which is encoding a 64-byte unsigned char binary data..
//
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int SignFile_PKCS1_BySM2PFX(
                    FILE* fpSourceFile,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    char** ppbyBase64PKCS1Signature, int* pnBase64PKCS1SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true, 
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q1_V2 );

//************************************
// Method:      SignFile_PKCS7Detached_BySM2PFX
// FullName:    SignFile_PKCS7Detached_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char* pszPassword
// Parameter:   [OUT]char** ppszBase64PKCS7Signature
// Parameter:   [OUT]int* pnBase64PKCS7SignatureLength
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [IN]bool bWithZValue
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q7_V1 / SIG_TYPE_SM2_Q7_V2 / SIG_TYPE_SM2_Q7_V3
// Parameter:   [IN]char* pszDigestEncryptionAlgOid
//                  SM2 sign algorithm OID.
// Description: Sign file by SM2PFX and encapsulated the result to SM2PKCS7.
//
// Author:      xyyang 
// Date:        2012/12/12
//************************************
int SignFile_PKCS7Detached_BySM2PFX(
                    FILE* fpSourceFile,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    char** ppszBase64PKCS7Signature, int* pnBase64PKCS7SignatureLength,
                    unsigned long fBase64Flags = 0,
                    bool bWithZValue = true,
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q7_V3,
                    char* pszDigestEncryptionAlgOid = szOID_SM2_SIGN );

//*************************************************************************
// Method:      SignFile_PKCS7Attached_BySM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]FILE* fpSM2PFXFile
// Parameter:   [IN]char * pszPassword
// Parameter:   [IN]FILE* fpOutASN1PKCS7SignatureFile
// Parameter:   [IN]bool bWithZValue
// Parameter:   [IN]bool fSignatureEncodedType
//                  SIG_TYPE_SM2_Q7_V1 / SIG_TYPE_SM2_Q7_V2 / SIG_TYPE_SM2_Q7_V3
// Parameter:   [IN]char* pszDigestEncryptionAlgOid
//                  SM2 sign algorithm OID.
// Description: Sign file and write the DER encoded PKCS#7 attached signature to the destination file
//            
// Author:      xybei
// Date:        2012/12/28
//*************************************************************************
int SignFile_PKCS7Attached_BySM2PFX(
                    FILE* fpSourceFile,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    FILE* fpOutASN1PKCS7SignatureFile,
                    bool bWithZValue = true,
                    unsigned long fSignatureEncodedType = SIG_TYPE_SM2_Q7_V3,
                    char* pszDigestEncryptionAlgOid = szOID_SM2_SIGN );

//*************************************************************************
// Method:      VerifyFileSignature_Raw
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]unsigned char* pbyPublicKeyX
// Parameter:   [IN]unsigned char* PbyPublicKeyY
// Parameter:   [IN]unsigned char* pbyRawSignatureRS
// Parameter:   [IN]int nRawSignatureRSSize
// Parameter:   [IN]bool bWithZValue = true
// Description: verify the signature on file,which is a 64-byte unsigned char binary data.,by public key.
//
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int VerifyFileSignature_Raw(
                    FILE* fpSourceFile,
                    unsigned char* pbyPublicKeyX,
                    unsigned char* PbyPublicKeyY,
                    unsigned char* pbyRawSignatureRS, int nRawSignatureRSSize,
                    bool bWithZValue = true );

//*************************************************************************
// Method:      VerifyFileSignature_PKCS1_ByCert
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [IN]char* pszBase64Cert
// Parameter:   [IN]int nBase64CertLength
// Parameter:   [IN]char* pszBase64PKCS1Signature
// Parameter:   [IN]int nBase64PKCS1Signature
// Parameter:   [IN]bool bWithZValue = true
// Description: verify the signature on file ,which is is base64 encoded value,by public key.
//
// Author:      xyyang 
// Date:        2012/12/11
//*************************************************************************
int VerifyFileSignature_PKCS1_ByCert(
                    FILE* fpSourceFile,
                    char* pszBase64Cert, int nBase64CertLength,
                    char* pszBase64PKCS1Signature, int nBase64PKCS1Signature,
                    bool bWithZValue = true);

//*************************************************************************
// Method:      VerifyFileSignature_PKCS7Attached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpP7AttachedSignatureFile
// Parameter:   [OUT]long long * pSourceDataStartPos
// Parameter:   [OUT]int * pnSourceSize
// Parameter:   [OUT]unsigned char * * ppbyPublicCertData
// Parameter:   [OUT]int * pnPublicCertSize
// Parameter:   [IN]bool bWithZValue
// Description: Verify DER encoded PKCS#7 attached signature file
//            
// Author:      xybei
// Date:        2012/12/28
//*************************************************************************
int VerifyFileSignature_PKCS7Attached(
                    FILE* fpP7AttachedSignatureFile,
                    long long* pSourceDataStartPos = NULL, int* pnSourceSize = NULL,
                    unsigned char** ppbyDERPublicCertData = NULL, int* pnDERPublicCertSize = NULL,
                    bool bWithZValue = true);
                    
//************************************
// Method:      VerifyFileSignature_PKCS7Detached
// FullName:    VerifyFileSignature_PKCS7Detached
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]char* pszBase64PKCS7DetachedSignature
// Parameter:   [IN]int nBase64PKCS7DetachedSignatureLen
// Parameter:   [IN]FILE* fpSourceFile
// Parameter:   [OUT]unsigned char** ppbyPublicCertData
// Parameter:   [OUT]int* pnPublicCertSize
// Parameter:   [IN]bool bWithZValue
// Description:  verify the signature on file ,which is encapsulated to SM2PKCS7.
//
// Author:      xyyang 
// Date:        2012/12/12
//************************************
int VerifyFileSignature_PKCS7Detached(
                    char* pszBase64PKCS7DetachedSignature, int nBase64PKCS7DetachedSignatureLen,
                    FILE* fpSourceFile,
                    unsigned char** ppbyPublicCertData = NULL, int* pnPublicCertSize = NULL,
                    bool bWithZValue = true);
#endif  // _SM2_DATA_SIGNING_H