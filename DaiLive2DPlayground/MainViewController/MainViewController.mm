//
//  MainViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/16.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "MainViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import "Live2D.h"
#import "Live2DModelIPhone.h"
#import "util/UtSystem.h"

using namespace live2d;

@interface MainViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic) Live2DModelIPhone *live2DModel;
@property (nonatomic, assign) CGFloat headX;
@property (nonatomic, assign) CGFloat headY;
@property (nonatomic, assign) CGFloat headZ;

@end

@implementation MainViewController

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    double t = UtSystem::getUserTimeMSec() / 1000.0 ;
    self.live2DModel->setParamFloat("PARAM_ANGLE_X", 30 * sin(t));
    self.live2DModel->update();
    self.live2DModel->draw();
}

#pragma mark - private instance method

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

- (NSArray *)textures {
    return @[ @"texture_00", @"texture_01", @"texture_02" ];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
        return;
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self setupGL];
    
    NSString *modelNamed = @"haru";
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:modelNamed ofType:@"moc"];
    self.live2DModel = Live2DModelIPhone::loadModel(modelPath.UTF8String);
    
    for (int index = 0; index < self.textures.count; index++) {
        NSString *imageNamed = self.textures[index];
        NSString *texturePath = [[NSBundle mainBundle] pathForResource:imageNamed ofType:@"png"];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:@{ GLKTextureLoaderApplyPremultiplication: @(YES), GLKTextureLoaderGenerateMipmaps: @(YES) } error:nil];
        int glTexNo = textureInfo.name;
        self.live2DModel->setTexture(index, glTexNo);
    }
    
    CGFloat modelWidth = self.live2DModel->getCanvasWidth();
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    glOrthof(0, modelWidth, modelWidth / (width / height), 0, 0.5f, -0.5f);
}

@end
