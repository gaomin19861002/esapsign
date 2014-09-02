//
//  PDFDocument.mm
//  demo_form_field
//
//  Created by Foxit on 12-2-7.
//  Copyright 2012 Foxit Software Corporation. All rights reserved.
//

#import "PDFDocument.h"
#include "fgsdk_common.h"
#define StampFileName @"FoxitLogo"
#define AttachFileName @"FoxitForm"

//Define a log function.
#define PRINT_RET(str, ret) if((ret)){NSLog(@"%@ failed(%i)", (str), (ret));return nil;}


FS_LPVOID	g_PrivateAlloc(FS_LPVOID clientData, FS_DWORD size)
{
    return malloc(size);
}

FS_LPVOID	g_PrivateRealloc(FS_LPVOID clientData, FS_LPVOID ptr, FS_DWORD new_size)
{
	return realloc(ptr, new_size);
}

void		g_PrivateFree(FS_LPVOID clientData, FS_LPVOID ptr)
{
	free(ptr);
}

FS_RESULT		g_OnRecover(FS_LPVOID clientData, FS_LPVOID senderObject, FS_DWORD senderObjectType)
{
    return FSCRT_ERRCODE_SUCCESS;
}

void		g_OnOutOfMemory(FS_LPVOID clientData)
{
    return;
}

FS_RESULT	g_OnEvent(FS_LPVOID clientData, FS_LPVOID senderObject, FS_DWORD senderObjectType, FS_DWORD eventType, FS_LPVOID eventData)
{
    return FSCRT_ERRCODE_SUCCESS;
}

FS_RESULT	g_CallFunction(FS_LPVOID clientData, FSCRT_DOCUMENT document, FS_INT32 function, FSCRT_VAR* parameters, FS_INT32 count, FSCRT_VAR* ret)
{
    return FSCRT_ERRCODE_SUCCESS;
}

FSCRT_MEMMGRHANDLER g_PrivateMemMgr;
FSCRT_APPHANDLER    g_AppHandler;
#define FGSDK_GLOBALBUFFER_SIZE	(1024 * 1024 * 16)

//End implemention of struct FS_FileRead.




//Begin implemention of struct FS_FileWrite.
FS_DWORD	FSFileWrite_GetSize(FS_LPVOID clientData)
{
	return 0;
}

FS_RESULT	FSFileWrite_WriteBlock(FS_LPVOID clientData, FS_LPCVOID buffer,
								   FS_DWORD offset, FS_DWORD size)
{
	FILE* fp = (FILE*)clientData;
	if(!fp)
		return -1;
	//fseek(fp, offset, SEEK_SET);
	fwrite(buffer, sizeof(char), size, fp);
	return 0;
}

FS_RESULT	FSFileWrite_Flush(FS_LPVOID clientData)
{
	return 0;
}
//End implemention of struct FS_FileWrite.




//Begin implemention of struct FS_MEM_FIXEDMGR.
static FS_BOOL emb_test_more(FS_LPVOID clientData, int alloc_size, void** new_memory, int* new_size)
{
	*new_size = alloc_size;
	if (*new_size < 1000000) *new_size = 1000000;
	*new_memory = malloc(*new_size);
    if (new_memory == NULL) 
        return FALSE;
	return TRUE;
}
static void emb_test_free(FS_LPVOID clientData, void* memory)
{
	free(memory);
}
//End implemention of struct FS_MEM_FIXEDMGR.

//Begin implemention of struct FPDFEMB_FONT_MAPPER

FS_BOOL MyMapFont(FS_LPVOID param, FS_LPCSTR name, FS_INT32 charset,
                  FS_DWORD flags, FS_INT32 weight,
                  FS_CHAR* path, FS_INT32* face_index)
{
    if(0 == charset)
        return TRUE;
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"DroidSansFallback" ofType:@"ttf"];
    if(filepath != NULL)
    {
        strcpy(path, [filepath UTF8String]);
        *face_index = 0;        
    }
	return TRUE;
}
//End implemention of struct FPDFEMB_FONT_MAPPER





@implementation PDFDocument
@synthesize desFilePath = _desFilePath;

- (BOOL)initPDFSDK
{
    g_PrivateMemMgr.Alloc = g_PrivateAlloc;
    g_PrivateMemMgr.Realloc = g_PrivateRealloc;
    g_PrivateMemMgr.Free = g_PrivateFree;
    m_sdkMemory = malloc(FGSDK_GLOBALBUFFER_SIZE);
    FS_RESULT ret =  FSCRT_Library_CreateMgr(m_sdkMemory, FGSDK_GLOBALBUFFER_SIZE, &g_PrivateMemMgr);
    if(ret != FSCRT_ERRCODE_SUCCESS)
    {
        NSLog(@"SDK Library initializatoin failed!\n");
        free(m_sdkMemory);
        m_sdkMemory = NULL;
        return NO;
    }
    
    //Unlock the SDK library.
    FSCRT_BSTR license_id;
    FSCRT_BStr_Init(&license_id);
    license_id.str = "N8tVutzb62s/S2UKn0/xUArzHX6lYhT8n5sQMH6mtzs/tVnfaVwLfg==";
    license_id.len = strlen(license_id.str);
    FSCRT_BSTR unlockCode;
    unlockCode.str = "8f3o18ONtRkJBDdKtFJS8bag4akLggDM5FPEGj2uDnut43FG9NBT5gOidLhz71yo8ASE6iHC7Fa1IZfRcsXg6Gm0t0COzmyYJkug8fD7wwtUVP5krGEK2Ap3huV77PUUH9q3K8ROJ+9lOy2X/UgUKMBguDZSJgfMJzVpB1NLgQHTLeXX4PF+5qhvwQco6TePZxBO+KnViYSBH2CEuKFF/X/Rb9/LELKCLsoQqmlv1ivVtc97gPxHI1j3Xkv2rkFRHg7Hzb/H7k8MXXCs6R0E+XjmCEoQY4r1mpgIO0y6i2DBSTt9oaSADsHKDUrxfPbna4+1HarK/ayhBr9s3ysOQ13BipaktHcpAaH64+cPvEQqtldcmBLwpZXVlenrPMgC3MTDHieIwLpzZkEYOPQ3iRg2NqmNv1BOYQoz51yS3FsLstmQup3QZQwcAM5TlS+mnxiGIDzk1h+0KAJ4On1f59TCvjZHDuDRiVpfYpgMiKPL3aeqSM7PNZJr2Ou8P1nIBZWCyAujZQ+7D2f3pjhm6z1osB/+a0Ok+ZsyguCWz55G8rq6dQSvC0yAnwC80ZnvdKv1qH/BTWW7+QvC8m5u7fbgu74JO2zcZeueTROjiJlkYCxBKfC9443bokyT692Bx3xBzMVIhbEJZeI0vBcvd7rDQ/kyrRUuI0wkzoB2E1pKPDkdGM8TW7WwiOmDo03duexzAG5QM4z4qP5Xu9NImAwzlMZCByja2BrDW/mVH04ZWVHxKfes5TEDR5OsAL3YdWOogNV4EXPpYxhKbTnC3RaoRH7cOHhl7CWLJ3QPXZyjCKGXWzgVsrF2OVgEN9fkY3NqWt0vTHqD9MOY9Z2zU2uhOIvJXlJt9x78mV7axEEqt7p52sPfXhWfEjj+ipb0TTED6/lqK2H1CdNZrpZjR8sSKp+4uIzcBlXoG52xxeebOrsPn0Z+6X3NaoxJhqZ5ufzWs/TSn0vDOqA+Ile3aiqpBJJYCfoy+BYcBPHwhzzRapn9nHUs/t9EOQUglQ8VtJClxziAQPj316zGREZVRws763gpRx56On/Vbn2UtSFDsIYRZ+6kN+VYF91tSo/IU0NOj++2cs1qbHwoorFHiOYvjwemoRc+mT4Kr+U0vpm95vCNBUqPy0V0lxjgixYyemKPP9cDl6deOUKL53GJhto8KpbfaKplfVvt9rta5l9/HlIEajmh4VQve6juO91vme2tfRfLRRsiSYomRI37vjTIubodDbs/wFjvT+xhIZLw52SZgIm+HDvM2KwfM9ooJZp/brk0t8rVy5RaXVkqqUZtjUzX7OWNUaCUWJPjray4HqUZ1uSMtg7P/O3Z4bJSoxNV49s1xg0jJTc2VKeQVlYf2UC50jIQLJmODd897hbzMXdyeMvUw20Ql8ZkkldMEweaaaJF3/tHVVAzBK0rYBTby8O0NH5IjcOUnETYSvyBAHazkJA4ol/MwnY50OWFeGJ2EoueJEmC6xz250MNr9FZf+9jVgoOW3G60NSxnm/jU1nhuy5v6ls5wYk8iTL/sD4jiu39oKFcueZWZEgUqdY1XTarMJMF5y3MM4jxhIFosOoT064t11vAdOI=";
    unlockCode.len = strlen(unlockCode.str);
    ret = FSCRT_License_UnlockLibrary(&license_id, &unlockCode);
    if (ret != FSCRT_ERRCODE_SUCCESS) {
        NSLog(@"The license is wrong! SDK Library initializatoin failed!\n");
        FSCRT_Library_DestroyMgr();
        free(m_sdkMemory);
        m_sdkMemory = NULL;
        return NO;
    }
    
    //Initialize PDF module before you use any functions of PDF module
    FSCRT_PDFModule_Initialize();
    
    g_AppHandler.OnRecover = g_OnRecover;
    g_AppHandler.clientData = &g_AppHandler;
    g_AppHandler.OnEvent = g_OnEvent;
    g_AppHandler.OnOutOfMemory = g_OnOutOfMemory;
    g_AppHandler.CallFunction = g_CallFunction;
    FSCRT_Library_SetAppHandler(&g_AppHandler);
    
    return YES;
}

- (void)releasePDFSDK
{
    FSCRT_PDFModule_Finalize();
    FSCRT_Library_DestroyMgr();
    free(m_sdkMemory);
    m_sdkMemory = NULL;
}

- (void) releasePDFPage:(FSCRT_PAGE) page
{
    FSPDF_Page_Clear(page);
}


- (void)setCurPage:(FSCRT_PAGE)pdfpage
{
	m_current_page = pdfpage;
}
-(NSInteger)pageCount
{
    return m_pageCount;
}

-(BOOL) openPDFDocument: (char*) filepath
{
    
    if (m_fpdfdoc != NULL) {
        FSPDF_Doc_Close(m_fpdfdoc);
        m_fpdfdoc = NULL;
        m_pfilepath = NULL;
    }
    
    m_pageCount = 0;
    m_pfilepath = filepath;
    FSCRT_BSTR bstr;
    bstr.str = filepath;
    bstr.len = strlen(filepath);
    
    FSCRT_FILE file;
    FS_RESULT ret = FSCRT_File_CreateFromFileName(&bstr, FSCRT_FILEMODE_READONLY, &file);
    if (ret != FSCRT_ERRCODE_SUCCESS)
        return FALSE;
    
    ret = FSPDF_Doc_StartLoad(file, NULL, &m_fpdfdoc, NULL);
    if (ret == FSCRT_ERRCODE_SUCCESS)
    {
        FSPDF_Doc_CountPages(m_fpdfdoc, &m_pageCount);
        return TRUE;
    }
    
    return FALSE;
}

- (void)closePDFDocument
{
    
    if (m_fpdfdoc != NULL) {
        FSPDF_Doc_Close(m_fpdfdoc);
        m_fpdfdoc = NULL;
        m_pfilepath = NULL;
    }
}

- (FSCRT_PAGE) getPDFPage:(NSUInteger) aindex
{
    FSCRT_PAGE page = NULL;
    FS_RESULT ret = FSPDF_Doc_GetPage(m_fpdfdoc, aindex, &page);
    if (ret != FSCRT_ERRCODE_SUCCESS)
        return NULL;
    
    FSCRT_PROGRESS progress = NULL;
    ret = FSPDF_Page_StartParse(page, FSPDF_PAGEPARSEFLAG_NORMAL, &progress);
    if (ret != FSCRT_ERRCODE_FINISHED) {
        if (ret != FSCRT_ERRCODE_SUCCESS) {
            FSPDF_Page_Clear(page);
            return NULL;
        }
        
        ret = FSCRT_ERRCODE_TOBECONTINUED;
        while (ret == FSCRT_ERRCODE_TOBECONTINUED || ret == FSCRT_ERRCODE_ROLLBACK) {
            ret = FSCRT_Progress_Continue(progress, NULL);
        }
        FSCRT_Progress_Release(progress);
    }
    
    if (ret != FSCRT_ERRCODE_FINISHED) {
        FSPDF_Page_Clear(page);
        return NULL;
    }
    
    return page;
}

- (FSCRT_PAGE) getCurPDFPage
{
	//Get the pdf page which is current viewing.
	return m_current_page;
}


- (CGPoint)pointInPageIndex:(NSUInteger)pageIndex
                  fromPoint:(CGPoint)point
                 inViewSize:(CGSize)szView
{
    
    FSCRT_MATRIX matrix;
    FSCRT_PAGE currentPage = [self getPDFPage:pageIndex];
	FSPDF_Page_GetMatrix(currentPage, 0, 0, szView.width, szView.height, 0, &matrix);
    
    FSCRT_MATRIX devmatrix;
    FSCRT_Matrix_GetReverse(&matrix, &devmatrix);
    FSCRT_Matrix_TransformPointF(&devmatrix, &(point.x), &(point.y));
	
	return CGPointMake(point.x, point.y);
//    
//	FS_POINT pagePoint;
//	pagePoint.x = point.x;
//	pagePoint.y = point.y;
//    FSCRT_PAGE currentPage = [self getPDFPage:pageIndex];
////    FS_FLOAT sizeX = 0;
////    FS_FLOAT sizeY = 0;
////    FPDF_Page_GetSize(currentPage, &sizeX, &sizeY);
////	pagePoint.x = point.x / szView.width * sizeX;
////	pagePoint.y = point.y / szView.height * sizeY;
//	FPDF_Page_DeviceToPagePoint(currentPage, 0, 0, szView.width, szView.height, 0, &pagePoint);
////	FPDF_Page_DeviceToPagePoint(currentPage, 0, 0, sizeX, sizeY, 0, &pagePoint);
//	return CGPointMake(pagePoint.x, pagePoint.y);
}

- (void)AddStampAnnotWithPath:(NSString *)filePath
                    leftTopPoint:(CGPoint)leftTopPoint
                rightBottomPoint:(CGPoint)rightBottomPoint
{
    FS_RESULT result = FSPDF_Page_LoadAnnots(m_current_page);
    if (FSCRT_ERRCODE_INVALIDLICENSE == result)
        return;
    if (FSCRT_ERRCODE_SUCCESS != result)
    {
        return;
    }
	//Add image as a stamp.
//    unsigned char* buf = (unsigned char *)imgData.bytes;
//	FSCRT_IMAGE image = NULL;
//	FSCRT_FILE file = FSDK_OpenFile((inputFile + "/" + "FoxitLogo.jpg").c_str(),"rb");
//	FSCRT_Image_LoadFromFile(file,&image);
//	FSPDF_Annot_SetStamp(annot,image,0);
//	FSCRT_Image_Release(image);
//	FSCRT_File_Release(file);
//    
    FS_INT32 count = 0;
    FSPDF_Annot_GetCount(m_current_page, NULL, &count);
    
    CGPoint pt = CGPointMake(100.0f, 100.0f);
//    FSCRT_RECTF rect = {pt.x - 5, pt.y + 50, pt.x + 50, pt.y - 3};
    FSCRT_RECTF rect = {leftTopPoint.x, leftTopPoint.y, rightBottomPoint.x, rightBottomPoint.y};
    FSCRT_BSTR bsAnnotType;
	FSCRT_BStr_Init(&bsAnnotType);
	FSCRT_BStr_Set(&bsAnnotType, FSPDF_ANNOTTYPE_STAMP, (FS_DWORD)strlen(FSPDF_ANNOTTYPE_STAMP));
    
    
	FS_RESULT ret = FSCRT_ERRCODE_SUCCESS;
	FSCRT_ANNOT annot = NULL;
	ret = FSPDF_Annot_Add(m_current_page, &rect, &bsAnnotType, NULL, count, &annot);
    FSCRT_BStr_Clear(&bsAnnotType);
    if (FSCRT_ERRCODE_SUCCESS != ret)
        return;
    
	//Add image as a stamp.
	FSCRT_IMAGE image = NULL;
	FSCRT_FILE fileStamp = FSDK_OpenFile([filePath UTF8String],"rb");
	FSCRT_Image_LoadFromFile(fileStamp,&image);
	FSPDF_Annot_SetStamp(annot,image,0);
	FSCRT_Image_Release(image);
	FSCRT_File_Release(fileStamp);
    FSPDF_Annot_ResetAppearance(annot);
    
    const char* file = [self.desFilePath UTF8String];
    FILE* fp = fopen(file, "wb");
//    string strOutputFile = [self.desFilePath UTF8String];
    ret = FSDK_SavePDFFile(m_fpdfdoc , [self.desFilePath UTF8String]);
    fclose(fp);

    return ;
//    
//    unsigned char* buf = (unsigned char *)imgData.bytes;
//	FPDF_ANNOT_STAMPINFO stampInfo;
//	stampInfo.color = 0xff0000;
//	stampInfo.size = sizeof(stampInfo);
//    //    CGPoint ptLeftTop = CGPointMake(223,631);
//    //    CGPoint ptRightBottom = CGPointMake(643, 231);
//    
//    FS_RECTF rect = {leftTopPoint.x, leftTopPoint.y, rightBottomPoint.x ,rightBottomPoint.y};
//	stampInfo.rect = rect;
//	stampInfo.imgtype = FPDF_IMAGETYPE_PNG; //bmp=1 jpg = 2
//	stampInfo.imgdatasize = imgData.length;
//	stampInfo.imgdata = (unsigned char*)buf;
//    
//    FPDF_Annot_Add(m_current_page, FPDF_ANNOTTYPE_STAMP, &stampInfo, sizeof(stampInfo), (FPDF_ANNOT*)&m_nAnnotIndex);
//    m_nAnnotIndex++;
//    const char* file = [self.desFilePath UTF8String];
//    FILE* fp = fopen(file, "wb");
//    FS_FILEWRITE fw;
//    fw.clientData = fp;
//    fw.Flush = FSFileWrite_Flush;
//    fw.GetSize = FSFileWrite_GetSize;
//    fw.WriteBlock = FSFileWrite_WriteBlock;
//    FPDF_Doc_SaveAs(m_fpdfdoc, &fw, FPDF_SAVEAS_INCREMENTAL, NULL);
//    fclose(fp);
    
    
}

@end
