//
//  MainViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/16.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "MainViewController.h"
#import "HaruViewController.h"
#import "WankoromochiViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *floatingView;
@property (weak, nonatomic) IBOutlet UITextField *parameterTextField;
@property (weak, nonatomic) IBOutlet UITextField *partTextField;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UISwitch *partSwitch;
@property (weak, nonatomic) IBOutlet UIView *movingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *floatingViewToTop;

@property (nonatomic, weak) UIPickerView *parameterPicker;
@property (nonatomic, weak) UIPickerView *partPicker;
@property (nonatomic, strong) DaiLive2DViewController *live2DViewController;
@property (nonatomic, assign) CGFloat previousScale;
@property (nonatomic, assign) BOOL isTouchOnMovingView;

@end

@implementation MainViewController

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.parameterPicker) {
        return self.live2DViewController.loader.parameters.count;
    }
    else {
        return self.live2DViewController.loader.parts.count;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.parameterPicker) {
        return self.live2DViewController.loader.parameters[row];
    }
    else {
        return self.live2DViewController.loader.parts[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.parameterPicker) {
        NSString *selectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
        self.parameterTextField.text = selectedString;
        [self enableSliderForParameter:selectedString];
    }
    else {
        NSString *selectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
        self.partTextField.text = selectedString;
        [self enableSwitchForPart:selectedString];
    }
}

#pragma mark - IBAction

- (IBAction)onParameterValueChange:(UISlider *)slider {
    self.live2DViewController.loader.parameter[self.parameterTextField.text].value = slider.value / 100;
}

- (IBAction)onPartValueChange:(UISwitch *)aSwitch {
    self.live2DViewController.loader.part[self.partTextField.text].value = aSwitch.on;
}

#pragma mark - Private Instance Method

#pragma mark * init

- (void)setupInitValues {
    self.valueSlider.enabled = NO;
    self.partSwitch.enabled = NO;
}

- (void)setupParameterTextField {
    UIPickerView *parameterPicker = [UIPickerView new];
    parameterPicker.dataSource = self;
    parameterPicker.delegate = self;
    self.parameterTextField.inputView = parameterPicker;
    self.parameterPicker = parameterPicker;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *parameterDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(parameterDoneAction)];
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.items = @[flexibleSpace, parameterDoneButton];
    [toolBar sizeToFit];
    self.parameterTextField.inputAccessoryView = toolBar;
}

- (void)setupPartTextField {
    UIPickerView *partPicker = [UIPickerView new];
    partPicker.dataSource = self;
    partPicker.delegate = self;
    self.partTextField.inputView = partPicker;
    self.partPicker = partPicker;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *partDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(partDoneAction)];
    UIToolbar *toolBar = [UIToolbar new];
    toolBar.items = @[flexibleSpace, partDoneButton];
    [toolBar sizeToFit];
    self.partTextField.inputAccessoryView = toolBar;
}

- (void)setupLive2DModel {
    
    // 建置 live2d model 畫面
    self.live2DViewController = [HaruViewController new];
    self.live2DViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.live2DViewController.view];
    [self.view bringSubviewToFront:self.floatingView];
}

- (void)setupGestures {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPitch:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

#pragma mark * Button Action

- (void)parameterDoneAction {
    UIPickerView *pickerView = (UIPickerView *)self.parameterTextField.inputView;
    NSString *finalSelectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
    self.parameterTextField.text = finalSelectedString;
    [self.parameterTextField resignFirstResponder];
    [self enableSliderForParameter:finalSelectedString];
}

- (void)partDoneAction {
    UIPickerView *pickerView = (UIPickerView *)self.partTextField.inputView;
    NSString *finalSelectedString = [pickerView.delegate pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0];
    self.partTextField.text = finalSelectedString;
    [self.partTextField resignFirstResponder];
    [self enableSwitchForPart:finalSelectedString];
}

#pragma mark * misc

- (void)enableSliderForParameter:(NSString *)parameter {
    self.valueSlider.enabled = YES;
    self.valueSlider.minimumValue = self.live2DViewController.loader.parameter[parameter].min * 100;
    self.valueSlider.maximumValue = self.live2DViewController.loader.parameter[parameter].max * 100;
    self.valueSlider.value = self.live2DViewController.loader.parameter[parameter].value * 100;
}

- (void)enableSwitchForPart:(NSString *)part {
    self.partSwitch.enabled = YES;
    self.partSwitch.on = self.live2DViewController.loader.part[part].value;
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (touch.view == self.movingView) {
        self.isTouchOnMovingView = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self.view];
    CGPoint previousLocation = [touch previousLocationInView:self.view];
    float deltaX = location.x - previousLocation.x;
    float deltaY = location.y - previousLocation.y;
    
    if (self.isTouchOnMovingView) {
        self.floatingViewToTop.constant += deltaY;
        [self.floatingView layoutIfNeeded];
    }
    else {
        CGPoint newPosition = self.live2DViewController.position;
        newPosition.x -= deltaX * 5;
        newPosition.y -= deltaY * 5;
        self.live2DViewController.position = newPosition;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchOnMovingView = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchOnMovingView = NO;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupInitValues];
    [self setupLive2DModel];
    [self setupParameterTextField];
    [self setupPartTextField];
    [self setupGestures];
}

@end
