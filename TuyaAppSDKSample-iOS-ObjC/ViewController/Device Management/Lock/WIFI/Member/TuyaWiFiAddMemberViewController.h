//
//  TuyaWiFiAddMemberViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"
#import "ThingSmartLockMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaWiFiAddMemberViewController : TuyaLockDeviceBaseViewController

@property (nonatomic, assign) BOOL isEdit;//是否编辑
@property (nonatomic, strong) ThingSmartLockMemberModel *dataSource;

@end

NS_ASSUME_NONNULL_END
