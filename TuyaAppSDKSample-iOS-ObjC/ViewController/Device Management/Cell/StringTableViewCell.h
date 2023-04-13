//
//  StringTableViewCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceStatusBehaveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface StringTableViewCell : DeviceStatusBehaveCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) void(^buttonAction)(NSString *text);
@end

NS_ASSUME_NONNULL_END
