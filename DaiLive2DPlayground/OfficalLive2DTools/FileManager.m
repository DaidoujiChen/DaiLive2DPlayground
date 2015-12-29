/*
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *
 *  Modify By DaidoujiChen https://github.com/DaidoujiChen
 *
 */

#import "FileManager.h"
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/glext.h>

@implementation FileManager

#pragma mark - Private Class Method

+ (NSString *)resourcePath {
    return [NSBundle mainBundle].bundlePath;
}

+ (NSString *)documentPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

#pragma mark - Class Method

// 從 resource folder 下讀取檔案 (for NSString)
+ (NSData *)openBundle:(NSString *)fileName {
    NSString *filePath = [[self resourcePath] stringByAppendingPathComponent:fileName];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    return data;
}

// 從 resource folder 下讀取檔案 (for const char)
+ (NSData *)openBundleWithCString:(const char *)fileName {
    return [self openBundle:[NSString stringWithCString:fileName encoding:NSUTF8StringEncoding]];
}

// 從 document folder 下讀取檔案 (for NSString)
+ (NSData *)openDocuments:(NSString *)fileName {
    NSString *filePath = [[self documentPath] stringByAppendingPathComponent:fileName];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    return data;
}

// 從 document folder 下讀取檔案 (for const char)
+ (NSData *)openDocumentsWithCString:(const char *)fileName {
    return [self openDocuments:[NSString stringWithCString:fileName encoding:NSUTF8StringEncoding]];
}

// 回傳該檔案的 resource path
+ (const char *)pathForResource:(const char *)fileName {
    NSString *filePath = [[self resourcePath] stringByAppendingPathComponent:[NSString stringWithCString:fileName encoding:NSUTF8StringEncoding]];
    return filePath.UTF8String;
}

// 回傳該檔案的 url path
+ (NSURL *)fileURLWithCString:(const char *)fileName {
    NSString *filePath = [[self resourcePath] stringByAppendingPathComponent:[NSString stringWithCString:fileName encoding:NSUTF8StringEncoding]];
	return [NSURL fileURLWithPath:filePath];
}


// 讀取一張圖片, 轉成 GLuint
+ (GLuint)loadGLTexture:(NSString *)fileName {
	GLuint texture;
	UIImage *image = [UIImage imageNamed:fileName];
    
    // 如果讀取不到圖片, 回傳 0
	if (!image) {
		return 0;
	}
	
	CGImageRef imageRef = image.CGImage ;
	size_t width = CGImageGetWidth(imageRef);
	size_t height = CGImageGetHeight(imageRef);
	
	// ビットマップデータを用意します (OpenGL 看不懂 O3O)
	GLubyte *imageData = (GLubyte *)calloc(width * height * 4, 1);
	CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(imageContext, CGRectMake(0, 0, (float)width, (float)height), imageRef);
	CGContextRelease(imageContext);
    
	// OpenGL用のテクスチャを生成します (OpenGL 看不懂 O3O)
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	free(imageData);
	
	GLenum error = glGetError();
	if (error) {
        NSLog(@"Load Texture Error : %d", error);
	}
	
	// 作成したテクスチャを返します
	return texture;
}

@end
