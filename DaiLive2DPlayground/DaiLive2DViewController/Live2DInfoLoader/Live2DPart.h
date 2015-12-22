//
//  Live2DPart.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/21.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Live2DPartValue.h"

@protocol Live2DPartDelegate;

@interface Live2DPart : NSObject <Live2DPartValueDelegate>

@property (nonatomic, weak) id <Live2DPartDelegate> delegate;

+ (Live2DPart *)shard;

- (Live2DPartValue *)objectForKeyedSubscript:(NSString *)part;

@end

@protocol Live2DPartDelegate <NSObject>

- (void)setValue:(double)value forPart:(NSString *)part;
- (double)valueForPart:(NSString *)part;

@end
