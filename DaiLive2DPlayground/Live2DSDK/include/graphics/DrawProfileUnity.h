/**
 *  DrawProfileUnity.h
 *
 *  Created by Live2D on 2013/08/02.
 *  Copyright(c) Live2D Inc. All rights reserved.
 *  [[ CONFIDENTIAL ]]
 */

#ifndef __Live2D__DrawProfileUnity__
#define __Live2D__DrawProfileUnity__
#include "../Live2D.h"
#ifdef L2D_BUILD_FOR_UNITY


#ifndef __SKIP_DOC__

//------------ LIVE2D NAMESPACE ------------
namespace live2d
{
	
class DrawProfileUnity {
public:
	static void preDraw ( );
	static void postDraw ( );
};
	
}
//------------ LIVE2D NAMESPACE ------------

#endif //L2D_BUILD_FOR_UNITY
#endif //__SKIP_DOC__
#endif /* defined(__Live2D__DrawProfileUnity__) */
