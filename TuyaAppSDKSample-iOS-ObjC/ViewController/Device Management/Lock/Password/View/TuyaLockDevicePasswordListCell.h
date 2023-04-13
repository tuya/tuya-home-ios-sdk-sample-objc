//
//  TuyaLockDevicePasswordListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDevicePasswordListCellDelegate <NSObject>

- (void)passwordListCellModifyAction;
- (void)passwordListCellDeleteAction;

@end

@interface TuyaLockDevicePasswordListCell : UITableViewCell

@property (nonatomic, weak) id<TuyaLockDevicePasswordListCellDelegate> cellDelegate;

@end

NS_ASSUME_NONNULL_END
