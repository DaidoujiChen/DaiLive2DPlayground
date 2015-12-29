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

#import <objc/runtime.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OffscreenImage.h"
#import "FileManager.h"

@interface OffscreenImageValues : NSObject

@property (nonatomic, assign) GLuint offscreenTexture;
@property (nonatomic, assign) GLuint offscreenFrameBuffer;
@property (nonatomic, assign) float viewportWidth;
@property (nonatomic, assign) float viewportHeight;
@property (nonatomic, assign) GLuint defaultFrameBuffer;
@property (nonatomic, assign) float size;

@end

@implementation OffscreenImageValues

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        self.size = 512;
    }
    return self;
}

@end

@implementation OffscreenImage

#pragma mark - Private Class Method

+ (OffscreenImageValues *)values {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [OffscreenImageValues new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Class Method

+ (void)createFrameBuffer:(float)width height:(float)height defaultFrameBuffer:(GLuint)defaultFrameBuffer {
	[self values].viewportWidth = width;
	[self values].viewportHeight = height;
	[self values].defaultFrameBuffer = defaultFrameBuffer;
	
	// OpenGL用のテクスチャを生成します
    GLuint offscreenTexture = [self values].offscreenTexture;
	glGenTextures(1, &offscreenTexture);
	glBindTexture(GL_TEXTURE_2D, offscreenTexture);
    [self values].offscreenTexture = offscreenTexture;
    
    float size = [self values].size;
	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size, size, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

    GLuint offscreenFrameBuffer = [self values].offscreenFrameBuffer;
	glGenFramebuffersOES(1, &offscreenFrameBuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, offscreenFrameBuffer);
	glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, offscreenTexture, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
    [self values].offscreenFrameBuffer = offscreenFrameBuffer;

	//  FramebufferObjectの有効性チェック
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"Failed to create FBO file : %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    }
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, [self values].defaultFrameBuffer);
}


+ (void)releaseFrameBuffer {
    GLuint offscreenTexture = [self values].offscreenTexture;
	glDeleteTextures(1, &offscreenTexture);
    [self values].offscreenTexture = offscreenTexture;
}


+ (void)setOffscreen {
    float size = [self values].size;
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, [self values].offscreenFrameBuffer);
	glViewport(0, 0, size, size);
}


+ (void)setOnscreen {
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, [self values].defaultFrameBuffer);
	glViewport(0, 0, [self values].viewportWidth, [self values].viewportHeight);
}

+ (void)drawDisplay:(float)opacity {
	float uv[] = { 0, 1, 1, 1, 1, 0, 0, 0 };
	float ratio = [self values].viewportHeight / [self values].viewportWidth;
    float vertex[] = { -1, ratio, 1, ratio, 1, -ratio, -1, -ratio };
    short index[] = { 0, 1, 2, 0, 2, 3 };
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(opacity, opacity, opacity, opacity);
	glBindTexture(GL_TEXTURE_2D , [self values].offscreenTexture);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, uv);
	glVertexPointer(2, GL_FLOAT, 0, vertex);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, index);
}

@end
