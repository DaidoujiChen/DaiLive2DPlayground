//
//  Live2DPartValue.h
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/21.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Live2DPartValueDelegate;

@interface Live2DPartValue : NSObject

@property (nonatomic, weak) id <Live2DPartValueDelegate> delegate;
@property (nonatomic, readonly) NSString *part;
@property (nonatomic, assign) double value;

- (id)initWithPart:(NSString *)part;

@end

@protocol Live2DPartValueDelegate <NSObject>

- (void)setValue:(double)value forPart:(NSString *)part;
- (double)valueForPart:(NSString *)part;

@end