//
//  TuyaLockDeviceBaseViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockDevice.h>
#import <ThingSmartLockKit/ThingSmartZigbeeLockDevice.h>
#import <ThingSmartLockKit/ThingSmartLockDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceBaseViewController : UIViewController

@property (nonatomic, copy) NSString *devId;
@property (strong, nonatomic) NSArray *memberList;
@property (strong, nonatomic) ThingSmartBLELockDevice *bleDevice;
@property (strong, nonatomic) ThingSmartZigbeeLockDevice *zigbeeDevice;
@property (strong, nonatomic) ThingSmartLockDevice *wifiDevice;

- (BOOL)isBLEDevice;
- (BOOL)isZigbeeDevice;
- (BOOL)isWiFiDevice;

- (NSString *)getDpIdWithDpCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
