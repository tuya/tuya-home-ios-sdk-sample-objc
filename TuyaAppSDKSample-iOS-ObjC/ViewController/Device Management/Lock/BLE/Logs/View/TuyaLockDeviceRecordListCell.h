//
//  TuyaLockDeviceRecordListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceRecordListCell : UITableViewCell

- (void)reloadData:(NSString *)title time:(NSTimeInterval)time logType:(NSString *)logType;

@end

NS_ASSUME_NONNULL_END
