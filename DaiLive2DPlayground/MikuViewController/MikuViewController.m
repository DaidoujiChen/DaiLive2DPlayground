//
//  MikuViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/22.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "MikuViewController.h"

@interface MikuViewController ()

@property (nonatomic, assign) BOOL isEyeClosing;
@property (nonatomic, assign) double eyeSpeed;

@end

@implementation MikuViewController

#pragma mark - Method Override

- (void)defaultModelSetting:(Live2DInfoLoader *)loader {
    loader.parameter[@"PARAM_EYE_L_SMILE"].value = 1.0;
    loader.parameter[@"PARAM_EYE_R_SMILE"].value = 1.0;
    loader.parameter[@"PARAM_MOUTH_FORM"].value = 1.0;
    loader.parameter[@"PARAM_MOUTH_OPEN_Y"].value = 1.0;
    self.isEyeClosing = NO;
}

- (void)animateModelSetting:(Live2DInfoLoader *)loader onTime:(UInt64)time {
    double globalTime = time / 500.0;
    loader.parameter[@"PARAM_ANGLE_Z"].value = 30.0 * sin(globalTime);
    loader.parameter[@"PARAM_ARM_L"].value = sin(globalTime);
    loader.parameter[@"PARAM_ARM_R"].value = cos(globalTime);
    loader.parameter[@"PARAM_BODY_ANGLE_X"].value = 10.0 * sin(globalTime);
    loader.parameter[@"PARAM_BODY_ANGLE_Y"].value = 10.0 * sin(globalTime);
    loader.parameter[@"PARAM_BODY_ANGLE_Z"].value = 10.0 * sin(globalTime);
    loader.parameter[@"PARAM_HAIR_FRONT"].value = sin(globalTime);
    loader.parameter[@"PARAM_HAIR_SIDE"].value = sin(globalTime);
    loader.parameter[@"PARAM_HAIR_BACK"].value = sin(globalTime);
    loader.parameter[@"PARAM_HAIR_BACK_L"].value = sin(globalTime);
    loader.parameter[@"PARAM_HAIR_BACK_R"].value = sin(globalTime);
    loader.parameter[@"PARAM_CHEEK"].value = (sin(globalTime) + 1.0) / 2.0;
    loader.parameter[@"PARAM_BREATH"].value = (cos(globalTime) + 1.0) / 2.0;
    
    if ((sin(globalTime) + 1.0) >= 1.9 && !self.isEyeClosing) {
        self.isEyeClosing = YES;
        self.eyeSpeed = (arc4random() % 200 + 100);
    }
    else if (self.isEyeClosing) {
        double eyeTime = time / self.eyeSpeed;
        loader.parameter[@"PARAM_EYE_L_OPEN"].value = sin(eyeTime) + 1.0;
        loader.parameter[@"PARAM_EYE_R_OPEN"].value = sin(eyeTime) + 1.0;
        if ((sin(eyeTime) + 1.0) >= 1.9) {
            self.isEyeClosing = NO;
        }
    }
}

#pragma mark - Life Cycle

- (id)init {
    self = [super initFromBundlePath:@"/Miku/model.plist"];
    if (self) {
    }
    return self;
}

@end
