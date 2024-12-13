//
//  DemoSplitVideoViewSizeCounter.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import "DemoSplitVideoViewSizeCounter.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoViewSizeCounter : NSObject <DemoSplitVideoViewSizeCounter>

- (instancetype)initWithVideoSizeRate:(CGFloat)videoSizeRate padding:(CGFloat)padding;

@end

NS_ASSUME_NONNULL_END
