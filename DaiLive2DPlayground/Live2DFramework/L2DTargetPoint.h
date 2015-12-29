/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#pragma once


//Live2D lib
#include "Live2D.h"
#include "util/UtMath.h"

namespace live2d
{
	namespace framework
	{
		class L2DTargetPoint
		{
		private:
			float faceTargetX;      //  顔の向きのX目標値(この値に近づいていく)
			float faceTargetY;      //  顔の向きのY目標値(この値に近づいていく)
			float faceX;            //  顔の向きX(-1～1)
			float faceY;            //  顔の向きY(-1～1)
			float faceVX;           //  顔の向きの変化速度X
			float faceVY;           //  顔の向きの変化速度Y
			l2d_int64 timeSec;
			l2d_int64 lastTimeSec;
			
		public:
			static const int FRAME_RATE = 30;
			
		public:
			L2DTargetPoint();
			
			virtual ~L2DTargetPoint(){}
			
			void update();
			
			float getX(){return this->faceX;}
			
			float getY(){return this->faceY;}
			
			void set( float x, float y );
		};
	}
}


