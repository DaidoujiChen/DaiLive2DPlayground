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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "stdio.h"
#import <string>
#import <map>

using namespace std;

@interface ModelSetting : NSObject

// init
- (id)initWithData:(NSData *)jsonData;

// 基本檔案
@property (nonatomic, readonly) const char *modelName;
@property (nonatomic, readonly) const char *modelFile;
@property (nonatomic, readonly) const char *physicsFile;
@property (nonatomic, readonly) const char *poseFile;

// 模型材質
@property (nonatomic, readonly) int textureCount;
- (const char *)textureAtIndex:(int)index;

// 參數設置
@property (nonatomic, readonly) int initParamCount;
- (float)initParamValueAtIndex:(int)index;
- (const char *)initParamIDAtIndex:(int)index;

// 部位設置
@property (nonatomic, readonly) int initPartsVisibleCount;
- (float)initPartsVisibleValueAtIndex:(int)index;
- (const char *)initPartsVisibleIDAtIndex:(int)index;

// 點擊設置
@property (nonatomic, readonly) int hitAreasCount;
- (const char *)hitAreaIDAtIndex:(int)index;
- (const char *)hitAreaNameAtIndex:(int)index;

// 表情設置
@property (nonatomic, readonly) int expressionCount;
- (const char *)expressionFileAtIndex:(int)index;
- (const char *)expressionNameAtIndex:(int)index;

// 動作設置
@property (nonatomic, readonly) int motionGroupCount;
- (int)motionCountByName:(const char *)name;
- (const char *)motionFileByName:(const char *)name atIndex:(int)index;
- (const char *)motionSoundByName:(const char*)name atIndex:(int)index;
- (int)motionFadeInByName:(const char*)name atIndex:(int)index;
- (int)motionFadeOutByName:(const char*)name atIndex:(int)index;
- (const char *)motionGroupNameAtIndex:(int)index;

- (BOOL)layout:(std::map<std::string, float>&)layout;

@end
