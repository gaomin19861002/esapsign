//
//  PDFDocument.h
//  demo_form_field
//
//  Created by Foxit on 12-2-7.
//  Copyright 2012 Foxit Software Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "include/fsdk.h"
@interface PDFDocument : NSObject {
    const char* m_pfilepath;
    NSInteger m_pageCount;
    void* m_pBuffer;
    FSCRT_FILE m_fileread;
    FSCRT_DOCUMENT m_fpdfdoc;
    FSCRT_FONTMAPPERHANDLER m_fontMapper;
    FS_LPVOID  m_sdkMemory;
    FSCRT_PAGE  m_current_page;
}
/** 文档存储位置 */
@property(nonatomic, copy)NSString      *desFilePath;



//Open the PDF document.
- (BOOL) openPDFDocument:(char*) file; 
//Close the PDF document.
- (void) closePDFDocument;

//Load the specified pdf page. 
- (FSCRT_PAGE) getPDFPage:(NSUInteger) aindex;
//Get the current displayed pdf page.
- (FSCRT_PAGE) getCurPDFPage;
//Render the pdf page to image, could render only a specified page area.
//- (FS_BITMAP) getPageImageByRect:(FPDF_PAGE) page p1:(int) nstartx p2:(int) nstarty p3:(int) sizex p4:(int) sizey p5:(int) bmWidth p6:(int) bmHeight;
//Release the loaded pdf page.
- (void) releasePDFPage:(FSCRT_PAGE) page;

//Initialise the fpdfemb library.
- (BOOL) initPDFSDK;
//Release the fpdfemb library.
- (void) releasePDFSDK;

- (void)setCurPage:(FSCRT_PAGE)pdfpage;

-(NSInteger)pageCount;

/**
 *  获取pdf文档中对应坐标
 *
 *  @param page   pdf当前页
 *  @param point  界面pdf视图中坐标
 *  @param szView 界面pdf视图窗体大小
 *
 *  @return 返回pdf中对应坐标
 */
- (CGPoint)pointInPageIndex:(NSUInteger)pageIndex
                  fromPoint:(CGPoint)point
                 inViewSize:(CGSize)szView;

/**
 *  添加签名
 *
 *  @param imgData          签名图片
 *  @param leftTopPoint     签名图片在当前页左上角点位置(pdf文件中位置，需要先进行坐标转换)
 *  @param rightBottomPoint 签名图片在当前页右下角点位置(pdf文件中位置，需要先进行坐标转换)
 *  @param filePath         文件存放路径
 */
- (void)AddStampAnnotWithPath:(NSString *)filePath
                    leftTopPoint:(CGPoint)leftTopPoint
                rightBottomPoint:(CGPoint)rightBottomPoint;

/**
 *  删除上一个签名
 */
//- (void)deleteAnnot;




@end
