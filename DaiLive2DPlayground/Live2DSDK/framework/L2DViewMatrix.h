/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#pragma once
#include "L2DMatrix44.h"
#include "util/UtDebug.h"

namespace live2d
{
	namespace framework
	{
		// カメラの位置変更に使うと便利な行列
		class L2DViewMatrix : public L2DMatrix44{
		private:
			float max;
			float min;
			
			float screenLeft;// デバイスに対応する論理座標上の範囲
			float screenRight;
			float screenTop;
			float screenBottom;
			float maxLeft;// 論理座標上の移動可能範囲（ここからははみ出さない）
			float maxRight;
			float maxTop;
			float maxBottom;
			
		public:
			L2DViewMatrix(){}
			
			void adjustTranslate(float shiftX, float shiftY) ;
			void adjustScale(float scaleCenterX,float scaleCenterY,float scale);
			void setScreenRect(float left, float right, float bottom, float top) ;
			void setMaxScreenRect(float left, float right, float bottom, float top) ;
			
			float getMaxScale(){return max ;}
			float getMinScale(){return min ;}
			void setMaxScale(float v){max=v;}
			void setMinScale(float v){min=v;}
			bool isMaxScale(){return getScaleX()>=max ;}
			bool isMinScale(){return getScaleX()<=min ;}
			float getScreenLeft(){return screenLeft;}
			float getScreenRight(){return screenRight;	}
			float getScreenBottom(){return screenBottom;}
			float getScreenTop(){	return screenTop;}
			float getMaxLeft(){return maxLeft;}
			float getMaxRight(){return maxRight;}
			float getMaxBottom(){	return maxBottom;}
			float getMaxTop(){return maxTop;}
		};
	}
}