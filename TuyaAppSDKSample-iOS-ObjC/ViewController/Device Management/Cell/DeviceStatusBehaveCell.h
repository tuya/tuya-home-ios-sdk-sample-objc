//
//  DeviceStatusBehaveCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceStatusBehaveCell : UITableViewCell
@property (strong, nonatomic) NSMutableArray *controls;
- (void)deviceOffline;
- (void)deviceOnline;
@end

NS_ASSUME_NONNULL_END
