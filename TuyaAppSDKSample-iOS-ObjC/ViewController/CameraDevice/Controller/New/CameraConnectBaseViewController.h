//
//  CameraConnectBaseViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import "CameraDevice.h"
#import "CameraVideoView.h"

#import "CameraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraConnectBaseViewController : CameraBaseViewController

- (instancetype)initWithDeviceId:(NSString *)devId;

@property (nonatomic, copy, readonly) NSString *devId;

@property (nonatomic, strong, readonly) CameraDevice *cameraDevice;

@property (nonatomic, strong, readonly) CameraVideoView *videoView;

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification;

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification;

- (void)disconnect;


@end

NS_ASSUME_NONNULL_END
