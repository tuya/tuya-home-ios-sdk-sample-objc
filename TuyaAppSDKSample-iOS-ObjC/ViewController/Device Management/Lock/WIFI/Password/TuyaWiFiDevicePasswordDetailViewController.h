//
//  TuyaWiFiDevicePasswordDetailViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"
#import "TuyaLockDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaWiFiDevicePasswordDetailViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, strong) NSDictionary *pwdDic;//单条密码信息

@end

NS_ASSUME_NONNULL_END
