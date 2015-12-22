//
//  Live2DParameter.h
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Live2DParameterValue.h"

@protocol Live2DParameterDelegate;

// 中間介層, 方便直接由 key 直存取變數
@interface Live2DParameter : NSObject <Live2DParameterValueDelegate>

@property (nonatomic, weak) id <Live2DParameterDelegate> delegate;

+ (Live2DParameter *)shard;

- (Live2DParameterValue *)objectForKeyedSubscript:(NSString *)parameter;

@end

@protocol Live2DParameterDelegate <NSObject>

- (NSDictionary *)infoForParameter:(NSString *)parameter;
- (void)setValue:(double)value forParameter:(NSString *)parameter;
- (double)valueForParameter:(NSString *)parameter;

@end
