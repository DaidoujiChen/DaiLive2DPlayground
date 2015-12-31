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
#import "L2DViewMatrix.h"

class LAppLive2DManager;

@interface LAppView : UIView

// 画面の拡大縮小、移動用の行列
@property (nonatomic, readonly) live2d::framework::L2DViewMatrix *viewMatrix;

- (void)startAnimation;
- (void)stopAnimation;
- (void)setDelegate:(LAppLive2DManager *)delegate;
- (void)terminate;

@end


