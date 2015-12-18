//
//  DaiLive2DViewController.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/17.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Live2DInfoLoader.h"

@interface DaiLive2DViewController : GLKViewController

@property (nonatomic, readonly) Live2DInfoLoader *loader;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint position;

- (id)initFromBundlePath:(NSString *)path;

@end
