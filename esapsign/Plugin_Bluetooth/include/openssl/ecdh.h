/* crypto/ecdh/ecdh.h */
/* ====================================================================
 * Copyright 2002 Sun Microsystems, Inc. ALL RIGHTS RESERVED.
 *
 * The Elliptic Curve Public-Key Crypto Library (ECC Code) included
 * herein is developed by SUN MICROSYSTEMS, INC., and is contributed
 * to the OpenSSL project.
 *
 * The ECC Code is licensed pursuant to the OpenSSL open source
 * license provided below.
 *
 * The ECDH software is originally written by Douglas Stebila of
 * Sun Microsystems Laboratories.
 *
 */
/* ====================================================================
 * Copyright (c) 2000-2002 The OpenSSL Project.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer. 
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by the OpenSSL Project
 *    for use in the OpenSSL Toolkit. (http://www.OpenSSL.org/)"
 *
 * 4. The names "OpenSSL Toolkit" and "OpenSSL Project" must not be used to
 *    endorse or promote products derived from this software without
 *    prior written permission. For written permission, please contact
 *    licensing@OpenSSL.org.
 *
 * 5. Products derived from this software may not be called "OpenSSL"
 *    nor may "OpenSSL" appear in their names without prior written
 *    permission of the OpenSSL Project.
 *
 * 6. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by the OpenSSL Project
 *    for use in the OpenSSL Toolkit (http://www.OpenSSL.org/)"
 *
 * THIS SOFTWARE IS PROVIDED BY THE OpenSSL PROJECT ``AS IS'' AND ANY
 * EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE OpenSSL PROJECT OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This product includes cryptographic software written by Eric Young
 * (eay@cryptsoft.com).  This product includes software written by Tim
 * Hudson (tjh@cryptsoft.com).
 *
 */
#ifndef HEADER_ECDH_H
#define HEADER_ECDH_H

#include <openssl/opensslconf.h>

#ifdef OPENSSL_NO_ECDH
#error ECDH is disabled.
#endif

#include <openssl/ec.h>
#include <openssl/ossl_typ.h>
#ifndef OPENSSL_NO_DEPRECATED
#include <openssl/bn.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

const ECDH_METHOD *ECDH_OpenSSL(void);

void	  ECDH_set_default_method(const ECDH_METHOD *);
const ECDH_METHOD *ECDH_get_default_method(void);
int 	  ECDH_set_method(EC_KEY *, const ECDH_METHOD *);

int ECDH_compute_key(void *out, size_t outlen, const EC_POINT *pub_key, EC_KEY *ecdh,
                     void *(*KDF)(const void *in, size_t inlen, void *out, size_t *outlen));

int 	  ECDH_get_ex_new_index(long argl, void *argp, CRYPTO_EX_new 
		*new_func, CRYPTO_EX_dup *dup_func, CRYPTO_EX_free *free_func);
int 	  ECDH_set_ex_data(EC_KEY *d, int idx, void *arg);
void 	  *ECDH_get_ex_data(EC_KEY *d, int idx);


/* BEGIN ERROR CODES */
/* The following lines are auto generated by the script mkerr.pl. Any changes
 * made after this point may be overwritten when the script is next run.
 */
void ERR_load_ECDH_strings(void);

/* Error codes for the ECDH functions. */

/* Function codes. */
#define ECDH_F_ECDH_CHECK				 102
#define ECDH_F_ECDH_COMPUTE_KEY				 100
#define ECDH_F_ECDH_DATA_NEW_METHOD			 101

/* Reason codes. */
#define ECDH_R_KDF_FAILED				 102
#define ECDH_R_NON_FIPS_METHOD				 103
#define ECDH_R_NO_PRIVATE_VALUE				 100
#define ECDH_R_POINT_ARITHMETIC_FAILURE			 101

int _SM2_generate_temp_keypair(BIGNUM* r, BIGNUM* x, BIGNUM* y, int nid);
int _SM2_BNBitAND(BIGNUM* ret, const BIGNUM* a, const BIGNUM* b);
/*ret is upbound*/
int _SM2_log2n(BIGNUM* bnN, int* ret);
int _SM2_KEP_calculate_xDash(BIGNUM* xDash, const BIGNUM* x, int w);
int _SM2_KEP_calculate_t(BIGNUM* t, const BIGNUM* d, const BIGNUM* xDash, const BIGNUM* r, const BIGNUM* n);
int _SM2_KEP_calculate_point_V(BIGNUM* Vx, BIGNUM* Vy, const BIGNUM* Px, const BIGNUM* Py, const BIGNUM* Rx,const BIGNUM* Ry,const BIGNUM* h,const BIGNUM* t,const BIGNUM* xDash, int nid);

int _SM2_CalculateZValue_byCurve(int nid, unsigned char* ID, unsigned int IDBytesLen, BIGNUM* x, BIGNUM* y, unsigned char* digestData);
int _SM2_CalculateZValue_byCurve_ex(int nid, unsigned char* ID, unsigned int IDBytesLen, unsigned char* x, unsigned char* y, unsigned char* digestData);
int _SM2_KEP(int   nid,
             const BIGNUM* Rix,
             const BIGNUM* Riy,
             const BIGNUM* ri,
             const BIGNUM* Userix,
             const BIGNUM* Useriy,
             const BIGNUM* di,
             const unsigned char* Za, 
             const BIGNUM* ROtherx,
             const BIGNUM* ROthery,
             const BIGNUM* OtherUserx,
             const BIGNUM* OtherUsery,
             const unsigned char* Zb,
             unsigned int kBitlen, 
             unsigned char* K);
int _SM2_KEP_ex(int   nid,
             unsigned char* Rix,
             unsigned char* Riy,
             unsigned char* ri,
             unsigned char* Userix,
             unsigned char* Useriy,
             unsigned char* di,
             const unsigned char* Za, 
             unsigned char* ROtherx,
             unsigned char* ROthery,
             unsigned char* OtherUserx,
             unsigned char* OtherUsery,
             const unsigned char* Zb,
             unsigned int kBitlen, 
             unsigned char* K);
int sm2kep_compute_key(void *out, size_t outlen, /*unsigned char* ID, unsigned int IDLen,*/ const EC_POINT *pub_key, 
				const EC_POINT *pub_user_key, EC_KEY *ecdh, EC_KEY *sm2kep, size_t isServer);

#ifdef  __cplusplus
}
#endif
#endif
