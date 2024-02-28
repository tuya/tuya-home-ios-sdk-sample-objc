//
//  TuyaLockDeviceUnlockModeModifyViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModeModifyViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, strong) ThingSmartBLELockOpmodeModel *model;
@property (nonatomic, strong) NSString *memberId;

@property (nonatomic, strong) ThingSmartZigbeeLockOpmodeModel *zigbeeModel;

@end

NS_ASSUME_NONNULL_END
