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

#import "LAppView.h"
#import "LAppDefine.h"
#import "TouchManager.h"
#import "AccelHelper.h"
#import "LAppRenderer.h"
#import "LAppLive2DManager.h"


#define INTERVAL_SEC (1.0 / 30)

using namespace live2d::framework;

@interface LAppView ()

@property (nonatomic, assign) NSTimeInterval animationFrameInterval;

@property (nonatomic) LAppLive2DManager *internalDelegate;
@property (nonatomic) live2d::framework::L2DMatrix44 *deviceToScreen;

// 画面の拡大縮小、移動用の行列
@property (nonatomic) live2d::framework::L2DViewMatrix *viewMatrix;

@property (nonatomic, strong) LAppRenderer *renderer;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSTimer *animationTimer;

// 加速度センサの制御
@property (nonatomic, strong) AccelHelper *accelHelper;

// ピンチなど
@property (nonatomic, strong) TouchManager* touchMgr;

@end

@implementation LAppView

#pragma mark - Private Class Method

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Private Instance Method

- (void)drawView {
    [self.accelHelper update];
    
    if (self.accelHelper.shake > 0.8f) {
        if(LAppDefine::DEBUG_LOG) {
            NSLog(@"shake event");
        }
        
        // シェイクモーションを起動する
        self.internalDelegate->shakeEvent();
        [self.accelHelper resetShake];
    }
    
    self.internalDelegate->setAccel(self.accelHelper.accelX, self.accelHelper.accelY, self.accelHelper.accelZ);
    [self.renderer render];
}

// 別スレッドでテクスチャをロードするような場合に使用する
- (void)setContextCurrent {
    [self.renderer setContextCurrent];
}

- (void)updateViewMatrix:(float)dx dy:(float)dy cx:(float)cx cy:(float)cy scale:(float)scale {
    bool isMaxScale = self.viewMatrix->isMaxScale();
    bool isMinScale = self.viewMatrix->isMinScale();
    
    // 拡大縮小
    self.viewMatrix->adjustScale(cx, cy, scale);
    
    // 移動
    self.viewMatrix->adjustTranslate(dx, dy);
    
    // 画面が最大になったときのイベント
    if(!isMaxScale) {
        if(self.viewMatrix->isMaxScale()) {
            self.internalDelegate->maxScaleEvent();
        }
    }
    
    // 画面が最小になったときのイベント
    if(!isMinScale) {
        if(self.viewMatrix->isMinScale()) {
            self.internalDelegate->minScaleEvent();
        }
    }
}

- (float)transformViewX:(float)deviceX {
    
    // 論理座標変換した座標を取得。
    float screenX = [self transformScreenX:deviceX];
    
    // 拡大、縮小、移動後の値。
    return self.viewMatrix->invertTransformX(screenX);
}

- (float)transformViewY:(float)deviceY {
    
    // 論理座標変換した座標を取得。
    float screenY = [self transformScreenY:deviceY];
    
    // 拡大、縮小、移動後の値。
    return self.viewMatrix->invertTransformY(screenY);
}

- (float)transformScreenX:(float)deviceX {
    return self.deviceToScreen->transformX(deviceX);
}

- (float)transformScreenY:(float)deviceY {
    return self.deviceToScreen->transformY(deviceY);
}

// 看起來又是一個沒人 call 的 method ?
- (void)setAnimationFrameInterval:(NSTimeInterval)frameInterval {
    
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1) {
        _animationFrameInterval = frameInterval;
        
        if (self.isAnimating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray<UITouch *> *touchArray = [NSMutableArray array];
    for (UITouch *t in touches) {
        [touchArray addObject:t];
    }
    
    if (touchArray.count == 1) {
        CGPoint point = [touchArray.firstObject locationInView:self];
        if (LAppDefine::DEBUG_TOUCH_LOG) {
            NSLog( @"touchesBegan x:%.0f y:%.0f", point.x, point.y);
        }
        [self.touchMgr touchesBegan:point];
        [self.nextResponder touchesBegan:touches withEvent:event];
        
    }
    else if (touchArray.count >= 2) {
        CGPoint point1 = [touchArray[0] locationInView:self];
        CGPoint point2 = [touchArray[1] locationInView:self];
        if (LAppDefine::DEBUG_TOUCH_LOG) {
            NSLog( @"touchesBegan x1:%.0f y1:%.0f x2:%.0f y2:%.0f", point1.x, point1.y, point2.x, point2.y);
        }
        [self.touchMgr touchesBegan:point1 to:point2];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray<UITouch *> *touchArray = [NSMutableArray array];
    for (UITouch *t in touches) {
        [touchArray addObject:t];
    }
    
    float screenX = [self transformScreenX:self.touchMgr.lastX];
    float screenY = [self transformScreenY:self.touchMgr.lastY];
    float viewX = [self transformViewX:self.touchMgr.lastX];
    float viewY = [self transformViewY:self.touchMgr.lastY];
    
    if (touchArray.count == 1) {
        CGPoint point = [touchArray.firstObject locationInView:self];
        
        if (LAppDefine::DEBUG_TOUCH_LOG) {
            NSLog( @"touchesMoved device{x:%.0f y:%.0f} screen{x:%.2f y:%.2f} view{x:%.2f y:%.2f}", point.x, point.y, screenX, screenY, viewX, viewY);
        }
        [self.touchMgr touchesMovedToPoint:point];
        
        // この値以上フリックしたらイベント発生
        const int FLICK_DISTANCE = 100;
        
        // フリックイベントの判定
        if (self.touchMgr.touchSingle && self.touchMgr.flipAvailable) {
            
            float flickDist = [self.touchMgr flickDistance];
            if (flickDist > FLICK_DISTANCE) {
                float startX = [self transformViewX:self.touchMgr.startX];
                float startY = [self transformViewY:self.touchMgr.startY];
                self.internalDelegate->flickEvent(startX, startY);
                [self.touchMgr disableFlick];
            }
        }
        
    }
    else if (touchArray.count >= 2) {
        
        // 前回のクリック位置に最も近いものを選びだす
        NSMutableArray *touches = [NSMutableArray array];
        for (int index = 0; index < touchArray.count; index++) {
            [touches addObject:[NSValue valueWithCGPoint:[touchArray[index] locationInView:self]]];
        }
        
        // iphone用 タッチ数が多い時にすべての点を受け取って自動判別する
        [self.touchMgr touchesMovedPath:touches];
        
        // 画面の拡大縮小、移動の設定
        float dx = self.touchMgr.deltaX * self.deviceToScreen->getScaleX();
        float dy = self.touchMgr.deltaY * self.deviceToScreen->getScaleY();
        float cx = self.deviceToScreen->transformX(self.touchMgr.lastX) * self.touchMgr.scale;
        float cy = self.deviceToScreen->transformY(self.touchMgr.lastY) * self.touchMgr.scale;
        float scale = self.touchMgr.scale;
        
        if(LAppDefine::DEBUG_TOUCH_LOG)NSLog( @"touchesMoved  dx:%.2f dy:%.2f cx:%.2f cy:%.2f scale:%.2f",dx,dy,cx,cy,scale);
        
        [self updateViewMatrix:dx dy:dy cx:cx cy:cy scale:scale];
        
    }
    self.internalDelegate->setDrag(viewX,viewY);
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(LAppDefine::DEBUG_TOUCH_LOG)NSLog( @"touchesEnded");
    self.internalDelegate->setDrag(0,0);
    UITouch* touch = [touches anyObject];
    if( [touch tapCount] == 1 )
    {
        // シングルタップ
        float x = self.deviceToScreen->transformX(self.touchMgr.lastX);// 論理座標変換した座標を取得。
        float y = self.deviceToScreen->transformY(self.touchMgr.lastY);// 論理座標変換した座標を取得。
        if (LAppDefine::DEBUG_LOG) NSLog( @"touchesBegan x:%.2f y:%.2f",x,y);
        self.internalDelegate->tapEvent( x, y );
    }
}

#pragma mark - Instance Method

- (void)startAnimation {
    if (!self.isAnimating) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"startAnimation");
        }
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:INTERVAL_SEC * self.animationFrameInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
        self.isAnimating = YES;
    }
}

- (void)stopAnimation {
    if (self.isAnimating) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"stopAnimation");
        }
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.isAnimating = NO;
    }
}

- (void)setDelegate:(LAppLive2DManager *)delegate {
    self.internalDelegate = delegate;
    [self.renderer setDelegate:delegate];
}

- (void)terminate {
    self.delegate = nil;
    self.accelHelper = nil;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    self.renderer = nil;
    self.touchMgr = nil;
    self.deviceToScreen = nil;
    self.viewMatrix = nil;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"OpenGL scale:%f", [UIScreen mainScreen].scale);
        }
        
		self.contentScaleFactor = [UIScreen mainScreen].scale;
		
		eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking: @(NO), kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8 };
		
        self.renderer = [LAppRenderer new];
        if (!self.renderer) {
            return nil;
        }
        [self.renderer resizeFromLayer:(CAEAGLLayer *)self.layer];
        
		self.isAnimating = NO;
		self.animationFrameInterval = 1;
		self.animationTimer = nil;
        
		self.multipleTouchEnabled = true;
        
        // タッチ関係のイベント管理
        self.touchMgr = [TouchManager new];
        
        // デバイス座標からスクリーン座標に変換するための
        self.deviceToScreen = new L2DMatrix44();
        
        // 画面の表示の拡大縮小や移動の変換を行う行列
        self.viewMatrix = new L2DViewMatrix();
        
        // 加速度関係のイベント
        self.accelHelper = [[AccelHelper alloc]init];
		
		float width = frame.size.width;
		float height = frame.size.height;
		float ratio = height / width;
		float left = VIEW_LOGICAL_LEFT;
		float right = VIEW_LOGICAL_RIGHT;
		float bottom = -ratio;
		float top = ratio;
		
        // デバイスに対応する画面の範囲。 Xの左端, Xの右端, Yの下端, Yの上端
		self.viewMatrix->setScreenRect(left, right, bottom, top);

		float screenW = fabs(left - right);
		self.deviceToScreen->multTranslate(-width / 2.0f, -height / 2.0f);
		self.deviceToScreen->multScale(screenW / width, -screenW / width);
        
        // 表示範囲の設定
        // 限界拡大率
        self.viewMatrix->setMaxScale(VIEW_MAX_SCALE);
        
        // 限界縮小率
        self.viewMatrix->setMinScale(VIEW_MIN_SCALE);
        
        // 表示できる最大範囲
        self.viewMatrix->setMaxScreenRect(VIEW_LOGICAL_MAX_LEFT, VIEW_LOGICAL_MAX_RIGHT, VIEW_LOGICAL_MAX_BOTTOM, VIEW_LOGICAL_MAX_TOP);
    }
    return self;
}

- (void)layoutSubviews {
    [self.renderer resizeFromLayer:(CAEAGLLayer *)self.layer];
    [self drawView];
}

@end
