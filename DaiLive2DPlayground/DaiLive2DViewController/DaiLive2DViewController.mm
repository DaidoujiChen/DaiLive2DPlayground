//
//  DaiLive2DViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/17.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "DaiLive2DViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import "Live2D.h"
#import "Live2DModelIPhone.h"
#import "util/UtSystem.h"

using namespace live2d;

@interface DaiLive2DViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic) Live2DModelIPhone *live2DModel;

@property (nonatomic, assign) BOOL isEyeClosing;
@property (nonatomic, assign) double eyeSpeed;

@end

@implementation DaiLive2DViewController

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    CGFloat modelWidth = self.live2DModel->getCanvasWidth();
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    glLoadIdentity();
    
    double value = -self.scale;
    double left = self.position.x - value;
    double right = (modelWidth + self.position.x) + value;
    double bottom = (((modelWidth + value) / (width / height)) + self.position.y) + value;
    double top = self.position.y - value;
    glOrthof(left, right, bottom, top, 0.5, -0.5);
    
    l2d_int64 time = UtSystem::getUserTimeMSec();
    double globalTime = time / 1000.0;
    self.live2DModel->setParamFloat("PARAM_ANGLE_Z", 30.0 * sin(globalTime));
    self.live2DModel->setParamFloat("PARAM_BODY_ANGLE_Z", 10.0 * sin(globalTime));
    self.live2DModel->setParamFloat("PARAM_HAIR_FRONT", sin(globalTime));
    self.live2DModel->setParamFloat("PARAM_HAIR_BACK", sin(globalTime));
    self.live2DModel->setParamFloat("PARAM_BREATH", (cos(globalTime) + 1.0) / 2.0);
    self.live2DModel->setParamFloat("PARAM_BUST_Y", cos(globalTime));
    
    if ((sin(globalTime) + 1.0) >= 1.9 && !self.isEyeClosing) {
        self.isEyeClosing = YES;
        self.eyeSpeed = (arc4random() % 200 + 100);
    }
    else if (self.isEyeClosing) {
        double eyeTime = time / self.eyeSpeed;
        self.live2DModel->setParamFloat("PARAM_EYE_L_OPEN", sin(eyeTime) + 1.0);
        self.live2DModel->setParamFloat("PARAM_EYE_R_OPEN", sin(eyeTime) + 1.0);
        if ((sin(eyeTime) + 1.0) >= 1.9) {
            self.isEyeClosing = NO;
        }
    }
    
    self.live2DModel->update();
    self.live2DModel->draw();
}

#pragma mark - private instance method

#pragma mark * OpenGLES

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark * live2d model textures

- (NSArray *)textures {
    return @[ @"Haru/haru.1024/texture_00", @"Haru/haru.1024/texture_01", @"Haru/haru.1024/texture_02" ];
}

#pragma mark * init live2d model

- (void)setupModel {
    NSString *modelNamed = @"Haru/haru";
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:modelNamed ofType:@"moc"];
    self.live2DModel = Live2DModelIPhone::loadModel(modelPath.UTF8String);
    
    for (int index = 0; index < self.textures.count; index++) {
        NSString *imageNamed = self.textures[index];
        NSString *texturePath = [[NSBundle mainBundle] pathForResource:imageNamed ofType:@"png"];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:@{ GLKTextureLoaderApplyPremultiplication: @(YES), GLKTextureLoaderGenerateMipmaps: @(YES) } error:nil];
        int glTexNo = textureInfo.name;
        self.live2DModel->setTexture(index, glTexNo);
    }
    self.live2DModel->setParamFloat("PARAM_EYE_L_SMILE", 1.0);
    self.live2DModel->setParamFloat("PARAM_EYE_R_SMILE", 1.0);
    self.live2DModel->setParamFloat("PARAM_ARM_L_A", -1.0);
    self.live2DModel->setParamFloat("PARAM_ARM_R_A", -1.0);
    self.isEyeClosing = NO;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    self.scale = 1.0;
    self.position = CGPointZero;
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
        return;
    }
    
    // 設置畫面相關設定
    GLKView *view = (GLKView *)self.view;
     view.context = self.context;
     view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self setupGL];
    [self setupModel];
}

@end
