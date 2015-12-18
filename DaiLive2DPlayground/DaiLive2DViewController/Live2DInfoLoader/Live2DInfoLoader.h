//
//  Live2DInfoLoader.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Live2DParameter.h"

@interface Live2DInfoLoader : NSObject

@property (nonatomic, readonly) NSString *model;
@property (nonatomic, readonly) NSArray<NSString *> *textures;
@property (nonatomic, readonly) NSArray<NSString *> *parameters;
@property (nonatomic, readonly) Live2DParameter *parameter;

- (id)initFromBundlePath:(NSString *)path;

@end
