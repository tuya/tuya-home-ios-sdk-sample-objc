//
//  TuyaLockDeviceFingerListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockOpmodeModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceUnlockModeListCell : UITableViewCell

- (void)reloadData:(ThingSmartBLELockOpmodeModel *)data;

@end

NS_ASSUME_NONNULL_END
