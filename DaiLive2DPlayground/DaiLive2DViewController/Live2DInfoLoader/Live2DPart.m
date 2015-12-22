//
//  Live2DPart.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/21.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DPart.h"
#import <objc/runtime.h>

@implementation Live2DPart

#pragma mark - Private Class Method

// 快取調用過的值
+ (Live2DPartValue *)cacheForPartValue:(NSString *)part {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *cacheTable = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, cacheTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd)[part];
}

#pragma mark - Class Method

+ (Live2DPart *)shard {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, _cmd, [Live2DPart new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Live2DPartValueDelegate

// 改變 part 值
- (void)setValue:(double)value forPart:(NSString *)part {
    [self.delegate setValue:value forPart:part];
}

// 取得當前 part 值
- (double)valueForPart:(NSString *)part {
    return [self.delegate valueForPart:part];
}

#pragma mark - Custom Keyed Subscripting

- (Live2DPartValue *)objectForKeyedSubscript:(NSString *)part {
    Live2DPartValue *parameterValue = [Live2DPart cacheForPartValue:part];
    if (!parameterValue) {
        parameterValue = [[Live2DPartValue alloc] initWithPart:part];
        parameterValue.delegate = self;
    }
    return parameterValue;
}

@end
