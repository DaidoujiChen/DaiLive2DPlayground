//
//  MainViewController.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/16.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomTypeHaru,
    CustomTypeWanko,
    CustomTypeMiku
} CustomType;

@interface CustomViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) CustomType type;

@end
