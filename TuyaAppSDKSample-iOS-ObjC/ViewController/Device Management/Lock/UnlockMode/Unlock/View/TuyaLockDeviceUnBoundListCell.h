//
//  TuyaLockDeviceUnBoundListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnBoundListCell : UITableViewCell

- (void)reloadData:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
