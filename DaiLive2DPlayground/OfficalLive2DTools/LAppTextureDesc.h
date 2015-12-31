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

#import "L2DTextureDesc.h"

class LAppTextureDesc : public live2d::framework::L2DTextureDesc {
    
public:
	LAppTextureDesc(unsigned int tex);
	virtual ~LAppTextureDesc();

private:
	unsigned int data;
};
