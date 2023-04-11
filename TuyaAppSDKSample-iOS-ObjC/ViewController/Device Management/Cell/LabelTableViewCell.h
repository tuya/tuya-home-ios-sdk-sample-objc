//
//  LabelTableViewCell.h
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "DeviceStatusBehaveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LabelTableViewCell : DeviceStatusBehaveCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

NS_ASSUME_NONNULL_END
