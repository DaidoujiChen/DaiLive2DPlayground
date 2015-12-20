//
//  Live2DParameterValue.h
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/20.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Live2DParameterValueDelegate;

@interface Live2DParameterValue : NSObject

@property (nonatomic, weak) id <Live2DParameterValueDelegate> delegate;
@property (nonatomic, readonly) NSString *parameter;
@property (nonatomic, readonly) double max;
@property (nonatomic, readonly) double min;
@property (nonatomic, assign) double value;

- (id)initWithParameter:(NSString *)parameter andMax:(double)max andMin:(double)min;

@end

@protocol Live2DParameterValueDelegate <NSObject>

- (void)setValue:(double)value forParameter:(NSString *)parameter;
- (double)valueForParameter:(NSString *)parameter;

@end
