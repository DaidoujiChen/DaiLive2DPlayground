/**
 *  MemoryInfo.h
 *
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */
#pragma once


#ifndef __SKIP_DOC__

#include "../../Live2D.h"


//--------- LIVE2D NAMESPACE ------------
namespace live2d 
{ 

	class AMemoryHolder ;

	#ifndef NULL
	#  define NULL    0
	#endif


	//******************************************************
	class MemoryInfo // デバッグ用なので管理外
	{
		friend class UtMemory ;
		friend class MemoryInfoSet ;
	public:
		MemoryInfo(void);
		~MemoryInfo(void);

		void dump(const char* message , l2d_size_t  cur , l2d_size_t  peak) ;
#ifdef L2D_DEBUG
		const char* getFileName( const char* path ) ;
#endif

	private:
		int				index ;
		void*			ptr ;
		l2d_size_t		size ;
		const char*		fileName ;
		int				lineNo ;

		AMemoryHolder*	allocator ;
		MemoryInfo*		next ;

	};

}
//--------- LIVE2D NAMESPACE ------------

#endif // __SKIP_DOC__
