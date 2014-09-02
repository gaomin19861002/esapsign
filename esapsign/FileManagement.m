//
//  FileManagement.m
//  esapsign
//
//  Created by Suzic on 14-8-20.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "FileManagement.h"

#import "NSArray+Additions.h"
#import "Util.h"
#import "UIImage+Additions.h"

@implementation FileManagement

+ (NSString *)getCachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

// document目录
+ (NSString *)getDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

// 删除一个文件
+ (BOOL)removeFile:(NSString *)strFilePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
	BOOL find = [manager fileExistsAtPath:strFilePath];
	if (find) { 
        find = [manager removeItemAtPath:strFilePath error:nil];
    }
    return find;
}

// 删除一个文件夹
+ (BOOL)removeFolder:(NSString *)strFolderName
{
    NSFileManager *manager = [NSFileManager defaultManager];
	BOOL find = [manager fileExistsAtPath:strFolderName];
	if (find) { 
        find = [manager removeItemAtPath:strFolderName error:nil];
    }
    return find;
}

// 拷贝资源目录文件到caches目录
+ (BOOL)copyResourceFileToCachesDirectory:(NSString *)strFileName
{
    if (![strFileName isKindOfClass:[NSString class]] || [strFileName length] == 0) {
        return NO;
    }
    NSString    *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:strFileName ];
    BOOL bResult = NO;
	NSString *destPath = [[FileManagement getCachesDirectory] stringByAppendingPathComponent: strFileName];
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL find = [manager fileExistsAtPath:destPath];
	if (!find) { 
		NSError *error;
		bResult = [manager copyItemAtPath:srcPath toPath:destPath error:&error];
		if (!bResult) {
			NSLog(@"Failed to copy files '%@'.", [error localizedDescription]);
		}
	}
	return bResult;
}

// 拷贝资源目录文件到caches目录
+ (BOOL)copyResourceFileToDocumentDirectory:(NSString *)strFileName
{
    if (![strFileName isKindOfClass:[NSString class]] || [strFileName length] == 0)
    {
        return NO;
    }
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:strFileName];
    BOOL bResult = NO;
	NSString *destPath = [[FileManagement getDocumentDirectory] stringByAppendingPathComponent: strFileName];
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL find = [manager fileExistsAtPath:destPath];
	if (!find)
    {
		NSError *error;
		bResult = [manager copyItemAtPath:srcPath toPath:destPath error:&error];
		if (!bResult) {
			NSLog(@"Failed to copy files '%@'.", [error localizedDescription]);
		}
	}
	return bResult;
}

// 拷贝资源目录下子目录到caches目录
+ (BOOL)copyResourceSubDirToCachesDirectory:(NSString *)subPath
{
    if (![subPath isKindOfClass:[NSString class]] || [subPath length] == 0)
    {
        return NO;
    }
    NSFileManager *manager = [NSFileManager defaultManager]; 
	NSString *srcIconsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:subPath];
	NSString *destIconsPath = [[FileManagement getCachesDirectory] stringByAppendingPathComponent: subPath];
	[manager createDirectoryAtPath:destIconsPath withIntermediateDirectories:YES attributes:nil error:nil];
	// 创建路径
	for(NSString *subPath in [manager subpathsAtPath:srcIconsPath])
    {
		if ([[subPath pathExtension] isEqualToString:@""])
		{
			NSString *fullPath = [NSString stringWithFormat:@"%@/%@", destIconsPath, subPath];
			[manager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		else {
			//CLog(@"file:%@", subPath);
		}
	}
	NSError *error;
	for (NSString *filename in [manager enumeratorAtPath: srcIconsPath])
    {
		if (![[filename pathExtension] isEqualToString:@""])
        {
			NSString *desFile = [NSString stringWithFormat:@"%@/%@", destIconsPath, filename];
			BOOL find = [manager fileExistsAtPath:desFile];
			if (!find)
            {
				NSString *srcFile = [NSString stringWithFormat:@"%@/%@",srcIconsPath,filename];
				BOOL success = [manager copyItemAtPath:srcFile toPath:desFile error:&error];
				if (!success) {
					NSLog(@"Failed to copy files '%@'.", [error localizedDescription]);
				}
			}
		}
	} 
	return YES;
}

@end


@implementation FileManagement (Additions)

+ (NSString *)signsImageCachedFolder
{
    NSString *strSigns = [[FileManagement getCachesDirectory] stringByAppendingPathComponent:@"SignsImageCached"];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL bIsDir = YES;
    if (![manager fileExistsAtPath:strSigns isDirectory:&bIsDir]) {
        [manager createDirectoryAtPath:strSigns withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return  strSigns;
}

/**
 *  获取本地签名
 *
 *  @return 返回所有签名图片列表
 */
+ (NSArray *)allDefaultSigns
{
    NSString *signCachedFolder = [FileManagement signsImageCachedFolder];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *arrImages = [[NSMutableArray alloc] initWithCapacity:1];
	for (NSString *filename in [manager enumeratorAtPath: signCachedFolder])
    {
		if (![[filename pathExtension] isEqualToString:@""])
        {
            NSString *srcFile = [NSString stringWithFormat:@"%@/%@",signCachedFolder,filename];
            UIImage *imageItem = [UIImage imageNamed:srcFile];
            [imageItem setImgURL:srcFile];
            [arrImages addObjectOrNil:imageItem];
		}
	}
    return arrImages;
}

/**
 *  添加默认签名
 *
 *  @param signImage 新签名图片
 *
 *  @return 返回执行结果
 */
+ (BOOL)addDefaultSignWithImage:(UIImage *)signImage
{
    if (signImage == nil)
    {
        return NO;
    }
    NSString *uuidImage = [Util generalUUID];
    NSLog(@"%s, %@, %@", __FUNCTION__, [Util generalUUID], [Util generalUUID]);
    NSData *dataImage = UIImagePNGRepresentation(signImage);
    NSString *signCachedFolder = [FileManagement signsImageCachedFolder];
    NSString *desFile = [signCachedFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", uuidImage]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:desFile isDirectory:NO]) {
        [manager removeItemAtPath:desFile error:nil];
    }
    BOOL bResult = [dataImage writeToFile:desFile atomically:YES];
    if (bResult) {
        [signImage setImgURL:desFile];
    }
    return bResult;
}

/**
 *  删除签名
 *
 *  @param signImageToBeDel 将要被删除的签名
 *
 *  @return 返回执行结果
 */
+(BOOL)deleteDefaultSignWithImage:(UIImage *)signImageToBeDel
{
    NSString *desFile = [signImageToBeDel imgURL];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL bResult = YES;
    if ([manager fileExistsAtPath:desFile isDirectory:NO]) {
        bResult = [manager removeItemAtPath:desFile error:nil];
    }
    return bResult;
}
@end