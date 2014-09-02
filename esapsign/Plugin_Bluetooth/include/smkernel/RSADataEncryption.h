/**************************************************************************
    filename:   RSADataEncryption.h
    author:     xxzhang
    created:    2013/04/16
    purpose:    Declare RSA CMS envelope interfaces.
                
**************************************************************************/
#import "openssl/evp.h"
#ifndef _RSA_DATA_ENCRYPTION_H__
#define _RSA_DATA_ENCRYPTION_H__

//*************************************************************************
// Method:      GenerateSymKey
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]int nSymAlgNID
//                  NID_rc4
//                  NID_des_ede3_cbc
// Parameter:   [OUT]unsigned char **ppbySymKey
// Parameter:   [OUT]int *pnSymKeyLen
// Description: generate symmetric key
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int GenerateSymKey(int nSymAlgNID, unsigned char **ppbySymKey, int *pnSymKeyLen);

//*************************************************************************
// Method:      GenerateSymKey
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]int nAlgNID
//                  NID_rc4
//                  NID_des_ede3_cbc
// Parameter:   [OUT]const EVP_CIPHER **ppEvpCipher
// Description: get EVP Cipher
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int GetEVPCipherbyNID(int nAlgNID, const EVP_CIPHER **ppEvpCipher);

//*************************************************************************
// Method:      SymEncrypt
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]int nSymAlgNID
//                  NID_rc4
//                  NID_des_ede3_cbc
// Parameter:   [IN]unsigned char* pbyKeyData
// Parameter:   [IN]int nKeyDataSize
// Parameter:   [IN]const unsigned char* pbyIv
// Parameter:   [IN]unsigned char* pbyPlainData
// Parameter:   [IN]int nPlainDataSize
// Parameter:   [OUT]unsigned char **ppbyEncryptedData
// Parameter:   [OUT]int *pnEncryptedDataSize
// Description: encrypt by symmetric key
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int SymEncrypt(int nSymAlgNID,
               unsigned char* pbyKeyData, int nKeyDataSize,
               const unsigned char* pbyIv,
               unsigned char* pbyPlainData, int nPlainDataSize,
               unsigned char** ppbyEncryptedData, int *pnEncryptedDataSize);

//*************************************************************************
// Method:      SymDecrypt
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]int nSymAlgNID
//                  NID_rc4
//                  NID_des_ede3_cbc
// Parameter:   [IN]unsigned char* pbySymKeyData
// Parameter:   [IN]int nbySymKeyDataSize
// Parameter:   [IN]unsigned char* pbyIV
// Parameter:   [IN]unsigned char* pbyEncryptedData
// Parameter:   [IN]int nEncryptedDataSize
// Parameter:   [OUT]unsigned char **ppbyPlainData
// Parameter:   [OUT]int *pnPlainDataSize
// Description: decrypt by symmetric key
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int SymDecrypt(int nSymAlgNID,
               unsigned char *pbyIV,
               unsigned char *pbySymKeyData, int nbySymKeyDataSize,               
               unsigned char *pbyEncryptedData, int nEncryptedDataSize,
               unsigned char **ppbyPlainData, int *pnPlainDataSize);

int RSAEncrypt(EVP_PKEY* pEvpPubKey, 
               unsigned char *pbyPlainData, int nPlainDataSize,
               unsigned char **ppbyEncryptedData, int *pnEncryptedDataSize);

int RSADecrypt(EVP_PKEY *pPrivateKey,  
               unsigned char *pbyEncryptedData,  int nEncryptedDataSize, 
               unsigned char **ppbyPlainData, int *pnPlainDataSize);

int RSAEncryptByX509(X509* pX509Cert, 
                     unsigned char *pbyPlainData, int nPlainDataSize,
                     unsigned char **ppbyEncryptedData, int *pnEncryptedDataSize);

int RSA_EncryptDataToDERCMSEnvelope( unsigned char* pbyPlainData, int nPlainDataSize,
                                     unsigned char* pbyDERCertContent, int nDERCertContentSize,
                                     int nSymEncAlgNID,
                                     unsigned char** ppbyDERCMSEnvelope, int* pnDERCMSEnvelopeSize );

//*************************************************************************
// Method:      RSA_EncryptDataToDERCMSEnvelope
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]unsigned char* pbyPlainData
// Parameter:   [IN]int nPlainDataSize
// Parameter:   [IN]unsigned char* pbyDERCertContent
// Parameter:   [IN]int nDERCertContentSize
// Parameter:   [IN]int nSymEncAlgNID
//                  NID_rc4
//                  NID_des_ede3_cbc
// Parameter:   [OUT]unsigned char** ppbyDERCMSEnvelope
// Parameter:   [OUT]int* pnDERCMSEnvelopeSize
// Description: generate envelope encoding by DER
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int RSA_EncryptDataToDERCMSEnvelope( unsigned char* pbyPlainData, int nPlainDataSize,
                                     unsigned char* pbyDERCertContent, int nDERCertContentSize,
                                     int nSymEncAlgNID,
                                     unsigned char** ppbyDERCMSEnvelope, int* pnDERCMSEnvelopeSize);


//*************************************************************************
// Method:      RSA_EncryptDataToCMSEnvelope
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]unsigned char* pbyPlainData
// Parameter:   [IN]int nPlainDataSize
// Parameter:   [IN]char* pszBase64CertContent
// Parameter:   [IN]unsigned long fBase64Flags
// Parameter:   [OUT]char** ppszBase64CMSEnvelope
// Parameter:   [OUT]int* pnBase64CMSEnvelopeLen
// Description: generate envelope encoding by Base64
//              only support 3DES_CBC and RC4
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int RSA_EncryptDataToCMSEnvelope( unsigned char* pbyPlainData, int nPlainDataSize,
                                  char* pszBase64CertContent,
                                  int nSymEncAlgNID,
                                  unsigned long fBase64Flags,
                                  char** ppszBase64CMSEnvelope, int* pnBase64CMSEnvelopeLen);

//*************************************************************************
// Method:      RSA_DecryptDataFromDERCMSEnvelope
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]unsigned char* pszDERCMSEnvelope
// Parameter:   [IN]int nDERCMSEnvelopeDataSize
// Parameter:   [IN]FILE* fpPFX
// Parameter:   [IN]char* pszPFXPwd
// Parameter:   [OUT]unsigned char** ppbyPlainData
// Parameter:   [OUT]int* pnPlainDataSize
// Description: decrypted envelope encoded by DER and get plainData
//              only support 3DES_CBC and RC4
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int RSA_DecryptDataFromDERCMSEnvelope( unsigned char* pszDERCMSEnvelope, int nDERCMSEnvelopeDataSize,
                                       FILE* fpPFX, char* pszPFXPwd,
                                       unsigned char** ppbyPlainData, int* pnPlainDataSize);

//*************************************************************************
// Method:      RSA_DecryptDataFromCMSEnvelope
// Access:      public 
// Returns:     Success: CFCA_OK; Failed:others
// Parameter:   [IN]char* pszBase64CMSEnvelope
// Parameter:   [IN]FILE* fpPFX
// Parameter:   [IN]char* pszPFXPwd
// Parameter:   [OUT]unsigned char** ppbyPlainData
// Parameter:   [OUT]int* pnPlainDataSize
// Description: decrypted envelope encoded by Base64 and get plainData
//              only support 3DES_CBC and RC4
// Author:      xxzhang
// Date:        2013/05/07
//*************************************************************************
int RSA_DecryptDataFromCMSEnvelope(  char* pszBase64CMSEnvelope,
                                    FILE* fpPFX, char* pszPFXPwd,
                                    unsigned char** ppbyPlainData, int* pnPlainDataSize);

#endif // _RSA_DATA_ENCRYPTION_H__
