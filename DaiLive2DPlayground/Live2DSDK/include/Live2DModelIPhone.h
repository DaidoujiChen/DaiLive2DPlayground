/**
 *  Live2DModelIPhone.h
 *
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */
#ifndef __LIVE2D_L2DMODE_IPHONE_H__
#define __LIVE2D_L2DMODE_IPHONE_H__


#include "Live2D.h"

#ifdef L2D_TARGET_IPHONE


#include "ALive2DModel.h"
#include "model/ModelImpl.h"
#include "graphics/DrawParam_OpenGLES1.h"

//--------- LIVE2D NAMESPACE ------------
namespace live2d 
{

	class ModelContext ;


	
	class Live2DModelIPhone : public live2d::ALive2DModel
	{
	public:
		Live2DModelIPhone(void) ;
		virtual ~Live2DModelIPhone(void) ;

	public:
		virtual void draw() ;

		void setTexture( int textureNo , GLuint openGLTextureNo ) ;
		
		static Live2DModelIPhone * loadModel( const live2d::LDString & filepath ) ;
		static Live2DModelIPhone * loadModel( const void * buf , int bufSize ) ;

		// 新しく利用できるModelのテクスチャ番号を確保(Avatar用)
		virtual int generateModelTextureNo() ;
		
		// Modelのテクスチャ番号を生成(Avatar用)
		virtual void releaseModelTextureNo(int no) ;
		
		virtual live2d::DrawParam* getDrawParam(){ return drawParamOpenGL ; }
		
		void setTextureColor(int textureNo, float r, float g, float b, float a=1);
		void setTextureInterpolate(int textureNo, float interpolate);
		void setTextureBlendMode(int textureNo, int mode);

	private:
		//Prevention of copy Constructor
		Live2DModelIPhone( const Live2DModelIPhone & ) ;				
		Live2DModelIPhone& operator=( const Live2DModelIPhone & ) ;	
		
	private:
		live2d::DrawParam_OpenGLES1 * 		drawParamOpenGL ;

	};
}
//--------- LIVE2D NAMESPACE ------------


#endif		// L2D_TARGET_IPHONE
#endif		// __LIVE2D_L2DMODE_IPHONE_H__
