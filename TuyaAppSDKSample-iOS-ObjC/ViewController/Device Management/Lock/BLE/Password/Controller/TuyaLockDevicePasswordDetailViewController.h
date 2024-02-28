//
//  TuyaLockDevicePasswordDetailViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "TuyaLockDevicePasswordListViewController.h"
#import "TuyaLockDeviceBaseViewController.h"
#import "TuyaLockDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDevicePasswordDetailViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, assign) PasswordActionType actionType;
@property (nonatomic, assign) PasswordType pwdType;

@property (nonatomic, strong) NSDictionary *pwdDic;//单条密码信息

@end

NS_ASSUME_NONNULL_END
