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

#import "SimpleImage.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "FileManager.h"

@interface SimpleImage ()

@property (nonatomic, assign) float imageLeft;
@property (nonatomic, assign) float imageRight;
@property (nonatomic, assign) float imageTop;
@property (nonatomic, assign) float imageBottom;

@property (nonatomic, assign) float uvLeft;
@property (nonatomic, assign) float uvRight;
@property (nonatomic, assign) float uvTop;
@property (nonatomic, assign) float uvBottom;

@property (nonatomic, assign) GLuint texture;

@end

@implementation SimpleImage

#pragma mark - Private Instance Method

- (void)setupInitValues {
    
    // 初期設定
    self.uvLeft = 0;
    self.uvRight = 1;
    self.uvBottom = 0;
    self.uvTop = 1;
    
    self.imageLeft = -1;
    self.imageRight = 1;
    self.imageBottom = -1;
    self.imageTop = 1;
}

#pragma mark - Instance Method

- (void)draw {
    float uv[] = { self.uvLeft, self.uvBottom, self.uvRight, self.uvBottom, self.uvRight, self.uvTop, self.uvLeft, self.uvTop };
    float ver[] = { self.imageLeft, self.imageTop, self.imageRight, self.imageTop, self.imageRight, self.imageBottom, self.imageLeft, self.imageBottom };
    short index[] = { 0, 1, 2, 0, 2, 3 };
    
    // 不懂的 OpenGL O3O
    glTexCoordPointer(2, GL_FLOAT, 0, uv);
    glVertexPointer(2, GL_FLOAT, 0, ver);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, index);
}

- (void)deleteTexture {
    glDeleteTextures(1, &_texture);
}

- (void)setDrawRect:(float)left right:(float)right bottom:(float)bottom top:(float)top {
    self.imageLeft = left;
    self.imageRight = right;
    self.imageBottom = bottom;
    self.imageTop = top;
}

- (void)setUVRect:(float)left right:(float)right bottom:(float)bottom top:(float)top {
    self.uvLeft = left;
    self.uvRight = right;
    self.uvBottom = bottom;
    self.uvTop = top;
}

#pragma mark - Life Cycle

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if(self) {
        self.texture = [FileManager loadGLTexture:path];
        [self setupInitValues];
    }
	
    return self;
}

@end
