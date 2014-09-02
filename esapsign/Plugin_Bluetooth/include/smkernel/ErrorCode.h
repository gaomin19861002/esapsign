#ifndef _ERROR_CODE_H
#define _ERROR_CODE_H

#define CFCA_ERROR -1
#define CFCA_OK     0

#ifndef WIN32

    //Error code for Linux
    #define ERROR_INVALID_PARAMETER              (0x80070057)    
    #define ERROR_OPEN_FAILED                    (0x8007006E)        
    #define ERROR_WRITE_FAULT                    (0x8007001D)            
    #define ERROR_READ_FAULT                     (0x8007001E)            
    #define ERROR_ENCRYPTION_FAILED              (0x80071770)
    #define ERROR_DECRYPTION_FAILED              (0x80071771)    
    #define NTE_BAD_SIGNATURE                    (0x80090006)

    
    

    #define ERROR_BASE64_ENCODING_FAILED         (0x00001004 | 0xA0070000)
    #define ERROR_BASE64_DECODING_FAILED         (0x00001005 | 0xA0070000)
    #define ERROR_CERT_TIME_INVALID              (0x00001031 | 0xA0070000)
    #define ERROR_CERT_OFFLINE_REVOCATION        (0x00001032 | 0xA0070000)
    #define ERROR_CERT_PARTIAL_CHAIN             (0x00001033 | 0xA0070000)
    #define ERROR_INVALID_CERTIFICATE_USAGE      (0x00002021 | 0xA0070000)

    #define ERROR_DATA_SIZE_EXCEEDS_LIMITED      (0x00001101 | 0xA0070000)
    #define ERROR_TOO_DEEP_RECURSIVE_COUNT       (0x00001102 | 0xA0070000)
    #define ERROR_DECODE_SM2_FILE_CERT_FAILED    (0x00001103 | 0xA0070000)
    #define ERROR_INVALID_PKCS7_SIGNATURE_FORMAT (0x00001104 | 0xA0070000)
    #define ERROR_INVALID_CMS_ENVELOPE_FORMAT    (0x00001105 | 0xA0070000)
    #define ERROR_ENVELOPE_SM2_PFX_UNMATCHED     (0x00001106 | 0xA0070000)
    #define ERROR_SIGN_FAILED                    (0x00001107 | 0xA0070000)
    #define ERROR_DECRYPT_SM2_FILE_CERT_FAILED   (0x00001108 | 0xA0070000)
    #define ERROR_VERIFY_CERT_FAILED             (0x00001109 | 0xA0070000)
    #define ERROR_GET_CERT_INFO_FAILED            (0x00001110 | 0xA0070000)
    

#else

//Error code for Windows
#ifndef ERROR_BASE64_ENCODING_FAILED
    //Error code have defined in CryptoKernel
    #define ERROR_BASE64_ENCODING_FAILED         (0x00001004 | 0xA0070000)
    #define ERROR_BASE64_DECODING_FAILED         (0x00001005 | 0xA0070000)
    #define ERROR_CERT_TIME_INVALID              (0x00001031 | 0xA0070000)
    #define ERROR_CERT_OFFLINE_REVOCATION        (0x00001032 | 0xA0070000)
    #define ERROR_CERT_PARTIAL_CHAIN             (0x00001033 | 0xA0070000)
    #define ERROR_INVALID_CERTIFICATE_USAGE      (0x00002021 | 0xA0070000)
#endif

    #define ERROR_DATA_SIZE_EXCEEDS_LIMITED      (0x00001101 | 0x20000000)
    #define ERROR_TOO_DEEP_RECURSIVE_COUNT       (0x00001102 | 0x20000000)
    #define ERROR_DECODE_SM2_FILE_CERT_FAILED    (0x00001103 | 0x20000000)
    #define ERROR_INVALID_PKCS7_SIGNATURE_FORMAT (0x00001104 | 0x20000000)
    #define ERROR_INVALID_CMS_ENVELOPE_FORMAT    (0x00001105 | 0x20000000)
    #define ERROR_ENVELOPE_SM2_PFX_UNMATCHED     (0x00001106 | 0x20000000)
    #define ERROR_SIGN_FAILED                    (0x00001107 | 0x20000000)
    #define ERROR_DECRYPT_SM2_FILE_CERT_FAILED   (0x00001108 | 0xA0070000)
    #define ERROR_VERIFY_CERT_FAILED             (0x00001109 | 0xA0070000)
    #define ERROR_GET_CERT_INFO_FAILED            (0x00001110 | 0xA0070000)

#endif

#endif //_ERROR_CODE_H

