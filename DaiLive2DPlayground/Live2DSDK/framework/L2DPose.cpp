/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#include "L2DPose.h"

namespace live2d
{
	namespace framework
	{
		L2DPose::L2DPose() :lastModel(NULL),lastTime(0)
		{
		}
		
		
		/*
		 * モデルのパラメータを更新。
		 * @param model
		 */
		void L2DPose::updateParam(ALive2DModel* model)
		{
			// 前回のモデルと同じではないときは初期化が必要
			if( model != lastModel )
			{
				//  パラメータインデックスの初期化
				initParam(model);
			}
			lastModel = model;
			
			l2d_int64  curTime = UtSystem::getTimeMSec();
			float deltaTimeSec = ( (lastTime == 0 ) ? 0 : ( curTime - lastTime )/1000.0f);
			lastTime = curTime;
			
			// 設定から時間を変更すると、経過時間がマイナスになることがあるので、経過時間0として対応。
			if (deltaTimeSec < 0) deltaTimeSec = 0;
			
			int offset=0;
			for (unsigned int i = 0; i < groupRows.size(); i++)
			{
				int rowCount=groupRows[i];
				normalizePartsOpacityGroup(model,deltaTimeSec,offset,rowCount);
				offset+=rowCount;
			}
			copyOpacityOtherParts(model);
		}
		
		
		/*
		 * 表示を初期化。
		 * αの初期値が0でないパラメータは、αを1に設定する。
		 * @param model
		 */
		void L2DPose::initParam(ALive2DModel* model)
		{
			int offset=0;
			for (unsigned int i=0; i<groupRows.size(); i++) {
				int rowCount=groupRows[i];
				for (int j = offset; j < offset+rowCount; j++)
				{
					partsGroups[j].initIndex(model);
					int partsIndex = partsGroups[j].partsIndex ;
					int paramIndex = partsGroups[j].paramIndex ;
					
					if(partsIndex<0)continue;
					
					model->setPartsOpacity(partsIndex , (j==offset ? 1.0f : 0.0f) ) ;
					model->setParamFloat(paramIndex , (j==offset ? 1.0f : 0.0f) ) ;
					
					for (unsigned int k = 0; k < partsGroups[j].link.size(); k++)
					{
						partsGroups[j].link[k].initIndex(model);
					}
				}
				offset+=rowCount;
			}
			
		}
		
		
		/*
		 * パーツのフェードイン、フェードアウトを設定する。
		 * @param model
		 * @param partsGroup
		 * @param deltaTimeSec
		 */
		void L2DPose::normalizePartsOpacityGroup( ALive2DModel* model , float deltaTimeSec ,int offset ,int rowCount)
		{
			int visibleParts = -1 ;
			float visibleOpacity = 1.0f ;
			
			float CLEAR_TIME_SEC = 0.5f ;// この時間で不透明になる
			float phi = 0.5f ;// 背景が出にくいように、１＞０への変化を遅らせる場合は、0.5よりも大きくする。ただし、あまり自然ではない
			float maxBackOpacity = 0.15f ;
			
			
			//  現在、表示状態になっているパーツを取得
			for (int i = offset ; i < offset + rowCount; i++ )
			{
				int partsIndex = partsGroups[i].partsIndex;
				int paramIndex = partsGroups[i].paramIndex;
				
				if( model->getParamFloat( paramIndex ) != 0 )
				{
					if( visibleParts >= 0 )
					{
						break ;
					}
					
					visibleParts = i ;
					visibleOpacity = model->getPartsOpacity(partsIndex) ;
					
					//  新しいOpacityを計算
					visibleOpacity += deltaTimeSec / CLEAR_TIME_SEC ;
					if( visibleOpacity > 1 )
					{
						visibleOpacity = 1 ;
					}
				}
			}
			
			if( visibleParts < 0 )
			{
				visibleParts = 0 ;
				visibleOpacity = 1 ;
			}
			
			//  表示パーツ、非表示パーツの透明度を設定する
			for (int i = offset ; i < offset + rowCount ; i++ )
			{
				int partsIndex = partsGroups[i].partsIndex;
				
				//  表示パーツの設定
				if( visibleParts == i )
				{
					model->setPartsOpacity(partsIndex , visibleOpacity ) ;// 先に設定
				}
				//  非表示パーツの設定
				else
				{
					float opacity = model->getPartsOpacity(partsIndex) ;
					float a1 ;// 計算によって求められる透明度
					if( visibleOpacity < phi )
					{
						a1 = visibleOpacity*(phi-1)/phi + 1 ; //  (0,1),(phi,phi)を通る直線式
					}
					else
					{
						a1 = (1-visibleOpacity)*phi/(1-phi) ; //  (1,0),(phi,phi)を通る直線式
					}
					
					// 背景の見える割合を制限する場合
					float backOp = (1-a1)*(1-visibleOpacity) ;
					if( backOp > maxBackOpacity )
					{
						a1 = 1 - maxBackOpacity/( 1- visibleOpacity ) ;
					}
					
					if( opacity > a1 )
					{
						opacity = a1 ;//  計算の透明度よりも大きければ（濃ければ）透明度を上げる
					}
					model->setPartsOpacity(partsIndex , opacity ) ;
				}
			}
		}
		
		
		/*
		 * パーツのαを連動する。
		 * @param model
		 * @param partsGroup
		 */
		void L2DPose::copyOpacityOtherParts(ALive2DModel* model)
		{
			for (unsigned int i_group = 0; i_group < partsGroups.size(); i_group++)
			{
				L2DPartsParam &partsParam = partsGroups[i_group];
				
				if(partsParam.link.size()==0)continue;// リンクするパラメータはない
				
				int partsIndex = partsGroups[i_group].partsIndex;
				
				float opacity = model->getPartsOpacity( partsIndex );
				
				for (unsigned int i_link = 0; i_link < partsParam.link.size(); i_link++)
				{
					L2DPartsParam &linkParts = partsParam.link[i_link];
					
					int linkPartsIndex = linkParts.partsIndex;
					
					if(linkPartsIndex < 0)continue;
					model->setPartsOpacity(linkPartsIndex, opacity);
				}
			}
		}
		
		
		/*
		 * JSONファイルから読み込む
		 * 仕様についてはマニュアル参照。JSONスキーマの形式の仕様がある。
		 * @param buf
		 * @return
		 */
		L2DPose* L2DPose::load(const void* buf ,int size)
		{
			L2DPose* ret = new L2DPose();
			
			Json* json = Json::parseFromBytes( (const char*)buf , size ) ;
			
			Value& root = json->getRoot() ;
			
			// パーツ切り替え一覧
			Value& poseListInfo = root["parts_visible"];
			int poseNum = poseListInfo.size();
			
			for (int i_pose = 0; i_pose < poseNum; i_pose++)
			{
				Value& poseInfo = poseListInfo[i_pose];
				
				// IDリストの設定
				Value& idListInfo = poseInfo["group"];
				int idNum = idListInfo.size();
				int rowCount=0;
				for (int i_group = 0; i_group < idNum; i_group++)
				{
					Value& partsInfo=idListInfo[i_group];
					L2DPartsParam parts;
					LDString paramID=partsInfo["id"].toString();
					parts.partsID=paramID;
					
					// リンクするパーツの設定
					if(partsInfo["link"].isNull())
					{
						// リンクが無いときもある
					}
					else
					{
						Value &linkListInfo = partsInfo["link"];
						int linkNum = linkListInfo.size();
						
						for (int i_link = 0; i_link< linkNum; i_link++)
						{
							L2DPartsParam linkParts;
							LDString linkID=linkListInfo[i_link].toString();
							linkParts.partsID=linkID;
							parts.link.push_back(linkParts);
						}
					}
					ret->partsGroups.push_back(parts);
					rowCount++;
				}
				ret->groupRows.push_back(rowCount);
				
			}
			
			delete json;
			return ret;
		}
	}
}