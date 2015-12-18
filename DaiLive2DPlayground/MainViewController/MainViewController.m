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

@property (weak, nonatomic) IBOutlet UIView *floatingView;
@property (weak, nonatomic) IBOutlet UITextField *parameterTextField;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;

@property (nonatomic, strong) DaiLive2DViewController *live2DViewController;
@property (nonatomic, assign) CGFloat previousScale;

@end

@implementation MainViewController

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.live2DViewController.loader.parameters.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.live2DViewController.loader.parameters[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
    self.parameterTextField.text = selectedString;
    self.valueSlider.enabled = YES;
    self.valueSlider.minimumValue = self.live2DViewController.loader.parameter[selectedString].min * 100;
    self.valueSlider.maximumValue = self.live2DViewController.loader.parameter[selectedString].max * 100;
    self.valueSlider.value = [self.live2DViewController valueForParameter:selectedString] * 100;
}

#pragma mark - IBAction

- (IBAction)onParameterValueChange:(UISlider *)slider {
    [self.live2DViewController setValue:slider.value / 100 forParameter:self.parameterTextField.text];
}

#pragma mark - Private Instance Method

- (void)setupInitValues {
    self.valueSlider.enabled = NO;
}

- (void)setupParameterTextField {
    UIPickerView *parameterPicker = [UIPickerView new];
    parameterPicker.dataSource = self;
    parameterPicker.delegate = self;
    self.parameterTextField.inputView = parameterPicker;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.items = @[flexibleSpace, doneButton];
    [toolBar sizeToFit];
    self.parameterTextField.inputAccessoryView  = toolBar;
}

- (void)doneAction {
    UIPickerView *pickerView = (UIPickerView *)self.parameterTextField.inputView;
    NSString *finalSelectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
    self.parameterTextField.text = finalSelectedString;
    [self.parameterTextField resignFirstResponder];
    
    self.valueSlider.enabled = YES;
    self.valueSlider.minimumValue = self.live2DViewController.loader.parameter[finalSelectedString].min * 100;
    self.valueSlider.maximumValue = self.live2DViewController.loader.parameter[finalSelectedString].max * 100;
    self.valueSlider.value = [self.live2DViewController valueForParameter:finalSelectedString] * 100;
}

- (void)setupLive2DModel {
    
    // 建置 live2d model 畫面
    self.live2DViewController = [[DaiLive2DViewController alloc] initFromBundlePath:@"/Haru/model.plist"];
    self.live2DViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.live2DViewController.view];
    [self.view bringSubviewToFront:self.floatingView];
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
    float deltaX = location.x - previousLocation.x;
    float deltaY = location.y - previousLocation.y;
    
    CGPoint newPosition = self.live2DViewController.position;
    newPosition.x -= deltaX * 5;
    newPosition.y -= deltaY * 5;
    self.live2DViewController.position = newPosition;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupInitValues];
    [self setupParameterTextField];
    [self setupLive2DModel];
    [self setupGestures];
}

@end
