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
@property (nonatomic, strong) NSDictionary *ModelInfo;

@end

@implementation Live2DInfoLoader

#pragma mark - Live2DParameterDelegate

// 回傳該 parameter 的預設最大最小值資訊
- (NSDictionary *)infoForParameter:(NSString *)parameter {
    return self.ModelInfo[@"ModelParam"][parameter];
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
    return [self.basePath stringByAppendingPathComponent:self.ModelInfo[@"ModelName"]];
}

// model 的 材質
- (NSArray<NSString *> *)textures {
    NSMutableArray *textures = [NSMutableArray array];
    for (NSString *texture in self.ModelInfo[@"ModelTextures"]) {
        [textures addObject:[self.basePath stringByAppendingPathComponent:texture]];
    }
    return textures;
}

// model 所包含的可控變數
- (NSArray<NSString *> *)parameters {
    NSDictionary *modelParam = self.ModelInfo[@"ModelParam"];
    return [modelParam.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

// 操作該變數
- (Live2DParameter *)parameter {
    Live2DParameter *parameter = [Live2DParameter new];
    parameter.delegate = self;
    return parameter;
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
        self.ModelInfo = [self dictionaryFromPlistBundlePath:path];
        if (!self.ModelInfo) {
            return nil;
        }
    }
    return self;
}

@end
