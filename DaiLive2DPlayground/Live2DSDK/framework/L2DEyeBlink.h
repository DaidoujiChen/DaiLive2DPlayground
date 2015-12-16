/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#pragma once

#include <stdlib.h>
#include <math.h>
#include <string>
//Live2D lib
#include "ALive2DModel.h"
#include "util/UtSystem.h"

namespace live2d
{
	namespace framework
	{
		class L2DEyeBlink
		{
		public:
			// 眼の状態定数
			enum EYE_STATE{
				STATE_FIRST = 0 ,
				STATE_INTERVAL ,
				STATE_CLOSING ,// 閉じていく途中
				STATE_CLOSED , // 閉じている状態
				STATE_OPENING// 開いていく途中
			};
			
			L2DEyeBlink();
			virtual ~L2DEyeBlink(){}
			
			l2d_int64 calcNextBlink() ;
			void setInterval( int blinkIntervalMsec) ;
			void setEyeMotion( int closingMotionMsec , int closedMotionMsec , int openingMotionMsec ) ;
			
			// モデルのパラメータを更新
			void setParam( live2d::ALive2DModel *model ) ;
			
		private:
			l2d_int64 nextBlinkTime ;// 次回眼パチする時刻（msec）
			int eyeState ;// 現在の状態
			l2d_int64 stateStartTime ;// 現在のstateが開始した時刻
			bool closeIfZero;// IDで指定された眼のパラメータが、0のときに閉じるなら true 、1の時に閉じるなら false
			
			// 左右の目のパラメータ
			std::string eyeID_L ;
			std::string eyeID_R ;
			
			// 設定
			int blinkIntervalMsec ;// 瞬きの間隔
			int closingMotionMsec ;// 眼が閉じるまでの時間
			int closedMotionMsec  ;// 閉じたままでいる時間
			int openingMotionMsec ;// 眼が開くまでの時間
		};
	}
}