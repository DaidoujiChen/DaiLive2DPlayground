/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#include "L2DMotionManager.h"

namespace live2d
{
	namespace framework
	{
		L2DMotionManager::L2DMotionManager()
		:currentPriority(0),reservePriority(0)
		{
			
		}
		
		
		int L2DMotionManager::startMotionPrio( AMotion* motion, bool isDelete, int priority )
		{
			if(priority==reservePriority)
			{
				reservePriority=0;// 予約を解除
			}
			currentPriority=priority;// 再生中モーションの優先度を設定
			return super::startMotion(motion, isDelete);
		}
		
		
		bool L2DMotionManager::updateParam(ALive2DModel* model)
		{
			bool updated=super::updateParam(model);
			if(isFinished())
			{
				currentPriority=0;// 再生中モーションの優先度を解除
			}
			return updated;
		}
		
		
		bool L2DMotionManager::reserveMotion(int priority)
		{
			if ( priority <= reservePriority || priority <= currentPriority )
			{
				return false;
			}
			reservePriority=priority;
			return true;
		}
	}
}