//
//  DemoSplitVideoInfoProcesser.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <ThingSmartCameraBase/ThingSmartCameraBase.h>

#import "DemoSplitVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoInfoProcesser : NSObject

+ (NSArray<NSArray<DemoSplitVideoInfo *>*> *)processVideoSplitInfoWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig;

@end

NS_ASSUME_NONNULL_END
