/*
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *
 *  Modify By DaidoujiChen https://github.com/DaidoujiChen
 *
 */

#import "LAppLive2DManager.h"
#import "LAppModel.h"
#import "LAppDefine.h"
#import "L2DMotionManager.h"
#import "PlatformManager.h"
#import "Live2DFramework.h"

using namespace live2d;
using namespace live2d::framework;

#pragma mark - Public Function

void LAppLive2DManager::releaseModel() {
    if (model) {
        delete model;
    }
}

void LAppLive2DManager::releaseView() {
    
    // ARC有効ならばreleaseと同様
    [view terminate];
    view = nil;
}

LAppView *LAppLive2DManager::createView(CGRect &rect) {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"create view x:%.0f y:%.0f width:%.2f height:%.2f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    }
    
    // Viewの初期化
    releaseView();
    view = [[LAppView alloc] initWithFrame:rect];
    [view setDelegate:this];
    return view;
}

void LAppLive2DManager::loadModel(const char *modelPath) {
    releaseModel();
    model = new LAppModel();
    model->load(modelPath);
    model->feedIn();
    onResume();
}

/*
 * タップしたときのイベント
 * @param tapCount
 * @return
 */
bool LAppLive2DManager::tapEvent(float x,float y) {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"tapEvent");
    }
    
    if (model->hitTest(HIT_AREA_HEAD, x, y)) {
        
        // 顔をタップしたら表情切り替え
        if (LAppDefine::DEBUG_LOG) {
            NSLog( @"tap face");
        }
        model->setRandomExpression();
    }
    else if (model->hitTest(HIT_AREA_BODY, x, y)) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog( @"tap body");
        }
        model->startRandomMotion(MOTION_GROUP_TAP_BODY, PRIORITY_NORMAL);
    }
    return true;
}

/*
 * フリックした時のイベント
 * @param
 * @param
 * @param flickDist
 */
void LAppLive2DManager::flickEvent(float x, float y) {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"flick x:%f y:%f", x, y);
    }
    
    if (model->hitTest(HIT_AREA_HEAD, x, y)) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog( @"flick head");
        }
        model->startRandomMotion(MOTION_GROUP_FLICK_HEAD, PRIORITY_NORMAL);
    }
}

void LAppLive2DManager::maxScaleEvent() {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"max scale event");
    }
    
    model->startRandomMotion(MOTION_GROUP_PINCH_IN, PRIORITY_NORMAL);
}

void LAppLive2DManager::minScaleEvent() {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"min scale event");
    }
    
    model->startRandomMotion(MOTION_GROUP_PINCH_OUT, PRIORITY_NORMAL);
}

/*
 * シェイクイベント
 */
void LAppLive2DManager::shakeEvent() {
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"shake event");
    }
    
    model->startRandomMotion(MOTION_GROUP_SHAKE, PRIORITY_FORCE);
}

/*
 * Activityが再開された時のイベント
 */
void LAppLive2DManager::onResume() {
    if (view) {
        [view startAnimation];
    }
}

/*
 * Activityがポーズされた時のイベント
 */
void LAppLive2DManager::onPause() {
    if (view) {
        [view stopAnimation];
    }
}

void LAppLive2DManager::setDrag(float x, float y) {
    model->setDrag(x, y);
}

void LAppLive2DManager::setAccel(float x, float y, float z) {
    model->setAccel(x, y, z);
}

L2DViewMatrix *LAppLive2DManager::getViewMatrix() {
    return view.viewMatrix;
}

#pragma mark - Life Cycle

LAppLive2DManager::LAppLive2DManager():model(NULL) {
    
	// 以下の命令でメモリリークの検査を実施（DEBUGモードのみ）
	// Live2D::dispose()時に、Live2Dの管理するメモリでリークが発生していた場合にダンプする
	// 	リークしている場合は、MEMORY_DEBUG_MEMORY_INFO_ALLでより詳細な情報をダンプします
	// 検査用のデータはglobal new演算子を使います
	// live2d::UtDebug::addMemoryDebugFlags( live2d::UtDebug::MEMORY_DEBUG_MEMORY_INFO_COUNT );//メモリリークの検出用
	Live2D::init();
	Live2DFramework::setPlatformManager(new PlatformManager());
}

LAppLive2DManager::~LAppLive2DManager() {
	releaseModel();
    releaseView();
	Live2D::dispose();
}
