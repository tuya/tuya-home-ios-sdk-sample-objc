//
//  TuyaLockDeviceMemberUpdateTimeView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockScheduleModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceMemberUpdateTimeItemViewDelegate <NSObject>

- (void)selectBtnClicked:(UIButton *)btn;
- (void)swBtnClicked:(UISwitch *)sw;

@end

@protocol TuyaLockDeviceMemberUpdateTimeViewDelegate <NSObject>

- (void)saveMemberTimeInfo;

@end

@interface TuyaLockDeviceMemberUpdateTimeView : UIView<TuyaLockDeviceMemberUpdateTimeItemViewDelegate>

@property (nonatomic, weak)   id<TuyaLockDeviceMemberUpdateTimeViewDelegate> delegate;

- (void)reloadData:(NSDictionary *)data;

- (NSDate *)getEffectiveData;
- (NSDate *)getInvalidData;
- (ThingSmartBLELockTimeScheduleInfo *)getScheduleInfo;

@end

@interface TuyaLockDeviceMemberUpdateTimeItemView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISwitch *swBtn;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, weak)   id<TuyaLockDeviceMemberUpdateTimeItemViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
