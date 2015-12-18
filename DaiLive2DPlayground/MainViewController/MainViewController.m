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
@property (nonatomic, assign) CGFloat previousScale;

@end

@implementation MainViewController

#pragma mark - Private Instance Method

- (void)setupLive2DModel {
    
    // 建置 live2d model 畫面
    self.live2DViewController = [DaiLive2DViewController new];
    self.live2DViewController.view.frame = self.view.bounds;;
    [self.view addSubview:self.live2DViewController.view];
}

- (void)setupGestures {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPitch:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark * Gestures

- (void)onPitch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.previousScale = 1.0f;
        return;
    }
    
    CGFloat scale = 1.0f - (self.previousScale - pinchGestureRecognizer.scale);
    if (scale > 1.0) {
        self.live2DViewController.scale += 10;
    }
    else if (scale < 1.0) {
        self.live2DViewController.scale -= 10;
    }
    self.previousScale = pinchGestureRecognizer.scale;
}

#pragma mark - Touch Events

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self.view];
    CGPoint previousLocation = [touch previousLocationInView:self.view];
    
    CGPoint newPosition = self.live2DViewController.position;
    float deltaX = location.x - previousLocation.x;
    float deltaY = location.y - previousLocation.y;
    newPosition.x -= deltaX * 5;
    newPosition.y -= deltaY * 5;
    self.live2DViewController.position = newPosition;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLive2DModel];
    [self setupGestures];
}

@end
