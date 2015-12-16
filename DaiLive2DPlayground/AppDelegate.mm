//
//  AppDelegate.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/16.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Live2D.h"

using namespace live2d;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Live2D::init();
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
