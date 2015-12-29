/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#include "L2DExpressionMotion.h"

using namespace std;

namespace live2d
{
	namespace framework
	{
		const char L2DExpressionMotion::EXPRESSION_DEFAULT[] = "DEFAULT";// 表情のデフォルト値要素のキー
		const int L2DExpressionMotion::TYPE_SET=0;
		const int L2DExpressionMotion::TYPE_ADD=1;
		const int L2DExpressionMotion::TYPE_MULT=2;
		
		/*
		 * モデルのパラメータを更新する。
		 * @AMotion
		 */
		void L2DExpressionMotion::updateParamExe( ALive2DModel * model , l2d_int64 timeMSec , float weight , MotionQueueEnt *motionQueueEnt )
		{
			int len=paramList.size();
			for ( int i = 0 ; i < len ; i++ )
			{
				L2DExpressionParam& param = paramList[i] ;
				if(param.type == TYPE_ADD)
				{
					model->addToParamFloat( param.pid.c_str()	, param.value , weight ) ;// 相対変化 加算
				}
				else if(param.type == TYPE_MULT)
				{
					model->multParamFloat( param.pid.c_str()	, param.value , weight ) ;// 相対変化 乗算
				}
				else if(param.type == TYPE_SET)
				{
					model->setParamFloat( param.pid.c_str()	, param.value , weight ) ;// 絶対変化
				}
			}
		}
		
		
		L2DExpressionMotion* L2DExpressionMotion::loadJson(const string & filepath )
		{
			int size = 0 ;
			
			char * buf = UtFile::loadFile(filepath.c_str() , &size ) ;// ファイルのロード
			if( buf == NULL ){
				UtDebug::error( "load file failed : file : %s @L2DExpressionMotion#loadJson()" , filepath.c_str() ) ;
				return NULL ;
			}
			
			L2DExpressionMotion* ret = loadJson( buf , size ) ;// モデルに展開
			
			if( buf ) UtFile::releaseLoadBuffer( buf ) ;
			
			return ret ;
		}
		
		
		/*
		 * JSONファイルから読み込み。
		 * 仕様についてはマニュアル参照。JSONスキーマの形式の仕様がある。
		 * @param buf
		 * @return
		 */
		L2DExpressionMotion* L2DExpressionMotion::loadJson(const void *buf ,int size )
		{
			L2DExpressionMotion* ret = new L2DExpressionMotion();
			
			Json* json = Json::parseFromBytes( (const char*)buf , size ) ;
			Value& root = json->getRoot() ;
			
			ret->setFadeIn(root["fade_in"].toInt(1000));// フェードイン
			ret->setFadeOut(root["fade_out"].toInt(1000));// フェードアウト
			
			// 各パラメータについて
			int paramNum = root["params"].size();
			for (int i = 0; i < paramNum; i++)
			{
				Value& param			= root["params"][i];
				string paramID		= param["id"].toString().c_str();// パラメータID
				float value			= (float)param["val"].toDouble();// 値
				
				// 計算方法の設定
				int calcTypeInt;
				if ( param["calc"].isNull() || param["calc"].toString() == "add" )
				{
					calcTypeInt = TYPE_ADD;
				}
				else if( param["calc"].toString() == "mult" )
				{
					calcTypeInt = TYPE_MULT;
				}
				else if( param["calc"].toString() == "set" )
				{
					calcTypeInt = TYPE_SET;
				}
				else
				{
					// その他 仕様にない値を設定したときは加算モードにすることで復旧
					calcTypeInt = TYPE_ADD;
				}
				
				// 計算方法 加算
				if( calcTypeInt == TYPE_ADD)
				{
					float defaultValue = (float)param["def"].toDouble(0);
					value = value - defaultValue;
				}
				// 計算方法 乗算
				else if( calcTypeInt == TYPE_MULT)
				{
					float defaultValue = (float)param["def"].toDouble(1);
					if( defaultValue == 0 )defaultValue = 1;// 0(不正値)を指定した場合は1(標準)にする
					value = value / defaultValue;
				}
				
				// 設定オブジェクトを作成してリストに追加する
				L2DExpressionParam item;
				
				item.pid=paramID;
				item.type=calcTypeInt;
				item.value=value;
				
				ret->paramList.push_back(item);
			}
			
			delete json;// JSONデータは不要になったら削除する
			
			return ret;
		}
		
		
		/*
		 * 旧SDKでの表情設定ファイルを読み込む
		 */
		void L2DExpressionMotion::loadExpressionJsonV09(LDMap<LDString , AMotion*>& expressions ,const void* buf,int size )
		{
			Json* json = Json::parseFromBytes( (const char*)buf , size ) ;
			
			Value& mo = json->getRoot() ;
			Value& defaultExpr = mo[EXPRESSION_DEFAULT] ;// 相対値の基準となる値
			
			LDVector<LDString>& keys = mo.getKeys() ;
			for( int i = keys.size()-1 ; i>= 0 ; --i)
			{
				LDString& key = keys[i] ;
				
				if( key==EXPRESSION_DEFAULT ) continue ;// 飛ばす
				
				Value& expr = mo[ key ] ;
				
				L2DExpressionMotion* exMotion = L2DExpressionMotion::loadJsonV09( defaultExpr , expr) ;
				expressions[ key.c_str() ] = exMotion ;
			}
			
			delete json ;
		}
		
		
		/*
		 * JSONの解析結果からExpressionを生成する
		 * 旧SDKでの設定ファイル読み込み
		 * @param v
		 */
		L2DExpressionMotion* L2DExpressionMotion::loadJsonV09( live2d::Value &defaultExpr , live2d::Value &expr )
		{
			L2DExpressionMotion* ret = new L2DExpressionMotion();
			ret->setFadeIn( expr["FADE_IN"].toInt(1000) ) ;
			ret->setFadeOut( expr["FADE_OUT"].toInt(1000) ) ;
			
			// --- IDリストを生成
			Value& defaultParams = defaultExpr["PARAMS"] ;
			Value& params = expr["PARAMS"] ;
			
			LDVector<LDString>& idList = params.getKeys() ;
			
			// --------- 値を設定 ---------
			for ( int i = idList.size() -1 ; i >= 0 ; --i )
			{
				LDString& pid = idList[i] ;
				float defaultV = (float)defaultParams[pid].toDouble(0) ;
				float v = (float)params[ pid ].toDouble( 0.0f ) ;
				
				L2DExpressionParam item;
				item.pid=pid.c_str();
				item.type=TYPE_ADD;
				item.value=v-defaultV;
				ret->paramList.push_back(item);
			}
			return ret;
		}
	}
}