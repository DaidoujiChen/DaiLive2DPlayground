/**
 * DrawParam_OpenGLES1.h
 *
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */
#ifndef __LIVE2D_DRAWPARAM_OPENGLES1_H__
#define __LIVE2D_DRAWPARAM_OPENGLES1_H__


#ifndef __SKIP_DOC__

#include "../Live2D.h"

#ifdef L2D_GRAPHICS_OPENGL_ES1

#ifdef L2D_TARGET_ANDROID
#define GL_GLEXT_PROTOTYPES
#include <GLES/gl.h>
#include <GLES/glext.h>
#endif

#ifdef L2D_TARGET_IPHONE
#include <OPENGLES/ES1/gl.h>
#include <OPENGLES/ES1/glext.h>
#endif

#include "DrawParam.h"

//------------ LIVE2D NAMESPACE ------------
namespace live2d
{ 
	
	class DrawParam_OpenGLES1 : public DrawParam
	{
	public:
		DrawParam_OpenGLES1();
		virtual ~DrawParam_OpenGLES1();
		
	public:
		virtual void drawTexture( int textureNo  , int indexCount , int vertexCount , l2d_index * indexArray 
								 , l2d_pointf * vertexArray , l2d_uvmapf * uvArray , float opacity, int colorCompositionType) ;
	
		void setTexture( int modelTextureNo , GLuint textureNo ) ;
		
		//  新しく利用できるModelのテクスチャ番号を確保(Avatar用）
		virtual int generateModelTextureNo() ;
		
		//  Modelのテクスチャ番号を生成(Avatar用）
		virtual void releaseModelTextureNo(int no) ;
		
		virtual void setupDraw();

	private:
		// Prevention of copy Constructor
		DrawParam_OpenGLES1( const DrawParam_OpenGLES1 & ) ;
		DrawParam_OpenGLES1& operator=( const DrawParam_OpenGLES1 & ) ;
	
	private:
		static const int DUMMY_GL_TEXTURE_NO = 9999 ;	//  generateした番号に立てるフラグ
		
	private:
        live2d::LDVector<GLuint>* 		texturesPtr ;				//  Destructorでテクスチャの解放は行わない。基本的に外部で行う。
	};
	
}
//------------ LIVE2D NAMESPACE ------------

#endif		// L2D_GRAPHICS_OPENGL_ES1
#endif		// __SKIP_DOC__
#endif		// __LIVE2D_DRAWPARAM_OPENGLES1_H__
