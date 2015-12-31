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

@interface OffscreenImage : NSObject

+ (void)createFrameBuffer:(float)width height:(float)height defaultFrameBuffer:(GLuint)defaultFrameBuffer;
+ (void)releaseFrameBuffer;
+ (void)setOffscreen;
+ (void)setOnscreen;

/*
 * オフスクリーンのバッファを描画する。
 * @param gl
 * @param opacity
 */
+ (void)drawDisplay:(float)opacity;

@end
