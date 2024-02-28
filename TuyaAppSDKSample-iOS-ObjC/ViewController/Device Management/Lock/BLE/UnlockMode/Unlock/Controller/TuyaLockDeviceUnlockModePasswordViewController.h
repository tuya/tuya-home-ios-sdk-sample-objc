//
//  TuyaLockDeviceUnlockModePasswordViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModePasswordViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, strong) ThingSmartBLELockOpmodeModel *model;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) NSString *memberId;

@end

NS_ASSUME_NONNULL_END
