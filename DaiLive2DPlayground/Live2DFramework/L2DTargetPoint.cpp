/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#include "L2DTargetPoint.h"
#include "util/UtSystem.h"

namespace live2d
{
	namespace framework
	{
		L2DTargetPoint::L2DTargetPoint()
		{
			this->faceTargetX   = 0;
			this->faceTargetY   = 0;
			this->faceX         = 0;
			this->faceY         = 0;
			this->faceVX        = 0.0f;
			this->faceVY        = 0.0f;
			this->lastTimeSec   = 0;
		}
		
		
		/***************************************************
		 @brief      更新
		 @brief      首を中央から左右に振るときの平均的な速さは、秒程度。加速・減速を考慮して、その２倍を最高速度とする。
		 @brief      顔のふり具合を、中央(0)から、左右は(±1)とする。
		 @param      なし
		 @return     なし
		 ****************************************************/
		void L2DTargetPoint::update()
		{
			// 首を中央から左右に振るときの平均的な早さは  秒程度。加速・減速を考慮して、その２倍を最高速度とする
			// 顔のふり具合を、中央（０）から、左右は（±１）とする
			const float FACE_PARAM_MAX_V = 40.0 / 10 ;// 7.5秒間に40分移動（5.3/sc)
			const float MAX_V =  FACE_PARAM_MAX_V * 1.0f / FRAME_RATE ;// 1frameあたりに変化できる速度の上限
			
			static l2d_int64 lastTimeSec = 0 ;
			if( lastTimeSec == 0 )
			{
				lastTimeSec = UtSystem::getUserTimeMSec() ;
				return ;
			}
			l2d_int64 curTimeSec = UtSystem::getUserTimeMSec() ;
			
			float deltaTimeWeight = (float)(curTimeSec - lastTimeSec)*FRAME_RATE/1000.0f ;
			lastTimeSec = curTimeSec ;
			
			// 最高速度になるまでの時間を
			const float TIME_TO_MAX_SPEED = 0.15f ;
			const float FRAME_TO_MAX_SPEED = TIME_TO_MAX_SPEED * FRAME_RATE  ;//sec*frame/sec
			const float MAX_A = deltaTimeWeight * MAX_V / FRAME_TO_MAX_SPEED ;// 1frameあたりの加速度
			
			
			// 目指す向きは、tmpdx,tmpdy 方向のベクトルとなる
			float dx = (faceTargetX - faceX) ;
			float dy = (faceTargetY - faceY) ;
			
			if( dx == 0 && dy == 0 ) return ;// 変化なし
			
			// 速度の最大よりも大きい場合は、速度を落とす
			float d = L2D_SQRT( dx*dx + dy*dy ) ;
			
			// 進行方向の最大速度ベクトル
			float vx = MAX_V * dx / d ;
			float vy = MAX_V * dy / d ;
			
			// 現在の速度から、新規速度への変化（加速度）を求める
			float ax = vx - faceVX ;
			float ay = vy - faceVY ;
			
			float a = L2D_SQRT( ax*ax + ay*ay ) ;
			
			// 加速のとき
			if( a < -MAX_A || a > MAX_A )
			{
				ax *= MAX_A / a ;
				ay *= MAX_A / a ;
			}
			
			// 加速度を元の速度に足して、新速度とする
			faceVX += ax ;
			faceVY += ay ;
			
			// 目的の方向に近づいたとき、滑らかに減速するための処理
			// 	設定された加速度で止まることのできる距離と速度の関係から
			// 	現在とりうる最高速度を計算し、それ以上のときは速度を落とす
			// 	※本来、人間は筋力で力（加速度）を調整できるため、より自由度が高いが、簡単な処理ですませている
			{
				// 加速度、速度、距離の関係式。
				//            2  6           2               3
				//      sqrt(a  t  + 16 a h t  - 8 a h) - a t
				// v = --------------------------------------
				//                    2
				//                 4 t  - 2
				//(t=1)
				// 	時刻tは、あらかじめ加速度、速度を1/60(フレームレート、単位なし)で
				// 	考えているので、t＝１として消してよい（※未検証）
				
				float max_v = 0.5f * ( L2D_SQRT( MAX_A*MAX_A + 16*MAX_A * d - 8*MAX_A * d ) - MAX_A ) ;
				float cur_v = L2D_SQRT( faceVX*faceVX + faceVY*faceVY ) ;
				
				if( cur_v > max_v )
				{
					// 現在の速度＞最高速度のとき、最高速度まで減速
					faceVX *= max_v / cur_v ;
					faceVY *= max_v / cur_v ;
				}
			}
			
			faceX += faceVX ;
			faceY += faceVY ;
			
			return;
		}
		
		
		void L2DTargetPoint::set( float x, float y )
		{
			this->faceTargetX   = x;
			this->faceTargetY   = y;
		}
	}
}