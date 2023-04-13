//
//  CameraDeviceManager.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import "CameraDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraDeviceManager : NSObject

@property (class, nonatomic, strong, readonly) CameraDeviceManager *sharedManager;

- (CameraDevice *)getCameraDeviceWithDevId:(NSString *)devId;

@end

NS_ASSUME_NONNULL_END
