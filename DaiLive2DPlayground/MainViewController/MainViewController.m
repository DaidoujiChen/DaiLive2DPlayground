//
//  MainViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/16.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "MainViewController.h"
#import "DaiLive2DViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) DaiLive2DViewController *live2DViewController;

@end

@implementation MainViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 建置 live2d model 畫面
    self.live2DViewController = [[DaiLive2DViewController alloc] initFromBundlePath:@"/Haru/model.plist"];
    CGRect newFrame = self.view.bounds;
    newFrame.origin.y += 150;
    self.live2DViewController.view.frame = newFrame;
    [self.view addSubview:self.live2DViewController.view];
}

@end
