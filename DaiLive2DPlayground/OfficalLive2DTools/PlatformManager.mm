/**
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *
 *  Modify By DaidoujiChen https://github.com/DaidoujiChen
 *
 */

#import "PlatformManager.h"
#import "FileManager.h"
#import "Live2DModelIPhone.h"
#import "LAppTextureDesc.h"

using namespace live2d;
using namespace live2d::framework;

#pragma mark - Public Function

unsigned char *PlatformManager::loadBytes(const char *path, size_t *size) {
    NSString *pathString = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
    NSData *data = [FileManager openBundle:pathString];
    *size = data.length;
    unsigned char *buf = (unsigned char *)data.bytes;
    return buf;
}

ALive2DModel *PlatformManager::loadLive2DModel(const char *path) {
    size_t size;
    unsigned char *buf = loadBytes(path, &size);
    
    //Create Live2D Model Instance
    ALive2DModel *live2DModel = Live2DModelIPhone::loadModel(buf, (int)size);
    return live2DModel;
}

L2DTextureDesc *PlatformManager::loadTexture(ALive2DModel *model, int no, const char *path) {
    GLuint glTexNo = [FileManager loadGLTexture:[NSString stringWithCString:path encoding:NSUTF8StringEncoding]];
    
    // テクスチャとモデルを結びつける
    ((Live2DModelIPhone *)model)->setTexture(no, glTexNo);
    
    LAppTextureDesc *desc = new LAppTextureDesc(glTexNo);
    return desc;
}

void PlatformManager::log(const char *txt) {
    NSLog(@"%@", [NSString stringWithCString:txt encoding:NSUTF8StringEncoding]);
}

#pragma mark - Life Cycle

PlatformManager::PlatformManager(void) {
}


PlatformManager::~PlatformManager(void) {
}
