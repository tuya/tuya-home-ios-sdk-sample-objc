//
//  TuyaLockDevicePasswordListViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockDevice.h>
#import "TuyaLockDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDevicePasswordListViewController : UIViewController

@property (strong, nonatomic) ThingSmartBLELockDevice *bleDevice;
@property (nonatomic, assign) PasswordType passwordType;

@end

NS_ASSUME_NONNULL_END
