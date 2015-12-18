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
@property (nonatomic, strong) NSDictionary *InfoRoot;

@end

@implementation Live2DInfoLoader

#pragma mark - Readonly Propertys

- (NSString *)model {
    return [self.basePath stringByAppendingPathComponent:self.InfoRoot[@"ModelName"]];
}

- (NSArray<NSString *> *)textures {
    NSMutableArray *textures = [NSMutableArray array];
    for (NSString *texture in self.InfoRoot[@"ModelTextures"]) {
        [textures addObject:[self.basePath stringByAppendingPathComponent:texture]];
    }
    return textures;
}

- (NSArray<NSString *> *)parameters {
    NSDictionary *modelParam = self.InfoRoot[@"ModelParam"];
    return modelParam.allKeys;
}

- (Live2DParameter *)parameter {
    return [[Live2DParameter alloc] initWithInfo:self.InfoRoot[@"ModelParam"]];
}

#pragma mark - Private Instance Method

- (NSString *)bundlePath {
    return [NSBundle mainBundle].bundlePath;
}

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
        self.InfoRoot = [self dictionaryFromPlistBundlePath:path];
        if (!self.InfoRoot) {
            return nil;
        }
    }
    return self;
}

@end
