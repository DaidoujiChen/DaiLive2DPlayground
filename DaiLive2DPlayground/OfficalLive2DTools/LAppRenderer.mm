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

#import "LAppRenderer.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "LAppDefine.h"
#import "LAppModel.h"
#import "LAppLive2DManager.h"
#import "SimpleImage.h"
#import "OffscreenImage.h"

using namespace live2d::framework;

@interface LAppRenderer ()

@property (nonatomic) LAppLive2DManager *internalDelegate;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) BOOL isNeedInitRender;

// The pixel dimensions of the CAEAGLLayer
@property (nonatomic, assign) GLint viewportWidth;
@property (nonatomic, assign) GLint viewportHeight;

// The OpenGL names for the framebuffer and renderbuffer used to render to this view
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;

// 加速度
@property (nonatomic, assign) float accelX;
@property (nonatomic, assign) float accelY;

// 背景
@property (nonatomic, strong) SimpleImage *background;

@end

@implementation LAppRenderer

#pragma mark - Private Instance Method

- (void)setupInitValues {
    self.isNeedInitRender = YES;
    
    // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
    glGenFramebuffersOES(1, &_defaultFramebuffer);
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    self.accelX = 0;
    self.accelY = 0;
}

/*
 * 背景の設定
 * @param gl
 */
- (void)setupBackground {
    NSString *path = [NSString stringWithCString:BACK_IMAGE_NAME encoding:NSUTF8StringEncoding];
    if (LAppDefine::DEBUG_LOG) {
        NSLog( @"background : %@", path);
    }
    self.background = [[SimpleImage alloc] initWithPath:path];
    
    // 描画範囲。画面の最大表示範囲に合わせる
    [self.background setDrawRect:VIEW_LOGICAL_MAX_LEFT right:VIEW_LOGICAL_MAX_RIGHT bottom:VIEW_LOGICAL_MAX_BOTTOM top:VIEW_LOGICAL_MAX_TOP];
}

-(void)renderInit {
    
    // OpenGL初期化
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, self.defaultFramebuffer);
    
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"viewport w:%d h:%d", self.viewportWidth, self.viewportHeight);
    }
    
    // Viewportの設定。デバイスと論理スクリーンの表示範囲をあわせる。
    glViewport(0, 0, self.viewportWidth, self.viewportHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // ここで指定した範囲が、表示される
    // glOrthof( Xの左端, Xの右端, Yの下端, Yの上端, Zの手前, Zの奥);
    L2DViewMatrix *viewMatrix = self.internalDelegate->getViewMatrix();
    glOrthof(viewMatrix->getScreenLeft(), viewMatrix->getScreenRight(), viewMatrix->getScreenBottom(), viewMatrix->getScreenTop(), 0.5f, -0.5f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // 背景色
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    [OffscreenImage createFrameBuffer:self.viewportWidth height:self.viewportHeight defaultFrameBuffer:self.defaultFramebuffer];
}

// no one call this method
- (void)setAccel:(float)x y:(float)y {
    self.accelX = x;
    self.accelY = y;
}

#pragma mark - Instance Method

- (void)render {
    
    if (self.viewportWidth <= 0 || self.viewportHeight <= 0 ) {
        return;
    }
    
    // OpenGLのコンテキストを設定
    [EAGLContext setCurrentContext:self.context];
    
    if (self.isNeedInitRender) {
        [self renderInit];
        self.isNeedInitRender = NO;
    }
    
    // 画面をクリア
    glClear(GL_COLOR_BUFFER_BIT);
    
    // OpenGLをLive2D用の設定にする
    // デプステストを行わない
    glDisable(GL_DEPTH_TEST);
    
    // カリングを行わない
    glDisable(GL_CULL_FACE);
    
    // ブレンドを行う
    glEnable(GL_BLEND);
    
    // ブレンド方法の指定
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable( GL_TEXTURE_2D );
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    // テクスチャのクランプ指定
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glColor4f(1, 1, 1, 1);
    
    // 背景とモデルの描画
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // ========== Push ==========
    glPushMatrix();
    {
        // 画面の拡大縮小、移動を設定
        L2DViewMatrix *viewMatrix = self.internalDelegate->getViewMatrix();
        glMultMatrixf(viewMatrix->getArray());
        
        //  背景の描画
        if (self.background) {
            
            // ========== Push ==========
            glPushMatrix();
            {
                // デバイスの回転による揺れ幅
                float SCALE_X = 0.25f;
                float SCALE_Y = 0.1f;
                
                // 揺れ
                glTranslatef(-SCALE_X  * self.accelX, SCALE_Y * self.accelY, 0);
                
                [self.background draw];
            }
            glPopMatrix();
            // ========== Pop ==========
        }
        
        // キャラの描画
        LAppModel *model = self.internalDelegate->getModel();
        if (model->isInitialized() && !model->isUpdating()) {
            model->update();
            model->draw();
        }
    }
    glPopMatrix();
    // ========== Pop ==========
    
    // 描画先を指定して描画開始
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.colorRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {
    
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, self.colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_viewportWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_viewportHeight);
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    // 再度初期化が走るようにする
    self.isNeedInitRender = YES;
    return YES;
}

- (void)setDelegate:(LAppLive2DManager *)delegate {
    self.internalDelegate = delegate;
}

// 別スレッドでテクスチャをロードするような場合に使用する
- (void)setContextCurrent {
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - Life Cycle

// Create an ES 1.1 context
- (id)init {
    self = [super init];
	if (self) {
		self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            return nil;
        }
        [self setupInitValues];
        [self setupBackground];
	}
	return self;
}


- (void)dealloc {
	[OffscreenImage releaseFrameBuffer];
	[self.background deleteTexture];
	
	// Tear down GL
	if (self.defaultFramebuffer) {
		glDeleteFramebuffersOES(1, &_defaultFramebuffer);
		self.defaultFramebuffer = 0;
	}
	
	if (self.colorRenderbuffer) {
		glDeleteRenderbuffersOES(1, &_colorRenderbuffer);
		self.colorRenderbuffer = 0;
	}
	
	// Tear down context
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
	self.delegate = nil;
}

@end
