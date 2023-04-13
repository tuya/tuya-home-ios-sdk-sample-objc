//
//  TuyaLockDeviceMemberListCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceMemberListCellDelegate <NSObject>

- (void)deleteMemberWithUserId:(NSDictionary *)model;

- (void)updateMemberWithModel:(NSDictionary *)model;

@end

@interface TuyaLockDeviceMemberListCell : UITableViewCell

@property (nonatomic, weak) id<TuyaLockDeviceMemberListCellDelegate> delegate;

- (void)reloadData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
