/**
 *  UtOpenGLES2.h
 *
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */
#ifndef __UT_OPENGLES2__
#define __UT_OPENGLES2__


#ifndef __SKIP_DOC__

#ifdef  L2D_GRAPHICS_OPENGL_ES2


//------------ LIVE2D NAMESPACE ------------
namespace live2d
{ 


	class UtOpenGLES2
	{
	public:
		static void disposeShader() ;
		static bool compileShader(GLuint *shader , GLenum type , const char *shaderSource ) ;
		static bool linkProgram(GLuint prog) ;
		static bool validateProgram(GLuint prog) ;
		static GLuint loadShaders(const char* vertShaderSrc, const char * fragShaderSrc ) ;

		static GLuint fboTextureNo;
		static void setFramebufferTexture( GLuint fbo );
		static GLuint getFramebufferTexture();
	};


} //------------ LIVE2D NAMESPACE ------------


#endif


#endif // __SKIP_DOC__

#endif // __UT_OPENGLES2__
