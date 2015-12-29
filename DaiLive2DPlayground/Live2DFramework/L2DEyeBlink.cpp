/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#include "L2DEyeBlink.h"

namespace live2d
{
	namespace framework
	{
		L2DEyeBlink::L2DEyeBlink()
		{
			// 妥当と思われる値で初期化
			eyeState = STATE_FIRST ;
			
			blinkIntervalMsec = 4000 ;// 瞬きの間隔
			
			closingMotionMsec = 100 ;// 眼が閉じるまでの時間
			closedMotionMsec  =  50 ;// 閉じたままでいる時間
			openingMotionMsec = 150 ;// 眼が開くまでの時間
			
			closeIfZero = true ;// IDで指定された眼のパラメータが、0のときに閉じるなら true 、1の時に閉じるなら false
			
			// 左右の目のパラメータ
			eyeID_L = "PARAM_EYE_L_OPEN" ;
			eyeID_R = "PARAM_EYE_R_OPEN" ;
		}
		
		
		l2d_int64 L2DEyeBlink::calcNextBlink()
		{
			// 次回の眼パチの時刻を決める。ざっくり
			l2d_int64 time = live2d::UtSystem::getTimeMSec() ;
			double r = (double)rand() / RAND_MAX ;
			return time + (l2d_int64)( r*( 2*blinkIntervalMsec - 1 ) ) ;
		}
		
		
		void L2DEyeBlink::setInterval( int blinkIntervalMsec)
		{
			this->blinkIntervalMsec = blinkIntervalMsec ;
		}
		
		
		void L2DEyeBlink::setEyeMotion( int closingMotionMsec , int closedMotionMsec , int openingMotionMsec )
		{
			this->closingMotionMsec = closingMotionMsec ;
			this->closedMotionMsec = closedMotionMsec ;
			this->openingMotionMsec = openingMotionMsec ;
		}
		
		
		/*
		 * モデルのパラメータを更新
		 * update時に呼び出す
		 */
		void L2DEyeBlink::setParam( live2d::ALive2DModel *model )
		{
			l2d_int64 time = live2d::UtSystem::getTimeMSec() ;
			float eyeParamValue ;// 設定する値
			float t = 0 ;
			
			switch( this->eyeState )
			{
				case STATE_CLOSING:
					// 閉じるまでの割合を0..1に直す(blinkMotionMsecの半分の時間で閉じる)
					t = (float)(( time - stateStartTime ) / (double)closingMotionMsec ) ;
					if( t >= 1 )
					{
						t = 1 ;
						this->eyeState = STATE_CLOSED ;// 次から開き始める
						this->stateStartTime = time ;
					}
					eyeParamValue = 1 - t ;
					break ;
				case STATE_CLOSED:
					t = (float)(( time - stateStartTime ) / (double)closedMotionMsec) ;
					if( t >= 1 )
					{
						this->eyeState = STATE_OPENING ;// 次から開き始める
						this->stateStartTime = time ;
					}
					eyeParamValue = 0 ;// 閉じた状態
					break ;
				case STATE_OPENING:
					t = (float)(( time - stateStartTime ) / (double)openingMotionMsec ) ;
					if( t >= 1 )
					{
						t = 1 ;
						this->eyeState = STATE_INTERVAL ;// 次から開き始める
						this->nextBlinkTime = calcNextBlink() ;// 次回のまばたきのタイミングを始める時刻
					}
					eyeParamValue = t ;
					break ;
				case STATE_INTERVAL:
					// まばたき開始時刻なら
					if( this->nextBlinkTime < time )
					{
						this->eyeState = STATE_CLOSING ;
						this->stateStartTime = time ;
					}
					eyeParamValue = 1 ;// 開いた状態
					break ;
				case STATE_FIRST:
				default:
					this->eyeState = STATE_INTERVAL ;
					this->nextBlinkTime = calcNextBlink() ;// 次回のまばたきのタイミングを始める時刻
					eyeParamValue = 1 ;// 開いた状態
					break ;
			}
			
			if( ! closeIfZero ) eyeParamValue = -eyeParamValue ;
			
			// ---- 値を設定 ----
			model->setParamFloat( eyeID_L.c_str() , eyeParamValue ) ;
			model->setParamFloat( eyeID_R.c_str() , eyeParamValue ) ;
			
		}
	}
}