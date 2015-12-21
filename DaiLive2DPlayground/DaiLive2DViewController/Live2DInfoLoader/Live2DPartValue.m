//
//  Live2DPartValue.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/21.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DPartValue.h"

@interface Live2DPartValue ()

@property (nonatomic, strong) NSString *part;

@end

@implementation Live2DPartValue

#pragma mark - Value Change

// 改變 part 值
- (void)setValue:(double)value {
    [self.delegate setValue:value forPart:self.part];
}

// 取得當前 part 值
- (double)value {
    return [self.delegate valueForPart:self.part];
}

#pragma mark - Life Cycle

- (id)initWithPart:(NSString *)part {
    self = [super init];
    if (self) {
        self.part = part;
    }
    return self;
}

@end
