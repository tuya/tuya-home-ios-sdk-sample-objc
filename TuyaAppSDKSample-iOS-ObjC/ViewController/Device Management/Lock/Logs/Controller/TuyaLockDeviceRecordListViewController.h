//
//  TuyaLockDeviceRecordListViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "TuyaLockDeviceBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceRecordListViewController : TuyaLockDeviceBaseViewController

//1：告警记录（老公版）  2：开门记录（老公版）  3：带筛选功能的记录（Pro）
@property (nonatomic, assign) int logType;

@end

NS_ASSUME_NONNULL_END
