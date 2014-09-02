/**************************************************************************
    filename:   CertificateOperations.h
    author:     xybei
    created:    2012/12/20
    purpose:    Declare certificate operations
                
**************************************************************************/
#ifndef _CERTIFICATE_OPERATION_H__
#define _CERTIFICATE_OPERATION_H__

#include <string>
#include <vector>
#include <time.h>
#ifdef WIN32
#undef X509_NAME
#endif
#include <openssl/x509v3.h>

#define VERIFY_CERT_TIME        0x00000001
#define VERIFY_CERT_CRL         0x00000002
#define VERIFY_CERT_CHAIN       0x00000004

#define CERT_TYPE_RSA           1
#define CERT_TYPE_SM2           2


int ConvertCertDataToX509(unsigned char* pbyCertData, int nCertDataSize, X509** ppX509Cert);

int LoadCertsToStore(std::vector<FILE*> vtrTrustedCertSet, X509_STORE **p_certStore);


//*************************************************************************
// Method:      CheckX509KeyUsage
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509
// Parameter:   [IN]unsigned int uiCheckBits
//                  A combination of the bits:
//                  KU_DIGITAL_SIGNATURE	0x0080
//                  KU_NON_REPUDIATION	    0x0040
//                  KU_KEY_ENCIPHERMENT	    0x0020
//                  KU_DATA_ENCIPHERMENT	0x0010
//                  KU_KEY_AGREEMENT	    0x0008
//                  KU_KEY_CERT_SIGN	    0x0004
//                  KU_CRL_SIGN		        0x0002
//                  KU_ENCIPHER_ONLY	    0x0001
//                  KU_DECIPHER_ONLY	    0x8000
// Parameter:   [IN]bool bFullMatch
//                  true:  All the check bits must be present.
//                  false: One of the check bit present is OK.
// Description: Check x509 certificate key usage.
//            
// Author:      xybei
// Date:        2013/04/16
//*************************************************************************
int CheckX509KeyUsage(X509* pX509, unsigned int uiCheckBits, bool bFullMatch);

int CheckCertKeyUsage(unsigned char* pbyCertData, int nCertDataSize, unsigned int uiCheckBits, bool bFullMatch);

int VerifyCertChainByTrustedStore(X509_STORE* pTrustedX509Store, X509* pCertToVerify);

int VerifyCertTime(X509* pCertToVerify);

int VerifyCertCRL(FILE* fpCRL, X509* pCertToVerify);

int VerifyCertChain(std::vector<FILE*> vtrTrustedCertSet, X509* pCertToVerify);


//*************************************************************************
// Method:      VerifyX509
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pCertToVerify
// Parameter:   [IN]unsigned int nVerifyFlag :(VERIFY_CERT_TIME | VERIFY_CERT_CRL | VERIFY_CERT_CHAIN)
// Parameter:   [IN]FILE * fpCRL
// Parameter:   [IN]std::vector<FILE * > vtrTrustedCertSet
// Description: Verify certificate by X509
//            
// Author:      xybei
// Date:        2012/12/21
//*************************************************************************
int VerifyX509(X509* pCertToVerify,
               unsigned int nVerifyFlag,
               FILE* fpCRL,
               std::vector<FILE*> vtrTrustedCertSet);


//*************************************************************************
// Method:      VerifyCertificate
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]unsigned char * pbyCertData
// Parameter:   [IN]int nCertDataSize
// Parameter:   [IN]unsigned int nVerifyFlag :(VERIFY_CERT_TIME | VERIFY_CERT_CRL | VERIFY_CERT_CHAIN)
// Parameter:   [IN]FILE * fpCRL
// Parameter:   [IN]std::vector<FILE * > vtrTrustedCertSet
// Description: Verify certificate by cert data
//            
// Author:      xybei
// Date:        2012/12/21
//*************************************************************************
int VerifyCertificate(unsigned char* pbyCertData,
                      int nCertDataSize,
                      unsigned int nVerifyFlag,
                      FILE* fpCRL,
                      std::vector<FILE*> vtrTrustedCertSet);


//*************************************************************************
// Method:      GetX509CertType
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]int * pnCertTypeFlag
// Description: The type flag(CERT_TYPE_RSA or CERT_TYPE_SM2) returned by pnCertTypeFlag.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509CertType(X509* pX509Cert, int* pnCertTypeFlag);


//*************************************************************************
// Method:      GetX509SubjectCN
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]char * * ppszSubjectCN
// Parameter:   [OUT]int * pnSubjectCNLen
// Description: The CN string is UTF-8 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509SubjectCN(X509* pX509Cert, char** ppszSubjectCN, int* pnSubjectCNLen);


//*************************************************************************
// Method:      GetX509SubjectDN
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]char * * ppszSubjectDN
// Parameter:   [OUT]int * pnSubjectDNLen
// Description: The DN string is UTF-8 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509SubjectDN(X509* pX509Cert, char** ppszSubjectDN, int* pnSubjectDNLen);


//*************************************************************************
// Method:      GetX509IssuerDN
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]char * * ppszIssuerDN
// Parameter:   [OUT]int * pnIssuerDNLen
// Description: The DN string is UTF-8 encoded.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509IssuerDN(X509* pX509Cert, char** ppszIssuerDN, int*pnIssuerDNLen);


//*************************************************************************
// Method:      GetX509NotBefore
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]time_t * ptNotBeforeInUTC
// Description: The time returned by this method is UTC time.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509NotBefore(X509* pX509Cert, time_t* ptNotBeforeInUTC);


//*************************************************************************
// Method:      GetX509NotAfter
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]time_t * ptNotAfterInUTC
// Description: The time returned by this method is UTC time.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509NotAfter(X509* pX509Cert, time_t* ptNotAfterInUTC);


//*************************************************************************
// Method:      GetX509SerialNumber
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]char * * ppszSerialNumber
// Parameter:   [OUT]int * pnSerialNumberLen
// Description: The SN returned by this method is hex format.
//            
// Author:      xybei
// Date:        2013/05/20
//*************************************************************************
int GetX509SerialNumber(X509* pX509Cert, char** ppszSerialNumber, int* pnSerialNumberLen);



//*************************************************************************
// Method:      GetX509SubjectKeyID
// Access:      public 
// Returns:     int 0:Success; Other:Failed
// Parameter:   [IN]X509 * pX509Cert
// Parameter:   [OUT]char * * ppszSubjectKeyID
// Parameter:   [OUT]int * pnSubjectKeyIDLen
// Description: The SubjectKeyID string is UTF-8 encoded.
//            
// Author:      xxzhang
// Date:        2013/07/12
//*************************************************************************
int GetX509SubjectKeyID(X509* pX509Cert, char** ppszSubjectKeyID, int* pnSubjectKeyIDLen);

#endif // _CERTIFICATE_OPERATION_H__
