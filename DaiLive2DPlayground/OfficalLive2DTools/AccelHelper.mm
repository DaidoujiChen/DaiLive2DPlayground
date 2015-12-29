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

#import "AccelHelper.h"
#import <CoreMotion/CoreMotion.h>
#import "util/UtSystem.h"

#define ACCEL_INTERVAL (0.1f)
#define ACCEL_THREASHOLD (0.1f)
#define ACCEL_MODE_IDLING (NO)
#define ACCEL_MODE_ACTIVE (YES)
#define ACCEL_AVERAGE_COUNT (10)
#define ACCEL_ACTIVE_PERIOD (10)
#define MAX_ACCEL_D (0.1f)
#define MAX_SCALE_VALUE (0.4f)

typedef enum {
    AccelHelperTypeX = 0,
    AccelHelperTypeY,
    AccelHelperTypeZ
} AccelHelperType;

@interface AccelHelper ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) long long lastTimeMSec;
@property (nonatomic, assign) float lastMove;

@property (nonatomic, assign) BOOL accelMode;
@property (nonatomic, strong) NSMutableArray *accelData;
@property (nonatomic, strong) NSMutableArray *accel;
@property (nonatomic, assign) int accelCounter;
@property (nonatomic, assign) int accelActiveModeEnd;
@property (nonatomic, assign) float accelInterval;

@property (nonatomic, assign) float acceleration_x;
@property (nonatomic, assign) float acceleration_y;
@property (nonatomic, assign) float acceleration_z;
@property (nonatomic, assign) float dst_acceleration_x;
@property (nonatomic, assign) float dst_acceleration_y;
@property (nonatomic, assign) float dst_acceleration_z;

@property (nonatomic, assign) float last_dst_acceleration_x;
@property (nonatomic, assign) float last_dst_acceleration_y;
@property (nonatomic, assign) float last_dst_acceleration_z;

@end

@implementation AccelHelper

#pragma mark - Readonly Property

- (float)shake {
    return self.lastMove;
}

- (float)accelX {
    return [self.accel[AccelHelperTypeX] floatValue];
}

- (float)accelY {
    return [self.accel[AccelHelperTypeY] floatValue];
}

- (float)accelZ {
    return [self.accel[AccelHelperTypeZ] floatValue];
}

#pragma mark - Private Instance Method

#pragma mark * Init

- (void)setupInitValues {
    self.lastTimeMSec = -1;
    
    self.accelMode = ACCEL_MODE_IDLING;
    self.accelCounter = 0;
    self.accelData = [NSMutableArray array];
    for (int index = 0; index < ACCEL_AVERAGE_COUNT; index++) {
        [self.accelData addObject:@(0)];
    }
    self.accel = [NSMutableArray array];
    for (int index = 0; index < 3; index++) {
        [self.accel addObject:@(0)];
    }
    self.accelActiveModeEnd = ACCEL_AVERAGE_COUNT * 2;
    self.accelInterval = ACCEL_INTERVAL;
    
    self.acceleration_x = 0;
    self.acceleration_y = 0;
    self.acceleration_z = 0;
    self.dst_acceleration_x = 0;
    self.dst_acceleration_y = 0;
    self.dst_acceleration_z = 0;
    
    self.last_dst_acceleration_x = 0;
    self.last_dst_acceleration_y = 0;
    self.last_dst_acceleration_z = 0;
}

#pragma mark - Instance Method

- (void)update {
    float dx = self.dst_acceleration_x - self.acceleration_x;
    float dy = self.dst_acceleration_y - self.acceleration_y;
    float dz = self.dst_acceleration_z - self.acceleration_z;
    
    if (dx >  MAX_ACCEL_D) {
        dx =  MAX_ACCEL_D;
    }
    else if (dx < -MAX_ACCEL_D) {
        dx = -MAX_ACCEL_D;
    }
    
    if (dy >  MAX_ACCEL_D) {
        dy =  MAX_ACCEL_D;
    }
    else if (dy < -MAX_ACCEL_D) {
        dy = -MAX_ACCEL_D;
    }
    
    if (dz >  MAX_ACCEL_D) {
        dz =  MAX_ACCEL_D;
    }
    else if(dz < -MAX_ACCEL_D) {
        dz = -MAX_ACCEL_D;
    }
    
    self.acceleration_x += dx;
    self.acceleration_y += dy;
    self.acceleration_z += dz;
    
    long long time = live2d::UtSystem::getTimeMSec();
    long long diff = time - self.lastTimeMSec;
    self.lastTimeMSec = time;
    
    // 経過時間に応じて、重み付けをかえる
    float scale = 0.2 * diff * 60 / (1000.0f);
    
    if (scale > MAX_SCALE_VALUE) {
        scale = MAX_SCALE_VALUE;
    }
    
    double xValue = [self.accel[AccelHelperTypeX] floatValue];
    double yValue = [self.accel[AccelHelperTypeY] floatValue];
    double zValue = [self.accel[AccelHelperTypeZ] floatValue];
    self.accel[AccelHelperTypeX] = @((self.acceleration_x * scale) + (xValue * (1.0 - scale)));
    self.accel[AccelHelperTypeY] = @((self.acceleration_y * scale) + (yValue * (1.0 - scale)));
    self.accel[AccelHelperTypeZ] = @((self.acceleration_z * scale) + (zValue * (1.0 - scale)));
}

- (void)resetShake {
    self.lastMove = 0;
}

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
	if (self) {
        
        // 基本設定值
        [self setupInitValues];
        
        // 加速器初始化
        self.motionManager = [CMMotionManager new];
        AccelHelper __weak *weakSelf = self;
        if (self.motionManager.isAccelerometerAvailable) {
            self.motionManager.accelerometerUpdateInterval = self.accelInterval;
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
                // 加速度の変化が少ない場合に無視するようにする
                // 一定量変化(ACCEL_THREASHOLD)が無いときは、小さな変化を無視する  ACCEL_IDLING_MODE
                // 一定量以上の変化が発生したあとは、一定期間（ACCEL_ACTIVE_TIME) ACCEL_ACTIVE_MODE として小さな変化も受け付ける
                double curAccelValue = accelerometerData.acceleration.x + accelerometerData.acceleration.y + accelerometerData.acceleration.z;
                int indexOfAccelData = (weakSelf.accelCounter++) % ACCEL_AVERAGE_COUNT;
                weakSelf.accelData[indexOfAccelData] = @(curAccelValue);
                
                double curAccelAve = 0;
                for (int index = 0; index < ACCEL_AVERAGE_COUNT; index++) {
                    curAccelAve += [weakSelf.accelData[index] floatValue];
                }
                curAccelAve /= ACCEL_AVERAGE_COUNT;
                
                if (fabs(curAccelAve - curAccelValue) > ACCEL_THREASHOLD) {
                    // 一定期間伸ばす
                    weakSelf.accelActiveModeEnd = weakSelf.accelCounter + ACCEL_ACTIVE_PERIOD;
                }
                weakSelf.accelMode = (weakSelf.accelCounter < weakSelf.accelActiveModeEnd) ? ACCEL_MODE_ACTIVE : ACCEL_MODE_IDLING;
                
                // アイドリングモードの場合は、加速度変化を反映せずに終了
                if (weakSelf.accelMode == ACCEL_MODE_IDLING) {
                    return;
                }
                
                // 計測された値を前後の値と平均化する
                float scale1 = 0.5;
                weakSelf.dst_acceleration_x = weakSelf.dst_acceleration_x * scale1 + accelerometerData.acceleration.x * (1-scale1);
                weakSelf.dst_acceleration_y = weakSelf.dst_acceleration_y * scale1 + accelerometerData.acceleration.y * (1-scale1);
                weakSelf.dst_acceleration_z = weakSelf.dst_acceleration_z * scale1 + accelerometerData.acceleration.z * (1-scale1);
                
                // ---- 以下はぐるぐる用の処理
                double move = fabs(weakSelf.dst_acceleration_x - weakSelf.last_dst_acceleration_x) + fabs(weakSelf.dst_acceleration_y - weakSelf.last_dst_acceleration_y) + fabs(weakSelf.dst_acceleration_z - weakSelf.last_dst_acceleration_z);
                weakSelf.lastMove = weakSelf.lastMove * 0.7 + move * 0.3;
                
                weakSelf.last_dst_acceleration_x = weakSelf.dst_acceleration_x;
                weakSelf.last_dst_acceleration_y = weakSelf.dst_acceleration_y;
                weakSelf.last_dst_acceleration_z = weakSelf.dst_acceleration_z;
            }];
        }
	}
	return self;
}

- (void)dealloc {
    [self.motionManager stopAccelerometerUpdates];
}

@end
