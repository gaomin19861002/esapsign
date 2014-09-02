/*****************************************************************************/
/* File Name: SMFileCertOperations.h                                         */
/* Description: Declare SM2 PFX interfaces                                   */
/*                                                                           */
/* Author: Xiangyou Bei                                                      */
/* Creation Date: Oct 19, 2012                                               */
/* Last Revision:                                                            */
/*****************************************************************************/

#ifndef _SM_FILE_CERT_OPERATIONS_H
#define _SM_FILE_CERT_OPERATIONS_H

// SM2 private data
typedef struct SM2_PRIVATE_DATA_st
{
    ASN1_OBJECT *dataID;
    ASN1_OBJECT *dataEncryptedAlg;
    ASN1_OCTET_STRING *encryptedSM2PrivateKey;
}SM2_PRIVATE_DATA;
DECLARE_ASN1_FUNCTIONS(SM2_PRIVATE_DATA)

// SM2 public data
typedef struct SM2_PUBLIC_DATA_st
{
    ASN1_OBJECT *dataID;
    ASN1_OCTET_STRING * SM2Certificate;
}SM2_PUBLIC_DATA;
DECLARE_ASN1_FUNCTIONS(SM2_PUBLIC_DATA)

// SM2 PFX
typedef struct SM2_PFX_st
{
    ASN1_INTEGER *version;
    SM2_PRIVATE_DATA *privateData;
    SM2_PUBLIC_DATA *publicData;
}SM2_PFX;
DECLARE_ASN1_FUNCTIONS(SM2_PFX);

// SM2 key pair
typedef struct SM2_KEY_PAIR_st
{
    unsigned char* pbyPrivateKey; int nPrivateKeySize;
    unsigned char* pbyPublicKeyX; int nPublicKeyXSize;
    unsigned char* pbyPublicKeyY; int nPublicKeyYSize;
}SM2_KEY_PAIR, *PSM2_KEY_PAIR;

int CreateSM2PrivateData(
                char* dataID,
                char* dataEncryptedAlg,
                unsigned char* encryptedSM2PrivateKey,
                unsigned int encryptedSM2PrivateKeySize,
                SM2_PRIVATE_DATA** ppstSM2PrivateData);

int CreateSM2PublicData(
                char* dataID,
                unsigned char* SM2Certificate,
                unsigned int SM2CertificateSize,
                SM2_PUBLIC_DATA** ppstSM2PublicData);

int CreateSM2PFX(
                long version, 
                SM2_PRIVATE_DATA* &pstSM2PrivateData,
                SM2_PUBLIC_DATA* &pstSM2PublicData,
                SM2_PFX** ppstSM2PFX);

int EncapsulateSM2PFX(
                unsigned char* pbySM2PublicCertData, int nSM2PublicCertDataSize,
                unsigned char* pbyPrivateKeyData, int nPrivateKeyDataSize,
                char* szPassword,
                unsigned char** ppbySM2PFXData, int* pnSM2PFXDataSize);

int ParseSM2PFX(
                unsigned char* pbySM2PFXData, int nSM2PFXDataSize,
                unsigned char** ppbyEncryptedPrivateKey, int* pnEncryptedPrivateKeySize,
                unsigned char** ppbyPublicCertData, int* pnPublicCertDataSize);

int GetPublicKeyXYFromSM2Cert(
                unsigned char* pbySM2CertData, int nSM2CertDataSize,
                unsigned char** ppbySM2PubKeyX, int* pnSM2PubKeyXSize,
                unsigned char** ppbySM2PubKeyY, int* pnSM2PubKeyYSize);

//*************************************************************************
// Method:      GetIssuerFromCert
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [OUT]unsigned char * * ppbyASN1Issuer
// Parameter:   [OUT]int * pnASN1IssuerSize
// Description: Get the ASN1 encoded Issuer data from certificate
//            
// Author:      xybei
// Date:        2012/12/05
//*************************************************************************
int GetIssuerFromCert(
                unsigned char* pbyCertData, int nCertDataSize,
                unsigned char** ppbyASN1Issuer, int* pnASN1IssuerSize);

//*************************************************************************
// Method:      GetSerialNumberFromCert
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [OUT]unsigned char * * ppbyASN1SerialNumber
// Parameter:   [OUT]int * pnASN1SerialNumber
// Description: Get the ASN1 encoded SerialNumber from certificate
//            
// Author:      xybei
// Date:        2012/12/05
//*************************************************************************
int GetSerialNumberFromCert(
                unsigned char* pbyCertData, int nCertDataSize,
                unsigned char** ppbyASN1SerialNumber, int* pnASN1SerialNumber);

//*************************************************************************
// Method:      GetSubjectKeyIDFromCert
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [OUT]unsigned char * * ppbySubjectKeyID
// Parameter:   [OUT]int * pnSubjectKeyIDSize
// Description: The returned value(V) of SubjectKeyID without TL
//            
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
int GetSubjectKeyIDFromCert(
                unsigned char* pbyCertData, int nCertDataSize,
                unsigned char** ppbySubjectKeyID, int* pnSubjectKeyIDSize);

//*************************************************************************
// Method:      DecryptKeyPairFromSM2PFX
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbySM2PFXData
// Parameter:   [IN]int nSM2PFXDataSize
// Parameter:   [IN]char * pszPassword
// Parameter:   [OUT]PSM2_KEY_PAIR pstSM2KeyPair
// Description: Parse and decrypt the SM2 PFX
//            
// Author:      xybei
// Date:        2012/12/09
//*************************************************************************
int DecryptKeyPairFromSM2PFX(
                unsigned char* pbySM2PFXData, int nSM2PFXDataSize,
                char* pszPassword,
                PSM2_KEY_PAIR pstSM2KeyPair);

//*************************************************************************
// Method:      CleanupSM2KeyPair
// Access:      public 
// Returns:     void
// Parameter:   [IN]PSM2_KEY_PAIR pstSM2KeyPair
// Description: This function only release the memory pointed by the member pointers of SM2_KEY_PAIR 
//            
// Author:      xybei
// Date:        2012/12/09
//*************************************************************************
void CleanupSM2KeyPair(
                PSM2_KEY_PAIR pstSM2KeyPair);

#endif  // _SM_FILE_CERT_OPERATIONS_H

