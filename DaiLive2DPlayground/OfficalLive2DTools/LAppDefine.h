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

// 畫面範圍, 與縮放配置
static const float VIEW_MAX_SCALE               = 2.0f;
static const float VIEW_MIN_SCALE               = 0.8f;

static const float VIEW_LOGICAL_LEFT            = -1;
static const float VIEW_LOGICAL_RIGHT           = 1;

static const float VIEW_LOGICAL_MAX_LEFT        = -2;
static const float VIEW_LOGICAL_MAX_RIGHT       = 2;
static const float VIEW_LOGICAL_MAX_BOTTOM      = -2;
static const float VIEW_LOGICAL_MAX_TOP         = 2;

// 設定背景檔案
static const char *BACK_IMAGE_NAME              = "back_class_normal.png";

// Model 檔案設定
static const char *MODEL_HARU                   = "HaruFullPack/haru.model.json";
static const char *MODEL_HARU_A                 = "HaruFullPack/haru_01.model.json";
static const char *MODEL_HARU_B                 = "HaruFullPack/haru_02.model.json";
static const char *MODEL_SHIZUKU                = "ShizukuFullPack/shizuku.model.json";
static const char *MODEL_WANKO                  = "WankoFullPack/wanko.model.json";

// Model 對應行為
// 閒置
static const char *MOTION_GROUP_IDLE			= "idle";

// 點到身體
static const char *MOTION_GROUP_TAP_BODY		= "tap_body";

// 摸頭
static const char *MOTION_GROUP_FLICK_HEAD      = "flick_head";

// 兩指內縮, model 放大
static const char *MOTION_GROUP_PINCH_IN		= "pinch_in";

// 兩指擴大, model 縮小
static const char *MOTION_GROUP_PINCH_OUT		= "pinch_out";

// 搖晃
static const char *MOTION_GROUP_SHAKE			= "shake";

// 點擊範圍定義
// 點到頭
static const char *HIT_AREA_HEAD                = "head";

// 點到身體
static const char *HIT_AREA_BODY                = "body";

// 行為優先順序
static const int PRIORITY_NONE                  = 0;
static const int PRIORITY_IDLE                  = 1;
static const int PRIORITY_NORMAL                = 2;
static const int PRIORITY_FORCE                 = 3;

// Debug 開關
class LAppDefine {
    
public:
    
    // デバッグ用ログの表示
    static const bool DEBUG_LOG = false;
    
    // タッチしたときの冗長なログの表示
    static const bool DEBUG_TOUCH_LOG = false;
    
    // あたり判定の可視化
	static const bool DEBUG_DRAW_HIT_AREA = false;
};
