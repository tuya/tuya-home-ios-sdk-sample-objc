//
//  TuyaLockDeviceAddMemberViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceAddMemberViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, assign) BOOL isEdit;//是否编辑
@property (nonatomic, strong) NSDictionary *dataSource;

@end

NS_ASSUME_NONNULL_END
