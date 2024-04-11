//
//  DemoSplitVideoInfo.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartCameraM/ThingSmartCameraM.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoInfo : thing_ipc_split_video_info

- (instancetype)initWithVideo_info:(thing_ipc_split_video_info *)video_info isLocalizer:(BOOL)isLocalizer isFirstIndex:(BOOL)isFirstIndex;

@property (nonatomic, assign, readonly) BOOL isLocalizer;

@property (nonatomic, assign, readonly) BOOL isFirstIndex;

@end

NS_ASSUME_NONNULL_END
