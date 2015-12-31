/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *
 *  Modify By DaidoujiChen https://github.com/DaidoujiChen
 *
 */

#import "LAppTextureDesc.h"
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

LAppTextureDesc::LAppTextureDesc(unsigned int tex) {
	data = tex;
}

LAppTextureDesc::~LAppTextureDesc() {
	glDeleteTextures(1, &data);
}
