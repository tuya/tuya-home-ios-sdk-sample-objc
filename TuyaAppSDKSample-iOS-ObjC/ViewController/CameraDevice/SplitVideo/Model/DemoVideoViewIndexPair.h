//
//  DemoVideoViewIndexPair.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <ThingSmartCameraBase/ThingSmartCameraBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoVideoViewIndexPair : NSObject <ThingSmartVideoViewIndexPair>

- (instancetype)initWithVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex;

@end

NS_ASSUME_NONNULL_END
