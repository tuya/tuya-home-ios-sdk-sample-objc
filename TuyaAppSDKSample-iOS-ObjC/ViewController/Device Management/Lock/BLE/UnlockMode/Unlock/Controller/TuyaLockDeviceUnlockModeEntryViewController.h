//
//  TuyaLockDeviceFingerEntryViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModeEntryViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, assign) int unlockModeType;
@property (nonatomic, assign) int userType;
@property (nonatomic, assign) int lockUserId;

@end

NS_ASSUME_NONNULL_END
