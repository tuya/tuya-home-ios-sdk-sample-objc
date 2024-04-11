//
//  DemoSplitVideoViewGenerater.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <ThingSmartCameraBase/ThingSmartCameraBase.h>

#import "DemoSplitVideoNodeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoViewGenerater : NSObject

- (instancetype)initWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig videoViewContext:(id<DemoSplitVideoViewContext>)videoViewContext;

- (nullable NSArray<DemoSplitVideoNodeView *> *)allViews;

#pragma mark - Portrait
- (nullable NSArray<DemoSplitVideoNodeView *> *)topViews;
- (nullable NSArray<DemoSplitVideoNodeView *> *)bottomViews;

#pragma mark - Landscape
- (nullable NSArray<DemoSplitVideoNodeView *> *)bigViews;
- (nullable NSArray<DemoSplitVideoNodeView *> *)smallViews;

@end

NS_ASSUME_NONNULL_END
