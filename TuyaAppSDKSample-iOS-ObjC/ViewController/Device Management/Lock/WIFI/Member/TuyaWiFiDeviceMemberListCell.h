//
//  TuyaWiFiDeviceMemberListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "ThingSmartLockMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaWiFiDeviceMemberListCellDelegate <NSObject>

- (void)deleteMemberWithUserId:(ThingSmartLockMemberModel *)model;

- (void)updateMemberWithModel:(ThingSmartLockMemberModel *)model;

@end

@interface TuyaWiFiDeviceMemberListCell : UITableViewCell

@property (nonatomic, weak) id<TuyaWiFiDeviceMemberListCellDelegate> delegate;

- (void)reloadData:(ThingSmartLockMemberModel *)model;

@end

NS_ASSUME_NONNULL_END
