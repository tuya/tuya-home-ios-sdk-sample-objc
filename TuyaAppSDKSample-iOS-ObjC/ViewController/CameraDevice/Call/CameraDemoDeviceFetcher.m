//
//  CameraDemoDeviceFetcher.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDemoDeviceFetcher.h"

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>
#import <ThingSmartCallChannelKit/ThingSmartCallChannelKit.h>

@implementation CameraDemoDeviceFetcher

+ (void)fetchDeviceWithDevId:(NSString *)devId completion:(CameraDemoFetchDeviceCompletion)completion {
    if (!devId) {
        !completion ?: completion(nil,[NSError thingcall_errorWithErrorCode:ThingSmartCallErrorInvalidParams errorMsg:@"devId is null" extra:@{@"innerCode" : @-1}]);
        return;
    }
    ThingSmartDeviceModel *deviceModel = [[ThingCoreCacheService sharedInstance] getDeviceInfoWithDevId:devId];
    if (deviceModel) {
        !completion ?: completion(deviceModel, nil);
        return;
    }
    [ThingSmartDevice syncDeviceInfoWithDevId:devId success:^(ThingSmartDeviceModel * _Nonnull deviceModel) {
        if (deviceModel) {
            [[ThingCoreCacheService sharedInstance] addDeviceModel:deviceModel];
            !completion ?: completion(deviceModel, nil);
        } else{
            !completion ?: completion(nil,[NSError thingcall_errorWithErrorCode:ThingSmartCallErrorInvalidResponse errorMsg:@"sync device info failed" extra:@{@"innerCode" : @-1}]);
        }

    } failure:^(NSError *error) {
        !completion ?: completion(nil,[NSError thingcall_errorWithErrorCode:ThingSmartCallErrorRequestFailed errorMsg:error.localizedDescription extra:@{@"innerCode" : @-1}]);
    }];
}


@end
