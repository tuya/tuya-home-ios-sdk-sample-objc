//
//  TuyaLockDeviceInputView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockScheduleModel.h>

NS_ASSUME_NONNULL_BEGIN

#define weekSelectWidth 50

//输入密码、密码名称view
@interface TuyaLockDeviceInputView : UIView

@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong) UITextField *contentTextField;

- (void)reloadTitle:(NSString *)title;

@end

//星期选择view
@interface TuyaLockDeviceWeekSelectView : UIView

- (NSString *)getScheduleModelWorkingDay:(BOOL)isZigbee;

- (void)reloadData:(NSString *)workingDay isZigbee:(BOOL)isZigbee;

- (void)btnReload:(int)value btn:(UIButton *)btn;

@end

NS_ASSUME_NONNULL_END
