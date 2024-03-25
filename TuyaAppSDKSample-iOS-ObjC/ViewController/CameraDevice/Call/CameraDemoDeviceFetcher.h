//
//  CameraDemoDeviceFetcher.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartDeviceModel;
typedef void(^CameraDemoFetchDeviceCompletion)(ThingSmartDeviceModel * _Nullable deviceModel,  NSError * _Nullable error);

@interface CameraDemoDeviceFetcher : NSObject

+ (void)fetchDeviceWithDevId:(NSString *)devId completion:(nullable CameraDemoFetchDeviceCompletion)completion;

@end

NS_ASSUME_NONNULL_END
