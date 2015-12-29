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

@property (nonatomic, strong) Live2DInfoLoader *loader;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic) Live2DModelIPhone *live2DModel;

@end

@implementation DaiLive2DViewController

#pragma mark - Live2DInfoLoaderDelegate

- (void)setValue:(double)value forParameter:(NSString *)parameter {
    self.live2DModel->setParamFloat(parameter.UTF8String, value);
}

- (double)valueForParameter:(NSString *)parameter {
    return self.live2DModel->getParamFloat(parameter.UTF8String);
}

- (void)setValue:(double)value forPart:(NSString *)part {
    self.live2DModel->setPartsOpacity(part.UTF8String, value);
}

- (double)valueForPart:(NSString *)part {
    return self.live2DModel->getPartsOpacity(part.UTF8String);
}

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
    
    [self animateModelSetting:self.loader onTime:UtSystem::getUserTimeMSec()];
    
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

#pragma mark * init live2d model

- (void)setupModel {
    self.live2DModel = Live2DModelIPhone::loadModel(self.loader.model.UTF8String);
    for (int index = 0; index < self.loader.textures.count; index++) {
        NSString *texturePath = self.loader.textures[index];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:@{ GLKTextureLoaderApplyPremultiplication: @(YES), GLKTextureLoaderGenerateMipmaps: @(YES) } error:nil];
        int glTexNo = textureInfo.name;
        self.live2DModel->setTexture(index, glTexNo);
    }
    [self defaultModelSetting:self.loader];
}

#pragma mark - Method Need To Override

- (void)defaultModelSetting:(Live2DInfoLoader *)loader {
    NSAssert(0, @"必須重寫此 Method");
}

- (void)animateModelSetting:(Live2DInfoLoader *)loader onTime:(UInt64)time {
    NSAssert(0, @"必須重寫此 Method");
}

#pragma mark - Life Cycle

- (id)initFromBundlePath:(NSString *)path {
    self = [super init];
    if (self) {
        Live2D::init();
        self.loader = [[Live2DInfoLoader alloc] initFromBundlePath:path];
        if (!self.loader) {
            NSAssert(0, @"Loader Init Fail");
            return nil;
        }
        self.loader.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paused = NO;
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

- (void)dealloc {
    [self tearDownGL];
    Live2D::dispose();
}

@end
