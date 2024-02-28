//
//  TuyaLockDeviceUnlockModePasswordView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockOpmodeModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModePasswordView : UIView

@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UISwitch *swBtn;

- (void)reloadData:(ThingSmartBLELockOpmodeModel *)model;

@end

NS_ASSUME_NONNULL_END
