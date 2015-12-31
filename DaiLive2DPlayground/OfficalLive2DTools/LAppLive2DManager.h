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

#import <UIKit/UIKit.h>
#import "type/LDVector.h"
#import "L2DViewMatrix.h"
#import "LAppView.h"

class LAppModel;

class LAppLive2DManager {
    
private :
    
	// モデルデータ
	LAppModel *model;
	
    // OpenGLのView
    LAppView *view;
    
    void releaseView();
    
public:
    LAppLive2DManager();    
    ~LAppLive2DManager();
	
    // 解放
	void releaseModel();
	
	// 初期化
	void init();
    
	// Live2Dモデル用のOpenGL画面を作成
    LAppView *createView(CGRect &rect);
	LAppView *getView() {
        return view;
    }
	
	// モデルの取得
    LAppModel *getModel() {
        return model;
    }
    
	// モデルの変更
    void loadModel(const char *modelPath);
	
	// 操作によるイベント
    bool tapEvent(float x,float y);
    void flickEvent(float x,float y);
    void maxScaleEvent();    
    void minScaleEvent();
    void shakeEvent();
    void onResume();
    void onPause();
    void setDrag(float x, float y);
    void setAccel(float x, float y, float z);
    
	// 画面表示の行列取得
	live2d::framework::L2DViewMatrix *getViewMatrix();
    
};
