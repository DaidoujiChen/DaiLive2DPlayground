//
//  Live2DParameter.m
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DParameter.h"

@interface Live2DParameterValue ()

@property (nonatomic, assign) double max;
@property (nonatomic, assign) double min;

@end

@implementation Live2DParameterValue

- (id)initWithMax:(double)max andMin:(double)min {
    self = [super init];
    if (self) {
        self.max = max;
        self.min = min;
    }
    return self;
}

@end

@interface Live2DParameter ()

@property (nonatomic, strong) NSDictionary *parameters;

@end

@implementation Live2DParameter

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.parameters = info;
    }
    return self;
}

- (Live2DParameterValue *)objectForKeyedSubscript:(NSString *)key {
    return [[Live2DParameterValue alloc] initWithMax:[self.parameters[key][@"Max"] doubleValue] andMin:[self.parameters[key][@"Min"] doubleValue]];
}

@end
