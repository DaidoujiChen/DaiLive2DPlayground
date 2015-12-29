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

#import "LAppModel.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "LAppDefine.h"
#import "L2DStandardID.h"
#import "Live2DModelIPhone.h"
#import "FileManager.h"
#import "OffscreenImage.h"

using namespace std;
using namespace live2d;
using namespace live2d::framework;

LAppModel::LAppModel():L2DBaseModel(), modelSetting(NULL), voice(NULL) {
    if (LAppDefine::DEBUG_LOG) {
        mainMotionMgr->setMotionDebugMode(true);
    }
}

LAppModel::~LAppModel(void) {
    if(LAppDefine::DEBUG_LOG) {
        NSLog(@"delete model");
    }
	
    modelSetting = nil;
	
	if(voice) {
		[voice stop];
		voice = nil;
	}
}

/*
 * Live2DモデルをOpenGLを使用して初期化する。
 * OpenGLは別々のスレッドからアクセスできないので注意。
 * メインスレッドからOpenGLを初期化しているなら、このメソッドもメインスレッドから呼ぶこと。
 */
void LAppModel::load(const char path[]) {
    string modelSettingPath = path;
	NSString *dir = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
    modelHomeDir = dir.stringByDeletingLastPathComponent.UTF8String;
	modelHomeDir += "/";
    
    if (LAppDefine::DEBUG_LOG) {
        NSLog( @"create model : %s",path);
    }
    
    updating = true;
    initialized = false;
    
    // Load Model From Json
    NSData *data = [FileManager openBundleWithCString:modelSettingPath.c_str()];
    modelSetting = [[ModelSetting alloc] initWithData:data];
	
    if (strcmp(modelSetting.modelFile, "") != 0) {
		string path = modelSetting.modelFile;
		path = modelHomeDir + path;
        loadModelData(path.c_str());
		
        int count = modelSetting.textureCount;
		textures.resize(count);
		
		for (int index = 0; index < count; index++) {
            string texturePath = [modelSetting textureAtIndex:index];
			texturePath = modelHomeDir + texturePath;
			loadTexture((int)index, texturePath.c_str());
		}
    }
	
    //Expression
	if (modelSetting.expressionCount > 0) {
		int count = modelSetting.expressionCount;
		for (int index = 0; index < count; index++) {
            string name = [modelSetting expressionNameAtIndex:index];
            string file = [modelSetting expressionFileAtIndex:index];
			file = modelHomeDir + file;
			loadExpression(name.c_str(),file.c_str());
		}
	}
	
	//Physics
	if(strcmp(modelSetting.physicsFile, "") != 0) {
		string path = modelSetting.physicsFile;
		path = modelHomeDir + path;
        loadPhysics(path.c_str());
    }
	
	//Pose
	if(strcmp(modelSetting.poseFile, "") != 0) {
		string path = modelSetting.poseFile;
		path = modelHomeDir + path;
        loadPose(path.c_str());
    }
	
	// 目パチ
	if (eyeBlink == NULL) {
		eyeBlink = new L2DEyeBlink();
	}
	
	// レイアウト
	map<string, float> layout;
    [modelSetting layout:layout];
	modelMatrix->setupLayout(layout);
	
	for (int index = 0; index < modelSetting.initParamCount; index++) {
		live2DModel->setParamFloat([modelSetting initParamIDAtIndex:index], [modelSetting initParamValueAtIndex:index]);
	}

	for (int index = 0; index < modelSetting.initPartsVisibleCount; index++) {
		live2DModel->setPartsOpacity([modelSetting initPartsVisibleIDAtIndex:index], [modelSetting initPartsVisibleValueAtIndex:index]);
	}
	
	live2DModel->saveParam();
	preloadMotionGroup(MOTION_GROUP_IDLE);
	mainMotionMgr->stopAllMotions();
	
    // 更新状態の完了
    updating = false;
    
    // 初期化完了
    initialized = true;
}

void LAppModel::preloadMotionGroup(const char name[]) {
    int count = [modelSetting motionCountByName:name];
    for (int index = 0; index < count; index++) {
        string motionFile = [modelSetting motionFileByName:name atIndex:index];
		string path = modelHomeDir + motionFile;
        
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"load motion name:%s",motionFile.c_str());
        }
        
        AMotion* motion = Live2DMotion::loadMotion([FileManager pathForResource:path.c_str()]);
        motion->setFadeIn((int)[modelSetting motionFadeInByName:name atIndex:index]);
        motion->setFadeOut((int)[modelSetting motionFadeOutByName:name atIndex:index]);
        motions[motionFile] = motion;
    }
}

void LAppModel::update() {
	dragMgr->update();
	dragX = dragMgr->getX();
	dragY = dragMgr->getY();
	
	//-----------------------------------------------------------------
    // 前回セーブされた状態をロード
	live2DModel->loadParam();
	if (mainMotionMgr->isFinished()) {
        
		// モーションの再生がない場合、待機モーションの中からランダムで再生する
		startRandomMotion(MOTION_GROUP_IDLE, PRIORITY_IDLE);
	}
	else {
        // モーションを更新
		bool update = mainMotionMgr->updateParam(live2DModel);
		
		if (!update) {
            
			// メインモーションの更新がないとき
            // 目パチ
			eyeBlink->setParam(live2DModel);
		}
	}
    
    // 状態を保存
	live2DModel->saveParam();
	//-----------------------------------------------------------------
	
    if (expressionMgr != NULL) {
        //  表情でパラメータ更新（相対変化）
        expressionMgr->updateParam(live2DModel);
    }
	
	// ドラッグによる変化
	// ドラッグによる顔の向きの調整
    // -30から30の値を加える
	live2DModel->addToParamFloat(PARAM_ANGLE_X, dragX * 30, 1);
	live2DModel->addToParamFloat(PARAM_ANGLE_Y, dragY * 30, 1);
	live2DModel->addToParamFloat(PARAM_ANGLE_Z, dragX * dragY * -30, 1);
	
	// ドラッグによる体の向きの調整
    // -10から10の値を加える
	live2DModel->addToParamFloat(PARAM_BODY_ANGLE_X, dragX * 10, 1);
	
	// ドラッグによる目の向きの調整
    // -1から1の値を加える
	live2DModel->addToParamFloat(PARAM_EYE_BALL_X, dragX, 1);
	live2DModel->addToParamFloat(PARAM_EYE_BALL_Y, dragY, 1);
	
	// 呼吸など
	l2d_int64 timeMSec = UtSystem::getUserTimeMSec() - startTimeMSec;
    
    // 2πt
	double t = (timeMSec / 1000.0) * 2 * 3.14159;
	
    // -15 ~ +15 まで周期的に加算。周期は他とずらす。
	live2DModel->addToParamFloat(PARAM_ANGLE_X, 15.0f * sin(t / 6.5345), 0.5f);
	live2DModel->addToParamFloat(PARAM_ANGLE_Y, 8.0f * sin(t / 3.5345), 0.5f);
	live2DModel->addToParamFloat(PARAM_ANGLE_Z, 10.0f * sin(t / 5.5345), 0.5f);
	live2DModel->addToParamFloat(PARAM_BODY_ANGLE_X, 4.0f * sin(t / 15.5345), 0.5f);
    
    // 0~1 まで周期的に設定。モーションを上書き。
	live2DModel->setParamFloat(PARAM_BREATH, 0.5f + 0.5f * sin(t / 3.2345), 1);
	
	// 加速度による変化
	live2DModel->addToParamFloat(PARAM_ANGLE_Z, 90 * accelX, 0.5f);
//	live2DModel->addToParamFloat(PARAM_ANGLE_Y,-90 * accelY ,0.5f);
//	live2DModel->addToParamFloat(PARAM_ANGLE_Z, 10 * accelX ,0.5f);
    
    if (physics != NULL) {
        
        // 物理演算でパラメータ更新
        physics->updateParam(live2DModel);
    }

	// リップシンクの設定
	if (lipSync) {
        // システムから音量を取得して0から1の値にする
		float value = 0;
		live2DModel->setParamFloat(PARAM_MOUTH_OPEN_Y, value, 0.8f);
	}
	
	// ポーズの設定
    if (pose != NULL) {
        pose->updateParam(live2DModel);
    }

	live2DModel->update();
}

/*
 * モデルを描画する。
 * プラットフォームごとの固有設定も行う。
 * モデルが設定されてない場合は何もしない。
 * @param gl
 */
void LAppModel::draw() {
    if (live2DModel == NULL) {
        return;
    }
    
	alpha += accAlpha;
	if (alpha < 0) {
		alpha = 0;
		accAlpha = 0;
	}
	else if (alpha > 1) {
		alpha = 1;
		accAlpha = 0;
	}
	
    if (alpha <= 0) {
        return;
    }
	
	if (alpha < 1) {
		// 半透明
		// オフスクリーンにモデルを描画
		[OffscreenImage setOffscreen];
		glClear(GL_COLOR_BUFFER_BIT);
        
        // ========== Push ==========
		glPushMatrix();
		{
			float *tr = modelMatrix->getArray();
			glMultMatrixf(tr);
			live2DModel->draw();
		}
		glPopMatrix();
        // ========== Pop ==========
		
		// 実際のウィンドウに半透明で描画
		[OffscreenImage setOnscreen];
        
        // ========== Push ==========
		glPushMatrix();
		{
			glLoadIdentity();
			[OffscreenImage drawDisplay:alpha];
		}
		glPopMatrix();
        // ========== Pop ==========
	}
	else {
		// 通常描画。
        // ========== Push ==========
		glPushMatrix();
		{
			float *tr = modelMatrix->getArray();
			glMultMatrixf(tr);
			live2DModel->draw();
			
		}
		glPopMatrix();
        // ========== Pop ==========
		
		if (LAppDefine::DEBUG_DRAW_HIT_AREA) {
            
			// デバッグ用当たり判定の描画
			drawHitRect();
		}
	}
}

int LAppModel::startMotion(const char name[], int no, int priority) {
	if (priority == PRIORITY_FORCE) {
		mainMotionMgr->setReservePriority(priority);
	}
	else if (!mainMotionMgr->reserveMotion(priority)) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"motion not start");
        }
		return -1;
	}
	
	string motionFile = [modelSetting motionFileByName:name atIndex:no];
	AMotion* motion = motions[motionFile];
	bool autoDelete = false;
	
	if (motion == NULL) {
        
		// 読み込み
		string path = modelHomeDir + motionFile;
		
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"load motion name:%s ",motionFile.c_str());
        }
		
		motion = Live2DMotion::loadMotion([FileManager pathForResource:path.c_str()]);
        motion->setFadeIn((int)[modelSetting motionFadeInByName:name atIndex:no]);
        motion->setFadeOut((int)[modelSetting motionFadeOutByName:name atIndex:no]);
		autoDelete = true;
	}
	
	if (strcmp([modelSetting motionSoundByName:name atIndex:no], "") == 0) {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"start motion : %s ",motionFile.c_str());
        }
        
        // 終了時にメモリから削除
		return mainMotionMgr->startMotionPrio(motion, autoDelete, priority);
	}
	else {
		string soundName = [modelSetting motionSoundByName:name atIndex:no];
		string soundPath = modelHomeDir + soundName;
		
        if(LAppDefine::DEBUG_LOG) {
            NSLog(@"start motion : %s  sound : %s",motionFile.c_str(),soundName.c_str());
        }
		startVoice(soundPath.c_str());
        
        // 終了時にメモリから削除
		return mainMotionMgr->startMotionPrio(motion,autoDelete,priority);
	}
}

int LAppModel::startRandomMotion(const char name[], int priority) {
    if ([modelSetting motionCountByName:name] == 0) {
        return -1;
    }
    int no = rand() % [modelSetting motionCountByName:name];
    return startMotion(name,no,priority);
}

void LAppModel::setExpression(const char expressionID[]) {
	AMotion* motion = expressions[expressionID];
    if (LAppDefine::DEBUG_LOG) {
        NSLog(@"expression[%s]", expressionID);
    }
    
	if(motion != NULL) {
		expressionMgr->startMotion(motion, false);
	}
	else {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"expression[%s] is null ", expressionID);
        }
	}
}

void LAppModel::setRandomExpression() {
	int no = rand() % expressions.size();
	map<string, AMotion *>::const_iterator map_ite;
	int i = 0;
	for (map_ite = expressions.begin(); map_ite != expressions.end(); map_ite++) {
		if (i == no) {
			string name = (*map_ite).first;
			setExpression(name.c_str());
			return;
		}
		i++;
	}
}

/*
 * 当たり判定との簡易テスト。
 * 指定IDの頂点リストからそれらを含む最大の矩形を計算し、点がそこに含まれるか判定
 *
 * @param id
 * @param testX
 * @param testY
 * @return
 */
bool LAppModel::hitTest(const char pid[],float testX,float testY) {
    
    if (alpha < 1) {
        // 透明時は当たり判定なし。
        return false;
    }
    
	int count = modelSetting.hitAreasCount;
	for (int index = 0; index < count; index++) {
        
		if (strcmp([modelSetting hitAreaNameAtIndex:index], pid) == 0) {
			const char *drawID = [modelSetting hitAreaIDAtIndex:index];
			int drawIndex = live2DModel->getDrawDataIndex(drawID);
            if (drawIndex < 0) {
                
                // 存在しない場合はfalse
                return false;
            }
            
			int count=0;
			float *points = live2DModel->getTransformedPoints(drawIndex, &count);
			float left = live2DModel->getCanvasWidth();
			float right = 0;
			float top = live2DModel->getCanvasHeight();
			float bottom = 0;
			
			for (int j = 0; j < count * 2; j += 2) {
				float x = points[j];
				float y = points[j+1];
                
                if (x < left) {
                    //  最小のx
                    left = x;
                }
                
                if (x > right) {
                    //  最大のx
                    right=x;
                }
                
                if (y < top) {
                    //  最小のy
                    top = y;
                }
                
                if (y > bottom) {
                    //  最大のy
                    bottom = y;
                }
			}
			
			float tx = modelMatrix->invertTransformX(testX);
			float ty = modelMatrix->invertTransformY(testY);
			
			return ( left <= tx && tx <= right && top <= ty && ty <= bottom );
		}
	}
    
    // 存在しない場合はfalse
	return false;
}

void LAppModel::startVoice( const char filename[]) {
	if (voice) {
		[voice stop];
		voice = nil;
	}
	
	// セリフ用のAVAudioPlayerを生成します
	NSURL *url = [FileManager fileURLWithCString:filename];
	if (url) {
		voice = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        voice.numberOfLoops = 0;
        voice.meteringEnabled = YES;
		[voice play];
	}
	else {
        if (LAppDefine::DEBUG_LOG) {
            NSLog(@"sound file not exists. %s",filename);
        }
	}
}

void LAppModel::feedIn() {
	alpha = 0;
	accAlpha = 0.05;
}

/*
 * デバッグ用当たり判定の表示
 */
void LAppModel::drawHitRect() {
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
    
    // ========== Push ==========
	glPushMatrix();
	{
		glMultMatrixf(modelMatrix->getArray());
		int count = [modelSetting hitAreasCount];
		for (int index = 0; index < count; index++) {
			string drawID = [modelSetting hitAreaIDAtIndex:index];
			int drawIndex = live2DModel->getDrawDataIndex(drawID.c_str());
            if (drawIndex < 0) {
                continue;
            }
			int count = 0;
			float *points = live2DModel->getTransformedPoints(drawIndex, &count);
			float left = live2DModel->getCanvasWidth();
			float right = 0;
			float top = live2DModel->getCanvasHeight();
			float bottom = 0;
			
			for (int j = 0; j < count * 2; j += 2) {
				float x = points[j];
				float y = points[j+1];
                
                if (x < left) {
                    //  最小のx
                    left = x;
                }
                
                if (x > right) {
                    //  最大のx
                    right = x;
                }
                
                if (y < top) {
                    //  最小のy
                    top = y;
                }
                
                if (y > bottom) {
                    //  最大のy
                    bottom = y;
                }
			}
			float vertex[] = { left, top, right, top, right, bottom, left, bottom, left, top };
            
			// 色は適当に作る
			float r = (index % 2 == 0) ? 1 : 0;
			float g = (index / 2 % 2 == 0) ? 1 : 0;
			float b = (index / 4 % 2 == 0) ? 1 : 0;
			float a = 0.5f;
			int size = 2;
			float color[] = { r, g, b, a, r, g, b, a, r, g, b, a, r, g, b, a, r, g, b, a };
			
            // 描画サイズをsizeにする
			glLineWidth(size);
            
            // 表示座標のセット
			glVertexPointer(2, GL_FLOAT, 0, vertex);
            
            // カラーのセット
			glColorPointer(4, GL_FLOAT, 0, color);
            
            // pointNumだけ描画する
			glDrawArrays(GL_LINE_STRIP, 0, 5);
		}
	}
	glPopMatrix();
    // ========== Pop ==========
    
	glEnable( GL_TEXTURE_2D );
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glEnableClientState( GL_VERTEX_ARRAY );
	glDisableClientState( GL_COLOR_ARRAY );
}
