//
//  Live2DParameterValue.m
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/20.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DParameterValue.h"

@interface Live2DParameterValue ()

@property (nonatomic, strong) NSString *parameter;
@property (nonatomic, assign) double max;
@property (nonatomic, assign) double min;

@end

@implementation Live2DParameterValue

#pragma mark - Value Change

// 改變 parameter 值
- (void)setValue:(double)value {
    [self.delegate setValue:value forParameter:self.parameter];
}

// 取得當前 parameter 值
- (double)value {
    return [self.delegate valueForParameter:self.parameter];
}

#pragma mark - Life Cycle

- (id)initWithParameter:(NSString *)parameter andMax:(double)max andMin:(double)min {
    self = [super init];
    if (self) {
        self.parameter = parameter;
        self.max = max;
        self.min = min;
    }
    return self;
}

@end
