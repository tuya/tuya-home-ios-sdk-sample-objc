//
//  EnumTableViewCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceStatusBehaveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnumTableViewCell : DeviceStatusBehaveCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) NSMutableArray *optionArray;
@property (strong, nonatomic) NSString *currentOption;
@property (strong, nonatomic) void(^selectAction)(NSString *option);
@end

NS_ASSUME_NONNULL_END
