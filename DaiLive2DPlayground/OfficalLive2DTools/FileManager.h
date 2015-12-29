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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

@interface FileManager : NSObject

+ (NSData *)openBundle:(NSString *)fileName;
+ (NSData *)openBundleWithCString:(const char *)fileName;
+ (NSData *)openDocuments:(NSString *)fileName;
+ (NSData *)openDocumentsWithCString:(const char *)fileName;
+ (const char *)pathForResource:(const char *)fileName;
+ (NSURL *)fileURLWithCString:(const char *)fileName;
+ (GLuint)loadGLTexture:(NSString *)fileName;

@end
