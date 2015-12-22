//
//  Live2DInfoLoader.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "Live2DInfoLoader.h"

@interface Live2DInfoLoader ()

@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, readonly) NSString *bundlePath;
@property (nonatomic, strong) NSDictionary *modelInfo;

@end

@implementation Live2DInfoLoader

#pragma mark - Live2DPartDelegate

// 改變 part 值
- (void)setValue:(double)value forPart:(NSString *)part {
    [self.delegate setValue:value forPart:part];
}

// 取得當前 part 值
- (double)valueForPart:(NSString *)part {
    return [self.delegate valueForPart:part];
}

#pragma mark - Live2DParameterDelegate

// 回傳該 parameter 的預設最大最小值資訊
- (NSDictionary *)infoForParameter:(NSString *)parameter {
    return self.modelInfo[@"ModelParam"][parameter];
}

// 改變 parameter 值
- (void)setValue:(double)value forParameter:(NSString *)parameter {
    [self.delegate setValue:value forParameter:parameter];
}

// 取得當前 parameter 值
- (double)valueForParameter:(NSString *)parameter {
    return [self.delegate valueForParameter:parameter];
}

#pragma mark - Readonly Propertys

// model 名稱
- (NSString *)model {
    return [self.basePath stringByAppendingPathComponent:self.modelInfo[@"ModelName"]];
}

// model 的 材質
- (NSArray<NSString *> *)textures {
    NSMutableArray *textures = [NSMutableArray array];
    for (NSString *texture in self.modelInfo[@"ModelTextures"]) {
        [textures addObject:[self.basePath stringByAppendingPathComponent:texture]];
    }
    return textures;
}

// model 所包含的可控變數
- (NSArray<NSString *> *)parameters {
    NSDictionary *modelParam = self.modelInfo[@"ModelParam"];
    return [modelParam.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

// 操作該變數
- (Live2DParameter *)parameter {
    Live2DParameter *parameter = [Live2DParameter shard];
    if (!parameter.delegate) {
        parameter.delegate = self;
    }
    return parameter;
}

// model 所包含的可顯示部位
- (NSArray<NSString *> *)parts {
    NSArray *modelPart = self.modelInfo[@"ModelPart"];
    return [modelPart sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

// 操作該部位
- (Live2DPart *)part {
    Live2DPart *part = [Live2DPart shard];
    if (!part.delegate) {
        part.delegate = self;
    }
    return part;
}

#pragma mark - Private Instance Method

// 取得 bundle 資料夾路徑
- (NSString *)bundlePath {
    return [NSBundle mainBundle].bundlePath;
}

// 取得 model plist 資料
- (NSDictionary *)dictionaryFromPlistBundlePath:(NSString *)path {
    NSString *filePath = [self.bundlePath stringByAppendingPathComponent:path];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

#pragma mark - Life Cycle

- (id)initFromBundlePath:(NSString *)path {
    self = [super init];
    if (self) {
        NSString *lastPathComponent = path.lastPathComponent;
        self.basePath = [self.bundlePath stringByAppendingString:[path stringByReplacingOccurrencesOfString:lastPathComponent withString:@""]];
        self.modelInfo = [self dictionaryFromPlistBundlePath:path];
        if (!self.modelInfo) {
            NSAssert(0, @"Load Plist Fail");
            return nil;
        }
    }
    return self;
}

@end
