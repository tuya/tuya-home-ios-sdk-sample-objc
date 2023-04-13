//
//  TuyaLockDeviceFingerGuideViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

// 0:指纹 1：密码 2：卡片
@interface TuyaLockDeviceUnlockModeGuideViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, assign) int unlockModeType;
@property (nonatomic, assign) int userType;
@property (nonatomic, assign) int lockUserId;
@property (nonatomic, strong) NSString *memberId;

@end

NS_ASSUME_NONNULL_END
