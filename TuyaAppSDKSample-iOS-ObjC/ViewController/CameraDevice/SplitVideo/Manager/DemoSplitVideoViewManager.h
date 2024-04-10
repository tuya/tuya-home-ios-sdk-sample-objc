//
//  DemoSplitVideoViewManager.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import "CameraDevice.h"
#import "CameraSplitVideoContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoViewManager : NSObject

- (instancetype)initWithCameraDevice:(CameraDevice *)cameraDevice;

@property (nonatomic, assign, readonly) BOOL isSupportedVideoSplitting;

- (CameraSplitVideoContainerView *)splitVideoView;

@end

NS_ASSUME_NONNULL_END
