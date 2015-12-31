//
//  OfficalViewController.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/31.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    OfficalTypeHaru,
    OfficalTypeHaru01,
    OfficalTypeHaru02,
    OfficalTypeWanko,
    OfficalTypeShizuku
} OfficalType;

@interface OfficalViewController : UIViewController

@property (nonatomic, assign) OfficalType type;

@end
