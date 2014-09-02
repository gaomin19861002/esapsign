#ifndef _CONSTANT_H
#define _CONSTANT_H

#define BLOCK_SIZE         ( 1024*16 )   // 16K
#define DES3_KEY_LEN         24
#define RC4_KEY_LEN          16
#define MIN_BLOCK_LEN_8       8

#define SM2_RAW_RS_SIZE      64
#define SM2_ASN1_Q1_MIN_SIZE 66
#define SM2_ASN1_Q1_MAX_SIZE 72


#define SIG_TYPE_RSA         0x0000

//Raw 64 bits RS
#define SIG_TYPE_SM2_Q1_V1   0x0001

// SEQUENCE
// --INTEGER(R)
// --INTEGER(S)
#define SIG_TYPE_SM2_Q1_V2   0x0002


// INTEGER(R)
// INTEGER(S)
#define SIG_TYPE_SM2_Q7_V1   0x0100

// SEQUENCE
// --INTEGER(R)
// --INTEGER(S)
#define SIG_TYPE_SM2_Q7_V2   0x0200

// OCTET STRING
#define SIG_TYPE_SM2_Q7_V3   0x0400


#define szOID_SM2               "1.2.156.10197.1.301"
#define szOID_SM2_SIGN          "1.2.156.10197.1.301.1"
#define szOID_SM2_EXCHANG       "1.2.156.10197.1.301.2"
#define szOID_SM2_ENCRYPT       "1.2.156.10197.1.301.3"

#define szOID_SM3               "1.2.156.10197.1.401"
#define szOID_SM2_SM3           "1.2.156.10197.1.501"

#define szOID_SM2_data          "1.2.156.10197.6.1.4.2.1"
#define szOID_SM2_signedData    "1.2.156.10197.6.1.4.2.2"
#define szOID_SM2_envelopedData "1.2.156.10197.6.1.4.2.3"

#define szOID_SM4               "1.2.156.10197.1.104"

#ifndef WIN32
#define szOID_RSA_envelopedData "1.2.840.113549.1.7.3"
#define szOID_RSA_RSA           "1.2.840.113549.1.1.1"
#define szOID_RSA_data          "1.2.840.113549.1.7.1"
#endif


#endif //_CONSTANT_H

