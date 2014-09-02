#ifndef _SM_DATA_ENCRYPTION_H
#define _SM_DATA_ENCRYPTION_H

#include <openssl/asn1t.h>

//*************************************************************************
// Method:      SM4_CalculateEncryptedSize
// Access:      public 
// Returns:     Encrypted data Size
// Parameter:   [IN]ulPlainDataSize
// Description: Calculate SM4 encrypted data size
//
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
#define SM4_CalculateEncryptedSize(ulPlainDataSize) (((ulPlainDataSize)/16 + 1)*16)

//*************************************************************************
// Method:      SM2_CalculateEncryptedSize
// Access:      public 
// Returns:     Encrypted data Size
// Parameter:   [IN]ulPlainDataSize
// Description: The encrypted data size does not contain the size of 0x04
//              returned size = sizeof(PublicKeyX) + sizeof(PublicKeyY) + sizeof(PlainData) + sizeof(Hash)
//
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
#define SM2_CalculateEncryptedSize(ulPlainDataSize) (32+32+(ulPlainDataSize)+32)

//*************************************************************************
// Method:      SM2_CalculateDecryptedSize
// Access:      public 
// Returns:     Decrypted data Size
// Parameter:   [IN] ulEncryptedDataSize
// Description: The encrypted data size does not contain the size of 0x04
//              returned size = sizeof(EncryptedData) - sizeof(PublicKeyX) - sizeof(PublicKeyY) - sizeof(Hash)
//
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
#define SM2_CalculateDecryptedSize(ulEncryptedDataSize) ((ulEncryptedDataSize)-32-32-32)

/*
 * The encryption result(C1||C3||C2) is compatible with the standard of GM/T 0003.4-2012
 */
int _SM2_encrypt_v2(int nid, unsigned char* M, unsigned int MByteLen, BIGNUM* Pbx, BIGNUM* Pby, unsigned char* C);
int _SM2_decrypt_v2(int nid, unsigned char* C, unsigned int CBytesLen, BIGNUM* dB, unsigned char* MDash);

//*************************************************************************
// Method:      SM2_Encrypt
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyPlainData
// Parameter:   [IN]int nPlainDataSize
// Parameter:   [IN]unsigned char * pbyPubKeyX
// Parameter:   [IN]int nPubKeyXSize
// Parameter:   [IN]unsigned char * pbyPubKeyY
// Parameter:   [IN]int nPubKeyYSize
// Parameter:   [OUT]unsigned char * * ppbyEncryptedData
// Parameter:   [OUT]int * pnEncryptedDataSize
// Description: The encrypted data without the 0x04 prefix
//            
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
int SM2_Encrypt(unsigned char* pbyPlainData,  int nPlainDataSize,
                unsigned char* pbyPubKeyX, int nPubKeyXSize,
                unsigned char* pbyPubKeyY, int nPubKeyYSize,
                unsigned char** ppbyEncryptedData, int* pnEncryptedDataSize);

//*************************************************************************
// Method:      SM2_Decrypt
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyEncryptedData
// Parameter:   [IN]int nEncryptedDataSize
// Parameter:   [IN]unsigned char * pbyPrivateKey
// Parameter:   [IN]int nPrivateKeySize
// Parameter:   [OUT]unsigned char * * ppbyPlainData
// Parameter:   [OUT]int * pnPlainDataSize
// Description: The encrypted data without the 0x04 prefix
//            
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
int SM2_Decrypt(unsigned char* pbyEncryptedData, int nEncryptedDataSize,
                unsigned char* pbyPrivateKey, int nPrivateKeySize,
                unsigned char** ppbyPlainData, int* pnPlainDataSize);

int SM4_Encrypt_CBC(unsigned char* pbyPlainData, int nPlainDataSize,
                    unsigned char* pbySessionKey, int nSessionKeySize/* = 32*/,
                    unsigned char** ppbyEncryptedData, int* pnEncryptedDataSize );


int SM4_Decrypt_CBC(unsigned char* pbyEncryptedData, int nEncryptedDataSize,
                    unsigned char* pbySessionKey, int nSessionKeySize/* = 32*/,
                    unsigned char** ppbyPlainData, int* pnPlainDataSize );

int SM4EncryptByPin(unsigned char* pbyPlainData, int nPlainDataSize,
                    char* pszPassword,
                    unsigned char** ppbyEncryptedData, int* pnEncryptedDataSize );

int SM4DecryptByPin(unsigned char* pbyEncryptedData, int nEncryptedDataSize,
                    char* pszPassword,
                    unsigned char** ppbyPlainData, int* pnPlainDataSize );

//*************************************************************************
// Method:      EncryptDataToDerCMSEnvelope
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyPlainData
// Parameter:   [IN]int nPlainDataSize
// Parameter:   [IN]char * pszBase64Cert
// Parameter:   [IN]int nBase64CertLength
// Parameter:   [OUT]unsigned char * * ppbyDerCMSEnvelope
// Parameter:   [OUT]int * pnDerCMSEnvelopeSize
// Description: Encrypt data to DER encoded CMS envelope
//            
// Author:      xybei
// Date:        2012/12/14
//*************************************************************************
int EncryptDataToDerCMSEnvelope(
                    unsigned char* pbyPlainData, int nPlainDataSize,
                    char* pszBase64Cert, int nBase64CertLength,
                    unsigned char** ppbyDerCMSEnvelope, int* pnDerCMSEnvelopeSize );

int DecryptDerCMSEnvelopeData(
                    unsigned char* pbyDerCMSEnvelope, int nDerCMSEnvelop,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    unsigned char** ppbyPlainData, int* pnPlainDataSize );

// Base64 encoded
int EncryptDataToBase64CMSEnvelope(
                    unsigned char* pbyPlainData, int nPlainDataSize,
                    char* pszBase64Cert, int nBase64CertLength,
                    char** ppszBase64CMSEnvelope, int* pnBase64CMSEnvelopeLength,
                    unsigned long fBase64Flags );

int DecryptBase64CMSEnvelopeData(
                    char* pszBase64CMSEnvelope, int nBase64CMSEnvelope,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    unsigned char** ppbyPlainData, int* pnPlainDataSize );

//*************************************************************************
// Method:      EncryptFileToDerCMSEnvelope
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE* fpPlainFile
// Parameter:   [IN]char * pszBase64Cert
// Parameter:   [IN]int nBase64CertLength
// Parameter:   [IN]FILE* fpOutDerCMSEnvelopeFile
// Description: The DER encoded CMS envelope data is written to the file user specified by pszOutDerCMSEnvelopeFileName
//            
// Author:      xybei
// Date:        2012/12/15
//*************************************************************************
int EncryptFileToDerCMSEnvelope(
                    FILE* fpPlainFile,
                    char* pszBase64Cert, int nBase64CertLength,
                    FILE* fpOutDerCMSEnvelopeFile);

//*************************************************************************
// Method:      DecryptDerCMSEnvelopeFile
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]FILE * fpCMSEnvelope
// Parameter:   [IN]FILE * fpSM2PFXFile
// Parameter:   [IN]char * pszPassword
// Parameter:   [IN]FILE * fpOutPlainFile
// Description: The DER encoded CMS envelope data is written to the file: fpOutPlainFile
//            
// Author:      xybei
// Date:        2012/12/18
//*************************************************************************
int DecryptDerCMSEnvelopeFile(
                    FILE* fpCMSEnvelope,
                    FILE* fpSM2PFXFile, char* pszPassword,
                    FILE* fpOutPlainFile);

#endif  // _SM_DATA_ENCRYPTION_H