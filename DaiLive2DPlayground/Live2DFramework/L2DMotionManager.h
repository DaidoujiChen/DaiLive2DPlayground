/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#pragma once

//Live2D lib
#include "ALive2DModel.h"
#include "motion/AMotion.h"
#include "motion/MotionQueueManager.h"

namespace live2d
{
	namespace framework
	{
		class L2DMotionManager : public MotionQueueManager
		{
			typedef MotionQueueManager super;
		public:
			L2DMotionManager();
			virtual ~L2DMotionManager(){}
			
		private:
			int currentPriority;//  現在再生中のモーションの優先度
			int reservePriority;//  再生予定のモーションの優先度。再生中は0になる。モーションファイルを別スレッドで読み込むときの機能。
			
		public:
			//  再生中のモーションの優先度
			int getCurrentPriority(){return currentPriority;}
			
			//  予約中のモーションの優先度
			int getReservePriority(){return reservePriority;}
			
			//  モーションを予約する
			void setReservePriority( int val ){reservePriority=val;}
			
			//  モーション開始
			int startMotionPrio( live2d::AMotion* motion, bool isDelete, int priority );
			
			bool updateParam(live2d::ALive2DModel* model);
			
			bool reserveMotion(int priority);
		};
	}
}

