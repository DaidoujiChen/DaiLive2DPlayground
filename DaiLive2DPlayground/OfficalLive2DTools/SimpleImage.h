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

@interface SimpleImage : NSObject

- (id)initWithPath:(NSString *)path;
- (void)draw;
- (void)deleteTexture;

/*
 * テクスチャの描画先の座標を設定(デフォルトは 0,0,1,1 に描かれる)
 *
 * @param left
 * @param right
 * @param bottom
 * @param top
 */
- (void)setDrawRect:(float)left right:(float)right bottom:(float)bottom top:(float)top;

/*
 * テクスチャの使用範囲を設定（テクスチャは0..1座標）
 * @param left
 * @param right
 * @param bottom
 * @param top
 */
- (void)setUVRect:(float)left right:(float)right bottom:(float)bottom top:(float)top;

@end
