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

#import "TouchManager.h"

@interface TouchManager ()

@property (nonatomic, assign) float startY;
@property (nonatomic, assign) float startX;

@property (nonatomic, assign) float lastX;
@property (nonatomic, assign) float lastY;
@property (nonatomic, assign) float lastX1;
@property (nonatomic, assign) float lastY1;
@property (nonatomic, assign) float lastX2;
@property (nonatomic, assign) float lastY2;

@property (nonatomic, assign) float lastTouchDist;

@property (nonatomic, assign) float deltaX;
@property (nonatomic, assign) float deltaY;

@property (nonatomic, assign) float scale;

@property (nonatomic, assign) BOOL touchSingle;
@property (nonatomic, assign) BOOL flipAvailable;

@end

@implementation TouchManager

#pragma mark - Private Instance Method

- (void)setupInitValues {
    self.lastX = 0;
    self.lastY = 0;
    self.lastX1 = 0;
    self.lastY1 = 0;
    self.lastX2 = 0;
    self.lastY2 = 0;
    self.lastTouchDist = 0;
    self.deltaX = 0;
    self.deltaY = 0;
    self.scale = 1.0f;
}

/*
 * 点1から点2への距離を求める
 * @param p1x
 * @param p1y
 * @param p2x
 * @param p2y
 * @return
 */
- (float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2 {
    return sqrt(pow((point1.x - point2.x), 2) + pow((point1.y - point2.y), 2));
}

/*
 * 二つの値から、移動量を求める。
 * 違う方向の場合は移動量０。同じ方向の場合は、絶対値が小さい方の値を参照する
 */
- (float)calcShift:(float)v1 to:(float)v2 {
    if (v1 > 0 != v2 > 0) {
        return 0;
    }

    float fugou = v1 > 0 ? 1 : -1;
    float a1 = fabs(v1);
    float a2 = fabs(v2);
    return fugou * ((a1 < a2) ? a1 : a2);
}

#pragma mark - Instance Method

- (void)disableFlick {
    self.flipAvailable = NO;
}

- (void)touchesBegan:(CGPoint)point {
    self.lastX = point.x;
    self.lastY = point.y;
    self.startX= point.x;
    self.startY= point.y;
    self.lastTouchDist = -1;
    self.flipAvailable = YES;
    self.touchSingle = YES;
}

- (void)touchesBegan:(CGPoint)point1 to:(CGPoint)point2 {
    float dist = [self distanceFrom:point1 to:point2];
    float centerX = (point1.x + point2.x) / 2;
    float centerY = (point1.y + point2.y) / 2;
    
    self.lastX1 = point1.x;
    self.lastY1 = point1.y;
    self.lastX2 = point2.x;
    self.lastY2 = point2.y;
    
    self.lastX = centerX;
    self.lastY = centerY;
    self.startX= centerX;
    self.startY= centerY;
    self.lastTouchDist = dist;
    self.flipAvailable = YES;
    self.touchSingle = NO;
}

- (void)touchesMovedPath:(NSArray<NSValue *> *)touches {
    
    // 前回のクリック位置に最も近いものを選びだす
    // pt1、pt2の両点への距離の和が最小となる点の組み合わせを総当たりで探す
    int finalIndex1 = 0;
    int finalIndex2 = 1;
    int minDist2 = 999999;
    
    for (int index1 = 0; index1 < touches.count; index1++) {
        CGPoint pp1 = [touches[index1] CGPointValue];
        
        for (int index2 = 0; index2 < touches.count; index2++) {
            if (index1 == index2) {
                continue;
            }
            
            CGPoint pp2 = [touches[index2] CGPointValue];
            
            float distTotal = (pow(self.lastX1 - pp1.x, 2) + pow(self.lastY1 - pp1.y, 2)) + (pow(self.lastX2 - pp2.x, 2) + pow(self.lastY2 - pp2.y, 2));
            if( distTotal < minDist2 ) {
                minDist2 = distTotal;
                finalIndex1 = index1;
                finalIndex2 = index2;
            }
        }
    }
    
    if (minDist2 > 70*70*2 && touches.count > 2) {
        // 処理しない
        return;
    }
    
    // pt2に一番近い点
    CGPoint pt1 = [touches[finalIndex1] CGPointValue];
    CGPoint pt2 = [touches[finalIndex2] CGPointValue];
    [self touchesMoved:pt1 to:pt2];
}

- (void)touchesMovedToPoint:(CGPoint)point {
    self.lastX = point.x;
    self.lastY = point.y;
    self.lastTouchDist = -1;
    self.touchSingle = YES;
}

- (void)touchesMoved:(CGPoint)point1 to:(CGPoint)point2 {
    float dist = [self distanceFrom:point1 to:point2];
    float centerX = (point1.x + point2.x) / 2;
    float centerY = (point1.y + point2.y) / 2;
    
    if (self.lastTouchDist > 0) {
        self.scale = pow(dist / self.lastTouchDist, 0.75);
        self.deltaX = [self calcShift:point1.x - self.lastX1 to:point2.x - self.lastX2];
        self.deltaY = [self calcShift:point1.y - self.lastY1 to:point2.y - self.lastY2];
    }
    else {
        self.scale = 1;
        self.deltaX = 0;
        self.deltaY = 0;
    }
    
    self.lastX = centerX;
    self.lastY = centerY;
    self.lastX1 = point1.x;
    self.lastY1 = point1.y;
    self.lastX2 = point2.x;
    self.lastY2 = point2.y;
    self.lastTouchDist = dist;
    self.touchSingle = NO;
}

- (float)flickDistance {
    return [self distanceFrom:CGPointMake(self.startX, self.startY) to:CGPointMake(self.lastX, self.lastY)];
}

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        [self setupInitValues];
    }
    return self;
}

@end
