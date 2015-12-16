/**
 *  MemoryInfoSet.h
 *
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */

#pragma once


#ifndef __SKIP_DOC__

#include "../../Live2D.h"

#ifndef NULL
#  define NULL    0
#endif


//--------- LIVE2D NAMESPACE ------------
namespace live2d 
{

	class AMemoryHolder ;
	class MemoryParam ;
	class MemoryInfo ;


	//******************************************************
	class MemoryInfoSet // デバッグ用なので管理外
	{
		friend class UtMemory ;
		friend class MemoryInfo ;
	public:
		MemoryInfoSet(const char* setName);
		~MemoryInfoSet(void);

		void dump(const char* message = NULL ) ;
		void dumpList( MemoryInfo *info ) ;

		void addMemoryInfo( void* ptr , MemoryParam* owner , l2d_size_t size , const char* filename , int lineno ) ;
		void removeMemoryInfo( void* ptr ) ;

		int getMallocTotal(){ return mallocTotal ; }	// mallocの回数をカウント
		int	getRestCount(){ return restCount ; }		// 確保しているポインタ数をカウント (mallocで++ , freeで--)
		int	getTotalMemory(){ return totalMemory ; }	// 累積メモリ

		int getCurMemory(){ return curMemory ; }		// 現在のメモリ
		int getPeakMemory(){ return peakMemory ; }		// 最大時のメモリ

	private:
		const char*		setName ;

		int				mallocTotal ;			// mallocの回数をカウント
		int				restCount ;				// 確保しているポインタ数をカウント (mallocで++ , freeで--)
		int				totalMemory ;			// 累積メモリ
		int				curMemory ;				// 現在のメモリ
		int				peakMemory ;			// 最大時のメモリ

		MemoryInfo*		usingMemoryInfo ;		// 使用中メモリ情報の先頭（連結リスト）
		MemoryInfo*		lastUsingMemoryInfo ;	// 使用中メモリ情報リストの最後尾（連結リスト）
		MemoryInfo*		freeMemoryInfo ;		// 解放済みメモリ情報リスト（連結リスト）
		MemoryInfo*		lastFreeMemoryInfo ;	// 解放済みメモリ情報リストの最後尾（連結リスト）
	};
}
//--------- LIVE2D NAMESPACE ------------

#endif // __SKIP_DOC__

