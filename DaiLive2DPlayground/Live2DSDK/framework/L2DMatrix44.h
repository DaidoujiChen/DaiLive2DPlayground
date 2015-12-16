/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 */
#pragma once

namespace live2d
{
	namespace framework
	{
		class L2DMatrix44
		{
		protected:
			float tr[16];// 行列データ
			
		public:
			L2DMatrix44();
			virtual ~L2DMatrix44(){}
			
			// 単位行列に初期化
			void identity() ;
			
			//  行列配列を取得
			float* getArray(){ return tr; }
			
			//  行列を設定
			void setMatrix( float* _tr );
			
			//  xの拡大率を取得
			float getScaleX(){return tr[0] ;}
			
			//  yの拡大率を取得
			float getScaleY(){return tr[5] ;}
			
			float getTranslateX(){return tr[12] ;}
			
			float getTranslateY(){return tr[13] ;}
			
			//  xの値を現在の行列で計算する
			float transformX( float src );
			
			//  yの値を現在の行列で計算する
			float transformY( float src );
			
			//  xの値を現在の行列で逆計算する
			float invertTransformX( float src );
			
			//  yの値を現在の行列で逆計算する
			float invertTransformY( float src );
			
			//  移動量の計算
			void multTranslate( float shiftX, float shiftY );
			void translate( float shiftX, float shiftY );
			void translateX( float shiftX ) {tr[12]=shiftX;}
			void translateY( float shiftY ) {tr[13]=shiftY;}
			
			//  拡大率の計算
			void multScale( float scaleX,float scaleY );
			void scale( float scaleX,float scaleY );
			
			//  受け取った２つの行列の掛け算を行う
			static void mul( float* a, float* b, float* dst );
			
			void append(L2DMatrix44* m);
		};
	}
}
