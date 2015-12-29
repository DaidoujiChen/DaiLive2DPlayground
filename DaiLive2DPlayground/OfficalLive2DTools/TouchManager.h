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

#import <UIKit/UIKit.h>

@interface TouchManager : NSObject

// タッチを開始した位置
@property (nonatomic, readonly) float startY;
@property (nonatomic, readonly) float startX;

// シングルタッチ時のxの値
@property (nonatomic, readonly) float lastX;

// シングルタッチ時のyの値
@property (nonatomic, readonly) float lastY;

// ダブルタッチ時の一つ目のxの値
@property (nonatomic, readonly) float lastX1;

// ダブルタッチ時の一つ目のyの値
@property (nonatomic, readonly) float lastY1;

// ダブルタッチ時の二つ目のxの値
@property (nonatomic, readonly) float lastX2;

// ダブルタッチ時の二つ目のyの値
@property (nonatomic, readonly) float lastY2;

// 2本以上でタッチしたときの指の距離
@property (nonatomic, readonly) float lastTouchDist;

// 前回の値から今回の値へのxの移動距離。
@property (nonatomic, readonly) float deltaX;

// 前回の値から今回の値へのyの移動距離。
@property (nonatomic, readonly) float deltaY;

// このフレームで掛け合わせる拡大率。拡大操作中以外は1。
@property (nonatomic, readonly) float scale;

// シングルタッチ時はtrue
@property (nonatomic, readonly) BOOL touchSingle;

// フリップが有効かどうか
@property (nonatomic, readonly) BOOL flipAvailable;

- (void)disableFlick;

/*
 * タッチ開始時イベント
 * @param x
 * @param deviceY
 */
- (void)touchesBegan:(CGPoint)point;

/*
 * タッチ開始時イベント。
 * @param x1
 * @param y1
 * @param x2
 * @param y2
 */
- (void)touchesBegan:(CGPoint)point1 to:(CGPoint)point2;
- (void)touchesMovedPath:(NSArray<NSValue *> *)touches;

/*
 * ドラッグ時のイベント
 * @param deviceX
 * @param deviceY
 */
- (void)touchesMovedToPoint:(CGPoint)point;

/*
 * ドラッグ時のイベント
 * @param x1
 * @param y1
 * @param x2
 * @param y2
 */
- (void)touchesMoved:(CGPoint)point1 to:(CGPoint)point2;
- (float)flickDistance;

@end
