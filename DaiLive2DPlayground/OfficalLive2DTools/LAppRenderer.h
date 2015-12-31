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
#import <UIKit/UIKit.h>

class LAppLive2DManager;

@interface LAppRenderer : NSObject

- (id)init;
- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

// Live2DManagerの参照を設定する
- (void)setDelegate:(LAppLive2DManager *)delegate;

// 別スレッドでテクスチャをロードするような場合に使用する
- (void)setContextCurrent;

@end




