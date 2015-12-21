//
//  Live2DInfoLoader.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Live2DParameter.h"
#import "Live2DPart.h"

@protocol Live2DInfoLoaderDelegate;

@interface Live2DInfoLoader : NSObject <Live2DParameterDelegate, Live2DPartDelegate>

@property (nonatomic, weak) id <Live2DInfoLoaderDelegate> delegate;
@property (nonatomic, readonly) NSString *model;
@property (nonatomic, readonly) NSArray<NSString *> *textures;
@property (nonatomic, readonly) NSArray<NSString *> *parameters;
@property (nonatomic, readonly) Live2DParameter *parameter;
@property (nonatomic, readonly) NSArray<NSString *> *parts;
@property (nonatomic, readonly) Live2DPart *part;

- (id)initFromBundlePath:(NSString *)path;

@end

@protocol Live2DInfoLoaderDelegate <NSObject>

- (void)setValue:(double)value forParameter:(NSString *)parameter;
- (double)valueForParameter:(NSString *)parameter;
- (void)setValue:(double)value forPart:(NSString *)part;
- (double)valueForPart:(NSString *)part;

@end
