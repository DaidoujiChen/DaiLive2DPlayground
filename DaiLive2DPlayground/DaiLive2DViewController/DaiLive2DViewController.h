//
//  DaiLive2DViewController.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/17.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Live2DInfoLoader.h"

@interface DaiLive2DViewController : GLKViewController <Live2DInfoLoaderDelegate>

@property (nonatomic, readonly) Live2DInfoLoader *loader;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint position;

- (id)initFromBundlePath:(NSString *)path;

// Method Need To Override
- (void)defaultModelSetting:(Live2DInfoLoader *)loader;
- (void)animateModelSetting:(Live2DInfoLoader *)loader onTime:(UInt64)time;

@end
