//
//  Live2DParameter.h
//  DaiLive2DPlayground
//
//  Created by 啟倫 陳 on 2015/12/18.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Live2DParameterValue : NSObject

@property (nonatomic, readonly) double max;
@property (nonatomic, readonly) double min;

@end

@interface Live2DParameter : NSObject

- (id)initWithInfo:(NSDictionary *)info;
- (Live2DParameterValue *)objectForKeyedSubscript:(NSString *)key;

@end
