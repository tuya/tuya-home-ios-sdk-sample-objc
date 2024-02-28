//
//  TuyaLockDeviceAddMemberView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceAddMemberViewDelegate <NSObject>

- (void)addMemberAction:(ThingSmartHomeAddMemberRequestModel *)model;
- (void)updateMemberAction:(ThingSmartHomeMemberRequestModel *)model;
- (void)selectRoleType;
- (void)warningAlert;

@end

@interface TuyaLockDeviceAddMemberView : UIView

@property (nonatomic, assign) BOOL isEdit;//是否编辑
@property (nonatomic, weak) id<TuyaLockDeviceAddMemberViewDelegate> delegate;

- (void)reloadRoleType:(NSString *)role;

- (void)reloadData:(NSDictionary *)model;

@end

@interface TuyaLockDeviceAddMemberItemView : UIView

@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *contentTextField;

@end

@interface TuyaLockDeviceAddMemberRoleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *roleLabel;

@end



NS_ASSUME_NONNULL_END
