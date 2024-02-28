//
//  TuyaLockDeviceUnlockModeModifyView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockOpmodeModel.h>
#import <ThingSmartLockKit/ThingSmartZigbeeLockOpmodeModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModeModifyView : UIView

@property (nonatomic, strong) UISwitch *swBtn;
@property (nonatomic, strong) UITextField *nameTextField;

- (void)reloadData:(ThingSmartBLELockOpmodeModel *)model;

- (void)reloadZigbeeData:(ThingSmartZigbeeLockOpmodeModel *)model;

@end

NS_ASSUME_NONNULL_END
