//
//  WankoromochiViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/21.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "WankoromochiViewController.h"

@interface WankoromochiViewController ()

@property (nonatomic, assign) BOOL isEyeClosing;
@property (nonatomic, assign) double eyeSpeed;

@end

@implementation WankoromochiViewController

#pragma mark - Method Override

- (void)defaultModelSetting:(Live2DInfoLoader *)loader {
}

- (void)animateModelSetting:(Live2DInfoLoader *)loader onTime:(UInt64)time {
    double globalTime = time / 1000.0;
    loader.parameter[@"PARAM_ANGLE_Z"].value = loader.parameter[@"PARAM_ANGLE_Z"].max * sin(globalTime);
    loader.parameter[@"PARAM_BODY_ANGLE_Z"].value = loader.parameter[@"PARAM_ANGLE_Z"].max * sin(globalTime);
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
    self = [super initFromBundlePath:@"/Wankoromochi/model.plist"];
    if (self) {
    }
    return self;
}

@end
