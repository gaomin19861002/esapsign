#define ATL_BASE64_FLAG_NONE	0
#define ATL_BASE64_FLAG_NOPAD	1
#define ATL_BASE64_FLAG_NOCRLF  2

int Base64EncodeGetRequiredLength(int nSrcLen, unsigned long dwFlags=ATL_BASE64_FLAG_NONE);

int Base64DecodeGetRequiredLength(int nSrcLen);

bool Base64Encode(const unsigned char *pbSrcData,
                  int nSrcLen,
                  char* szDest,
                  int *pnDestLen,
                  unsigned long dwFlags = ATL_BASE64_FLAG_NONE);

bool Base64Decode(const char* szSrc,
                  int nSrcLen,
                  unsigned char *pbDest,
                  int *pnDestLen);

int Base64EncodeEx(unsigned char* pbyData,
                   int nDataSize,
                   char** ppBase64EncodedStr,
                   int* pnBase64EncodedStrLen,
                   unsigned long dwFlags = ATL_BASE64_FLAG_NONE);

int Base64DecodeEx(char* pszBase64Str,
                   int nBase64StrLen,
                   unsigned char** ppDecodedData,
                   int* pnDecodedDataSize);
