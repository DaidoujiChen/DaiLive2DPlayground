//
//  Live2DParameter.m
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DParameter.h"
#import <objc/runtime.h>

@implementation Live2DParameter

#pragma mark - Private Class Method

// 快取調用過的值
+ (Live2DParameterValue *)cacheForParameterValue:(NSString *)parameter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *cacheTable = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cacheTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd)[parameter];
}

#pragma mark - Class Method

+ (Live2DParameter *)shard {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [Live2DParameter new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Live2DParameterValueDelegate

// 改變 parameter 值
- (void)setValue:(double)value forParameter:(NSString *)parameter {
    [self.delegate setValue:value forParameter:parameter];
}

// 取得當前 parameter 值
- (double)valueForParameter:(NSString *)parameter {
    return [self.delegate valueForParameter:parameter];
}

#pragma mark - Custom Keyed Subscripting

- (Live2DParameterValue *)objectForKeyedSubscript:(NSString *)parameter {
    Live2DParameterValue *parameterValue = [Live2DParameter cacheForParameterValue:parameter];
    if (!parameterValue) {
        NSDictionary *info = [self.delegate infoForParameter:parameter];
        parameterValue = [[Live2DParameterValue alloc] initWithParameter:parameter andMax:[info[@"Max"] doubleValue] andMin:[info[@"Min"] doubleValue]];
        parameterValue.delegate = self;
    }
    return parameterValue;
}

@end
