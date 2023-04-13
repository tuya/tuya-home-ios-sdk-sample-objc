//
//  SwitchTableViewCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceStatusBehaveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SwitchTableViewCell : DeviceStatusBehaveCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (strong, nonatomic) void(^switchAction)(UISwitch *switchButton);
@end

NS_ASSUME_NONNULL_END
